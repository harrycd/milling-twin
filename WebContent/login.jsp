<%@page import="java.util.List"%>
<%@page import="uk.ac.cf.milling.utils.data.IoUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Login</title>
</head>
<body>
	<input type="text" value="username" disabled />
	<input type="text" value="password" disabled />
	<button onclick="window.location.href='sm?action=login'">Login</button>
</body>
</html>