<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>SSE Test</title>

<style type="text/css">
	#page-wrapper {
		style="width: 100%; 
		display: table;
	}
	
	
	#control-wrapper{
		padding:10px;
	}
	
	#canvas-wrapper {
		display: table-cell;
		width: 50%;
	}
	
	#graphs-wrapper {
		display: table-cell;
		height:100vh;
		vertical-align: top;
	}
	
	.graph-container {
		width:80%;
		height:45%;
	}
	
</style>
</head>
<body>
	<div id="page-wrapper">
		<div style="display: table-row">
			<div id="control-wrapper">
				<button id="startButton" onclick="start()">Start</button>
				<button id="stopButton" onclick="stop()">Stop</button>
				status: <input type="text" id="statusArea" value="">
			</div>
			<div style="display: table-cell;">
				x:<input type="text" id="xCoord" value="0">
				y:<input type="text" id="yCoord" value="0">
				z:<input type="text" id="zCoord" value="0">
			</div>
		</div>
		<div style="display: table-row;">
			<div id="canvas-wrapper"></div>
			<div id="graphs-wrapper">
				<div id="graph01" class="graph-container"></div>
				<div id="graph02" class="graph-container"></div>
			</div>
		</div>
	</div>

	<script src="js/three.min.js"></script>
		<script src="js/OrbitControls.js"></script>
		<script>
			var scene = new THREE.Scene();
			scene.background = new THREE.Color( 0xffffff );
			var camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );
			var controls = new THREE.OrbitControls( camera );
			
			var renderer = new THREE.WebGLRenderer();
			renderer.setSize( window.innerWidth*0.55, window.innerHeight*0.9 );
			
			var container = container = document.getElementById("canvas-wrapper");
			container.appendChild( renderer.domElement );

			var geometry = new THREE.CylinderGeometry( 1, 1, 2, 16 );
			var material = new THREE.MeshBasicMaterial( { color: 0xffff00 } );
			var cylinder = new THREE.Mesh( geometry, material );
			scene.add( cylinder );
			
			// wireframe
			var wireframe = new THREE.WireframeHelper( cylinder, 0xffffff );
			scene.add( wireframe );
			
			// axis
			var axesHelper = new THREE.AxesHelper( 5 );
			scene.add( axesHelper );

			camera.position.z = 10;
			controls.update();
			renderer.render( scene, camera );
			
			function animate() {
// 				requestAnimationFrame( animate );
				cylinder.position.x = document.getElementById('xCoord').value;
				wireframe.position.x = document.getElementById('xCoord').value;
				cylinder.position.y = document.getElementById('yCoord').value;
				wireframe.position.y = document.getElementById('yCoord').value;
				cylinder.position.z = document.getElementById('zCoord').value;
				wireframe.position.z = document.getElementById('zCoord').value;
				
				controls.update();
				renderer.render( scene, camera );
			};
		</script>
		
		<!-- Highcharts JavaScript -->
    	<script src="js/highcharts.js"></script>
		<script src="js/exporting.js"></script>
		<script src="js/offline-exporting.js"></script>
		<script type="text/javascript">
		var graph01 = Highcharts.chart("graph01", {
		    chart: {
		        type: 'area'
		    },
		    title: {
		        text: 'Current time vs reference time'
		    },
		    subtitle: {
		        text: 'Comparison between the current process time and the reference time specified by running the same program on other machines'
		    },
		    xAxis: {
		        allowDecimals: false,
		        labels: {
		            formatter: function () {
		                return this.value; // clean, unformatted number for year
		            }
		        }
		    },
		    yAxis: {
		        title: {
		            text: 'Time since start'
		        },
		        labels: {
		            formatter: function () {
		                return Math.floor(this.value / 60) + 'min';
		            }
		        }
		    },
		    tooltip: {
		        pointFormat: '{series.name} running for <b>{point.y:,.0f}</b><br/>to do {point.x} %'
		    },
		    plotOptions: {
		        area: {
		            pointStart: 0,
		            marker: {
		                enabled: false,
		                symbol: 'circle',
		                radius: 2,
		                states: {
		                    hover: {
		                        enabled: true
		                    }
		                }
		            }
		        },
		    },
		    series: [{
		        name: 'Reference',
		        data: [
		            1, 		2, 		3, 		4, 		5, 		6, 		11, 	32, 	110, 	235,
		            369, 	640, 	905, 	1236, 	1763, 	2757, 	3618, 	4444, 	8822, 	11468,
		            18434, 	21126, 	25387, 	26459, 	29056, 	30982, 	31040, 	31233, 	32224, 	33342,
		            41130, 	45130, 	49540, 	58040, 	67610, 	77170, 	83680, 	90180
			    ]
		    }, {
		        name: 'Current',
		        data: [
		            10, 	20, 	30, 	40, 	50, 	60, 	75, 	92, 	210, 	235,
		            369, 	640, 	1005, 	1436, 	2063, 	3057, 	4618, 	6444, 	9822, 	15468,
		            20434, 	24126, 	27387, 	29459, 	31056, 	31982, 	32040, 	31233, 	39224, 	47342,
		            51130, 	51130, 	59540, 	68040, 	77610, 	87170, 	93680, 	100180
			    ]
		    }]
		});
		
		//Add points and update graph at a minimum every 5000msec
		var countdown = 0;
		var beginTime = new Date().getTime();
		var currentTime = beginTime;
		function updateChart(pointValue){
			graph01.series[1].addPoint(pointValue, false, false);
			currentTime = new Date().getTime();
			if (currentTime-beginTime > 5000){
				graph01.redraw();
				beginTime = currentTime;
			}
		}
		</script>
		
		<!-- Server side event implementation -->
			<script>
			var eventSource = null;
			
			function start(){
				//eventSource = new EventSource("http://localhost:8080/MillingTwin/TwinMain");
				eventSource = new EventSource("jacob");
				eventSource.onopen = function(){
					statusArea.value = "Connected";
				}
				eventSource.onmessage = function(message){
// 					document.getElementById("xCoord").value = message.data;
					var sseData = JSON.parse(message.data);
					document.getElementById("xCoord").value = sseData.xcoord /100;
					document.getElementById("yCoord").value = sseData.ycoord /100;
					document.getElementById("zCoord").value = sseData.zcoord /100;
					updateChart(sseData.ycoord);
					animate();
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