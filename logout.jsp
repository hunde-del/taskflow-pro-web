<%@ include file="/includes/db.jsp" %>
<%
    session.invalidate();
    response.sendRedirect(request.getContextPath() + "/login.jsp");
%>
