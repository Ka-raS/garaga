<%@ page contentType="text/html; charset=UTF-8" import="java.util.ArrayList,com.karas.garaga.model.*" %>
<%
    Service7 service = null;

    {
        final ArrayList<Service7> services = (ArrayList<Service7>) session.getAttribute("customerServices");
        if (services != null) {
            final long id = toId(request.getParameter("id"));

            for (final Service7 s : services) {
                if (s.id() == id) {
                    service = s;
                    break;
                }
            }
        }
    }

    if (service == null) {
        response.sendRedirect("UISearchServiceSparePart7.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Service Detail | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Service Detail</h1>
    <div class="toolbar">
        <a class="button" href="UISearchServiceSparePart7.jsp">Back</a>
    </div>
    <table class="details">
        <tr>
            <th>ID</th>
            <td><%= formatId(service.id()) %></td>
        </tr>
        <tr>
            <th>Name</th>
            <td><%= escape(service.name()) %></td>
        </tr>
        <tr>
            <th>Price</th>
            <td><%= money(service.price()) %> VND</td>
        </tr>
        <tr>
            <th>Duration</th>
            <td>
                <% if (service.duration() == null) { %>
                    -
                <% } else { %>
                    <%= service.duration().toHours() <= 0 ? "" : (service.duration().toHours() + " h") %>
                    <%= service.duration().toMinutesPart() <= 0 ? "" : (service.duration().toMinutesPart() + " min") %>
                <% } %>
            </td>
        </tr>
        <tr>
            <th>Description</th>
            <td class="multiline"><%= cell(service.description()) %></td>
        </tr>
    </table>
</main>
</body>
</html>
