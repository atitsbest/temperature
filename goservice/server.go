package main

import (
  "fmt"
  "log"
  "time"
  "net/http"
  "regexp"
  "html/template"
  "io/ioutil"
  "encoding/json"
  "database/sql"
  _ "github.com/lib/pq"
)

var connectionString =  "user=temperature password=TemperatuRe dbname=temperature_development"

var validPath = regexp.MustCompile("^*$")

var templates = template.Must(template.ParseFiles("views/index.html"))

type JsonMeasurement struct {
  Measurement Measurement
}

type Measurement struct {
  Sensor string
  Value int
}

type RootViewModel struct {
  Sensor string
  Value float32
  CreatedAt string
}

// ------- HELPERS --------

func panicOnError(e error) {
  if e != nil { log.Fatal(e) }
}

func renderTemplate(w http.ResponseWriter, tmpl string, ms []RootViewModel) {
  err := templates.ExecuteTemplate(w, tmpl+".html", ms)
  if err != nil {
    http.Error(w, err.Error(), http.StatusInternalServerError)
  }
}

// ------- HELPERS (END) ---

func rootHandler(resp http.ResponseWriter, req *http.Request) {
  var (
    sensor string
    value int
    created_at time.Time
  )
  // DB öffnen...
  db, err := sql.Open("postgres", connectionString)
  panicOnError(err)
  // ...DB am Ende der Funktion wieder schließen.
  defer db.Close()

  // Letzten Eintrag abfragen.
  rows, err := db.Query(`
    select m1.*
    from measurements m1 
    left outer join measurements m2
    on (m1.sensor = m2.sensor and m1.created_at < m2.created_at)
    where m2.sensor is null`)
  panicOnError(err)

  var ms []RootViewModel

  // Eintrag lesen.
  for rows.Next() {
    err = rows.Scan(&sensor, &value, &created_at)
    panicOnError(err)
    ms = append(ms, RootViewModel{
      Sensor:sensor, 
      Value: float32(value) / 100.0, 
      CreatedAt:created_at.Format("am Mo 2. Jan 2006 um 15:04:05")  })
  }

  renderTemplate(resp, "index", ms)
}

func getMeasurementHandler(resp http.ResponseWriter, req *http.Request) {
  var (
    sensor string
    value int
  )

  // DB öffnen...
  db, err := sql.Open("postgres", connectionString)
  panicOnError(err)
  // ...DB am Ende der Funktion wieder schließen.
  defer db.Close()

  // Letzten Eintrag abfragen.
  rows, err := db.Query("select sensor, value from measurements order by created_at desc limit 1")
  panicOnError(err)

  // Eintrag lesen.
  rows.Next()
  err = rows.Scan(&sensor, &value)
  panicOnError(err)

  // Ergebnis anzeigen.
  fmt.Fprintf(resp, "Sensor: %s => %d", sensor, value)
}

func postMeasurementHandler(resp http.ResponseWriter, req *http.Request) {
  // Json-Payload aus dem Request lesen.
  var mm JsonMeasurement
  body, err := ioutil.ReadAll(req.Body)
  panicOnError(err)
  log.Printf("Body => %s", body)
  err = json.Unmarshal(body, &mm)
  panicOnError(err)

  log.Printf("Payload => %#v", mm)

  // In die DB einfügen.
  db, err := sql.Open("postgres", connectionString)
  panicOnError(err)
  defer db.Close()

  _, err = db.Exec("insert into measurements(sensor, value, created_at) values(($1),($2),($3))",
    mm.Measurement.Sensor,
    mm.Measurement.Value,
    time.Now())
  panicOnError(err)

}

func measurementHandler(resp http.ResponseWriter, req *http.Request) {
  switch req.Method {
    case "GET": getMeasurementHandler(resp, req)
    case "POST": postMeasurementHandler(resp, req)
    default: http.Error(resp, "Unbehandeltes Http-Verb!", http.StatusNotFound)
  }
}

func makeHandler(fn func(http.ResponseWriter, *http.Request)) http.HandlerFunc {
  return func(w http.ResponseWriter, r *http.Request) {
    start := time.Now()

    m := validPath.FindStringSubmatch(r.URL.Path)
    if m == nil {
      http.NotFound(w, r)
      return
    }
    fn(w, r)

    // Dauer berechnen und anzeigen.
    duration := time.Since(start)
    log.Printf("Duration: %s", duration)
  }
}

func main() {
  http.HandleFunc("/", makeHandler(rootHandler))
  http.HandleFunc("/measurements/", makeHandler(measurementHandler))
  log.Fatal(http.ListenAndServe(":9001", nil))
}
