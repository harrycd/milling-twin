<!DOCTYPE html>
<%@page import="uk.ac.cf.milling.utils.db.BilletUtils"%>
<%@page import="uk.ac.cf.milling.objects.Billet"%>
<%@page import="uk.ac.cf.milling.objects.Nc"%>
<%@page import="uk.ac.cf.milling.utils.db.NcUtils"%>
<%@page import="java.util.List"%>
<html>
<head>
<meta charset="UTF-8">
<title>Milling Twin</title>

<link rel="stylesheet" href="css/bootstrap.min.css">

</head>
<body>
	<div id="data-store-element"></div>
	
	<div class="container">
		<div class="row mt-3">
			<div class="col-sm">
				<% List<Nc> ncs = NcUtils.getNcs(); %>
				<select id="ncs" onchange="ncSelection()">
					<option value="0">Select NC file...</option>
					<% for (Nc nc : ncs) { %>
					<option value=<%out.print(nc.getNcId());%>><%out.print(nc.toString());%></option>
					<% } %>
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
			<div class="col-sm">
				<table class="table table-bordered">
					<tr>
						<th> Scope </th>
						<th> X </th>
						<th> Y </th>
						<th> Z </th>
					</tr>
					<tr>
						<td>Global</td>
						<td id="xg-coord">0.000</td>
						<td id="yg-coord">0.000</td>
						<td id="zg-coord">0.000</td>
					</tr>
					<tr>
						<td>Local</td>
						<td id="xl-coord">0.000</td>
						<td id="yl-coord">0.000</td>
						<td id="zl-coord">0.000</td>
					</tr>
				</table>
			</div>
		</div>
		<div class="row mt-3">
			<div class="col-sm">
				Process Time : 
				<span id="mon-time"> 0 : 0 : 0</span>
			</div>
		</div>
	
		
		
		<div class="row mt-3">
			<div id="canvas-wrapper" ></div>
		</div>
		
		<div class="row mt-3">
			<div id="graphs-wrapper" class="col-sm"></div>
		</div>
		
		<div class="row mt-3">
			<div class="col-sm">
				Debugging status:
				<input type="text" id="debug-1" value="xxx" disabled>
				<input type="text" id="debug-2" value="xxx" disabled>
				<input type="text" id="debug-3" value="xxx" disabled>
			</div>
		</div>
		<div id="debug-sphere-controls" class="row mt-3">
			<div class="col-sm">
				<label class="form-label m-2">Sphere control:</label>
				<label class="form-label">x:</label>
				<input id="sphere-x" type="text" class="m-2" size="1" value="0">
				<label class="form-label">y:</label>
				<input id="sphere-y" type="text" class="m-2" size="1" value="0">
				<label class="form-label">z:</label>
				<input id="sphere-z" type="text" class="m-2" size="1" value="0">
			</div>
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