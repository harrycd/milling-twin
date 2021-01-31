<%@page import="java.util.List"%>
<%@page import="uk.ac.cf.milling.utils.data.IoUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="css/bootstrap.min.css">

<title>Login</title>
</head>
<body>
	<input type="text" class="form-control" placeholder="username" disabled />
	<input type="password" value="password" disabled />
	<button class="btn btn-primary" onclick="window.location.href='sm?action=login'">Login</button>
	<script src="js/bootstrap.bundle.min.js" type="text/javascript"></script>
</body>
</html>