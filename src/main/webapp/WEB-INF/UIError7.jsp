<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<%
    final boolean notFound = pageContext.getErrorData().getStatusCode() == 404;
    final String title = notFound ? "Page Not Found" : "Something Went Wrong";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= title %> | Garaga</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1><%= title %></h1>
    <section class="card home">
        <p><%= notFound ? "The page you are looking for does not exist."
                : "The system could not complete your request. Please try again later." %></p>
        <div class="actions">
            <a class="button primary" href="<%= request.getContextPath() %>/">Go to Home</a>
        </div>
    </section>
</main>
</body>
</html>
