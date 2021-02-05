<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="css/bootstrap.min.css">

<title>Login</title>
</head>
<body>
	<div class = "container">
		<div class="row">
			<form action="sm">
				<div class="form-group mt-5">
					<select id="db-name" name="db-name" class="form-control"></select>
				</div>
				<div class="form-group mt-4">
					<label for="username">Username</label>
					<input id="username" type="text" class="form-control" placeholder="username" disabled />
					<label for="password" class="mt-2">Password</label>
					<input id="password" type="password" class="form-control" placeholder="password" disabled />
					<input name="action" type="hidden" value="load-database" />
				</div>
				<div class="mt-3">
					<button id="submit-login-form" type="submit" class="btn btn-dark" disabled>Connect</button>
				</div>
			</form>
		</div>
	</div>

	<script src="js/bootstrap.bundle.min.js" type="text/javascript"></script>
	<script type="text/javascript">
		window.addEventListener('load', function () {
			var xhr = new XMLHttpRequest();
			xhr.open("GET", "sm?action=get-database-list");
			xhr.onload = function() {
				if (xhr.status === 200) {
					let dbList = JSON.parse(xhr.responseText).dbList;
					let select = document.getElementById("db-name");
					
					select.add(new Option("Select Machine Database..."));
					for (const dbName of dbList){
						select.add(new Option(dbName));
					}

				} else {
					console.log("Could not retrieve list of databases.")
				}
			};
			xhr.send();
		})
		document.getElementById("db-name").onchange = function(){
			document.getElementById("submit-login-form").disabled = false;
		}
	</script>
</body>
</html>