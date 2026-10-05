<%@ include file="/includes/auth.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" import="java.util.*" %>
<%
String ctx = request.getContextPath();
/* ===== ANALYTICS PAGE ===== */
int comp=0, pend=0, overdue=0, total=0;
Connection con = null;
try { con = db();
    PreparedStatement ps = con.prepareStatement("SELECT status, COUNT(*) as c FROM tasks WHERE user_id=? AND is_deleted=0 GROUP BY status");
    ps.setInt(1,userId); ResultSet rs = ps.executeQuery();
    while(rs.next()){
        String st = rs.getString("status"); int c = rs.getInt("c");
        total += c;
        if(st.equals("completed")) comp=c;
        if(st.equals("pending")||st.equals("in_progress")) pend+=c;
    }
} catch(Exception e){} finally {if(con!=null)try{con.close();}catch(Exception e){}}
%>
<!DOCTYPE html>
<html lang="en" data-theme="<%=userTheme%>">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Analytics – TaskFlow Pro</title>
<link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body class="app-body">
<%@ include file="/includes/nav.jsp" %>
<div class="app-main">
  <header class="topbar">
    <button class="hamburger" onclick="toggleSidebar()"><span></span><span></span><span></span></button>
    <div class="topbar-title"><h2>Analytics</h2></div>
  </header>
  <div class="page-content">
    <div class="stats-grid">
      <div class="stat-card glass">
        <div class="stat-info"><p class="stat-label">Total Tasks</p><h3 class="stat-value"><%=total%></h3></div>
      </div>
      <div class="stat-card glass">
        <div class="stat-info"><p class="stat-label">Completed</p><h3 class="stat-value"><%=comp%></h3></div>
      </div>
      <div class="stat-card glass">
        <div class="stat-info"><p class="stat-label">Active</p><h3 class="stat-value"><%=pend%></h3></div>
      </div>
    </div>
    <div class="dash-card glass">
      <h4>Task Overview</h4>
      <div style="height:300px"><canvas id="ch"></canvas></div>
    </div>
  </div>
</div>
<script>
new Chart(document.getElementById('ch'), {
    type:'bar',
    data: { labels:['Completed','Active'], datasets:[{label:'Tasks', data:[<%=comp%>,<%=pend%>], backgroundColor:['#72EF36','#FFC107']}] },
    options: { responsive:true, maintainAspectRatio:false }
});
</script>
</body>
</html>
