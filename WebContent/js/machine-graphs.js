/**
 * Generates graphs comparing simulation with monitoring data
 */
var chart;
var chartData = {}; //store in this element the data to show in the graph (see reference for data format)

function addPoint(seriesIndex, value){
	chart.series[seriesIndex].addPoint([value]);
}

function setChartData(dataX, dataY){
	chartData.dataX = dataX;
	chartData.dataY = dataY;
	chartData.dataPointCount = 1000;
}

function setChartTitle(title){
	chart.title.text = title;
}

function changeGraphParameter(paramName){
	var dataY = dataStorage.machine[paramName];
	var dataX = dataStorage.machine["t"];

	setChartData(dataX, dataY);
	setChartTitle(paramName);
}

function generateGraph(){
	chart = Highcharts.chart('graphs-wrapper', {
	    chart: {
	        type: 'line',
	        events: {
	            load: function () {

	                // set up the updating of the chart each second
	                var series = this.series[0];
	                setInterval(function () {
	                	if(chartData.dataY != undefined){
	                		let dataXY = combineArrays(chartData.dataX, chartData.dataY);
	                		series.setData(dataXY.slice(-chartData.dataPointCount), true, false, true);
	                	}
	                }, 1000);
	            }
	        }
	    },

	    title: {
	        text: 'Machine data'
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
	        name: 'Machine data',
	        data: [0]
	    }]
	});
}

function combineArrays(dataX, dataY){
	let dataXY = dataX.map(function(x,i){
		return [x * 1000, dataY[i]];
	});
	return dataXY;
}