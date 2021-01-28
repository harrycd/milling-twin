/**
 * Generates graphs comparing simulation with monitoring data
 */

function generateGraph(){

	Highcharts.chart('graphs-wrapper', {

		chart: {
			zoomType: 'x'
		},

		title: {
			text: 'Process time comparison'
		},

		subtitle: {
			text: 'Expected vs Real'
		},

		yAxis: {
			title: {
				text: 'Process time (sec)'
			}
		},
		legend: {
			layout: 'vertical',
			align: 'right',
			verticalAlign: 'middle'
		},

		tooltip: {
			valueDecimals: 2
		},

//		xAxis: {
//		type: 'datetime'
//		},

		series: [
			{
				data: timesMonitoring,
				lineWidth: 0.5,
				name: 'Machine'
			},
			{
				data: timesTheoretical,
				lineWidth: 0.5,
				name: 'Simulator'
			}
			]
	});
}