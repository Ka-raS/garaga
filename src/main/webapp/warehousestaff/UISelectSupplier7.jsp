<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.ArrayList,com.karas.garaga.dao.SupplierDAO7,com.karas.garaga.model.*" %>
<%
    if (!(session.getAttribute("member") instanceof WarehouseStaff7 staff)) {
        response.sendRedirect("../member/UILogin7.jsp?err=timeout");
        return;
    }

    final String keyword = request.getParameter("keyword") == null ? null : request.getParameter("keyword").strip();
    final int pageNo = toPage(request.getParameter("page"));

    if (session.getAttribute("importSuppliers") == null
            || keyword != null && request.getParameter("page") == null) {
        session.setAttribute("importSuppliers", new ArrayList<Supplier7>());
    }

    final ArrayList<Supplier7> suppliers = (ArrayList<Supplier7>) session.getAttribute("importSuppliers");
    if (keyword != null && suppliers.size() <= pageNo * PAGE_SIZE) {
        suppliers.addAll(new SupplierDAO7().searchSuppliers(keyword,
                (pageNo + 1) * PAGE_SIZE - suppliers.size(), suppliers.size()));
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Import Invoice: Select Supplier | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Import Invoice: Select Supplier</h1>
    <div class="toolbar">
        <a class="button" href="UIMainWarehouseStaff7.jsp">Back</a>
        <span class="spacer"></span>
        <a class="button" href="UIAddNewSupplier7.jsp">Add New Supplier</a>
    </div>
    <form method="get" action="UISelectSupplier7.jsp" class="search">
        <label for="keyword">Supplier Name</label>
        <input id="keyword" name="keyword" value="<%= suppliers.isEmpty() ? "" : escape(keyword) %>"
               placeholder="<%= keyword != null && suppliers.isEmpty()
                       ? "No results" : "Leave empty to list all suppliers" %>" autofocus>
        <button type="submit" class="primary">Search</button>
    </form>
    <% if (!suppliers.isEmpty()) { %>
        <table>
            <thead>
            <tr>
                <th class="num">No.</th>
                <th>ID</th>
                <th>Name</th>
                <th>Phone Number</th>
            </tr>
            </thead>
            <tbody>
            <% for (int i = 0; i < suppliers.size(); i++) { %>
                <tr id="row-<%= i %>">
                    <td class="num"><%= i + 1 %></td>
                    <td class="code"><%= formatId(suppliers.get(i).id()) %></td>
                    <td>
                        <a href="UIImportInvoice7.jsp?action=selectSupplier&amp;supplierId=<%=
                                suppliers.get(i).id() %>">
                            <%= escape(suppliers.get(i).name()) %>
                        </a>
                    </td>
                    <td><%= escape(suppliers.get(i).phoneNumber()) %></td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% if (keyword != null && suppliers.size() == (pageNo + 1) * PAGE_SIZE) { %>
            <div class="load-more">
                <a class="button" href="UISelectSupplier7.jsp?page=<%= pageNo + 1 %>&amp;keyword=<%=
                        URLEncoder.encode(keyword, StandardCharsets.UTF_8) %>#row-<%= suppliers.size() %>">Load More</a>
            </div>
        <% } %>
    <% } %>
</main>
</body>
</html>
