/* Simulator setup */

var container = document.getElementById("canvas-wrapper");

/* Graphics setup */
//TODO changing elemSize != 1 meshes up machining.
var elemSize = 1;//mm

/********************************************************************************/

/* The code below this point should not be amended */

var tool, billet;
var scene, camera, controls, ambientLight, light, renderer;
var toolMesh, billetMesh, sphereMesh;
var billetElemCountX, billetElemCountZ;

function initialiseSimulation(billetData){
	var canvasWrapperWidth = window.innerWidth*0.8;
	var canvasWrapperHeight = window.innerHeight*0.65;
	
	scene = new THREE.Scene();
	scene.background = new THREE.Color( 0xffffff );
	
	camera = new THREE.PerspectiveCamera( 125, canvasWrapperWidth/canvasWrapperHeight, 0.1, 1000 );
	
	controls = new THREE.OrbitControls( camera, container );
	
	ambientLight = new THREE.AmbientLight(0xfafafa, 0.5);
	scene.add(ambientLight);
	
	
	billet = generateBillet(
			billetData.xBilletMin, billetData.xBilletMax, 
			billetData.zBilletMin, billetData.zBilletMax, 
			billetData.yBilletMin, billetData.yBilletMax
			);
	showBilletMesh(billet);

	//this is a default tool that will be substituted with the right one as soon as the process begins
	tool = generateTool(50, 5, 16);
	showToolMesh(tool);
	
	light = new THREE.PointLight(0xffffff, 1, 0, 1);
	light.position.set(0, billet.coordinates.ymax*2, 0);
	light.castShadow = true;
	scene.add(light);
	
	/* The plane on which the billet sits (is used to cover machined billet elements) */
	var planeGeometry = new THREE.PlaneGeometry( billet.size.x, billet.size.z, 1 );
	var planeTexture = new THREE.TextureLoader().load( 'image/plane.jpg' );
	var planeMaterial = new THREE.MeshPhongMaterial( { 
		color: 0xffffff, 
		wireframe: false,
		side: THREE.DoubleSide
	} );
	var plane = new THREE.Mesh( planeGeometry, planeMaterial );
	scene.add( plane );
	plane.rotation.x = Math.PI/2;
	plane.position.x += billet.size.x/2;
	plane.position.y -= billet.size.y/2;
	plane.position.z += billet.size.z/2;
	
	//For debugging purposes a sphere is added
	const debugSphere = new THREE.SphereGeometry( 5, 32, 32 );
	const debugSphereMaterial = new THREE.MeshBasicMaterial( {color: 0xff00ff} );
	sphereMesh = new THREE.Mesh( debugSphere, debugSphereMaterial );
	scene.add( sphereMesh );
	
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
	
	container.appendChild( renderer.domElement );
	
	controls.update();
	renderer.render( scene, camera );
	
}

/**
 * Generates a new tool of cylindrical shape
 * 
 * @param height - tool height
 * @param radius - tool radius
 * @returns the generated tool
 */
function generateTool(height, radius, radialSegments){
	var tool = {
			height : height,
			radius : radius,
			radialSegments : radialSegments,
			position : {
				x : 0,
				y : 1000,
				z : 0
			}
	}
	return tool;
}

/**
 * Generates and adds to scene the mesh of the provided cutting tool
 * 
 * @param tool - cutting tool to display
 */
function showToolMesh(tool){
	printStatus("new tool: " + JSON.stringify(tool));
	//Remove current tool mesh from scene if exists
	if (toolMesh != undefined){
		scene.remove( toolMesh );
		printStatus("previous tool removed");
	}
	
	//Cutting tool mesh construction
	var toolGeometry = new THREE.CylinderGeometry( tool.radius, tool.radius, tool.height, tool.radialSegments );
//	var toolTexture = new THREE.TextureLoader().load( 'image/tool.png' );
	var toolMaterial = new THREE.MeshPhongMaterial( { 
//		map: toolTexture,
		color: 0xff5555,
		wireframe: false,
	} );
	toolMesh = new THREE.Mesh( toolGeometry, toolMaterial );
	toolMesh.position.x = tool.position.x;
	toolMesh.position.y = tool.position.y - tool.height/2;
	toolMesh.position.z = tool.position.z;
	
	scene.add( toolMesh );
}


/**
 * Generates a billet object
 * @param xmin - minimum x axis coordinate
 * @param xmax - maximum x axis coordinate
 * @param ymin - minimum y axis coordinate
 * @param ymax - maximum y axis coordinate
 * @param zmin - minimum z axis coordinate
 * @param zmax - maximum z axis coordinate
 * @returns the generated billet object
 */
function generateBillet(xmin, xmax, ymin, ymax, zmin, zmax){
	var billet = {
			coordinates : {
				xmin : xmin,
				xmax : xmax,
				ymin : ymin,
				ymax : ymax,
				zmin : zmin,
				zmax : zmax
			},
			size : {
				x : xmax-xmin,
				y : ymax-ymin,
				z : zmax-zmin
			}, 
			displayOffset : {
				x : xmin,
				y : ymin,
				z : zmin
			}
	};
	
	return billet;
}

/**
 * Generates and adds to scene the mesh of the provshowBilletMeshparam billet
 */
function showBilletMesh(billet){
	
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

var mrr = [];

var mrrIndex = -1;
var newSampleReceived = false;
function animate() {
	window.requestAnimationFrame( animate );
	
	// Ensure that data has been received 
	if (dataStorage.machine == undefined) {
		return;
	}
	
	// Get the index position of the new sample in the storage arrays
	let toolPropertiesArrayIndex = dataStorage.machineTool.toolRadius.length-1; // Index for cutting tool related data
	let sampleIndex = dataStorage.machine.X.length-1; //Index for all other data

	//Add new MRR array element if new sample received
	if (newSampleReceived){
		mrr.push(0);
		mrrIndex++;
		newSampleReceived = false;
	}
	
	// SphereMesh positioning (used for debugging)
	sphereMesh.position.x = document.getElementById("sphere-x").value;
	sphereMesh.position.y = document.getElementById("sphere-y").value;
	sphereMesh.position.z = document.getElementById("sphere-z").value;
	
	// Cutting tool change if needed
	if (dataStorage.machineTool.toolRadius[0] != undefined 
			&& dataStorage.machineTool.toolRadius[toolPropertiesArrayIndex] != tool.radius){
		
		tool.radius = dataStorage.machineTool.toolRadius[toolPropertiesArrayIndex]; //to prevent re-runing the block until tool is changed

		tool = generateTool(
				dataStorage.machineTool.toolHeight[toolPropertiesArrayIndex], 
				dataStorage.machineTool.toolRadius[toolPropertiesArrayIndex], 
				16);
		
		showToolMesh(tool);
	}
	
	// Cutting tool move to new position
	toolMesh.position.x = dataStorage.machine.X[sampleIndex] - billet.coordinates.xmin;
	toolMesh.position.y = dataStorage.machine.Z[sampleIndex] - billet.coordinates.ymin - tool.height/2;//tool length considered
	toolMesh.position.z = dataStorage.machine.Y[sampleIndex] - billet.coordinates.zmin;

	var xIndexToolPosition = Math.floor(toolMesh.position.x / elemSize);
	var zIndexToolPosition = Math.floor(toolMesh.position.z / elemSize);

	var xIndexStart = Math.floor( (Number(toolMesh.position.x) - tool.radius) /elemSize);
	var xIndexEnd = Math.floor( (Number(toolMesh.position.x) + tool.radius) /elemSize);

	//Iterate over the elements that are within the x limits of the tool position				
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
						//Add difference to mrr array (difference equals to amount of material removed)
						mrr[mrrIndex] += (billetMesh.geometry.attributes.position.array[vertInd] - toolNoseYPosition);
						billetMesh.geometry.attributes.position.array[vertInd] = toolNoseYPosition; 
					}
				}
			})
			
			//plotMRR(mrr, 10);
			
			//update the mesh
			if (!billetMesh.geometry.attributes.position.needsUpdate){
				billetMesh.geometry.attributes.position.needsUpdate = true;
			}
		}
	}

	controls.update();

	renderer.render( scene, camera );
};

/**
 *  Plots a graph of Material Removed (it is not rate)
 * @param mrr
 * @param ma
 */
function plotMRR(mrr, ma){
	dataStorage.mrr = mrr;
	let mrrMean = [];
	let mrrPart;
	let sum = 0;
	if (mrr.length < 1000){
		setChartData(mrr);
	} else {
		mrrPart = mrr.slice(mrr.length - 1000);
		let i,j;
		for (i = 0; i < (mrrPart.length - ma); i++){
			for (j = 0; j < ma; j++){
				sum += mrrPart[i+j];
			}
			mrrMean.push(sum);
			sum = 0;
		}
		setChartData(mrrMean);
	}
}

function startSimulation(){
	animate();
}

function stopSimulation(){
	//doesn't work
	window.cancelAnimationFrame( animate );
}


function wire(){
	scene.children.forEach(function(child) {
		if (typeof child.material !== 'undefined'){
			child.material.wireframe = !child.material.wireframe;
		}
	});
}