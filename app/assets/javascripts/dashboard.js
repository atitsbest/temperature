//= require underscore
//= require highcharts
//= require exporting
(function() {

  var chart_options = {
    chart: {
        type: 'spline'
    },
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
        }
    },
    yAxis: {
        title: {
            text: 'Temperatur (°C)'
        },
        min: 0
    },
    tooltip: {
        formatter: function() {
                return '<b>'+ this.series.name +'</b><br/>'+
                Highcharts.dateFormat('%e. %b', this.x) +': '+ this.y +' m';
        }
    }
  };


  $(function() {
    $.when($.getJSON("/api/measurements.json")).
      then(function(data) {

        $(data).each(function(i, d) {
          d.date = new Date(d.date);
          d.value = +d.value / 1000.0;
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
