/**
 * Various functions needed to run the page
 */

var dataStorage = {};

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

var sampleCounter = 0;
function populateSseData(sseData){
	// For compatibility with previous version keep the next line
	newSampleReceived = true;
	
	// Store data to local arrays
	updateKeys(dataStorage, sseData);
	
	populateToolPositionTable(dataStorage.machine, sampleCounter);
	
	if ((++sampleCounter % 50) == 0){ // check every 100 samples
		updateAvailableGraphParametersList(dataStorage.machine, dataStorage.simulator);
	}
	
}

function populateToolPositionTable(data, index){// TODO now it receives arrays so it has to get the last element of the array!!
	document.getElementById("xg-coord").innerHTML = data.X[index].toFixed(3);
	document.getElementById("yg-coord").innerHTML = data.Y[index].toFixed(3);
	document.getElementById("zg-coord").innerHTML = data.Z[index].toFixed(3);
	document.getElementById("xl-coord").innerHTML = (data.X[index] - billetData.xBilletMin).toFixed(3);
	document.getElementById("yl-coord").innerHTML = (data.Y[index] - billetData.yBilletMin).toFixed(3);
	document.getElementById("zl-coord").innerHTML = (data.Z[index] - billetData.zBilletMin).toFixed(3);
	
	document.getElementById("mon-time").innerHTML = formatTime(data.t[index]);
}

function updateAvailableGraphParametersList(machineData, simulatorData){
	const machineParams = Object.keys(machineData);
	const simulatorParams = Object.keys(simulatorData);
	const commonParams = machineParams.filter(value => simulatorParams.includes(value));
	
	let select = document.getElementById("available-graph-parameters");
	const selected = select.options[select.selectedIndex].text;

	// Remove previous parameters
	select.length = 0;
	
	// Add first the selected and the everything available
	select.add(new Option(selected));
	for (const commonParam of commonParams){
		select.add(new Option(commonParam));
	}
	
}

/**
 * Generates the structure of supplied data and appends the data to objTree arrays.
 * 
 * @param objTree - object to append data
 * @param data - data to append
 * 
 */
function updateKeys(objTree, data){
	const keys = Object.keys(data);
	for (const key of keys){
		objTree[key] = objTree[key] || {};
		if (typeof(data[key]) == "number"){ 	// This is the end of the branch so value should be pushed to the array
			if ((Object.keys(objTree[key]).length === 0 && objTree[key].constructor === Object)){ // Check if it is an empty object {}
				objTree[key] = []; 				// Turn it to the array that stores values
			}
			objTree[key].push(data[key])		// Add the value to the array
		
		} else {								// It is not the end of the branch
			updateKeys(objTree[key], data[key]);// Continue to children
		}
	}
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

function printStatus(message) {
	var statusArea = document.getElementById("status-area");
	statusArea.value += new Date().toLocaleTimeString() + " " + message	+ "\n";
	statusArea.scrollTop = statusArea.scrollHeight;
}

function formatTime(timeDiff){
	var hours = Math.trunc(timeDiff/3600);
	var minutes = Math.trunc((timeDiff-hours*3600)/60);
	var seconds = Math.trunc(timeDiff - hours*3600 - minutes*60);
	var sign = "";
	if (hours < 0 || minutes < 0 || seconds < 0){
		sign = "-";
	} else {
		sign = "";
	}
	return (sign + Math.abs(hours) + " : " + Math.abs(minutes) + " : " + Math.abs(seconds));
}