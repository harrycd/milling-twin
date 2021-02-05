<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
<meta charset="UTF-8">
<title>Milling Twin</title>

<link rel="stylesheet" href="css/bootstrap.min.css">
<link rel="shortcut icon" href="image/favicon.ico" />

</head>
<body>
	
	<div class="container">
		<div class="row mt-3">
			<div class="col-sm">
				<select id="ncs" onchange="ncSelection()">
					<option value="0">Select NC file...</option>
					<c:forEach items="${ncs}" var="nc">
						<option value="${nc.ncId}"> ${nc} </option>
					</c:forEach>
				</select>
			</div>
			<div class="col-sm">
				<button id="connect-button" class="pure-button pure-button-active" onclick="connect()">Connect</button>
				<button id="mrr-button" class="pure-button pure-button-disabled" onclick="downloadObjectAsJson({timesMonitoring,mrr}, 'mrr.txt')">MRR</button>
			</div>
			
		</div>
		<div class="row mt-3">
			<div class="col-sm">
				<textarea id="status-area" rows="5" cols="100"></textarea>
			</div>
		</div>
		
		<div class="row mt-3">
			<div id="canvas-wrapper" class="border border-primary" ></div>
		</div>

		<div class="row mt-3">
			<div class="col-sm">
				<table id="table-params" class="table table-bordered table-hover table-sm">
					<thead>
						<tr style="text-align:center">
							<th>Parameter</th>
							<th>Machine</th>
							<th>Simulator</th>
							<th>Difference</th>
						</tr>
					</thead>
					<tbody>
						<tr style="text-align:right">
							<td> X Local </td>
							<td id = "x-local-coord-machine"></td>
							<td id = "x-local-coord-simulator"></td>
							<td id = "x-local-coord-diff"></td>
						</tr>
						<tr style="text-align:right">
							<td> Y Local </td>
							<td id = "y-local-coord-machine"></td>
							<td id = "y-local-coord-simulator"></td>
							<td id = "y-local-coord-diff"></td>
						</tr>
						<tr style="text-align:right">
							<td> Z Local </td>
							<td id = "z-local-coord-machine"></td>
							<td id = "z-local-coord-simulator"></td>
							<td id = "z-local-coord-diff"></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		
		<div class="row mt-3">
			<div class="col-sm">
				<label class="col-form-label">Process Time</label> 
				<span id="mon-time"> 0 : 0 : 0</span>
			</div>
		</div>

		<div class="row mt-3">
			<select id="available-graph-parameters" class="form-select" onchange="changeGraphParameter(this.options[this.selectedIndex].text)">
				<option selected>..Select Parameter</option>
			</select>
			<div id="graphs-wrapper" class="col-sm"></div>
		</div>

	</div>
	
	<script src="js/bootstrap.bundle.min.js" type="text/javascript"></script>
	
<!-- Various assistive functions -->
	<script src="js/machine-main.js" type="text/javascript"></script>



	<script src="js/highcharts.js" type="text/javascript"></script>
	<script src="js/exporting.js" type="text/javascript"></script>
	<script src="js/export-data.js" type="text/javascript"></script>
	<script src="js/offline-exporting.js" type="text/javascript"></script>
	<script src="js/series-label.js" type="text/javascript"></script>
	<script src="js/machine-graphs.js" type="text/javascript"></script>

<!-- Milling Simulation implementation	 -->
	<script src="js/three.js" type="text/javascript"></script>
	<script src="js/OrbitControls.js"></script>
	<script src="js/machine-simulation.js" type="text/javascript"></script>
	
<!-- Server Sent Events implementation	 -->
	<script src="js/machine-sse.js" type="text/javascript"></script>
	
</body>
</html>