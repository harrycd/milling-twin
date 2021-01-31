<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="css/bootstrap.min.css">

<title>Connect</title>
</head>
<body>
	<form action="sm">
		<select name="db-name">
			<c:forEach items="${databases}" var="dbName">
				<option value="${dbName}"> ${dbName} </option>
			</c:forEach>
		</select>
		<input name="action" type="hidden" value="load-database" />
		<button type="submit">Connect</button>
	</form>
	
	<script src="js/bootstrap.bundle.min.js" type="text/javascript"></script>
</body>
</html>