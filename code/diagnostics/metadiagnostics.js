
      var progressChart = c3.generate({
      bindto: '#progressChart',
      data: {
      x: 'x',
      columns: [
      ['x','2016-11-25', '2017-01-18', '2017-01-19', '2016-11-28', '2016-12-13', '2017-01-10', '2016-11-24', '2016-11-15', '2016-11-29', '2017-01-17', '2016-12-11', '2016-12-02', '2016-12-05', '2016-12-19'],
      ['Original scanned pages', 7618, 7648, 7648, 7618, 7648, 7648, 7618, 6096, 7618, 7239, 7648, 7636, 7636, 7648],
      ['Edited HOCR pages', 1614, 2110, 2110, 1631, 1709, 1787, 1614, 1615, 1631, 1873, 1709, 1631, 1709, 1709],
      ['Pages in TEI', 437, 852, 852, 437, 699, 810, 429, 335, 437, 852, 604, 497, 534, 743],
      ['Pages in TEI with names tagged', 20, 622, 622, 20, 50, 605, 20, 15, 20, 622, 50, 32, 32, 50]
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
      