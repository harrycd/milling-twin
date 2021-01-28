/**
 * Various functions needed to run the page
 */

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
	document.getElementById("xg-coord").innerHTML = data.xCoord.toFixed(3);
	document.getElementById("yg-coord").innerHTML = data.yCoord.toFixed(3);
	document.getElementById("zg-coord").innerHTML = data.zCoord.toFixed(3);
	document.getElementById("xl-coord").innerHTML = (data.xCoord - billetData.xBilletMin).toFixed(3);
	document.getElementById("yl-coord").innerHTML = (data.yCoord - billetData.yBilletMin).toFixed(3);
	document.getElementById("zl-coord").innerHTML = (data.zCoord - billetData.zBilletMin).toFixed(3);
	
	document.getElementById("mon-time").innerHTML = formatTime(data.monTime);

}

function graphs() {
	generateGraph();
	MicroModal.show('graphs-modal');
}

function process() {
	MicroModal.show('process-modal');
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