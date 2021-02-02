/**
 * Server Sent Events implementation
 */

var eventSource = null;

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
		populateSseData(sseData);
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

