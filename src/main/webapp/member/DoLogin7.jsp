<%@ page import="com.karas.garaga.dao.MemberDAO7,com.karas.garaga.model.*" %>
<%
    if (!(request.getAttribute("member") instanceof Member7 login)) {
        response.sendRedirect("UILogin7.jsp");
        return;
    }

    final Member7 member = new MemberDAO7().checkLogin(login);
    if (member == null) {
        response.sendRedirect("UILogin7.jsp?err=fail");
    } else {
        request.changeSessionId();
        session.setAttribute("member", member);
        response.sendRedirect(member instanceof WarehouseStaff7
                ? "../warehousestaff/UIMainWarehouseStaff7.jsp" : "../customer/UIMainCustomer7.jsp");
    }
%>
