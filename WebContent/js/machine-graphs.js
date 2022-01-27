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
	// Initialise graph parameters
	chartData.ma = 1;
	
	// Build chart
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
	                		
	                		dataMachine = dataMachine.slice(-chartData.dataPointCount);
	                		dataSimulator = dataSimulator.slice(-chartData.dataPointCount);
	                		
	                		if (chartData.ma > 1){
	                			dataMachine = calculateMA(dataMachine, chartData.ma);
	                			dataSimulator = calculateMA(dataSimulator, chartData.ma);
	                		}
	                		
	                		series[0].setData(dataMachine, true, false, true);
	                		series[1].setData(dataSimulator, true, false, true);
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
	        pointFormat: '{point.x:%H:%M:%S}<br/>{point.y:.2f}'
	    },

	    legend: {
	        enabled: true
	    },

	    exporting: {
	        enabled: true
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

function calculateMA(data, ma){
	const ma_minus_1 = ma-1;
	const dataLength = data.length;
	let maData = [];
	 
	for (let i = ma_minus_1; i < data.length; i++){
		let maValue = 0;
		for (let j = i-ma_minus_1; j < i; j++){
			maValue += data[j][1];
		}
		maData.push([data[i][0], maValue/ma]);
	}
	
	return maData;
}

function setMA(ma){
	chartData.ma = ma;
}