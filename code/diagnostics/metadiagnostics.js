
      var progressChart = c3.generate({
      bindto: '#progressChart',
      data: {
      x: 'x',
      columns: [
      ['x','2016-11-25', '2016-11-28', '2016-11-24', '2016-11-15', '2016-11-29'],
      ['Original scanned pages', 7618, 7618, 7618, 6096, 7618],
      ['Edited HOCR pages', 1614, 1631, 1614, 1615, 1631],
      ['Pages in TEI', 437, 437, 429, 335, 437],
      ['Pages in TEI with names tagged', 20, 20, 20, 15, 20]
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
      