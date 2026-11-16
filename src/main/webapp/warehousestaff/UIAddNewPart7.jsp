<%@ page contentType="text/html; charset=UTF-8" import="java.io.InputStream,java.math.BigDecimal" %>
<%@ page import="java.sql.SQLIntegrityConstraintViolationException,java.util.ArrayList" %>
<%@ page import="java.util.List,jakarta.servlet.http.Part" %>
<%@ page import="com.karas.garaga.dao.SparePartDAO7,com.karas.garaga.model.*" %>
<%
    if (!(session.getAttribute("member") instanceof WarehouseStaff7 staff)) {
        response.sendRedirect("../member/UILogin7.jsp?err=timeout");
        return;
    }

    String error = null;

    if ("POST".equals(request.getMethod())) {
        final ArrayList<SparePartImage7> images = new ArrayList<>();

        try {
            for (final Part file : request.getParts()) {
                if (!"images".equals(file.getName()) || file.getSize() == 0) {
                    continue;
                }

                if (!List.of("image/jpeg", "image/png", "image/webp", "image/gif").contains(file.getContentType())) {
                    error = "Image " + file.getSubmittedFileName() + " must be a JPEG, PNG, WebP or GIF file";
                    break;
                }

                try (InputStream data = file.getInputStream()) {
                    images.add(new SparePartImage7(images.size(), file.getContentType(), data.readAllBytes()));
                }
            }
        } catch (IllegalStateException e) {
            error = "Each image must be at most 5 MB and all images together at most 20 MB";
        }

        if (error == null) {
            final SparePart7 part = new SparePart7(text(request.getParameter("barcode")),
                    text(request.getParameter("name")), text(request.getParameter("unit")),
                    text(request.getParameter("producer")),
                    new BigDecimal(request.getParameter("unitPrice")).setScale(2),
                    text(request.getParameter("description")), images);

            try {
                new SparePartDAO7().addNewPart(part);
                images.clear();
                session.setAttribute("importSpareParts", new ArrayList<>(List.of(part)));
                response.sendRedirect("UISelectParts7.jsp?msg=added");
                return;
            } catch (SQLIntegrityConstraintViolationException e) {
                error = e.getMessage();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add New Spare Part | Garaga</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<main>
    <h1>Add New Spare Part</h1>
    <div class="toolbar">
        <a class="button" href="UISelectParts7.jsp">Back</a>
    </div>
    <form method="post" action="UIAddNewPart7.jsp"
          enctype="multipart/form-data" class="card form medium">
        <div class="form-grid">
            <label class="wide"><span class="required">Name</span>
                <input name="name" value="<%= escape(request.getParameter("name")) %>" placeholder="Spare part name"
                       required pattern=".*\S.*" title="Please fill out this field" autofocus>
            </label>
            <label><span class="required">Unit</span>
                <input name="unit" value="<%= escape(request.getParameter("unit")) %>"
                       placeholder="piece, set, bottle..." required pattern=".*\S.*" title="Please fill out this field">
            </label>
            <label><span class="required">Unit Price (VND)</span>
                <input type="number" name="unitPrice" min="0" max="9999999999999.99" step="0.01"
                       value="<%= escape(request.getParameter("unitPrice")) %>" required>
                <span class="hint">Selling price to customers</span>
            </label>
            <label>Barcode
                <input name="barcode" value="<%= escape(request.getParameter("barcode")) %>">
            </label>
            <label>Producer
                <input name="producer" value="<%= escape(request.getParameter("producer")) %>">
            </label>
            <label class="wide">Description
                <textarea name="description" rows="3"><%= escape(request.getParameter("description")) %></textarea>
            </label>
            <label class="wide">Images
                <input type="file" name="images" accept="image/jpeg,image/png,image/webp,image/gif" multiple>
                <span class="hint"><%= error == null
                        ? "JPEG, PNG, WebP or GIF, at most 5 MB each, shown in the selected order"
                        : "Please select the images again" %></span>
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
