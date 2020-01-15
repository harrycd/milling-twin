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
		/*****************************************************************************/
		var billet = {
				size : {
					x : 10, 
					y : 6, 
					z : 10
				}
		}
		
		var tool = {
				height : 5,
				radius : 1,
				position : {
					x : -2,
					y : 6,
					z : -2
				}
		}

		/* Graphics setup */
		//TODO changing elemSize != 1 meshes up machining.
		var elemSize = 0.11;//mm
		var toolRadialSegments = 16;

		/********************************************************************************/
		
		if (elemSize > tool.radius){
			alert("Element size cannot be larger than tool radius!");
			throw new Error("Element size > tool radius");
		}
		
		
		/* The code below should not be amended */
		var canvasWrapperWidth = window.innerWidth;
		var canvasWrapperHeight = window.innerHeight;
		
		var scene = new THREE.Scene();
		scene.background = new THREE.Color( 0xffffff );
		
		var camera = new THREE.PerspectiveCamera( 125, canvasWrapperWidth/canvasWrapperHeight, 0.1, 1000 );
		
		var controls = new THREE.OrbitControls( camera, document.getElementById("canvas-wrapper") );
		
		var ambientLight = new THREE.AmbientLight(0xffffff, 0.2);
		scene.add(ambientLight);
		
		var light = new THREE.PointLight(0xffffff, 1, 0, 1);
		light.position.set(10, 15, 10);
		light.castShadow = true;
// 		light.shadow.camera.near = 0.5;
// 		light.shadow.camera.far = 25;
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
		var toolMaterial = new THREE.MeshPhongMaterial( { 
			map: toolTexture,
			color: 0xff0000,
			wireframe: false,
			} );
		var toolMesh = new THREE.Mesh( toolGeometry, toolMaterial );
		toolMesh.position.x = tool.position.x;
		toolMesh.position.y = tool.position.y;
		toolMesh.position.z = tool.position.z;
		scene.add( toolMesh );
		
		//Billet
		var billetGeometry = new THREE.BufferGeometry();
		var billetElemCountX = Math.floor(billet.size.x / elemSize);
		var billetElemCountZ = Math.floor(billet.size.z / elemSize);
		billet.size.x = billetElemCountX * elemSize;
		billet.size.z = billetElemCountZ * elemSize;
		var billetVertices = new Float32Array(18 * billetElemCountX * billetElemCountZ);
		var counter = 0;
		for (var x = 0; x < billet.size.x; x += elemSize){
			for (var z = 0; z < billet.size.z; z += elemSize){
				billetVertices[counter++] = x;
				billetVertices[counter++] = billet.size.y;
				billetVertices[counter++] = z;
				
				billetVertices[counter++] = x;
				billetVertices[counter++] = billet.size.y;
				billetVertices[counter++] = z+elemSize;
				
				billetVertices[counter++] = x+elemSize;
				billetVertices[counter++] = billet.size.y;
				billetVertices[counter++] = z;
				
				billetVertices[counter++] = x+elemSize;
				billetVertices[counter++] = billet.size.y;
				billetVertices[counter++] = z+elemSize;
				
				billetVertices[counter++] = x+elemSize;
				billetVertices[counter++] = billet.size.y;
				billetVertices[counter++] = z;
				
				billetVertices[counter++] = x;
				billetVertices[counter++] = billet.size.y;
				billetVertices[counter++] = z+elemSize;
				
			}
		}
		
		billetGeometry.addAttribute( 'position', new THREE.BufferAttribute( billetVertices, 3 ) );
		billetGeometry.computeVertexNormals();
		var billetMaterial = new THREE.MeshPhongMaterial( { 
			color: 0x0000ff, 
			wireframe: false,
			side: THREE.DoubleSide,
			shading : THREE.FlatShading
		} );


		//Add the merged billet to the scene		
		var billetMesh = new THREE.Mesh(billetGeometry, billetMaterial);
		scene.add ( billetMesh );
		collidableMeshList.push( billetMesh );
		
		/* The plane on which the billet sits (used to cover machined billet elements) */
		var planeGeometry = new THREE.PlaneGeometry( 50, 50, 1 );
		var planeTexture = new THREE.TextureLoader().load( 'image/plane.jpg' );
		var planeMaterial = new THREE.MeshPhongMaterial( { 
			color: 0xffffff, 
			wireframe: false,
			side: THREE.DoubleSide
		} );
		var plane = new THREE.Mesh( planeGeometry, planeMaterial );
		scene.add( plane );
		plane.rotation.x = Math.PI/2;
		plane.rotation.z = Math.PI/2;
		plane.position.y -= 15;
		
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
		//The vertices to amend if the vertice is machined by tool (relative values)
		var verticeIndexToAmend = [11, 26, 32, 18*billetElemCountZ+5, 18*billetElemCountZ+17, 18*billetElemCountZ+20];

		
		function animate() {
			if (machining){
				if (counter <= 0){
					incr=elemSize;
				}else if (counter > 10){
					incr=-elemSize;
				}
				counter += incr;
				// Here the position of the tool is specified
				toolMesh.position.x += incr;
				toolMesh.position.y += incr/100;
				toolMesh.position.z += incr;
				
				/* i should not appear below this point */
				
				light.position.set(toolMesh.position.x, toolMesh.position.y+15, toolMesh.position.z);
				
				var xIndexToolPosition = Math.floor(toolMesh.position.x / elemSize);
				var zIndexToolPosition = Math.floor(toolMesh.position.z / elemSize);
				
				var xIndexStart = Math.floor( (toolMesh.position.x - tool.radius) /elemSize);
				var xIndexEnd = Math.floor( (toolMesh.position.x + tool.radius) /elemSize);
				
				//Iterate over the element that are within the x limits of the tool position				
				for (var xIndex = xIndexStart; xIndex <= xIndexEnd; xIndex++){
					if ((xIndex < 0) || (xIndex > billetElemCountX)) continue;
					
					/*
					Z for which the elements are within the tool limits are found:
					(X-Xo)² + (Z-Zo)² = R² <=> |Z-Zo| =< sqrt(R²-(X-Xo)²) <=>
					<=> Zo - sqrt(R²-(X-Xo)²) =< Z =< Zo + sqrt(R²-(X-Xo)²)
					*/
					
					//Calculate the number of elements consisting a radius
					var toolRadiusElem = tool.radius / elemSize;
					//Calculate sqrt(radius² - (x-xo)²)
					//The units of radius and x are elemSize (radius = 3 means radius = 3 * elemSize)
					var sqrtCalc = Math.sqrt(toolRadiusElem * toolRadiusElem - (xIndex-xIndexToolPosition)*(xIndex-xIndexToolPosition));
					
					//Iterate over the elements that are within the z limits of the tool for this x position
					var zIndexStart = Math.floor(-sqrtCalc + zIndexToolPosition);
					var zIndexEnd = Math.floor(sqrtCalc + zIndexToolPosition);
					
					//At this point if we multiply xIndex or ZIndex with elem size we will get
					//the exact position of the vertice
					
					//Iterate over the element that are within the z limits of the tool position
					for (var zIndex = zIndexStart; zIndex <= zIndexEnd; zIndex++){
						if ((zIndex < 0) || (zIndex > billetElemCountZ)) continue;
						
						// 0 is starting vertice. The vertices which have to change are
						// 4, 9, 11, 14, 18, 19 so the array index for the related y is 
						// 3*vertice-1 so it is:
						// 11, 26, 32, 41, 53, 56
						
						//We have to search for the vertices that are at (xIndex, zIndex) position
						//As the vertices were custom made the position of each one in the vertice array
						//is already known.
						
						//The index of vertices to start amendment of y(height)
						var arrayStartIndex = (18 * billetElemCountZ) * (xIndex-1) + (18 * zIndex-1);
						
						//Get the height that the machined element should be pushed at.
						var toolNoseYPosition = toolMesh.position.y - tool.height/2;
						
						// Go through every vertice that needs to be pushed downwards
						var vertind = 0; //The index to amend
						verticeIndexToAmend.forEach(function(v){
							vertInd = arrayStartIndex + v;
							if (vertInd >= 0){
								if (billetMesh.geometry.attributes.position.array[vertInd] > toolNoseYPosition){
									billetMesh.geometry.attributes.position.array[vertInd] = toolNoseYPosition; 
								}
							}
						})
						//update the mesh
						if (!billetMesh.geometry.attributes.position.needsUpdate){
							billetMesh.geometry.attributes.position.needsUpdate = true;
						}
					}
				}
			
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
				if (typeof child.material !== 'undefined'){
					child.material.wireframe = !child.material.wireframe;
				}
			});
		}
	</script>
	
</body>