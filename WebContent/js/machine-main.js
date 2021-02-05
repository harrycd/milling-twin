/**
 * Various functions needed to run the page
 */

var dataStorage = {};
var otherStorage = {};

function ncSelection(){
	var ncCombobox = document.getElementById("ncs");
	var ncId = ncCombobox.options[ncCombobox.selectedIndex].value;

	var xhr = new XMLHttpRequest();
	xhr.open('GET', 'sm?action=billetretrieve&ncId=' + ncId);
	xhr.onload = function() {
		if (xhr.status === 200) {
			otherStorage.billetData = JSON.parse(xhr.responseText);
			printStatus("loading... ");
			initialiseSimulation(otherStorage.billetData);
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
	otherStorage.sampleCounter = 0;
	document.getElementById("connect-button").innerHTML = "Disconnect";
	document.getElementById("connect-button").setAttribute("onclick", "disconnect()");
}

function disconnect(){
	disconnectFromDataSource();
	stopSimulation();
	document.getElementById("connect-button").innerHTML = "Connect";
	document.getElementById("connect-button").setAttribute("onclick", "connect()");
}

function populateSseData(sseData){
	// For compatibility with previous version keep the next line
	otherStorage.newSampleReceived = true;
	
	// Store data to local arrays
	updateKeys(dataStorage, sseData);
	
	// Check if new parameters have been received (check every 50 samples)
	if ((otherStorage.sampleCounter % 50) == 0){
		updateParametersList(dataStorage.machine, dataStorage.simulator);
	}
	
	// Update the table showing parameter values
	updateParamTable(dataStorage.machine, dataStorage.simulator, otherStorage.sampleCounter);
	
	otherStorage.sampleCounter++;
}

function updateParamTable(machineData, simulatorData, index){// TODO now it receives arrays so it has to get the last element of the array!!
	const x_machine = machineData.X[index] - otherStorage.billetData.xBilletMin;
	const x_simulator = simulatorData.X[index] - otherStorage.billetData.xBilletMin;
	document.getElementById("x-local-coord-machine").innerHTML = x_machine.toFixed(3);
	document.getElementById("x-local-coord-simulator").innerHTML = x_simulator.toFixed(3);
	document.getElementById("x-local-coord-diff").innerHTML = (x_machine - x_simulator).toFixed(3);

	const y_machine = machineData.Y[index] - otherStorage.billetData.yBilletMin;
	const y_simulator = simulatorData.Y[index] - otherStorage.billetData.yBilletMin;
	document.getElementById("y-local-coord-machine").innerHTML = y_machine.toFixed(3);
	document.getElementById("y-local-coord-simulator").innerHTML = y_simulator.toFixed(3);
	document.getElementById("y-local-coord-diff").innerHTML = (y_machine - y_simulator).toFixed(3);
	
	const z_machine = machineData.Z[index] - otherStorage.billetData.zBilletMin;
	const z_simulator = simulatorData.Z[index] - otherStorage.billetData.zBilletMin;
	document.getElementById("z-local-coord-machine").innerHTML = z_machine.toFixed(3);
	document.getElementById("z-local-coord-simulator").innerHTML = z_simulator.toFixed(3);
	document.getElementById("z-local-coord-diff").innerHTML = (z_machine - z_simulator).toFixed(3);
	
	updateRowValues(machineData, simulatorData, index)
	
	document.getElementById("mon-time").innerHTML = formatTime(machineData.t[index]);
}

function updateRowValues(machineData, simulatorData, index){
	for (param of otherStorage.commonParams){
		document.getElementById(param + "-param-machine").innerHTML = machineData[param][index].toFixed(3);
		document.getElementById(param + "-param-simulator").innerHTML = simulatorData[param][index].toFixed(3);
		document.getElementById(param + "-param-diff").innerHTML = (machineData[param][index] - simulatorData[param][index]).toFixed(3);
	}
}

function updateParametersList(machineData, simulatorData){
	const machineParams = Object.keys(machineData);
	const simulatorParams = Object.keys(simulatorData);
	//TODO change to union
	otherStorage.commonParams = machineParams.filter(value => simulatorParams.includes(value));
	
	let select = document.getElementById("available-graph-parameters");
	if (select.length < otherStorage.commonParams.length + 1) { //Run only if params change. Note 1 param is displayed twice (thus the +1)
		const selected = select.options[select.selectedIndex].text;
		const paramTable = document.getElementById("table-params");
		
		
		// Remove previous parameters
		select.length = 0;
		
		// Add first the selected and the everything available
		select.add(new Option(selected));
		for (const commonParam of otherStorage.commonParams){
			select.add(new Option(commonParam));
			
			const row = paramTable.insertRow();
			row.setAttribute("style","text-align:right");
			
			row.insertCell().innerHTML = commonParam;
			row.insertCell().setAttribute("id", (commonParam + "-param-machine") );
			row.insertCell().setAttribute("id", (commonParam + "-param-simulator") );
			row.insertCell().setAttribute("id", (commonParam + "-param-diff") );
		}
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