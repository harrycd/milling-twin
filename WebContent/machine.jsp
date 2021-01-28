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
	<div id="data-store-element"></div>
	
	<div class="page-wrapper">
		<div class="header-wrapper">
			<% List<Nc> ncs = NcUtils.getNcs(); %>
			<select id="ncs" onchange="ncSelection()">
				<option value="0">Select NC file...</option>
				<% for (Nc nc : ncs) { %>
				<option value=<%out.print(nc.getNcId());%>><%out.print(nc.toString());%></option>
				<% } %>
			</select> &nbsp;
			
			<button id="connect-button" onclick="connect()">Connect</button>
			<button id="view-graphs-button" onclick="graphs()">Graphs</button>
			<button id="view-process-button" onclick="process()">Process</button>
			<button id="mrr-button" onclick="downloadObjectAsJson(mrr, 'mrr.txt')">MRR</button>
			
			
		</div>
		<div class="main-wrapper">
			<textarea id="status-area" rows="5" cols="100"></textarea>
			<br>
			<table border="1">
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
			<br>
			Process Time : 
			<span id="mon-time"> 0 : 0 : 0</span>
		</div>
	</div>
	<br>
	<input type="text" id="debug-1" value="xxx">
	<input type="text" id="debug-2" value="xxx">
	<input type="text" id="debug-3" value="xxx">
	
	
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
	
<!-- The modal containing the process simulation canvas -->
	
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
					<div id="debug-sphere-controls">
						x:<input id="sphere-x" type="text" size="1" value="0">
						&nbsp;y:<input id="sphere-y" type="text" size="1" value="0">
						&nbsp;z:<input id="sphere-z" type="text" size="1" value="0">
					</div>
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
	<script src="js/machine-main.js" type="text/javascript"></script>

<!-- Graphs display implementation -->

	<script src="js/micromodal.min.js" type="text/javascript"></script>
	<script src="js/highcharts.js" type="text/javascript"></script>
	<script src="js/exporting.js" type="text/javascript"></script>
	<script src="js/offline-exporting.js" type="text/javascript"></script>
	<script src="js/machine-graphs.js" type="text/javascript"></script>

<!-- Milling Virtual implementation	 -->
	<script src="js/three.js" type="text/javascript"></script>
	<script src="js/OrbitControls.js"></script>
	<script src="js/machine-simulation.js" type="text/javascript"></script>
	
<!-- Server Sent Events implementation	 -->
	<script src="js/machine-sse.js" type="text/javascript"></script>
	
</body>
</html>