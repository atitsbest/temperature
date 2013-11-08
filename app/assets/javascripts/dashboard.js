//= require underscore
//= require highcharts
(function() {

  var colors= [
   ['#A6C776', '#A0C170', '#fff'],
   ['#82578F', '#765189', '#fff'], 
   ['#D98C80', '#D38674', '#fff'], 
   ['#D8B380', '#D2AD7A', '#fff'],
   ['#56748B', '#527078', '#fff']
  ];

  function generate_options(colors) {
    return {
      chart: {
          type: 'spline',
          height: 200,
          backgroundColor: colors[0],
          borderColor: colors[2]
      },
      colors: [
        colors[2]
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
          tickColor: colors[1],
          lineColor: colors[1]
      },
      yAxis: {
          title: {
              text: ''
          },
          labels: {
            style: { color: 'rgba(0,0,0, .2)' }
          },
          min: 9,
          gridLineColor: colors[1],
          gridLineDashStyle: 'ShortDash',
          lineColor: colors[1]
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
      },
      credits: {
        enabled: false    
      }
    };
  }


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

            var current_colors = colors[i%colors.length];
          
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
              generate_options(current_colors),
              { series: [serie] });

            // Chart in der DOM platzieren.
            $(panel)
              .highcharts(options);

            // TODO: Hintegrundfarbe setzten besser machen!
            $(panel)
              .parent().parent().css('background', current_colors[0]);


          }


        });

      }).
      fail(function(error) {
        alert(error);
      });
  });

})();
