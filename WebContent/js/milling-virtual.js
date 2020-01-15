/* Process setup */
/*****************************************************************************/

//Adding a default size >0 to prevent errors
var billet = {
		size : {
			x : 1, 
			y : 1, 
			z : 1,
		},
		displayOffset : {
			x : 0,
			y : 0,
			z : 0
		}
}

var tool = {
		height : 1,
		radius : 1,
		position : {
			x : -100,
			y : 1000,
			z : -100
		}
}

/* Graphics setup */
//TODO changing elemSize != 1 meshes up machining.
var elemSize = 0.1;//mm
var toolRadialSegments = 16;

/********************************************************************************/

/**
 * This contains the javascript needed to create the virtual representation of milling process
 * Code here should not be amended by the user
 */



if (elemSize > tool.radius){
	alert("Element size cannot be larger than tool radius!");
	throw new Error("Element size > tool radius");
}


/* The code below should not be amended */

var scene, camera, controls, ambientLight, light, renderer, container;
var toolMesh, billetMesh;
var billetElemCountX, billetElemCountZ;

function init(){
	var canvasWrapperWidth = window.innerWidth*0.8;
	var canvasWrapperHeight = window.innerHeight*0.65;
	
	scene = new THREE.Scene();
	scene.background = new THREE.Color( 0xffffff );
	
	camera = new THREE.PerspectiveCamera( 125, canvasWrapperWidth/canvasWrapperHeight, 0.1, 1000 );
	
	controls = new THREE.OrbitControls( camera, document.getElementById("canvas-wrapper") );
	
	ambientLight = new THREE.AmbientLight(0xfafafa, 0.5);
	scene.add(ambientLight);
	
	light = new THREE.PointLight(0xffffff, 1, 0, 1);
	light.position.set(0, 0, 0);
	light.castShadow = true;
	scene.add(light);
	
	
// Cutting tool creation
	generateTool(10, 10, 32);

	
// Create the billet
	generateBillet();
	
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
	
	camera.position.x = 100;
	camera.position.y = 100;
	camera.position.z = 100;
	
	renderer = new THREE.WebGLRenderer();
	renderer.setSize( canvasWrapperWidth, canvasWrapperHeight );
	renderer.shadowMap.enabled = true;
	renderer.shadowMap.type = THREE.BasicShadowMap;
	
	container = document.getElementById("canvas-wrapper");
	container.appendChild( renderer.domElement );
	
	controls.update();
	renderer.render( scene, camera );
	
}

function generateTool(radius, height, toolRadialSegments){
	console.log("New tool - Radius:" + radius + " Height:" + height + " Segments:" + toolRadialSegments);
	//Remove current tool from scene if exists
	if (toolMesh != undefined){
		scene.remove( toolMesh );
	}
	
	//Cutting tool construction
	tool.height = height;
	tool.radius = radius;
	var toolGeometry = new THREE.CylinderGeometry( radius, radius, height, toolRadialSegments );
//	var toolTexture = new THREE.TextureLoader().load( 'image/tool.png' );
	var toolMaterial = new THREE.MeshPhongMaterial( { 
//		map: toolTexture,
		color: 0xff0000,
		wireframe: false,
	} );
	toolMesh = new THREE.Mesh( toolGeometry, toolMaterial );
	toolMesh.position.x = tool.position.x;
	toolMesh.position.y = tool.position.y;
	toolMesh.position.z = tool.position.z;
	scene.add( toolMesh );
}

function setBilletDims(xmin, xmax, ymin, ymax, zmin, zmax){
	billet.size.x = xmax-xmin; 
	billet.size.z = ymax-ymin;
	billet.size.y = zmax-zmin;
	
	billet.displayOffset.x = xmin;
	billet.displayOffset.z = ymin;
	billet.displayOffset.y = zmin;
}

function generateBillet(){
	
	//Remove current billet from scene if exists 
	if (billetMesh != undefined){
		scene.remove( billetMesh );
	}
	
	//Billet construction from vertices
	var billetGeometry = new THREE.BufferGeometry();
	billetElemCountX = Math.floor(billet.size.x / elemSize);
	billetElemCountZ = Math.floor(billet.size.z / elemSize);
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
	billetMesh = new THREE.Mesh(billetGeometry, billetMaterial);
	scene.add ( billetMesh );
}


function animate() {

	// Here the position of the tool is specified
	// Z and Y coordinates are different from the milling standard ones
	toolMesh.position.x = document.getElementById("x-coord").innerHTML;
	toolMesh.position.y = document.getElementById("z-coord").innerHTML;
	toolMesh.position.z = document.getElementById("y-coord").innerHTML;

		/* i should not appear below this point */

		light.position.set(toolMesh.position.x, toolMesh.position.y+tool.height, toolMesh.position.z);

		var xIndexToolPosition = Math.floor(toolMesh.position.x / elemSize);
		var zIndexToolPosition = Math.floor(toolMesh.position.z / elemSize);

		var xIndexStart = Math.floor( (Number(toolMesh.position.x) - tool.radius) /elemSize);
		var xIndexEnd = Math.floor( (Number(toolMesh.position.x) + tool.radius) /elemSize);

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
				
				//The vertices to amend if the vertice is machined by tool (relative values)
				var verticeIndexToAmend = [11, 26, 32, 18*billetElemCountZ+5, 18*billetElemCountZ+17, 18*billetElemCountZ+20];
				
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

	controls.update();
	window.requestAnimationFrame( animate );
	renderer.render( scene, camera );
};
init();
window.requestAnimationFrame( animate );

function wire(){
	scene.children.forEach(function(child) {
		if (typeof child.material !== 'undefined'){
			child.material.wireframe = !child.material.wireframe;
		}
	});
}