/**
 * Various functions needed to run the page
 */

var dataStorage;
var timesMonitoring = [];
var timesTheoretical = [];

function printStatus(message) {
	var statusArea = document.getElementById("status-area");
	statusArea.value += new Date().toLocaleTimeString() + " " + message	+ "\n";
	statusArea.scrollTop = statusArea.scrollHeight;
}

var billetData;
function ncSelection(){
	var ncCombobox = document.getElementById("ncs");
	var ncId = ncCombobox.options[ncCombobox.selectedIndex].value;

	var xhr = new XMLHttpRequest();
	xhr.open('GET', 'sm?action=billetretrieve&ncId=' + ncId);
	xhr.onload = function() {
		if (xhr.status === 200) {
			billetData = JSON.parse(xhr.responseText);
			printStatus("loading... ");
			initialiseSimulation(billetData);
			printStatus("NC file loaded successfully");
		} else {
			printStatus('Request failed: ' + xhr.status);
		}
	};
	xhr.send();
}

function connect(){
	connectToDataSource();
	startSimulation();
	generateGraph();
	document.getElementById("connect-button").innerHTML = "Disconnect";
	document.getElementById("connect-button").setAttribute("onclick", "disconnect()");
}

function disconnect(){
	disconnectFromDataSource();
	stopSimulation();
	document.getElementById("connect-button").innerHTML = "Connect";
	document.getElementById("connect-button").setAttribute("onclick", "connect()");
}

function populateData(data){
	document.getElementById("xg-coord").innerHTML = data.X.toFixed(3);
	document.getElementById("yg-coord").innerHTML = data.Y.toFixed(3);
	document.getElementById("zg-coord").innerHTML = data.Z.toFixed(3);
	document.getElementById("xl-coord").innerHTML = (data.X - billetData.xBilletMin).toFixed(3);
	document.getElementById("yl-coord").innerHTML = (data.Y - billetData.yBilletMin).toFixed(3);
	document.getElementById("zl-coord").innerHTML = (data.Z - billetData.zBilletMin).toFixed(3);
	
	document.getElementById("mon-time").innerHTML = formatTime(data.t);
	
	timesMonitoring.push(data.monTime);
	timesTheoretical.push(data.thTime);
}

function populateSseData(sseData){
	// For compatibility with current version keep the next two lines
	populateData(sseData);
	document.getElementById("data-store-element").sseData = sseData;
	//TODO
	
	
}

function downloadObjectAsJson(exportObj, exportName){
    var dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(exportObj));
    var downloadAnchorNode = document.createElement('a');
    downloadAnchorNode.setAttribute("href",     dataStr);
    downloadAnchorNode.setAttribute("download", exportName + ".json");
    document.body.appendChild(downloadAnchorNode); // required for firefox
    downloadAnchorNode.click();
    downloadAnchorNode.remove();
  }

function formatTime(timeDiff){
	var hours = Math.trunc(timeDiff/3600);
	var minutes = Math.trunc((timeDiff-hours*3600)/60);
	var seconds = Math.trunc(timeDiff - hours*3600 - minutes*60);
	var sign = "";
	if (hours < 0 || minutes < 0 || seconds < 0){
		sign = "-";
	} else {
		sign = "+";
	}
	return (sign + Math.abs(hours) + " : " + Math.abs(minutes) + " : " + Math.abs(seconds));
}