<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.math.BigDecimal,java.time.Instant,java.util.ArrayList,java.util.Objects" %>
<%@ page import="com.karas.garaga.model.*" %>
<%
    if (!(session.getAttribute("member") instanceof WarehouseStaff7 staff)) {
        response.sendRedirect("../member/UILogin7.jsp?err=timeout");
        return;
    }

    if ("selectSupplier".equals(request.getParameter("action"))) {
        final ArrayList<Supplier7> suppliers = (ArrayList<Supplier7>) session.getAttribute("importSuppliers");
        final long supplierId = toId(request.getParameter("supplierId"));
        Supplier7 selectedSupplier = null;
        if (suppliers != null) {
            for (final Supplier7 s : suppliers) {
                if (s.id() == supplierId) {
                    selectedSupplier = s;
                    break;
                }
            }
        }

        if (selectedSupplier == null) {
            response.sendRedirect("UISelectSupplier7.jsp");
            return;
        }

        session.setAttribute("importSupplier", selectedSupplier);
    }

    final Supplier7 supplier = (Supplier7) session.getAttribute("importSupplier");
    if (supplier == null) {
        response.sendRedirect("UISelectSupplier7.jsp");
        return;
    }

    final ArrayList<ImportPartDetail7> parts = Objects.requireNonNullElse(
            (ArrayList<ImportPartDetail7>) session.getAttribute("importParts"), new ArrayList<>());
    if ("remove".equals(request.getParameter("action"))) {
        final long sparePartId = toId(request.getParameter("sparePartId"));
        parts.removeIf(part -> part.part().id() == sparePartId);
    }

    session.setAttribute("importParts", parts);
    if ("confirm".equals(request.getParameter("action")) && !parts.isEmpty()) {
        session.setAttribute("importInvoice", new ImportInvoice7(Instant.now(), text(request.getParameter("notes")),
                parts, staff, supplier));
        response.sendRedirect("DoSaveImportInvoice7.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Import Invoice | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Import Invoice</h1>
    <section class="card">
        <div class="section-header">
            <h2>Supplier</h2>
            <a class="button" href="UISelectSupplier7.jsp">Change Supplier</a>
        </div>
        <table class="details">
            <tr>
                <th>Name</th>
                <td><%= escape(supplier.name()) %></td>
            </tr>
            <tr>
                <th>Address</th>
                <td><%= escape(supplier.address()) %></td>
            </tr>
            <tr>
                <th>Phone Number</th>
                <td><%= escape(supplier.phoneNumber()) %></td>
            </tr>
            <tr>
                <th>Email</th>
                <td><%= cell(supplier.email()) %></td>
            </tr>
        </table>
    </section>
    <section class="card">
        <div class="section-header">
            <h2>Parts</h2>
            <a class="button primary" href="UISelectParts7.jsp">Select Parts</a>
        </div>
        <table>
            <thead>
            <tr>
                <th class="num">No.</th>
                <th>ID</th>
                <th>Part Name</th>
                <th>Unit</th>
                <th>Notes</th>
                <th class="num">Quantity</th>
                <th class="num">Unit Price (VND)</th>
                <th class="num">Amount (VND)</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <% for (int i = 0; i < parts.size(); i++) {
                final ImportPartDetail7 part = parts.get(i); %>
                <tr>
                    <td class="num"><%= i + 1 %></td>
                    <td class="code"><%= formatId(part.part().id()) %></td>
                    <td><%= escape(part.part().name()) %></td>
                    <td><%= escape(part.part().unit()) %></td>
                    <td class="multiline"><%= cell(part.notes()) %></td>
                    <td class="num"><%= part.quantity() %></td>
                    <td class="num"><%= money(part.importedUnitPrice()) %></td>
                    <td class="num"><%= money(part.amount()) %></td>
                    <td>
                        <form method="post" action="UIImportInvoice7.jsp">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="sparePartId" value="<%= part.part().id() %>">
                            <button type="submit" class="link danger">Remove</button>
                        </form>
                    </td>
                </tr>
            <% } %>
            <% if (parts.isEmpty()) { %>
                <tr>
                    <td colspan="9" class="empty">No spare parts yet. Click "Select Parts" to add some.</td>
                </tr>
            <% } %>
            </tbody>
            <tfoot>
            <tr>
                <th colspan="7">Grand Total</th>
                <th class="num"><%= money(parts.stream().map(ImportPartDetail7::amount)
                        .reduce(BigDecimal.ZERO, BigDecimal::add)) %></th>
                <th></th>
            </tr>
            </tfoot>
        </table>
    </section>
    <form method="post" action="UIImportInvoice7.jsp" class="form">
        <input type="hidden" name="action" value="confirm">
        <section class="card">
            <label>Notes
                <textarea name="notes" rows="2" placeholder="Optional"></textarea>
            </label>
        </section>
        <div class="actions">
            <button type="submit" class="primary" <%= parts.isEmpty() ? "disabled" : "" %>>Confirm</button>
        </div>
    </form>
</main>
<%= alert("save".equals(request.getParameter("err")) ? "The invoice could not be saved. Please try again." : null) %>
</body>
</html>
