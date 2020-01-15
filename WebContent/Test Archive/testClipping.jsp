<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	
	<title>SSE Test2</title>
	
	<link rel="icon" href="data:;base64,iVBORwOKGO=" />
	
</head>
<body>
	<div id="page-wrapper">
			<div id="control-wrapper">
				 <br> memory_geometries: 	<input type="text" id="memory_geometries" value="">
				 <br> memory_textures: 		<input type="text" id="memory_textures" value="">
				 <br> render_calls: 		<input type="text" id="render_calls" value="">
				 <br> render_triangles: 	<input type="text" id="render_triangles" value="">
				 <br> render_points: 		<input type="text" id="render_points" value="">
				 <br> render_lines: 		<input type="text" id="render_lines" value="">
				 <br> programs: 			<input type="text" id="programs" value="">
				 <br>
				 <button onclick="startMachining()">Start</button>
				 <button onclick="stopMachining()">Stop</button>
				 <button onclick="wire()">wire</button>
				 
			</div>
			<div id="canvas-wrapper"></div>
	</div>

	<script src="js/three.js"></script>
	<script src="js/OrbitControls.js"></script>
	<script src="js/ThreeCSG.js"></script>
	<script>
		var canvasWrapperWidth = window.innerWidth;
		var canvasWrapperHeight = window.innerHeight;
		
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
		
		var localPlane = new THREE.Plane( new THREE.Vector3( 1,  1, 0 ), 0 );
// 		var globalPlane = new THREE.Plane( new THREE.Vector3( 1, 0, 0 ), 5 );
// 		renderer.clippingPlanes = [ globalPlane ];
		renderer.localClippingEnabled = true;
		
		//the cutting tool
		var toolGeometry = new THREE.CylinderGeometry( 0.7, 0.7, 5, 16 );
// 		var toolGeometry = new THREE.CubeGeometry( 0.7, 5, 0.7);
		var toolMaterial = new THREE.MeshPhongMaterial( { color: 0xff0000 } );
		var tool = new THREE.Mesh( toolGeometry, toolMaterial );
		var toolOffsetX = -4;
		var toolOffsetY = 3.5;
		var toolOffsetZ = -4;
		tool.position.x = toolOffsetX;
		tool.position.y = toolOffsetY;
		tool.position.z = toolOffsetZ;
		scene.add( tool );
		
		//The billet -> part
		var billetGeometry = new THREE.CubeGeometry( 5, 5, 5 );
		var billetMaterial = new THREE.MeshPhongMaterial( { 
			color: 0x0000ff, 
			wireframe: false,
			clippingPlanes: [ localPlane ],
		    clipShadows: false
		} );
		var part = new THREE.Mesh( billetGeometry, billetMaterial );
		var partOffsetX = 0;
		var partOffsetY = 0;
		var partOffsetZ = 0;
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

		var counter = 0;
		var i = 0;
		var machining = false;
		function animate() {
			if (machining){
				if (counter <= 0){
					i=0.05;
				}else if (counter > 2){
					i=-0.05;
				}
				counter += i;
					
				tool.position.x += i;
	// 			tool.position.y -= i;
				tool.position.z += i;
				
				light.position.set(tool.position.x, tool.position.y, tool.position.z);
	
// 				var toolBSP = new ThreeBSP( tool );
// 				scene.remove(part);
// 				var partBSP = new ThreeBSP( part );
// 				part = partBSP.subtract( toolBSP ).toMesh( billetMaterial );
// 				part.geometry.computeVertexNormals();
// 				scene.add( part );
			}
				
 			document.getElementById('memory_geometries').value = renderer.info.memory.geometries;
 			document.getElementById('memory_textures').value = renderer.info.memory.textures;
 			document.getElementById('render_calls').value = renderer.info.render.calls;
 			document.getElementById('render_triangles').value = renderer.info.render.triangles;
 			document.getElementById('render_points').value = renderer.info.render.points;
 			document.getElementById('render_lines').value = renderer.info.render.lines;
 			document.getElementById('programs').value = counter;

 			controls.update();
			requestAnimationFrame( animate );
			renderer.render( scene, camera );
		};
		animate();
		
		function startMachining(){
			machining = true;
		}

		function stopMachining(){
			machining = false;
		}
		
		function wire(){
			billetMaterial.wireframe = !billetMaterial.wireframe;
		}
	</script>
	
</body>