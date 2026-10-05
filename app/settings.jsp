<%@ include file="/includes/auth.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
String ctx = request.getContextPath();
String msg="", msgType="";
if("POST".equals(request.getMethod())){
    String t=request.getParameter("theme");
    if(t!=null && !t.isEmpty()){
        Connection con=null;
        try{ con=db();
             PreparedStatement ps=con.prepareStatement("UPDATE users SET theme_pref=? WHERE id=?");
             ps.setString(1,t); ps.setInt(2,userId); ps.executeUpdate();
             session.setAttribute("userTheme",t);
             userTheme=t;
             msg="Settings saved."; msgType="success";
        }catch(Exception e){msg=e.getMessage();msgType="error";}
        finally{if(con!=null)try{con.close();}catch(Exception e){}}
    }
}
%>
<!DOCTYPE html>
<html lang="en" data-theme="<%=userTheme%>">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Settings – TaskFlow Pro</title>
<link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
</head>
<body class="app-body">
<%@ include file="/includes/nav.jsp" %>
<div class="app-main">
  <header class="topbar">
    <button class="hamburger" onclick="toggleSidebar()"><span></span><span></span><span></span></button>
    <div class="topbar-title"><h2>Settings</h2></div>
  </header>
  <div class="page-content">
    <% if(!msg.isEmpty()){%><div class="alert alert-<%=msgType%>"><%=msg%></div><%}%>
    <div class="form-panel glass">
      <form method="POST">
        <div class="form-group"><label>Theme</label>
          <select name="theme" class="form-control">
            <option value="dark" <%="dark".equals(userTheme)?"selected":""%>>Dark Mode</option>
            <option value="light" <%="light".equals(userTheme)?"selected":""%>>Light Mode</option>
          </select>
        </div>
        <button class="btn btn-primary">Save Settings</button>
      </form>
    </div>
  </div>
</div>
</body>
</html>
