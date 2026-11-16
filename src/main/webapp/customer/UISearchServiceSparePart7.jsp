<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.ArrayList,com.karas.garaga.dao.*,com.karas.garaga.model.*" %>
<%
    final String keyword = text(request.getParameter("keyword"));
    final int pageNo = toPage(request.getParameter("page"));

    if (session.getAttribute("customerServices") == null
            || keyword != null && request.getParameter("page") == null) {
        session.setAttribute("customerServices", new ArrayList<Service7>());
        session.setAttribute("customerSpareParts", new ArrayList<SparePart7>());
    }

    final ArrayList<Service7> services = (ArrayList<Service7>) session.getAttribute("customerServices");
    final ArrayList<SparePart7> spareParts = (ArrayList<SparePart7>) session.getAttribute("customerSpareParts");

    if (keyword != null && services.size() + spareParts.size() <= pageNo * PAGE_SIZE) {
        if (spareParts.isEmpty()) {
            services.addAll(new ServiceDAO7().searchServices(keyword,
                    (pageNo + 1) * PAGE_SIZE - services.size(), services.size()));
        }

        spareParts.addAll(new SparePartDAO7().searchSpareParts(keyword,
                (pageNo + 1) * PAGE_SIZE - services.size() - spareParts.size(), spareParts.size()));
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Search Service &amp; Spare Parts | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Search Service &amp; Spare Parts</h1>
    <div class="toolbar">
        <a class="button" href="UIMainCustomer7.jsp">Back</a>
    </div>
    <form method="get" action="UISearchServiceSparePart7.jsp" class="search">
        <label for="keyword">Keyword</label>
        <input id="keyword" name="keyword"
               value="<%= services.isEmpty() && spareParts.isEmpty() ? "" : escape(keyword) %>"
               placeholder="<%= keyword != null && services.isEmpty() && spareParts.isEmpty()
                       ? "No results" : "Service or spare part name" %>" required autofocus>
        <button type="submit" class="primary">Search</button>
    </form>
    <% if (!services.isEmpty() || !spareParts.isEmpty()) { %>
        <table>
            <thead>
            <tr>
                <th class="num">No.</th>
                <th>Name</th>
                <th>Type</th>
                <th class="num">Price (VND)</th>
            </tr>
            </thead>
            <tbody>
            <% for (int i = 0; i < services.size(); i++) { %>
                <tr id="row-<%= i %>">
                    <td class="num"><%= i + 1 %></td>
                    <td>
                        <a href="UIServiceDetail7.jsp?id=<%= services.get(i).id() %>">
                            <%= escape(services.get(i).name()) %>
                        </a>
                    </td>
                    <td>Service</td>
                    <td class="num"><%= money(services.get(i).price()) %></td>
                </tr>
            <% } %>
            <% for (int i = 0; i < spareParts.size(); i++) { %>
                <tr id="row-<%= services.size() + i %>">
                    <td class="num"><%= services.size() + i + 1 %></td>
                    <td>
                        <a href="UISparePartDetail7.jsp?id=<%= spareParts.get(i).id() %>">
                            <%= escape(spareParts.get(i).name()) %>
                        </a>
                    </td>
                    <td>Spare Part</td>
                    <td class="num"><%= money(spareParts.get(i).unitPrice()) %></td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% if (keyword != null && services.size() + spareParts.size() == (pageNo + 1) * PAGE_SIZE) { %>
            <div class="load-more">
                <a class="button" href="UISearchServiceSparePart7.jsp?page=<%= pageNo + 1 %>&amp;keyword=<%=
                        URLEncoder.encode(keyword, StandardCharsets.UTF_8) %>#row-<%=
                        services.size() + spareParts.size() %>">Load More</a>
            </div>
        <% } %>
    <% } %>
</main>
</body>
</html>
