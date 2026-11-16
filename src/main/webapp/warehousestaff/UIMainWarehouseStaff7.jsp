<%@ page contentType="text/html; charset=UTF-8" import="java.util.List,com.karas.garaga.model.WarehouseStaff7" %>
<%
    if (!(session.getAttribute("member") instanceof WarehouseStaff7 staff)) {
        response.sendRedirect("../member/UILogin7.jsp?err=timeout");
        return;
    }

    for (final String key : List.of("importSuppliers", "importSupplier", "importSpareParts", "importParts",
            "importInvoice")) {
        session.removeAttribute(key);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Warehouse Staff Home | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Warehouse Staff Home</h1>
    <section class="card home">
        <h2>Hello, <%= escape(staff.info().fullname()) %></h2>
        <p class="muted">ID: <%= formatId(staff.info().id()) %> · <%= escape(staff.info().email()) %></p>
        <div class="actions">
            <a class="button primary" href="UISelectSupplier7.jsp">Import Parts</a>
        </div>
    </section>
</main>
</body>
</html>
