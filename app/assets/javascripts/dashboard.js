//= require underscore
//= require highcharts
//= require jquery.timeago
//= require jquery.timeago.de
//
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
              }
          },
          area: {
            fillColor: 'rgba(255,255,255,.1)'
          }
      },
      tooltip: {
          enabled: true,
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

  function create_serie_for(data, name)
  {
      var values = data[name]
        .map(function(v) { return [v.d*1000, v.v/100.0]; });
    
      return {
        name: name,
        data: values
      };
  }


  $(function() {
    $.when($.getJSON("/api/measurements.json")).
      then(function(data) {
        $(".sensor").each(function(i, panel) {

          var sensor = $(panel).data('sensor');
          if (sensor !== undefined) {
            // Farbe für diesen Chart.
            var current_colors = colors[i%colors.length];
          
            // Daten für den einen Sensor filtern.
            var serie = create_serie_for(data, sensor);

            var options = _.extend(
              generate_options(current_colors),
              { series: [serie] });

            // Chart in der DOM platzieren.
            $(panel).find('.chart')
              .highcharts(options);

            // TODO: Hintegrundfarbe setzten besser machen!
            $(panel).css('background', current_colors[0]);
          }

        });

      }).
      fail(function(error) {
        alert(error);
      });


      // SSE für Temperaturänderungen init.
      var source = new EventSource('/realtime/measurements');
        source.addEventListener('update', function(e) {
        update = JSON.parse(e.data);
        temp = update.data.v / 100.0;
        ago = $.timeago(new Date(update.data.d*1000));
        $sensor = $('[data-sensor="' + update.sensor + '"]');
        $sensor.find('.temperature > span').text(temp);
        $sensor.find('.timeago > .val').text(ago);
      });
      
  });

})();
