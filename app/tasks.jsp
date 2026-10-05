<%@ include file="/includes/auth.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" import="java.util.*" %>
<%
/* ===== TASKS PAGE – list, add, edit, delete, restore, filter ===== */
String action   = request.getParameter("action");   // new|edit|delete|restore|trash
String msg = "", msgType = "";
int editId = 0;
Map<String,String> editTask = new LinkedHashMap<>();

Connection con = null;
boolean showTrash = "trash".equals(action);
String fStatus = request.getParameter("status") != null ? request.getParameter("status") : "";
String fPriority = request.getParameter("priority") != null ? request.getParameter("priority") : "";
String fCat = request.getParameter("cat") != null ? request.getParameter("cat") : "";
String fSearch = request.getParameter("q") != null ? request.getParameter("q") : "";
String fSort = request.getParameter("sort") != null ? request.getParameter("sort") : "newest";
List<Map<String,String>> cats = new ArrayList<>();
List<Map<String,String>> tasks = new ArrayList<>();
try { con = db();

/* ---- Handle POST actions ---- */
if ("POST".equals(request.getMethod())) {
    String act = request.getParameter("act");

    if ("save".equals(act)) { // CREATE or UPDATE
        int tid = 0;
        try { tid = Integer.parseInt(request.getParameter("task_id")); } catch(Exception e){}
        String title  = request.getParameter("title");
        String desc   = request.getParameter("description");
        String prio   = request.getParameter("priority");
        String stat   = request.getParameter("status");
        String due    = request.getParameter("due_date");
        String start  = request.getParameter("start_date");
        String catId  = request.getParameter("category_id");
        String est    = request.getParameter("estimated_time");
        String notes  = request.getParameter("notes");

        if (title==null||title.trim().isEmpty()) {
            msg="Task title is required."; msgType="error";
        } else {
            if (tid == 0) { // INSERT
                PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO tasks(user_id,category_id,title,description,priority,status,due_date,start_date,estimated_time,notes) VALUES(?,?,?,?,?,?,?,?,?,?)");
                ins.setInt(1, userId);
                ins.setObject(2, (catId!=null&&!catId.isEmpty()) ? Integer.parseInt(catId) : null);
                ins.setString(3, title.trim());
                ins.setString(4, desc);
                ins.setString(5, prio!=null?prio:"medium");
                ins.setString(6, stat!=null?stat:"pending");
                ins.setObject(7, (due!=null&&!due.isEmpty()) ? java.sql.Date.valueOf(due) : null);
                ins.setObject(8, (start!=null&&!start.isEmpty()) ? java.sql.Date.valueOf(start) : null);
                ins.setObject(9, (est!=null&&!est.isEmpty()) ? Integer.parseInt(est) : null);
                ins.setString(10, notes);
                ins.executeUpdate();
                // Log
                PreparedStatement log = con.prepareStatement("INSERT INTO activity_logs(user_id,action,entity_type,ip_address) VALUES(?,?,?,?)");
                log.setInt(1,userId); log.setString(2,"Created task: "+title.trim()); log.setString(3,"task"); log.setString(4,request.getRemoteAddr());
                log.executeUpdate();
                msg="Task created successfully!"; msgType="success";
            } else { // UPDATE
                PreparedStatement upd = con.prepareStatement(
                    "UPDATE tasks SET category_id=?,title=?,description=?,priority=?,status=?,due_date=?,start_date=?,estimated_time=?,notes=?," +
                    "completed_at=CASE WHEN ?='completed' THEN NOW() ELSE completed_at END WHERE id=? AND user_id=?");
                upd.setObject(1, (catId!=null&&!catId.isEmpty()) ? Integer.parseInt(catId) : null);
                upd.setString(2, title.trim());
                upd.setString(3, desc);
                upd.setString(4, prio!=null?prio:"medium");
                upd.setString(5, stat!=null?stat:"pending");
                upd.setObject(6, (due!=null&&!due.isEmpty()) ? java.sql.Date.valueOf(due) : null);
                upd.setObject(7, (start!=null&&!start.isEmpty()) ? java.sql.Date.valueOf(start) : null);
                upd.setObject(8, (est!=null&&!est.isEmpty()) ? Integer.parseInt(est) : null);
                upd.setString(9, notes);
                upd.setString(10, stat!=null?stat:"pending");
                upd.setInt(11, tid); upd.setInt(12, userId);
                upd.executeUpdate();
                msg="Task updated!"; msgType="success";
            }
        }

    } else if ("delete".equals(act)) {
        int tid = Integer.parseInt(request.getParameter("task_id"));
        PreparedStatement del = con.prepareStatement("UPDATE tasks SET is_deleted=1 WHERE id=? AND user_id=?");
        del.setInt(1,tid); del.setInt(2,userId); del.executeUpdate();
        msg="Task moved to trash."; msgType="success";

    } else if ("restore".equals(act)) {
        int tid = Integer.parseInt(request.getParameter("task_id"));
        PreparedStatement res = con.prepareStatement("UPDATE tasks SET is_deleted=0 WHERE id=? AND user_id=?");
        res.setInt(1,tid); res.setInt(2,userId); res.executeUpdate();
        msg="Task restored!"; msgType="success";

    } else if ("perm_delete".equals(act)) {
        int tid = Integer.parseInt(request.getParameter("task_id"));
        PreparedStatement pdel = con.prepareStatement("DELETE FROM tasks WHERE id=? AND user_id=?");
        pdel.setInt(1,tid); pdel.setInt(2,userId); pdel.executeUpdate();
        msg="Task permanently deleted."; msgType="success";
    }
    action = null; // After POST, show list
}

/* ---- Load edit task ---- */
if ("edit".equals(action) && request.getParameter("id") != null) {
    try { editId = Integer.parseInt(request.getParameter("id")); } catch(Exception e){}
    if (editId > 0) {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM tasks WHERE id=? AND user_id=? AND is_deleted=0");
        ps.setInt(1,editId); ps.setInt(2,userId);
        ResultSet er = ps.executeQuery();
        if(er.next()) {
            editTask.put("id",       er.getString("id"));
            editTask.put("title",    er.getString("title"));
            editTask.put("description", er.getString("description")!=null?er.getString("description"):"");
            editTask.put("priority", er.getString("priority"));
            editTask.put("status",   er.getString("status"));
            editTask.put("due_date", er.getString("due_date")!=null?er.getString("due_date"):"");
            editTask.put("start_date",er.getString("start_date")!=null?er.getString("start_date"):"");
            editTask.put("category_id",er.getObject("category_id")!=null?er.getString("category_id"):"");
            editTask.put("estimated_time",er.getObject("estimated_time")!=null?er.getString("estimated_time"):"");
            editTask.put("notes",    er.getString("notes")!=null?er.getString("notes"):"");
        } else { editId=0; }
    }
}

/* ---- Load categories ---- */
PreparedStatement cp = con.prepareStatement("SELECT id,category_name,color FROM categories WHERE user_id=? ORDER BY category_name");
cp.setInt(1,userId);
ResultSet cr = cp.executeQuery();
while(cr.next()) {
    Map<String,String> m=new LinkedHashMap<>();
    m.put("id",cr.getString("id")); m.put("name",cr.getString("category_name")); m.put("color",cr.getString("color"));
    cats.add(m);
}

/* ---- Filters & list ---- */
fStatus   = request.getParameter("status") !=null ? request.getParameter("status") :"";
fPriority = request.getParameter("priority")!=null? request.getParameter("priority"):"";
fCat      = request.getParameter("cat")    !=null ? request.getParameter("cat")    :"";
fSearch   = request.getParameter("q")      !=null ? request.getParameter("q")      :"";
fSort     = request.getParameter("sort")   !=null ? request.getParameter("sort")   :"newest";
showTrash = "trash".equals(action);

StringBuilder sql = new StringBuilder(
    "SELECT t.*,c.category_name,c.color AS cat_color FROM tasks t " +
    "LEFT JOIN categories c ON t.category_id=c.id " +
    "WHERE t.user_id=? AND t.is_deleted=");
sql.append(showTrash ? "1" : "0");
List<Object> params = new ArrayList<>(); params.add(userId);

if (!fStatus.isEmpty())   { sql.append(" AND t.status=?");     params.add(fStatus); }
if (!fPriority.isEmpty()) { sql.append(" AND t.priority=?");   params.add(fPriority); }
if (!fCat.isEmpty())      { sql.append(" AND t.category_id=?");params.add(Integer.parseInt(fCat)); }
if (!fSearch.isEmpty())   {
    sql.append(" AND (t.title LIKE ? OR t.description LIKE ?)");
    params.add("%"+fSearch+"%"); params.add("%"+fSearch+"%");
}
switch(fSort) {
    case "oldest":
        sql.append(" ORDER BY t.created_at ASC"); break;
    case "priority":
        sql.append(" ORDER BY FIELD(t.priority,'high','medium','low')"); break;
    case "due_date":
        sql.append(" ORDER BY t.due_date ASC"); break;
    default:
        sql.append(" ORDER BY t.created_at DESC"); break;
}

PreparedStatement lps = con.prepareStatement(sql.toString());
for(int i=0;i<params.size();i++) {
    Object v=params.get(i);
    if(v instanceof Integer) lps.setInt(i+1,(Integer)v);
    else lps.setString(i+1,(String)v);
}
ResultSet lr = lps.executeQuery();
while(lr.next()) {
    Map<String,String> m=new LinkedHashMap<>();
    m.put("id",      lr.getString("id"));
    m.put("title",   lr.getString("title"));
    m.put("description", lr.getString("description")!=null?lr.getString("description"):"");
    m.put("priority",lr.getString("priority"));
    m.put("status",  lr.getString("status"));
    m.put("due_date",lr.getString("due_date")!=null?lr.getString("due_date"):"");
    m.put("category",lr.getString("category_name")!=null?lr.getString("category_name"):"");
    m.put("cat_color",lr.getString("cat_color")!=null?lr.getString("cat_color"):"#6C63FF");
    m.put("estimated_time", lr.getString("estimated_time")!=null?lr.getString("estimated_time"):"");
    tasks.add(m);
}

} catch(Exception ex) { msg=h(ex.getMessage()); msgType="error"; }
finally { if(con!=null) try{con.close();}catch(Exception e){} }

boolean showForm = "new".equals(action) || editId > 0;
String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en" data-theme="<%=userTheme%>">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Tasks – TaskFlow Pro</title>
<link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body class="app-body">
<%@ include file="/includes/nav.jsp" %>
<div class="app-main">
  <header class="topbar">
    <button class="hamburger" onclick="toggleSidebar()"><span></span><span></span><span></span></button>
    <div class="topbar-title"><h2><%=showTrash?"Trash Bin":"My Tasks"%></h2></div>
    <div class="topbar-actions">
      <% if(!showTrash) { %>
      <a href="?action=trash" class="btn btn-ghost btn-sm">🗑 Trash</a>
      <a href="?action=new"   class="btn btn-primary btn-sm">＋ New Task</a>
      <% } else { %>
      <a href="tasks.jsp" class="btn btn-ghost btn-sm">← Back to Tasks</a>
      <% } %>
    </div>
  </header>

  <div class="page-content">
    <% if(!msg.isEmpty()) { %><div class="alert alert-<%=msgType%>"><%=msg%></div><% } %>

    <!-- Task Form Modal (inline) -->
    <% if (showForm) { %>
    <div class="form-panel glass animate-up">
      <div class="form-panel-header">
        <h3><%=editId>0?"Edit Task":"New Task"%></h3>
        <a href="tasks.jsp" class="btn-icon-close">✕</a>
      </div>
      <form method="POST" action="">
        <input type="hidden" name="act" value="save">
        <input type="hidden" name="task_id" value="<%=editId>0?editId:0%>">
        <div class="form-grid-2">
          <div class="form-group full-width">
            <label>Task Title *</label>
            <input type="text" name="title" value="<%=editId>0?h(editTask.get("title")):""%>" placeholder="What needs to be done?" required class="form-control">
          </div>
          <div class="form-group full-width">
            <label>Description</label>
            <textarea name="description" rows="3" placeholder="Add details..." class="form-control"><%=editId>0?h(editTask.get("description")):""%></textarea>
          </div>
          <div class="form-group">
            <label>Priority</label>
            <select name="priority" class="form-control">
              <% for(String p:new String[]{"high","medium","low"}) { %>
              <option value="<%=p%>" <%=(editId>0&&p.equals(editTask.get("priority")))?"selected":""%>><%=p.substring(0,1).toUpperCase()+p.substring(1)%></option>
              <% } %>
            </select>
          </div>
          <div class="form-group">
            <label>Status</label>
            <select name="status" class="form-control">
              <% for(String s:new String[]{"pending","in_progress","completed","cancelled"}) { %>
              <option value="<%=s%>" <%=(editId>0&&s.equals(editTask.get("status")))?"selected":""%>><%=s.replace("_"," ").substring(0,1).toUpperCase()+s.replace("_"," ").substring(1)%></option>
              <% } %>
            </select>
          </div>
          <div class="form-group">
            <label>Due Date</label>
            <input type="date" name="due_date" value="<%=editId>0?h(editTask.get("due_date")):""%>" class="form-control">
          </div>
          <div class="form-group">
            <label>Start Date</label>
            <input type="date" name="start_date" value="<%=editId>0?h(editTask.get("start_date")):""%>" class="form-control">
          </div>
          <div class="form-group">
            <label>Category</label>
            <select name="category_id" class="form-control">
              <option value="">-- None --</option>
              <% for(Map<String,String> cat:cats) { %>
              <option value="<%=cat.get("id")%>" <%=(editId>0&&cat.get("id").equals(editTask.get("category_id")))?"selected":""%>><%=h(cat.get("name"))%></option>
              <% } %>
            </select>
          </div>
          <div class="form-group">
            <label>Estimated Time (min)</label>
            <input type="number" name="estimated_time" value="<%=editId>0?h(editTask.get("estimated_time")):""%>" placeholder="e.g. 60" class="form-control" min="1">
          </div>
          <div class="form-group full-width">
            <label>Notes</label>
            <textarea name="notes" rows="2" placeholder="Any extra notes..." class="form-control"><%=editId>0?h(editTask.get("notes")):""%></textarea>
          </div>
        </div>
        <div class="form-actions">
          <a href="tasks.jsp" class="btn btn-ghost">Cancel</a>
          <button type="submit" class="btn btn-primary"><%=editId>0?"Update Task":"Create Task"%></button>
        </div>
      </form>
    </div>
    <% } %>

    <!-- Filters bar -->
    <% if (!showTrash) { %>
    <form method="GET" action="" class="filter-bar glass">
      <div class="search-wrap">
        <svg class="search-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" name="q" value="<%=h(fSearch)%>" placeholder="Search tasks..." class="search-input">
      </div>
      <select name="status" class="filter-select">
        <option value="">All Status</option>
        <% for(String s:new String[]{"pending","in_progress","completed","cancelled","overdue"}) { %>
        <option value="<%=s%>" <%=s.equals(fStatus)?"selected":""%>><%=s.replace("_"," ")%></option>
        <% } %>
      </select>
      <select name="priority" class="filter-select">
        <option value="">All Priority</option>
        <% for(String p:new String[]{"high","medium","low"}) { %>
        <option value="<%=p%>" <%=p.equals(fPriority)?"selected":""%>><%=p%></option>
        <% } %>
      </select>
      <select name="cat" class="filter-select">
        <option value="">All Categories</option>
        <% for(Map<String,String> cat:cats) { %>
        <option value="<%=cat.get("id")%>" <%=cat.get("id").equals(fCat)?"selected":""%>><%=h(cat.get("name"))%></option>
        <% } %>
      </select>
      <select name="sort" class="filter-select">
        <option value="newest" <%="newest".equals(fSort)?"selected":""%>>Newest</option>
        <option value="oldest" <%="oldest".equals(fSort)?"selected":""%>>Oldest</option>
        <option value="priority" <%="priority".equals(fSort)?"selected":""%>>Priority</option>
        <option value="due_date" <%="due_date".equals(fSort)?"selected":""%>>Due Date</option>
      </select>
      <button type="submit" class="btn btn-primary btn-sm">Filter</button>
      <a href="tasks.jsp" class="btn btn-ghost btn-sm">Reset</a>
    </form>
    <% } %>

    <!-- Task Cards -->
    <div class="task-cards-grid">
      <% if (tasks.isEmpty()) { %>
      <div class="empty-state glass">
        <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" opacity="0.3"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
        <h3><%=showTrash?"Trash is empty":"No tasks found"%></h3>
        <p><%=showTrash?"Deleted tasks appear here":"Create your first task to get started!"%></p>
        <% if(!showTrash) { %><a href="?action=new" class="btn btn-primary">＋ Create Task</a><% } %>
      </div>
      <% } else { for(Map<String,String> t : tasks) {
          String dd = t.get("due_date");
          boolean overdue = dd!=null&&!dd.isEmpty()&&!t.get("status").equals("completed")&&!t.get("status").equals("cancelled")&&java.sql.Date.valueOf(dd).before(new java.util.Date());
      %>
      <div class="task-card glass animate-up <%=overdue?"overdue":""%>">
        <div class="task-card-header">
          <span class="priority-badge <%=t.get("priority")%>"><%=t.get("priority")%></span>
          <span class="status-badge <%=t.get("status").replace("_","-")%>"><%=t.get("status").replace("_"," ")%></span>
        </div>
        <h4 class="task-card-title <%="completed".equals(t.get("status"))?"strikethrough":""%>"><%=h(t.get("title"))%></h4>
        <% if (!t.get("description").isEmpty()) { %><p class="task-card-desc"><%=h(t.get("description").length()>80?t.get("description").substring(0,80)+"…":t.get("description"))%></p><% } %>
        <div class="task-card-meta">
          <% if (!t.get("category").isEmpty()) { %><span class="cat-chip" style="border-color:<%=t.get("cat_color")%>"><%=h(t.get("category"))%></span><% } %>
          <% if (!dd.isEmpty()) { %><span class="due-chip <%=overdue?"overdue":""%>">📅 <%=dd%></span><% } %>
          <% if (!t.get("estimated_time").isEmpty()) { %><span class="due-chip">⏱ <%=t.get("estimated_time")%>m</span><% } %>
        </div>
        <div class="task-card-actions">
          <% if (!showTrash) { %>
          <a href="?action=edit&id=<%=t.get("id")%>" class="btn btn-ghost btn-xs">Edit</a>
          <form method="POST" style="display:inline" onsubmit="return confirm('Move to trash?')">
            <input type="hidden" name="act" value="delete">
            <input type="hidden" name="task_id" value="<%=t.get("id")%>">
            <button type="submit" class="btn btn-danger btn-xs">Delete</button>
          </form>
          <% } else { %>
          <form method="POST" style="display:inline">
            <input type="hidden" name="act" value="restore">
            <input type="hidden" name="task_id" value="<%=t.get("id")%>">
            <button type="submit" class="btn btn-ghost btn-xs">Restore</button>
          </form>
          <form method="POST" style="display:inline" onsubmit="return confirm('Delete permanently?')">
            <input type="hidden" name="act" value="perm_delete">
            <input type="hidden" name="task_id" value="<%=t.get("id")%>">
            <button type="submit" class="btn btn-danger btn-xs">Delete Forever</button>
          </form>
          <% } %>
        </div>
      </div>
      <% } } %>
    </div>
  </div>
</div>
<script src="<%=ctx%>/assets/js/feather.min.js"></script>
<script src="<%=ctx%>/assets/js/app.js"></script>
<script>if(window.feather)feather.replace();</script>
</html>
<!-- Force recompile: 1 -->
