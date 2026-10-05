<%-- auth.jsp  –  Include this at top of every protected page --%>
<%@ include file="/includes/db.jsp" %>
<%
    // Ensure user is logged in
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    int    userId   = (Integer) session.getAttribute("userId");
    String userFullName = (String) session.getAttribute("userFullName");
    String userEmail    = (String) session.getAttribute("userEmail");
    String userRole     = (String) session.getAttribute("userRole");
    String userTheme    = (String) session.getAttribute("userTheme");
    String userAvatar   = (String) session.getAttribute("userAvatar");
    if (userTheme == null) userTheme = "dark";
%>
