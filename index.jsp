<%@ include file="/includes/db.jsp" %>
<%
    if (session.getAttribute("userId") != null) {
        response.sendRedirect(request.getContextPath() + "/app/dashboard.jsp");
        return;
    }
    response.sendRedirect(request.getContextPath() + "/login.jsp");
%>
