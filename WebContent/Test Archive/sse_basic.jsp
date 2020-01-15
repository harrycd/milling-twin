<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>SSE Test</title>
</head>
<body>
	<button id="startButton" onclick="start()">Start</button>
	<button id="stopButton" onclick="stop()">Stop</button>
	<button id="clearButton" onclick="clear()">Clear</button>
	<textarea id="statusArea" rows="10" cols="10"></textarea>
	<textarea id="dataArea" rows="10" cols="10"></textarea>
	
	<script type="text/javascript">
		var eventSource = null;
// 		var status = document.getElementById("dataArea");
// 		var data = document.getElementById("dataArea");
		
		function start(){
			//eventSource = new EventSource("http://localhost:8080/MillingTwin/TwinMain");
			eventSource = new EventSource("sm?action=monitoring&ncId=1");
			eventSource.onopen = function(){
				statusArea.value = "Connected";
				dataArea.value = "ready";
			}
			eventSource.onmessage = function(message){
				dataArea.value = message.data;
			}
			eventSource.onerror = function(){
				statusArea.value = "Error";
			}
			startButton.disabled = true;
		}
		
		function stop(){
			eventSource.close();
			startButton.disabled = false;
		}
		
		function clear(){
			dataArea.value = "";
			statusArea.value = "Cleared";
		}
	</script>
</body>
</html>