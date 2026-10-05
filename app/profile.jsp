<%@ include file="/includes/auth.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
String ctx = request.getContextPath();
String msg="", msgType="";
if("POST".equals(request.getMethod())){
    String n=request.getParameter("name");
    if(n!=null && !n.isEmpty()){
        Connection con=null;
        try{ con=db();
             PreparedStatement ps=con.prepareStatement("UPDATE users SET full_name=? WHERE id=?");
             ps.setString(1,n); ps.setInt(2,userId); ps.executeUpdate();
             session.setAttribute("userFullName",n);
             msg="Profile updated."; msgType="success";
        }catch(Exception e){msg=e.getMessage();msgType="error";}
        finally{if(con!=null)try{con.close();}catch(Exception e){}}
    }
}
%>
<!DOCTYPE html>
<html lang="en" data-theme="<%=userTheme%>">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Profile – TaskFlow Pro</title>
<link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
</head>
<body class="app-body">
<%@ include file="/includes/nav.jsp" %>
<div class="app-main">
  <header class="topbar">
    <button class="hamburger" onclick="toggleSidebar()"><span></span><span></span><span></span></button>
    <div class="topbar-title"><h2>Profile</h2></div>
  </header>
  <div class="page-content">
    <% if(!msg.isEmpty()){%><div class="alert alert-<%=msgType%>"><%=msg%></div><%}%>
    <div class="form-panel glass">
      <form method="POST">
        <div class="form-group"><label>Full Name</label><input type="text" name="name" value="<%=h(userFullName)%>" class="form-control"></div>
        <div class="form-group"><label>Email</label><input type="text" value="<%=h(userEmail)%>" disabled class="form-control"></div>
        <button class="btn btn-primary">Save Profile</button>
      </form>
    </div>
  </div>
</div>
</body>
</html>
