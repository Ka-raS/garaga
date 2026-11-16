<%@ page import="com.karas.garaga.model.WarehouseStaff7" %>
<%
    response.sendRedirect(session.getAttribute("member") instanceof WarehouseStaff7
            ? "warehousestaff/UIMainWarehouseStaff7.jsp"
            : "customer/UIMainCustomer7.jsp");
%>
