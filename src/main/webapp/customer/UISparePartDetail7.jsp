<%@ page contentType="text/html; charset=UTF-8" import="java.util.ArrayList,com.karas.garaga.model.*" %>
<%
    SparePart7 sparePart = null;

    {
        final ArrayList<SparePart7> spareParts = (ArrayList<SparePart7>) session.getAttribute("customerSpareParts");
        if (spareParts != null) {
            final long id = toId(request.getParameter("id"));

            for (final SparePart7 p : spareParts) {
                if (p.id() == id) {
                    sparePart = p;
                    break;
                }
            }
        }
    }

    if (sparePart == null) {
        response.sendRedirect("UISearchServiceSparePart7.jsp");
        return;
    }

    final int imageNo = toPositiveInt(request.getParameter("image")) % Math.max(sparePart.images().size(), 1);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Spare Part Detail | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Spare Part Detail</h1>
    <div class="toolbar">
        <a class="button" href="UISearchServiceSparePart7.jsp">Back</a>
    </div>
    <div class="detail-grid">
        <table class="details">
            <tr>
                <th>ID</th>
                <td><%= formatId(sparePart.id()) %></td>
            </tr>
            <tr>
                <th>Barcode</th>
                <td><%= cell(sparePart.barcode()) %></td>
            </tr>
            <tr>
                <th>Name</th>
                <td><%= escape(sparePart.name()) %></td>
            </tr>
            <tr>
                <th>Unit</th>
                <td><%= escape(sparePart.unit()) %></td>
            </tr>
            <tr>
                <th>Producer</th>
                <td><%= cell(sparePart.producer()) %></td>
            </tr>
            <tr>
                <th>Unit Price</th>
                <td><%= money(sparePart.unitPrice()) %> VND</td>
            </tr>
            <tr>
                <th>In Stock</th>
                <td><%= sparePart.stockQuantity() > 0 ? sparePart.stockQuantity() : "Out of stock" %></td>
            </tr>
            <tr>
                <th>Description</th>
                <td class="multiline"><%= cell(sparePart.description()) %></td>
            </tr>
        </table>
        <figure class="gallery card">
            <% if (sparePart.images().isEmpty()) { %>
                <div class="no-image">No image</div>
            <% } else { %>
                <img src="DoLoadSparePartImage7.jsp?id=<%= sparePart.id() %>&amp;ordinal=<%=
                        sparePart.images().get(imageNo).ordinal() %>"
                     alt="<%= escape(sparePart.name()) %> image <%= imageNo + 1 %>">
                <% if (sparePart.images().size() > 1) { %>
                    <figcaption>
                        <a class="button" href="UISparePartDetail7.jsp?id=<%= sparePart.id() %>&amp;image=<%=
                                (imageNo + sparePart.images().size() - 1) % sparePart.images().size() %>"
                           aria-label="Previous image">&lt;</a>
                        <span><%= imageNo + 1 %> / <%= sparePart.images().size() %></span>
                        <a class="button" href="UISparePartDetail7.jsp?id=<%= sparePart.id() %>&amp;image=<%=
                                (imageNo + 1) % sparePart.images().size() %>" aria-label="Next image">&gt;</a>
                    </figcaption>
                <% } %>
            <% } %>
        </figure>
    </div>
</main>
</body>
</html>
