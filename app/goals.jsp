<%@ include file="/includes/auth.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" import="java.util.*" %>
<%
String ctx = request.getContextPath();
/* ===== GOALS PAGE ===== */
String msg="",msgType="";
String action = request.getParameter("action");

Connection con = null;
Map<String,String> editGoal = new LinkedHashMap<>();
int editId = 0;
List<Map<String,String>> goals = new ArrayList<>();
try { con = db();

if ("POST".equals(request.getMethod())) {
    String act = request.getParameter("act");
    if ("save".equals(act)) {
        int gid=0; try{gid=Integer.parseInt(request.getParameter("goal_id"));}catch(Exception e){}
        String name   = request.getParameter("goal_name");
        String desc   = request.getParameter("description");
        String gtype  = request.getParameter("goal_type");
        String target = request.getParameter("target_date");
        int prog=0; try{prog=Integer.parseInt(request.getParameter("progress"));}catch(Exception e){}
        String gstat  = request.getParameter("status");

        if(name==null||name.trim().isEmpty()){msg="Goal name is required.";msgType="error";}
        else if(gid==0) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO goals(user_id,goal_name,description,goal_type,target_date,progress,status) VALUES(?,?,?,?,?,?,?)");
            ps.setInt(1,userId); ps.setString(2,name.trim()); ps.setString(3,desc);
            ps.setString(4,gtype!=null?gtype:"weekly");
            ps.setObject(5,(target!=null&&!target.isEmpty())?java.sql.Date.valueOf(target):null);
            ps.setInt(6,prog); ps.setString(7,gstat!=null?gstat:"active");
            ps.executeUpdate();
            msg="Goal created!"; msgType="success";
        } else {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE goals SET goal_name=?,description=?,goal_type=?,target_date=?,progress=?,status=? WHERE id=? AND user_id=?");
            ps.setString(1,name.trim()); ps.setString(2,desc); ps.setString(3,gtype!=null?gtype:"weekly");
            ps.setObject(4,(target!=null&&!target.isEmpty())?java.sql.Date.valueOf(target):null);
            ps.setInt(5,prog); ps.setString(6,gstat!=null?gstat:"active");
            ps.setInt(7,gid); ps.setInt(8,userId);
            ps.executeUpdate();
            msg="Goal updated!"; msgType="success";
        }
        action=null;
    } else if("delete".equals(act)) {
        int gid=Integer.parseInt(request.getParameter("goal_id"));
        con.prepareStatement("DELETE FROM goals WHERE id="+gid+" AND user_id="+userId).executeUpdate();
        msg="Goal deleted."; msgType="success";
    }
}

/* Load edit goal */
if("edit".equals(action)&&request.getParameter("id")!=null) {
    try{editId=Integer.parseInt(request.getParameter("id"));}catch(Exception e){}
    if(editId>0){
        PreparedStatement ps=con.prepareStatement("SELECT * FROM goals WHERE id=? AND user_id=?");
        ps.setInt(1,editId);ps.setInt(2,userId);
        ResultSet er=ps.executeQuery();
        if(er.next()){
            editGoal.put("id",er.getString("id")); editGoal.put("goal_name",er.getString("goal_name"));
            editGoal.put("description",er.getString("description")!=null?er.getString("description"):"");
            editGoal.put("goal_type",er.getString("goal_type")); editGoal.put("status",er.getString("status"));
            editGoal.put("progress",er.getString("progress"));
            editGoal.put("target_date",er.getString("target_date")!=null?er.getString("target_date"):"");
        } else editId=0;
    }
}

/* Load all goals */
PreparedStatement gps = con.prepareStatement("SELECT * FROM goals WHERE user_id=? ORDER BY created_at DESC");
gps.setInt(1,userId);
ResultSet gr = gps.executeQuery();
while(gr.next()){
    Map<String,String> m=new LinkedHashMap<>();
    m.put("id",gr.getString("id")); m.put("goal_name",gr.getString("goal_name"));
    m.put("description",gr.getString("description")!=null?gr.getString("description"):"");
    m.put("goal_type",gr.getString("goal_type")); m.put("status",gr.getString("status"));
    m.put("progress",gr.getString("progress")); m.put("target_date",gr.getString("target_date")!=null?gr.getString("target_date"):"");
    goals.add(m);
}
} catch(Exception ex){msg=h(ex.getMessage());msgType="error";}
finally{if(con!=null)try{con.close();}catch(Exception e){}}

boolean showForm = "new".equals(action)||editId>0;
%>
<!DOCTYPE html>
<html lang="en" data-theme="<%=userTheme%>">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Goals – TaskFlow Pro</title>
<link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body class="app-body">
<%@ include file="/includes/nav.jsp" %>
<div class="app-main">
  <header class="topbar">
    <button class="hamburger" onclick="toggleSidebar()"><span></span><span></span><span></span></button>
    <div class="topbar-title"><h2>Goals</h2></div>
    <div class="topbar-actions"><a href="?action=new" class="btn btn-primary btn-sm">＋ New Goal</a></div>
  </header>
  <div class="page-content">
    <% if(!msg.isEmpty()){%><div class="alert alert-<%=msgType%>"><%=msg%></div><%}%>

    <% if(showForm) { %>
    <div class="form-panel glass animate-up">
      <div class="form-panel-header">
        <h3><%=editId>0?"Edit Goal":"New Goal"%></h3>
        <a href="goals.jsp" class="btn-icon-close">✕</a>
      </div>
      <form method="POST">
        <input type="hidden" name="act" value="save">
        <input type="hidden" name="goal_id" value="<%=editId>0?editId:0%>">
        <div class="form-grid-2">
          <div class="form-group full-width">
            <label>Goal Name *</label>
            <input type="text" name="goal_name" value="<%=editId>0?h(editGoal.get("goal_name")):""%>" placeholder="What do you want to achieve?" required class="form-control">
          </div>
          <div class="form-group full-width">
            <label>Description</label>
            <textarea name="description" rows="2" class="form-control" placeholder="Describe your goal..."><%=editId>0?h(editGoal.get("description")):""%></textarea>
          </div>
          <div class="form-group">
            <label>Goal Type</label>
            <select name="goal_type" class="form-control">
              <% for(String gt:new String[]{"daily","weekly","monthly","annual"}) {%>
              <option value="<%=gt%>" <%=(editId>0&&gt.equals(editGoal.get("goal_type")))?"selected":""%>><%=gt.substring(0,1).toUpperCase()+gt.substring(1)%></option>
              <%}%>
            </select>
          </div>
          <div class="form-group">
            <label>Status</label>
            <select name="status" class="form-control">
              <% for(String gs:new String[]{"active","completed","cancelled"}) {%>
              <option value="<%=gs%>" <%=(editId>0&&gs.equals(editGoal.get("status")))?"selected":""%>><%=gs.substring(0,1).toUpperCase()+gs.substring(1)%></option>
              <%}%>
            </select>
          </div>
          <div class="form-group">
            <label>Target Date</label>
            <input type="date" name="target_date" value="<%=editId>0?h(editGoal.get("target_date")):""%>" class="form-control">
          </div>
          <div class="form-group">
            <label>Progress: <span id="progVal"><%=editId>0?editGoal.get("progress"):"0"%>%</span></label>
            <input type="range" name="progress" min="0" max="100" value="<%=editId>0?editGoal.get("progress"):"0"%>" class="form-range" oninput="document.getElementById('progVal').textContent=this.value+'%'">
          </div>
        </div>
        <div class="form-actions">
          <a href="goals.jsp" class="btn btn-ghost">Cancel</a>
          <button type="submit" class="btn btn-primary"><%=editId>0?"Update Goal":"Create Goal"%></button>
        </div>
      </form>
    </div>
    <% } %>

    <div class="goals-grid">
      <% if(goals.isEmpty()) { %>
      <div class="empty-state glass">
        <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" opacity="0.3"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/></svg>
        <h3>No goals yet</h3><p>Set your first goal and start achieving!</p>
        <a href="?action=new" class="btn btn-primary">＋ Set a Goal</a>
      </div>
      <% } else { for(Map<String,String> g:goals) {
         int prog=0; try{prog=Integer.parseInt(g.get("progress"));}catch(Exception e){}
         String gtype=g.get("goal_type");
      %>
      <div class="goal-card glass animate-up">
        <div class="goal-card-header">
          <span class="goal-type-badge <%=gtype%>"><%=gtype%></span>
          <span class="status-badge <%=g.get("status")%>"><%=g.get("status")%></span>
        </div>
        <h4 class="goal-name"><%=h(g.get("goal_name"))%></h4>
        <% if(!g.get("description").isEmpty()){%><p class="goal-desc"><%=h(g.get("description"))%></p><%}%>
        <% if(!g.get("target_date").isEmpty()){%><p class="goal-date">🎯 Target: <%=g.get("target_date")%></p><%}%>
        <div class="progress-wrap">
          <div class="progress-label"><span>Progress</span><span><%=prog%>%</span></div>
          <div class="progress-bar"><div class="progress-fill" style="width:<%=prog%>%"></div></div>
        </div>
        <div class="task-card-actions">
          <a href="?action=edit&id=<%=g.get("id")%>" class="btn btn-ghost btn-xs">Edit</a>
          <form method="POST" style="display:inline" onsubmit="return confirm('Delete this goal?')">
            <input type="hidden" name="act" value="delete">
            <input type="hidden" name="goal_id" value="<%=g.get("id")%>">
            <button type="submit" class="btn btn-danger btn-xs">Delete</button>
          </form>
        </div>
      </div>
      <% } } %>
    </div>
  </div>
</div>
<script src="<%=ctx%>/assets/js/feather.min.js"></script>
<script src="<%=ctx%>/assets/js/app.js"></script>
<script>if(window.feather)feather.replace();</script>
</body>
</html>
