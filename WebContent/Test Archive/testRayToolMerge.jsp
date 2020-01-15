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
				 <br> collisions: 			<input type="text" id="collisions" value="">
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
		/* Process setup */
		var billet = {
				size : {
					x : 5, 
					y : 5, 
					z : 5
				}
		}
		
		var tool = {
				height : 5,
				radius : 0.9,
				position : {
					x : -2,
					y : 3.5,
					z : -2
				}
		}
		

		/* Graphics setup */
		var elemSize = 0.04;//mm
		var toolRadialSegments = 16;
		
		
		/* The code below should not be amended */
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
		
		var collidableMeshList = [];
		
		//the cutting tool
		var toolGeometry = new THREE.CylinderGeometry( tool.radius, tool.radius, tool.height, toolRadialSegments );
		var toolTexture = new THREE.TextureLoader().load( 'image/tool.png' );
		var toolMaterial = new THREE.MeshPhongMaterial( { map: toolTexture, wireframe: true  } );
		var toolMesh = new THREE.Mesh( toolGeometry, toolMaterial );
		toolMesh.position.x = tool.position.x;
		toolMesh.position.y = tool.position.y;
		toolMesh.position.z = tool.position.z;
		scene.add( toolMesh );
		
		//Billet
		//Create a prototype element and copy it to create the whole billet
		var billetGeometry = new THREE.Geometry();
		var elemGeometry = new THREE.BoxGeometry( elemSize, 5, elemSize );
		var billetMaterial = new THREE.MeshPhongMaterial( { color: 0x0000ff, wireframe: true } );
		var elem = new THREE.Mesh( elemGeometry, billetMaterial );
		
		// Create all elements as copies of the prototype
		for (xCoord = 0; xCoord <= 5; xCoord += elemSize){
			for (zCoord = 0; zCoord <= 5; zCoord += elemSize){
				var copyElem = elem.clone();
				copyElem.position.x = xCoord;
				copyElem.position.y = 2.5;
				copyElem.position.z = zCoord;
				copyElem.updateMatrix();
				scene.add ( copyElem );
//                 billetGeometry.merge(copyElem.geometry, copyElem.matrix);
				collidableMeshList.push(copyElem);
			}
		}
		//Add the merged billet to the scene		
// 		var billetMaterial = new THREE.MeshPhongMaterial( { color: 0x0000ff, wireframe: true } );
// 		var billetMesh = new THREE.Mesh(billetGeometry, billetMaterial);
// 		scene.add ( billetMesh );
		
		/* The plane on which the billet sits (used to cover machined billet elements) */
		var planeGeometry = new THREE.PlaneGeometry( 50, 50, 1 );
		var planeTexture = new THREE.TextureLoader().load( 'image/plane.jpg' );
		var material = new THREE.MeshBasicMaterial( {  } );
		var planeMaterial = new THREE.MeshBasicMaterial( {
			side: THREE.DoubleSide,
			map: planeTexture} );
		var plane = new THREE.Mesh( planeGeometry, planeMaterial );
		scene.add( plane );
		plane.rotation.x = Math.PI/2;
		plane.rotation.z = Math.PI/2;
// 		plane.position.y -= 25;
		
		/* The rays to cast in order to machine the billet */
		
		var numberOfRays = toolRadialSegments;
		
		var raycasters = [];
		var raycasterDirections = [];
		var raycasterOrigins = [];
		var raycasterOffsetX = tool.position.x;
		var raycasterOffsetY = tool.position.y - tool.height/2;
		var raycasterOffsetZ = tool.position.z;
		
		var increment = 2*Math.PI/numberOfRays;
		var fullCircle = 2*Math.PI;
		var quarterCircle = Math.PI / 2;
		var rayLength = 2 * tool.radius * Math.sin(fullCircle/numberOfRays/2);
		for (var radians = 0; radians < fullCircle; radians += increment){
			var origin = new THREE.Vector3( raycasterOffsetX + tool.radius * Math.cos( radians ), raycasterOffsetY, raycasterOffsetZ + tool.radius * Math.sin( radians ) );
			var direction = new THREE.Vector3(Math.cos( Math.PI/numberOfRays + radians + quarterCircle ), 0, Math.sin( Math.PI/numberOfRays + radians + Math.PI/2 ) );
			raycasters.push( new THREE.Raycaster(origin, direction, 0, rayLength) );
			
// 			var arrowHelper = new THREE.ArrowHelper( direction, origin, rayLength, 0x000000 );
// 			scene.add( arrowHelper );
		}
		
		
		// axis
		var axesHelper = new THREE.AxesHelper( 5 );
		scene.add( axesHelper );

		camera.position.x = -5;
		camera.position.y = 5;
		camera.position.z = 15;
		controls.update();
		renderer.render( scene, camera );

		var counter = 0;
		var i = 0;
		var machining = false;

		
		function animate() {
			if (machining){
				if (counter <= 0){
					i=elemSize;
				}else if (counter > 8){
					i=-elemSize;
				}
				counter += i;
					
				toolMesh.position.x += i;
				toolMesh.position.y += i;
				toolMesh.position.z += i;
				
				light.position.set(toolMesh.position.x, toolMesh.position.y, toolMesh.position.z);
	
			
				// for each raycaster
				raycasters.forEach(function(raycaster) {
					raycaster.ray.origin.x += i;
					raycaster.ray.origin.y += i;
					raycaster.ray.origin.z += i;
					var collisionResults = raycaster.intersectObjects( collidableMeshList );
					if (collisionResults.length > 0){
						collisionResults.forEach(function(element) {
							element.object.position.y = raycaster.ray.origin.y-2.5;
 							document.getElementById('collisions').value = collisionResults.length;
						});
					}
				});
			}

 			document.getElementById('memory_geometries').value = renderer.info.memory.geometries;
 			document.getElementById('memory_textures').value = renderer.info.memory.textures;
 			document.getElementById('render_calls').value = renderer.info.render.calls;
 			document.getElementById('render_triangles').value = renderer.info.render.triangles;
 			document.getElementById('render_points').value = renderer.info.render.points;
 			document.getElementById('render_lines').value = renderer.info.render.lines;

 			controls.update();
			window.requestAnimationFrame( animate );
			renderer.render( scene, camera );
		};
		window.requestAnimationFrame( animate );
		
		function startMachining(){
			machining = true;
		}

		function stopMachining(){
			machining = false;
		}
		
		function wire(){
			scene.children.forEach(function(child) {
				child.wireframe = !child.wireframe;
			});
		}
	</script>
	
</body>