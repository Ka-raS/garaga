<%@ page contentType="text/html; charset=UTF-8" import="com.karas.garaga.model.Member7" %>
<%
    if ("POST".equals(request.getMethod())) {
        request.setAttribute("member", new Member7(request.getParameter("username"),
                request.getParameter("password")));
        request.getRequestDispatcher("DoLogin7.jsp").forward(request, response);
        return;
    }

    final String message = "fail".equals(request.getParameter("err")) ? "Invalid username or password"
            : "timeout".equals(request.getParameter("err")) ? "Please log in to continue"
            : "logout".equals(request.getParameter("msg")) ? "You have been logged out"
            : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Login</h1>
    <form method="post" action="UILogin7.jsp" class="card form narrow">
        <label>Username
            <input name="username" required autocomplete="username" autofocus>
        </label>
        <label>Password
            <input type="password" name="password" required autocomplete="current-password">
        </label>
        <div class="actions">
            <button type="submit" class="primary">Login</button>
        </div>
    </form>
</main>
<%= alert(message) %>
</body>
</html>
