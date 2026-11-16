<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.math.BigDecimal,java.util.ArrayList" %>
<%@ page import="com.karas.garaga.dao.SparePartDAO7,com.karas.garaga.model.*" %>
<%
    if (!(session.getAttribute("member") instanceof WarehouseStaff7 staff)) {
        response.sendRedirect("../member/UILogin7.jsp?err=timeout");
        return;
    }

    final ArrayList<ImportPartDetail7> parts = (ArrayList<ImportPartDetail7>) session.getAttribute("importParts");
    if (parts == null) {
        response.sendRedirect("UISelectSupplier7.jsp");
        return;
    }

    final String keyword = request.getParameter("keyword") == null ? null : request.getParameter("keyword").strip();
    final int pageNo = toPage(request.getParameter("page"));

    if (session.getAttribute("importSpareParts") == null
            || keyword != null && request.getParameter("page") == null) {
        session.setAttribute("importSpareParts", new ArrayList<SparePart7>());
    }

    final ArrayList<SparePart7> spareParts = (ArrayList<SparePart7>) session.getAttribute("importSpareParts");
    if (keyword != null && spareParts.size() <= pageNo * PAGE_SIZE) {
        spareParts.addAll(new SparePartDAO7().searchSpareParts(keyword,
                (pageNo + 1) * PAGE_SIZE - spareParts.size(), spareParts.size()));
    }

    String error = null;

    if ("confirm".equals(request.getParameter("action"))) {
        final ArrayList<ImportPartDetail7> updated = new ArrayList<>(parts);
        for (final SparePart7 sparePart : spareParts) {
            final String key = "-" + sparePart.id();
            final String quantity = request.getParameter("quantity" + key);
            final String unitPrice = request.getParameter("unitPrice" + key);
            if (quantity == null) {
                continue;
            }

            int index = -1;
            for (int i = 0; i < updated.size(); i++) {
                if (updated.get(i).part().id() == sparePart.id()) {
                    index = i;
                    break;
                }
            }

            if (quantity.isEmpty() && unitPrice.isEmpty()) {
                if (index >= 0) {
                    updated.remove(index);
                }
            } else if (quantity.isEmpty() || unitPrice.isEmpty()) {
                error = "Please fill out both quantity and unit price for " + sparePart.name();
                break;
            } else {
                final ImportPartDetail7 detail = new ImportPartDetail7(Integer.parseInt(quantity),
                        new BigDecimal(unitPrice).setScale(2), text(request.getParameter("notes" + key)), sparePart);
                if (index >= 0) {
                    updated.set(index, detail);
                } else {
                    updated.add(detail);
                }
            }
        }

        if (error == null) {
            session.setAttribute("importParts", updated);
            response.sendRedirect("UIImportInvoice7.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Import Invoice: Select Parts | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Import Invoice: Select Parts</h1>
    <div class="toolbar">
        <a class="button" href="UIImportInvoice7.jsp">Back</a>
        <span class="spacer"></span>
        <a class="button" href="UIAddNewPart7.jsp">Add New Spare Part</a>
        <button type="submit" form="bulk" name="action" value="confirm" class="primary confirm">Confirm</button>
    </div>
    <form method="get" action="UISelectParts7.jsp" class="search">
        <label for="keyword">Spare Part Name</label>
        <input id="keyword" name="keyword" value="<%= spareParts.isEmpty() ? "" : escape(keyword) %>"
               placeholder="<%= keyword != null && spareParts.isEmpty()
                       ? "No results" : "Leave empty to list all spare parts" %>" autofocus>
        <button type="submit" class="primary">Search</button>
    </form>
    <form method="post" id="bulk" action="UISelectParts7.jsp?page=<%= pageNo %><%= keyword == null ? ""
            : "&amp;keyword=" + URLEncoder.encode(keyword, StandardCharsets.UTF_8) %>">
        <% if (!spareParts.isEmpty()) { %>
            <table>
                <thead>
                <tr>
                    <th class="num">No.</th>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Unit</th>
                    <th>Producer</th>
                    <th>Quantity</th>
                    <th>Import Unit Price (VND)</th>
                    <th>Notes</th>
                </tr>
                </thead>
                <tbody>
                <% for (int i = 0; i < spareParts.size(); i++) {
                    final SparePart7 sparePart = spareParts.get(i);
                    final String key = "-" + sparePart.id();
                    final boolean posted = request.getParameter("quantity" + key) != null;
                    ImportPartDetail7 part = null;
                    for (final ImportPartDetail7 p : parts) {
                        if (p.part().id() == sparePart.id()) {
                            part = p;
                            break;
                        }
                    } %>
                    <tr id="row-<%= i %>" class="<%= part == null ? "" : "selected" %>">
                        <td class="num"><%= i + 1 %></td>
                        <td class="code"><%= formatId(sparePart.id()) %></td>
                        <td><%= escape(sparePart.name()) %></td>
                        <td><%= escape(sparePart.unit()) %></td>
                        <td><%= cell(sparePart.producer()) %></td>
                        <td>
                            <input type="number" name="quantity<%= key %>" class="quantity" min="1"
                                   max="2147483647" step="1" placeholder="-"
                                   value="<%= escape(posted ? request.getParameter("quantity" + key)
                                           : part == null ? null : String.valueOf(part.quantity())) %>">
                        </td>
                        <td>
                            <input type="number" name="unitPrice<%= key %>" min="0" max="9999999999999.99" step="0.01"
                                   placeholder="-"
                                   value="<%= escape(posted ? request.getParameter("unitPrice" + key)
                                           : part == null ? null : part.importedUnitPrice().toPlainString()) %>">
                        </td>
                        <td>
                            <input name="notes<%= key %>" class="notes"
                                   value="<%= escape(posted ? request.getParameter("notes" + key)
                                           : part == null ? null : part.notes()) %>">
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% if (keyword != null && spareParts.size() == (pageNo + 1) * PAGE_SIZE) { %>
                <div class="load-more">
                    <button type="submit" formnovalidate
                            formaction="UISelectParts7.jsp?page=<%= pageNo + 1 %>&amp;keyword=<%=
                            URLEncoder.encode(keyword, StandardCharsets.UTF_8) %>#row-<%= spareParts.size() %>">
                        Load More
                    </button>
                </div>
            <% } %>
        <% } %>
    </form>
</main>
<%= alert("added".equals(request.getParameter("msg")) ? "The new spare part has been added" : error) %>
</body>
</html>
