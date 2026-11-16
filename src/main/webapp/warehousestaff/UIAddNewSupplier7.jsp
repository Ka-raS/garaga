<%@ page contentType="text/html; charset=UTF-8" import="java.sql.SQLIntegrityConstraintViolationException" %>
<%@ page import="com.karas.garaga.dao.SupplierDAO7,com.karas.garaga.model.*" %>
<%
    if (!(session.getAttribute("member") instanceof WarehouseStaff7 staff)) {
        response.sendRedirect("../member/UILogin7.jsp?err=timeout");
        return;
    }

    String error = null;

    if ("POST".equals(request.getMethod())) {
        final Supplier7 supplier = new Supplier7(text(request.getParameter("name")),
                text(request.getParameter("address")), text(request.getParameter("phoneNumber")),
                text(request.getParameter("email")), text(request.getParameter("description")));

        try {
            new SupplierDAO7().addNewSupplier(supplier);
            session.setAttribute("importSupplier", supplier);
            response.sendRedirect("UIImportInvoice7.jsp");
            return;
        } catch (SQLIntegrityConstraintViolationException e) {
            error = e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add New Supplier | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Add New Supplier</h1>
    <div class="toolbar">
        <a class="button" href="UISelectSupplier7.jsp">Back</a>
    </div>
    <form method="post" action="UIAddNewSupplier7.jsp" class="card form medium">
        <div class="form-grid">
            <label><span class="required">Name</span>
                <input name="name" value="<%= escape(request.getParameter("name")) %>" required
                       pattern=".*\S.*" title="Please fill out this field" autofocus>
            </label>
            <label><span class="required">Phone Number</span>
                <input name="phoneNumber" value="<%= escape(request.getParameter("phoneNumber")) %>" required
                       inputmode="tel" pattern="0[0-9]{9}" title="10 digits starting with 0">
            </label>
            <label>Email
                <input type="email" name="email" value="<%= escape(request.getParameter("email")) %>">
            </label>
            <label><span class="required">Address</span>
                <input name="address" value="<%= escape(request.getParameter("address")) %>" required
                       pattern=".*\S.*" title="Please fill out this field">
            </label>
            <label class="wide">Description
                <textarea name="description" rows="3"><%= escape(request.getParameter("description")) %></textarea>
            </label>
        </div>
        <div class="actions">
            <button type="submit" class="primary">Confirm</button>
        </div>
    </form>
</main>
<%= alert(error) %>
</body>
</html>
