<!DOCTYPE html>
<%@page import="uk.ac.cf.milling.utils.BilletUtils"%>
<%@page import="uk.ac.cf.milling.objects.Billet"%>
<%@page import="uk.ac.cf.milling.objects.Nc"%>
<%@page import="uk.ac.cf.milling.utils.NcUtils"%>
<%@page import="java.util.List"%>
<html>
<head>
<meta charset="UTF-8">
<title>Milling Twin</title>

<style type="text/css">
.page-wrapper {
	style ="width: 100%;
	display: table;
}

.header-wrapper {
	padding: 10px;
	display: table-row;
}

.main-wrapper {
	border-style: solid;
	display: table-cell;
	width: 50%;
	display: table-row;
}

.footer-wrapper {
	
}

</style>

<link href="css/micromodal.css" rel="stylesheet">

</head>
<body>
	<div class="page-wrapper">
		<div class="header-wrapper">
			<% List<Nc> ncs = NcUtils.getNcs(); %>
			<select id="ncs" onchange="ncSelection()">
				<option value="0">Select NC file...</option>
				<% for (Nc nc : ncs) { %>
				<option value=<%out.print(nc.getNcId());%>><%out.print(nc.toString());%></option>
				<% } %>
			</select>
			
			<input id="x-billet-min" type="hidden" value="">
			<input id="x-billet-max" type="hidden" value="">
			<input id="y-billet-min" type="hidden" value="">
			<input id="y-billet-max" type="hidden" value="">
			<input id="z-billet-min" type="hidden" value="">
			<input id="z-billet-max" type="hidden" value="">
			
			<button id="connect-button" onclick="start()">Connect</button>
			<button id="view-graphs-button" onclick="graphs()">Graphs</button>
			<button id="view-process-button" onclick="process()">Process</button>
		</div>
		<div class="main-wrapper">
			<textarea id="status-area" rows="5" cols="100"></textarea>
			<br>
			<table border="1">
				<tr>
					<th> X </th>
					<th> Y </th>
					<th> Z </th>
					<th> Time Th </th>
					<th> Time Mon </th>
				</tr>
				<tr>
					<td id="x-coord">0.000</td>
					<td id="y-coord">0.000</td>
					<td id="z-coord">0.000</td>
					<td id="th-time">0.000</td>
					<td id="mon-time">0.000</td>
				</tr>
			</table>
			<br>
			Process Time : 
			<span id="diff-time"> 0 : 0 : 0</span>
		</div>
	</div>
	
	
<!-- The modal containing the graphs -->
	<div class="modal micromodal-slide" id="graphs-modal" aria-hidden="true">
		<div class="modal__overlay" tabindex="-1" data-micromodal-close>
			<div class="modal__container" role="dialog" aria-modal="true" aria-labelledby="graphs-modal-title">
				<header class="modal__header">
					<h2 class="modal__title" id="graphs-modal-title">Graphs</h2>
					<button class="modal__close" aria-label="Close modal" data-micromodal-close></button>
				</header>
				<main class="modal__content" id="graphs-modal-content">
					<div id="graphs-wrapper"></div>
				</main>
				<footer class="modal__footer">
					<!-- <button class="modal__btn modal__btn-primary">Continue</button> -->
					<!-- <button class="modal__btn" data-micromodal-close aria-label="Close this dialog window">Close</button> -->
				</footer>
			</div>
		</div>
	</div>
	
<!-- The modal containing the canvas -->
	
	<div class="modal micromodal-slide" id="process-modal" aria-hidden="true">
		<div class="modal__overlay" tabindex="-1" data-micromodal-close>
			<div class="modal__container" role="dialog" aria-modal="true" aria-labelledby="process-modal-title">
				<header class="modal__header">
					<h2 class="modal__title" id="process-modal-title">Live Process</h2>
					<button onclick="wire()">W</button>
					<button class="modal__close" aria-label="Close modal" data-micromodal-close></button>
				</header>
				<main class="modal__content" id="process-modal-content">
					<!-- Here goes the canvas for process representation -->
					<div id="canvas-wrapper"></div>
				</main>
				<footer class="modal__footer">
					<!-- <button class="modal__btn modal__btn-primary">Continue</button> -->
					<!-- <button class="modal__btn" data-micromodal-close aria-label="Close this dialog window">Close</button> -->
				</footer>
			</div>
		</div>
	</div>
	
<!-- Various assistive functions -->
	<script type="text/javascript">
		function printStatus(message) {
			var statusArea = document.getElementById("status-area");
			statusArea.value += new Date().toLocaleTimeString() + " " + message	+ "\n";
			statusArea.scrollTop = statusArea.scrollHeight;
		}
		
		function ncSelection(){
			var ncCombobox = document.getElementById("ncs");
			var ncId = ncCombobox.options[ncCombobox.selectedIndex].value;
			
			var xhr = new XMLHttpRequest();
			xhr.open('GET', 'sm?action=billetretrieve&ncId=' + ncId);
			xhr.onload = function() {
				if (xhr.status === 200) {
					var billetJSON = JSON.parse(xhr.responseText);
					setBilletDims(
							billetJSON.xBilletMin, billetJSON.xBilletMax, 
							billetJSON.yBilletMin, billetJSON.yBilletMax, 
							billetJSON.zBilletMin, billetJSON.zBilletMax);
					generateBillet();
				} else {
					printStatus('Request failed: ' + xhr.status);
				}
			};
			xhr.send();
		}
	</script>


<!-- Graphs display implementation -->

	<script src="js/micromodal.min.js" type="text/javascript"></script>
	<script src="js/highcharts.js" type="text/javascript"></script>
	<script src="js/exporting.js" type="text/javascript"></script>
	<script src="js/offline-exporting.js" type="text/javascript"></script>
	<script>
		function generateGraph(){
			
			Highcharts.chart('graphs-wrapper', {

			    chart: {
			        zoomType: 'x'
			    },

			    title: {
			        text: 'Process time comparison'
			    },

			    subtitle: {
			        text: 'Expected vs Real'
			    },
			    
			    yAxis: {
			        title: {
			            text: 'Process time (sec)'
			        }
			    },
			    legend: {
			        layout: 'vertical',
			        align: 'right',
			        verticalAlign: 'middle'
			    },

			    tooltip: {
			        valueDecimals: 2
			    },

// 			    xAxis: {
// 			        type: 'datetime'
// 			    },

			    series: [
			       {
			        data: timesMonitoring,
			        lineWidth: 0.5,
			        name: 'Machine'
			    	},
			       {
			        data: timesTheoretical,
			        lineWidth: 0.5,
			        name: 'Simulator'
			    	}
			    ]
			});
		}

		function graphs() {
			generateGraph();
			MicroModal.show('graphs-modal');
		}
		
		function process() {
			MicroModal.show('process-modal');
		}
	</script>


<!-- Milling Virtual implementation	 -->
	<script src="js/three.js" type="text/javascript"></script>
	<script src="js/OrbitControls.js"></script>
	<script src="js/milling-virtual.js" type="text/javascript"></script>
	
	
	
<!-- Server Sent Events implementation	 -->
	<script type="text/javascript">
		var eventSource = null;
		var timesMonitoring = [];
		var timesTheoretical = [];
		
		function start(){
			var statusArea = document.getElementById("status-area");
			var nccombobox = document.getElementById("ncs");
			var ncId = nccombobox.options[nccombobox.selectedIndex].value;			
			eventSource = new EventSource("sm?action=monitoring&ncId=" + ncId);
			eventSource.onopen = function(){
				printStatus("Connected");
			}
			eventSource.onmessage = function(message){
				var sseData = JSON.parse(message.data);
				
				if (sseData.toolRadius != undefined){
					generateTool(sseData.toolRadius, sseData.toolHeight, 32);
				}
				document.getElementById("x-coord").innerHTML = sseData.xCoord.toFixed(3);
				document.getElementById("y-coord").innerHTML = sseData.yCoord.toFixed(3);
				document.getElementById("z-coord").innerHTML = sseData.zCoord.toFixed(3);
				document.getElementById("th-time").innerHTML = sseData.thTime.toFixed(1);
				document.getElementById("mon-time").innerHTML = sseData.monTime.toFixed(1);

				document.getElementById("diff-time").innerText = formatTime(sseData.monTime - sseData.thTime);
				
				
				
				timesMonitoring.push(sseData.monTime);
				timesTheoretical.push(sseData.thTime);
				
			}
			eventSource.onerror = function(){
				printStatus("Error");
				stop();
			}
 			document.getElementById("connect-button").innerHTML = "Disconnect";
 			document.getElementById("connect-button").setAttribute("onclick", "stop()");
 			
		}
		
		function stop(){
			eventSource.close();
			document.getElementById("connect-button").innerHTML = "Connect";
 			document.getElementById("connect-button").setAttribute("onclick", "start()");
			printStatus("Disconnected");
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

		
	</script>
</body>
</html>