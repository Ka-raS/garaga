<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.time.ZoneId,java.time.format.DateTimeFormatter,com.karas.garaga.model.*" %>
<%
    if (!(session.getAttribute("member") instanceof WarehouseStaff7 staff)) {
        response.sendRedirect("../member/UILogin7.jsp?err=timeout");
        return;
    }

    final ImportInvoice7 invoice = (ImportInvoice7) session.getAttribute("importInvoice");
    if (invoice == null || invoice.id() == -1) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Print Import Invoice | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Print Import Invoice</h1>
    <div class="toolbar no-print">
        <a class="button" href="UIMainWarehouseStaff7.jsp">Home</a>
        <span class="spacer"></span>
        <button type="button" class="primary" onclick="window.print()">Print</button>
    </div>
    <article class="card invoice">
        <div class="invoice-header">
            <h2>IMPORT INVOICE</h2>
            <div>Date: <%= DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").withZone(ZoneId.of("Asia/Ho_Chi_Minh"))
                    .format(invoice.importedAt()) %></div>
            <div><strong>ID: <%= formatId(invoice.id()) %></strong></div>
        </div>
        <table class="details">
            <tr>
                <th>Supplier</th>
                <td><%= escape(invoice.supplier().name()) %></td>
                <th>Received By</th>
                <td><%= escape(invoice.warehouseStaff().info().fullname()) %></td>
            </tr>
            <tr>
                <th>Address</th>
                <td><%= escape(invoice.supplier().address()) %></td>
                <th>Staff ID</th>
                <td><%= formatId(invoice.warehouseStaff().info().id()) %></td>
            </tr>
            <tr>
                <th>Phone Number</th>
                <td><%= escape(invoice.supplier().phoneNumber()) %></td>
                <th>Phone Number</th>
                <td><%= escape(invoice.warehouseStaff().info().phoneNumber()) %></td>
            </tr>
            <tr>
                <th>Notes</th>
                <td colspan="3" class="multiline"><%= cell(invoice.notes()) %></td>
            </tr>
        </table>
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
            </tr>
            </thead>
            <tbody>
            <% for (int i = 0; i < invoice.importParts().size(); i++) {
                final ImportPartDetail7 part = invoice.importParts().get(i); %>
                <tr>
                    <td class="num"><%= i + 1 %></td>
                    <td class="code"><%= formatId(part.part().id()) %></td>
                    <td><%= escape(part.part().name()) %></td>
                    <td><%= escape(part.part().unit()) %></td>
                    <td class="multiline"><%= cell(part.notes()) %></td>
                    <td class="num"><%= part.quantity() %></td>
                    <td class="num"><%= money(part.importedUnitPrice()) %></td>
                    <td class="num"><%= money(part.amount()) %></td>
                </tr>
            <% } %>
            </tbody>
            <tfoot>
            <tr>
                <th colspan="7">Grand Total</th>
                <th class="num"><%= money(invoice.total()) %></th>
            </tr>
            </tfoot>
        </table>
        <div class="signatures">
            <div>
                <strong>Delivered By</strong>
                <small>(Signature)</small>
                <p>On behalf of <%= escape(invoice.supplier().name()) %></p>
            </div>
            <div>
                <strong>Received By</strong>
                <small>(Signature)</small>
                <p><%= escape(invoice.warehouseStaff().info().fullname()) %></p>
            </div>
        </div>
    </article>
</main>
<%= alert("Import invoice " + formatId(invoice.id()) + " has been saved") %>
</body>
</html>
