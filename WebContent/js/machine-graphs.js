/**
 * Generates graphs comparing simulation with monitoring data
 */
var chart;
var chartData = {}; //store in this element the data to show in the graph (see reference for data format)

function addPoint(seriesIndex, value){
	chart.series[seriesIndex].addPoint([value]);
}

function changeGraphParameter(paramName){
	var dataYMachine = dataStorage.machine[paramName];
	var dataYSimulator = dataStorage.simulator[paramName];
	var dataX = dataStorage.machine["t"];
	
	setChartData(dataX, dataYMachine, dataYSimulator);
	setChartTitle(paramName);
}

function setChartData(dataX, dataYMachine, dataYSimulator){
	chartData.dataX = dataX;
	chartData.dataYMachine = dataYMachine;
	chartData.dataYSimulator = dataYSimulator;
	chartData.dataPointCount = 1000;
}

function setChartTitle(title){
	chart.title.text = title;
}

function generateGraph(){
	chart = Highcharts.chart('graphs-wrapper', {
	    chart: {
	        type: 'line',
	        events: {
	            load: function () {

	                // set up the updating of the chart each second
	                var series = this.series;
	                setInterval(function () {
	                	if(chartData.dataYMachine != undefined){
	                		let dataMachine = combineArrays(chartData.dataX, chartData.dataYMachine);
	                		let dataSimulator = combineArrays(chartData.dataX, chartData.dataYSimulator);
	                		series[0].setData(dataMachine.slice(-chartData.dataPointCount), true, false, true);
	                		series[1].setData(dataSimulator.slice(-chartData.dataPointCount), true, false, true);
	                	}
	                }, 1000);
	            }
	        }
	    },

	    title: {
	        text: 'Digital Twin data'
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

	    series: [
	    	{
		        name: 'Machine',
		        data: [0]
	    	},
	    	{
	    		name: 'Simulator',
	    		data: [0]
	    	}
	    ]
	});
}

function combineArrays(dataX, dataY){
	let dataXY = dataX.map(function(x,i){
		return [x * 1000, dataY[i]];
	});
	return dataXY;
}