<%@page import="java.util.List"%>
<%@page import="uk.ac.cf.milling.utils.IoUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Login</title>
</head>
<body>
	
	<select id="db-connect-name">
		<% String folderPath = "C:\\Users\\Alexo\\OneDrive\\PhD\\Eclipse 2018-09\\MillingVM"; %>
		<% String folderPathRelaxed = "C:%5C%5CUsers%5C%5CAlexo%5C%5COneDrive%5C%5CPhD%5C%5CEclipse%202018-09%5C%5CMillingVM"; %>
		<% //String folderPath = System.getProperty("user.dir") + "\\Database"; %>
		<% List<String> dbNames = IoUtils.getFileNames(folderPath, ".db"); %>
		<% for (String dbName : dbNames) { %>
		<option value=<%out.print(folderPathRelaxed + "%5C%5C" + dbName);%>> 
			<% out.print(dbName); %>
		</option>
		<% } %>
	</select>
	<button id="db-connect-button" onclick="dbConnect()">Connect</button>
	<script type="text/javascript">
		function dbConnect(){
			var dbCombobox = document.getElementById("db-connect-name");
			var dbFilePath = dbCombobox.options[dbCombobox.selectedIndex].value;
			
			var xhr = new XMLHttpRequest();
			var dbFilePath = document.getElementById('db-connect-name').value;
			xhr.open('GET', 'sm?action=login&dbFilePath=' + dbFilePath);
			xhr.onload = function() {
				if (xhr.status === 200) {
					window.location.replace("home.jsp");
				} else {
					alert('Login failed.  Returned status: ' + xhr.status);
				}
			};
			xhr.send();
		}
	</script>

</body>
</html>