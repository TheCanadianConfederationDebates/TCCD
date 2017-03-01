
      var progressChart = c3.generate({
      bindto: '#progressChart',
      data: {
      x: 'x',
      columns: [
      ['x','2017-02-23', '2017-01-25', '2017-02-01', '2017-01-18', '2017-01-30', '2017-01-19', '2017-02-16', '2017-01-10', '2017-01-17', '2017-02-08', '2017-02-21', '2017-02-22', '2017-02-27'],
      ['Original scanned pages', 7648, 7648, 7648, 7648, 7648, 7648, 7648, 7648, 7239, 7648, 7648, 7648, 7648],
      ['Edited HOCR pages', 2697, 2197, 2389, 2110, 2282, 2110, 2697, 1787, 1873, 2608, 2697, 2697, 2697],
      ['Pages in TEI', 1154, 900, 900, 852, 900, 852, 1026, 810, 852, 963, 1120, 1120, 1154],
      ['Pages in TEI with names tagged', 828, 641, 641, 622, 641, 622, 828, 605, 622, 710, 828, 828, 828]
        ],
      axes: {
        data1: 'y',
        data1: 'y2'
      }
      
      },
      axis: {
        x: {
          type: 'timeseries',
          tick: {
          fit: true,
          culling: false,
          rotate: 90,
          format: '%Y-%m-%d'
        }
      },
      y: {
        label: {
          text: 'Pages',
          position: 'outer-middle'
        },
        tick:{
          outer: false,
          min: 0,
          max: 10000,
          format: d3.format('d')
        }
      },
      y2: {
        show: true,
        tick:{
          format: d3.format('.0%')
        }
      }
    },
    padding: {
    right: 100,
    left: 75
    }
    });
      