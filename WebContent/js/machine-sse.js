/**
 * Server Sent Events implementation
 */

var eventSource = null;
var timesMonitoring = [];
var timesTheoretical = [];

function connectToDataSource(){
	printStatus("Establishing connection...");
	var nccombobox = document.getElementById("ncs");
	var ncId = nccombobox.options[nccombobox.selectedIndex].value;			
	eventSource = new EventSource("sm?action=monitoring&ncId=" + ncId);
	
	eventSource.onopen = function(){
		printStatus("Connected");
	}
	
	eventSource.onmessage = function(message){
		//Store data on DOM element so it is available to other functions
		var sseData = JSON.parse(message.data);
		document.getElementById("data-store-element").sseData = sseData;

		populateData(sseData);

		timesMonitoring.push(sseData.monTime);
		timesTheoretical.push(sseData.thTime);

	}
	
	eventSource.onerror = function(){
		printStatus("Error");
		stop();
	}
}

function disconnectFromDataSource(){
	eventSource.close();
	printStatus("Disconnected");
}

