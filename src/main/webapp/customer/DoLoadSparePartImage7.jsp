<%@ page session="false" import="com.karas.garaga.dao.SparePartImageDAO7,com.karas.garaga.model.SparePartImage7" %>
<%@ include file="/WEB-INF/jspf/helpers.jspf" %>
<%
    final SparePartImage7 image = new SparePartImageDAO7().getImage(toId(request.getParameter("id")),
            toPositiveInt(request.getParameter("ordinal")));
    if (image == null) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    response.setCharacterEncoding((String) null);
    response.setContentType(image.contentType());
    response.setContentLength(image.data().length);
    response.setHeader("Cache-Control", "private, max-age=3600");
    response.setHeader("X-Content-Type-Options", "nosniff");
    response.setHeader("Content-Security-Policy", "sandbox");
    response.getOutputStream().write(image.data());
%>
