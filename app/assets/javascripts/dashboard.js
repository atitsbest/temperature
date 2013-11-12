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
              }
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

  function prepare_data(data) 
  {
      $(data).each(function(i, d) {
        d.value = +d.value / 100.0;
      });
  }

  function create_serie_for(data, name)
  {
      var values = _.chain(data).
        where({sensor: name}).
        map(function(v) { return [v.date, v.value]; }).
        value();
    
      return {
        name: name,
        data: values
      };
  }


  $(function() {
    $.when($.getJSON("/api/measurements.json"),
           $.getJSON("/api/measurements/chunked/10.json")).
      then(function(data1, data2) {
        var data = data1[0],
            chunked = data2[0];

        prepare_data(data);
        prepare_data(chunked);

        $(".chart").each(function(i, panel) {

          var sensor = $(panel).data('sensor');
          if (sensor !== undefined) {

            // Farbe für diesen Chart.
            var current_colors = colors[i%colors.length];
          
            // Daten für den einen Sensor filtern.
            var serie = create_serie_for(data, sensor);
            var serie_chunked = create_serie_for(chunked, sensor);

            var options = _.extend(
              generate_options(current_colors),
              { series: [serie_chunked, serie] });

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
