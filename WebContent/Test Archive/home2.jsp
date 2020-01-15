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
		border-style: solid;
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
				 <br> memory_geometries: 	<input type="text" id="memory_geometries" value="">
				 <br> memory_textures: 		<input type="text" id="memory_textures" value="">
				 <br> render_calls: 		<input type="text" id="render_calls" value="">
				 <br> render_triangles: 	<input type="text" id="render_triangles" value="">
				 <br> render_points: 		<input type="text" id="render_points" value="">
				 <br> render_lines: 		<input type="text" id="render_lines" value="">
				 <br> programs: 			<input type="text" id="programs" value="">
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

	<script src="js/three.js"></script>
	<script src="js/OrbitControls.js"></script>
	<script src="js/ThreeCSG.js"></script>
	<script>
		var canvasWrapperWidth = document.getElementById("canvas-wrapper").clientWidth;
		var canvasWrapperHeight = document.getElementById("canvas-wrapper").clientHeight;
		
		var scene = new THREE.Scene();
		scene.background = new THREE.Color( 0xffffff );
		
		var camera = new THREE.PerspectiveCamera( 125, canvasWrapperWidth/canvasWrapperHeight, 0.1, 1000 );
		
		var controls = new THREE.OrbitControls( camera, document.getElementById("canvas-wrapper") );
		
		var ambientLight = new THREE.AmbientLight(0xffffff, 0.2);
		scene.add(ambientLight);
		
		var light = new THREE.PointLight(0xffffff, 1, 18, 1.5);
		light.position.set(8, 10, 8);
		light.castShadow = true;
		light.shadow.camera.near = 0.1;
		light.shadow.camera.far = 25;
		scene.add(light);
		
		var renderer = new THREE.WebGLRenderer();
		renderer.setSize( canvasWrapperWidth, canvasWrapperHeight );
		renderer.shadowMap.enabled = true;
		renderer.shadowMap.type = THREE.BasicShadowMap;
		
		var container = container = document.getElementById("canvas-wrapper");
		container.appendChild( renderer.domElement );
		
		//the cutting tool
		var toolGeometry = new THREE.CylinderGeometry( 0.7, 0.7, 5, 16 );
// 		var toolGeometry = new THREE.CubeGeometry( 0.7, 5, 0.7);
		var toolMaterial = new THREE.MeshPhongMaterial( { color: 0xff0000 } );
		var tool = new THREE.Mesh( toolGeometry, toolMaterial );
		var toolOffsetX = 0.5;
		var toolOffsetY = 5;
		var toolOffsetZ = 0.5;
		tool.position.x = toolOffsetX;
		tool.position.y = toolOffsetY;
		tool.position.z = toolOffsetZ;
		scene.add( tool );
		
		//The billet -> part
		var billetGeometry = new THREE.CubeGeometry( 5, 5, 5 );
		var billetMaterial = new THREE.MeshPhongMaterial( { color: 0x0000ff } );
		var part = new THREE.Mesh( billetGeometry, billetMaterial );
		var partOffsetX = 2.5;
		var partOffsetY = 2.5;
		var partOffsetZ = 2.5;
		part.position.x = partOffsetX;
		part.position.y = partOffsetY;
		part.position.z = partOffsetZ;
// 		var partBSP;
		scene.add ( part );
		// = new ThreeBSP( part );
		
		// axis
		var axesHelper = new THREE.AxesHelper( 5 );
		scene.add( axesHelper );

		camera.position.z = 10;
		controls.update();
		renderer.render( scene, camera );

		// Set the minimum refresh rate for part and tool
		var toolTimeBegin = new Date().getTime();
		var toolTimeCurrent = toolTimeBegin;
		
		function animate() {
			toolTimeCurrent = new Date().getTime();
			// update the tool position (parseFloat() is needed if toolOffsetX is removed)
			// yz of threejs is different of yz of the machine
			tool.position.x = toolOffsetX + parseFloat(document.getElementById('xCoord').value);
			tool.position.y = toolOffsetY + parseFloat(document.getElementById('zCoord').value);
			tool.position.z = toolOffsetZ + parseFloat(document.getElementById('yCoord').value);
			
			light.position.set(tool.position.x, tool.position.y, tool.position.z);

			//Subtract every 5sec (otherwise browser hangs because of CPU 100%)
			if (true && (toolTimeCurrent - toolTimeBegin > 1000) ){
				var toolBSP = new ThreeBSP( tool );
				scene.remove(part);
				var partBSP = new ThreeBSP( part );
				part = partBSP.subtract( toolBSP ).toMesh( billetMaterial );
// 				part.geometry.computeVertexNormals();
				scene.add( part );
				
				//reset the timer
				toolTimeBegin = toolTimeCurrent;
			}
						
			controls.update();
			renderer.render( scene, camera );
			document.getElementById('memory_geometries').value = renderer.info.memory.geometries;
			document.getElementById('memory_textures').value = renderer.info.memory.textures;
			document.getElementById('render_calls').value = renderer.info.render.calls;
			document.getElementById('render_triangles').value = renderer.info.render.triangles;
			document.getElementById('render_points').value = renderer.info.render.points;
			document.getElementById('render_lines').value = renderer.info.render.lines;
			document.getElementById('programs').value = renderer.info.programs;
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
		        name: 'Current',
		        data: [
			            10, 	20, 	30, 	40, 	50, 	60, 	75, 	92, 	210, 	235,
			            369, 	640, 	1005, 	1436, 	2063, 	3057, 	4618, 	6444, 	9822, 	15468,
			            20434, 	24126, 	27387, 	29459, 	31056, 	31982, 	32040, 	31233, 	39224, 	47342,
			            51130, 	51130, 	59540, 	68040, 	77610, 	87170, 	93680, 	100180
				    ]
		    }, {
		        name: 'Reference',
		        data: [
			            1, 		2, 		3, 		4, 		5, 		6, 		11, 	32, 	110, 	235,
			            369, 	640, 	905, 	1236, 	1763, 	2757, 	3618, 	4444, 	8822, 	11468,
			            18434, 	21126, 	25387, 	26459, 	29056, 	30982, 	31040, 	31233, 	32224, 	33342,
			            41130, 	45130, 	49540, 	58040, 	67610, 	77170, 	83680, 	90180
				    ]
		    }]
		});
	
		//Add points and update graph at a minimum every 5000msec
		var countdown = 0;
		var graphTimeBegin = new Date().getTime();
		var graphTimeCurrent = graphTimeBegin;
		function updateChart(pointValue){
			//TODO remove return. Used to test how much memory threejsCSG uses
			return;
			graph01.series[1].addPoint(pointValue, false, false);
			graphTimeCurrent = new Date().getTime();
			if (graphTimeCurrent - graphTimeBegin > 5000){
				graph01.redraw();
				graphTimeBegin = graphTimeCurrent;
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
// 				document.getElementById("xCoord").value = message.data;
				var sseData = JSON.parse(message.data);
				 
				document.getElementById("xCoord").value = sseData.xcoord /10;
				document.getElementById("yCoord").value = sseData.ycoord /10;
				document.getElementById("zCoord").value = sseData.zcoord /10;
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
			statusArea.value = "Disconnected";
		}
	</script>
</body>
</html>