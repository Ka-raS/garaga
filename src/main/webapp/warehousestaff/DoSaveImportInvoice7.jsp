<%@ page import="java.sql.SQLException" %>
<%@ page import="com.karas.garaga.dao.ImportInvoiceDAO7,com.karas.garaga.model.*" %>
<%
    if (!(session.getAttribute("member") instanceof WarehouseStaff7 staff)) {
        response.sendRedirect("../member/UILogin7.jsp?err=timeout");
        return;
    }

    final ImportInvoice7 invoice = (ImportInvoice7) session.getAttribute("importInvoice");
    if (invoice == null || invoice.id() != -1) {
        response.sendRedirect("UIImportInvoice7.jsp");
        return;
    }

    try {
        new ImportInvoiceDAO7().saveInvoice(invoice);
    } catch (SQLException e) {
        application.log("Cannot save the import invoice", e);
        session.removeAttribute("importInvoice");
        response.sendRedirect("UIImportInvoice7.jsp?err=save");
        return;
    }

    session.removeAttribute("importSupplier");
    session.removeAttribute("importParts");
    session.removeAttribute("importSpareParts");
    response.sendRedirect("UIPrintImportInvoice7.jsp");
%>
