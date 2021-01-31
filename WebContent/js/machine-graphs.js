/**
 * Generates graphs comparing simulation with monitoring data
 */
var chartData; //store in this element the data to show in the graph (see reference for data format)

function addPoint(seriesIndex, value){
	chart.series[seriesIndex].addPoint([value]);
}

function generateRandomData(pointCount){
	var data = [];
	var i = 0;
	for (i = 0; i <= pointCount; i += 1) {
		data.push([Math.random()*10]);
	}
	
	return data;
}

function generateGraph(){
	Highcharts.chart('graphs-wrapper', {
	    chart: {
	        type: 'line',
	        events: {
	            load: function () {

	                // set up the updating of the chart each second
	                var series = this.series[0];
	                setInterval(function () {
	                	if(chartData != undefined){
//		                    series.addPoint([Math.random()*10], true, true, false);
	                		series.setData(chartData, true, false, true);
	                	}
	                }, 1000);
	            }
	        }
	    },

	    time: {
	        useUTC: false
	    },

	    title: {
	        text: 'Live random data'
	    },

	    xAxis: {
	        type: 'datetime',
	        tickPixelInterval: 150
	    },

	    yAxis: {
	        title: {
	            text: 'Value'
	        },
	        plotLines: [{
	            value: 0,
	            width: 1,
	            color: '#808080'
	        }]
	    },

	    tooltip: {
	        headerFormat: '<b>{series.name}</b><br/>',
	        pointFormat: '{point.x:%Y-%m-%d %H:%M:%S}<br/>{point.y:.2f}'
	    },

	    legend: {
	        enabled: false
	    },

	    exporting: {
	        enabled: false
	    },

	    series: [{
	        name: 'Random data',
	        data: [0]
	    }]
	});
}