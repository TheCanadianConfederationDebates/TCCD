
      var progressChart = c3.generate({
      bindto: '#progressChart',
      data: {
      x: 'x',
      columns: [
      ['x','2017-06-09', '2017-06-26', '2017-08-21', '2017-03-30', '2017-04-05', '2017-11-21', '2017-06-30', '2017-03-24', '2017-09-11', '2017-02-23', '2017-01-19', '2017-03-08', '2017-10-13', '2017-07-05', '2017-06-28', '2017-01-17', '2017-04-19', '2017-02-21', '2017-04-04', '2017-02-08', '2017-04-25', '2017-11-20', '2017-04-07', '2017-10-23', '2017-02-22', '2017-12-12', '2017-06-21', '2017-01-10', '2017-03-22', '2017-02-16', '2017-11-07', '2017-03-21', '2017-03-14', '2017-10-30', '2017-08-23', '2017-02-01', '2017-03-31', '2017-01-18', '2017-08-15', '2017-03-29', '2017-02-27', '2017-12-08', '2017-11-23', '2017-12-01', '2017-03-27', '2017-04-13', '2017-05-24', '2017-01-30', '2017-08-24', '2017-09-27', '2017-01-25', '2017-08-30', '2017-10-04', '2017-03-03', '2017-12-19'],
      ['Original scanned pages', 7650, 7650, 7961, 7648, 7648, 8930, 7961, 7648, 9353, 7648, 7648, 7648, 9353, 7961, 7650, 7239, 7648, 7648, 7648, 7648, 7648, 8930, 7648, 8930, 7648, 8930, 7650, 7648, 7648, 7648, 8930, 7648, 7648, 8930, 7961, 7648, 7648, 7648, 7961, 7648, 7648, 8930, 8930, 8930, 7648, 7648, 7648, 7648, 8662, 9353, 7648, 9353, 9353, 7648, 8930],
      ['Edited HOCR pages', 2697, 2697, 2781, 2697, 2697, 2780, 2781, 2697, 2781, 2697, 2110, 2697, 2781, 2781, 2697, 1873, 2697, 2697, 2697, 2608, 2697, 2780, 2697, 2780, 2697, 2780, 2697, 1787, 2697, 2697, 2780, 2697, 2697, 2780, 2781, 2389, 2697, 2110, 2781, 2697, 2697, 2780, 2780, 2780, 2697, 2697, 2697, 2282, 2781, 2781, 2197, 2781, 2781, 2697, 2780],
      ['Pages in TEI', 2016, 2224, 2916, 1798, 1798, 4005, 2292, 1798, 2961, 1154, 852, 1341, 3380, 2296, 2271, 852, 1832, 1120, 1798, 963, 1921, 3941, 1798, 3427, 1120, 4164, 2176, 810, 1749, 1026, 3667, 1708, 1531, 3535, 2916, 900, 1798, 852, 2749, 1798, 1154, 4164, 4005, 4119, 1798, 1823, 1946, 900, 2917, 3260, 900, 2917, 3326, 1226, 4236],
      ['Pages in TEI with names tagged', 1921, 2143, 2840, 1644, 1663, 3966, 2211, 1505, 2885, 828, 622, 995, 3324, 2215, 2190, 622, 1697, 828, 1663, 710, 1840, 3902, 1663, 3400, 828, 4125, 2095, 605, 1505, 828, 3628, 1268, 1184, 3508, 2840, 641, 1644, 622, 2673, 1644, 828, 4125, 3966, 4080, 1644, 1688, 1865, 641, 2841, 3184, 641, 2841, 3250, 901, 4196]
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
      