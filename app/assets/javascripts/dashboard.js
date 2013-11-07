//= require d3.v3

(function() {
  var parse = d3.time.format.utc("%Y-%m-%dT%H:%M:%S.%LZ").parse;

  /**
   * Chart erstellen und platzieren.
   *
   * @param element Hier soll der Chart erstellt werden.
   */
  function placeChart(element, data) {
    var sensor = $(element).data('sensor');

    if (sensor === undefined) return;

    var margin = {top: 0, right: 0, bottom: 20, left: 0},
        width = parseInt(d3.select(element).style('width'), 10) - margin.left - margin.right,
        height = 100 - margin.top - margin.bottom;

    // Scales and axes. Note the inverted domain for the y-scale: bigger is up!
    var x = d3.time.scale().range([0, width]),
        y = d3.scale.linear().range([height, 0]),
        xAxis = d3.svg.axis().scale(x).tickSize(-height).tickSubdivide(true),
        yAxis = d3.svg.axis().scale(y).ticks(4).orient("right");

    // An area generator, for the light fill.
    var area = d3.svg.area()
        .interpolate("monotone")
        .x(function(d) { return x(d.created_at); })
        .y0(height)
        .y1(function(d) { return y(d.value); });

    // A line generator, for the dark stroke.
    var line = d3.svg.line()
        .interpolate("monotone")
        .x(function(d) { return x(d.created_at); })
        .y(function(d) { return y(d.value); });


    // Filter to one sensor;
    var values = data.filter(function(d) {
      return d.sensor == sensor;
    });

    // Compute the minimum and maximum date, and the maximum value.
    x.domain([values[0].created_at, values[values.length - 1].created_at]);
    y.domain([0, d3.max(values, function(d) { return d.value; })]).nice();

    // Add an SVG element with the desired dimensions and margin.
    var svg = d3.select(element).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
        .on("click", click);

    // Add the clip path.
    svg.append("clipPath")
        .attr("id", "clip")
      .append("rect")
        .attr("width", width)
        .attr("height", height);

    // Add the area path.
    svg.append("path")
        .attr("class", "area")
        .attr("clip-path", "url(#clip)")
        .attr("d", area(values));

    // Add the x-axis.
    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    // Add the y-axis.
    svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + width + ",0)")
        .call(yAxis);

    // Add the line path.
    svg.append("path")
        .attr("class", "line")
        .attr("clip-path", "url(#clip)")
        .attr("d", line(values));

    // Add a small label for the sensor name.
    svg.append("text")
        .attr("x", width - 6)
        .attr("y", height - 6)
        .style("text-anchor", "end")
        .text(values[0].sensor);

    // On click, update the x-axis.
    function click() {
      var n = values.length - 1,
          i = Math.floor(Math.random() * n / 2),
          j = i + Math.floor(Math.random() * n / 2) + 1;
      x.domain([values[i].created_at, values[j].created_at]);
      var t = svg.transition().duration(750);
      t.select(".x.axis").call(xAxis);
      t.select(".area").attr("d", area(values));
      t.select(".line").attr("d", line(values));
    }
  }

  $(function() {
    d3.json("/api/measurements.json", function(error, data) {
      if (!error) {
        $(data).each(function(i, d) {
          d.created_at = parse(d.created_at);
          d.value = +d.value;
        });
        $(".panel-body").each(function(i, panel) {
          placeChart(panel, data);
        });
      }
      else alert(error);
    });
  });

})();
