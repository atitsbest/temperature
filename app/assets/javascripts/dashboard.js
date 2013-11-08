//= require underscore
//= require highcharts
(function() {

  var chart_options = {
    chart: {
        type: 'spline',
        height: 200,
        backgroundColor: '#A6C776',
        borderColor: '#fff'
    },
    colors: [
      '#fff'
    ],
    title: {
        text: ''
    },
    subtitle: {
        text: ''
    },
    xAxis: {
        type: 'datetime',
        dateTimeLabelFormats: { // don't display the dummy year
            month: '%e. %b',
            year: '%b'
        },
        labels: {
          style: { color: 'rgba(0,0,0, .2)' }
        },
        tickColor: '#A0C170',
        lineColor: '#A0C170'
    },
    yAxis: {
        title: {
            text: ''
        },
        labels: {
          style: { color: 'rgba(0,0,0, .2)' }
        },
        min: 9,
        gridLineColor: '#A0C170',
        gridLineDashStyle: 'ShortDash',
        lineColor: '#CEE3B0'
    },
    legend: {
        enabled: false
    },
    plotOptions: {
        spline: {
            lineWidth: 2,
            marker: {
                enabled: false
            },
            pointInterval: 3600000 // one hour
            // pointStart: Date.UTC(2009, 9, 6, 0, 0, 0)
        }
    },
    tooltip: {
        enabled: false,
        formatter: function() {
                return '<b>'+ this.series.name +'</b><br/>'+
                Highcharts.dateFormat('%e. %b', this.x) +': '+ this.y +' °C';
        }
    }
  };


  $(function() {
    $.when($.getJSON("/api/measurements.json")).
      then(function(data) {

        $(data).each(function(i, d) {
          d.date = new Date(d.date);
          d.value = +d.value / 100.0;
        });
        $(".chart").each(function(i, panel) {

          var sensor = $(panel).data('sensor');
          if (sensor !== undefined) {
          
            // Daten für den einen Sensor filtern.
            var values = _.chain(data).
              where({sensor: sensor}).
              map(function(v) { return [v.date, v.value]; }).
              value();
          
            var serie = {
              name: sensor,
              data: values
            };

            var options = _.extend(
              _.clone(chart_options), 
              { series: [serie] });

            // Chart in der DOM platzieren.
            $(panel).highcharts(options);
          }


        });

      }).
      fail(function(error) {
        alert(error);
      });
  });

})();
