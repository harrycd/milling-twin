<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Basic 3.js</title>
<style>
/* body { */
/* 	margin: 0; */
/* } */
</style>
</head>
<body>
	<button onclick="x_plus_one()">x+</button>
	<button onclick="x_minus_one()">x-</button>
	<button onclick="y_plus_one()">y+</button>
	<button onclick="y_minus_one()">y-</button>
	<button onclick="z_plus_one()">z+</button>
	<button onclick="z_minus_one()">z-</button>
	<br>
	<button onclick="xr_plus_one()">rx+</button>
	<button onclick="xr_minus_one()">rx-</button>
	<button onclick="yr_plus_one()">ry+</button>
	<button onclick="yr_minus_one()">ry-</button>
	<button onclick="zr_plus_one()">rz+</button>
	<button onclick="zr_minus_one()">rz-</button>
	<br>
	<div id="canvas-wrapper"></div>
	
	<script src="../js/three.js"></script>
		<script type="text/javascript">
	//----------------------------------------------------------------------------
	// opts
	// {
	//  height: width, 
	//  width: depth,
	//  linesHeight: b,
	//  linesWidth: c,
	//  color: 0xcccccc
	// }
	//
	//____________________________________________________________________________
	function createAGrid() {
	  var config = {
	    height: 500,
	    width: 500,
	    linesHeight: 10,
	    linesWidth: 10,
	    color: 0xff7777
	  };

	  var material = new THREE.LineBasicMaterial({
	    color: config.color,
	    opacity: 0.2
	  });

	  var gridObject = new THREE.Object3D(),
	    gridGeo = new THREE.Geometry(),
	    stepw = 2 * config.width / config.linesWidth,
	    steph = 2 * config.height / config.linesHeight;

	  //width
	  for (var i = -config.width; i <= config.width; i += stepw) {
	    gridGeo.vertices.push(new THREE.Vector3(-config.height, i, 0));
	    gridGeo.vertices.push(new THREE.Vector3(config.height, i, 0));

	  }
	  //height
	  for (var i = -config.height; i <= config.height; i += steph) {
	    gridGeo.vertices.push(new THREE.Vector3(i, -config.width, 0));
	    gridGeo.vertices.push(new THREE.Vector3(i, config.width, 0));
	  }

	  var line = new THREE.Line(gridGeo, material, THREE.LineSegments);
	  gridObject.add(line);

	  return gridObject;
	}
	</script>
	<script>
		var container = document.getElementById("canvas-wrapper");
		const scene = new THREE.Scene();
		const camera = new THREE.PerspectiveCamera(75, window.innerWidth
				/ window.innerHeight, 0.1, 1000);

		const renderer = new THREE.WebGLRenderer();
		renderer.setSize(window.innerWidth, window.innerHeight);
		container.appendChild(renderer.domElement);

		const geometry = new THREE.BoxGeometry();
		const material = new THREE.MeshBasicMaterial({
			color : 0x00ff00
		});
		const cube = new THREE.Mesh(geometry, material);
		scene.add(cube);

		camera.position.z = 5;
		
		const axesHelper = new THREE.AxesHelper( 5 );
		scene.add( axesHelper );
		
		var gridObject = createAGrid();
		scene.add( gridObject );
		
		

		const animate = function() {
			requestAnimationFrame(animate);
			renderer.render(scene, camera);
		};

		animate();
	</script>
	<script type="text/javascript">
	function x_plus_one(){
		cube.position.x++;
	}
	function x_minus_one(){
		cube.position.x--;
	}
	function y_plus_one(){
		cube.position.y++;
	}
	function y_minus_one(){
		cube.position.y--;
	}
	function z_plus_one(){
		cube.position.z++;
	}
	function z_minus_one(){
		cube.position.z--;
	}
	function xr_plus_one(){
		cube.rotation.x++;
	}
	function xr_minus_one(){
		cube.rotation.x--;
	}
	function yr_plus_one(){
		cube.rotation.y++;
	}
	function yr_minus_one(){
		cube.rotation.y--;
	}
	function zr_plus_one(){
		cube.rotation.z++;
	}
	function zr_minus_one(){
		cube.rotation.z--;
	}
	</script>
	

</body>
</html>