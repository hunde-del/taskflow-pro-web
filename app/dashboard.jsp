<%@ include file="/includes/auth.jsp" %>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
/* ===== DASHBOARD ===== */
Map<String,Integer> stats = new LinkedHashMap<>();
stats.put("total",0); stats.put("pending",0); stats.put("in_progress",0);
stats.put("completed",0); stats.put("overdue",0);

List<Map<String,String>> todayTasks   = new ArrayList<>();
List<Map<String,String>> upcomingTasks = new ArrayList<>();
List<Map<String,String>> recentActivity = new ArrayList<>();
int productivityScore = 0;

Connection con = null;
try {
    con = db();
    // Task stats
    PreparedStatement ps = con.prepareStatement(
        "SELECT status, COUNT(*) as cnt FROM tasks WHERE user_id=? AND is_deleted=0 GROUP BY status");
    ps.setInt(1, userId);
    ResultSet rs = ps.executeQuery();
    int total=0;
    while(rs.next()) { stats.put(rs.getString("status"), rs.getInt("cnt")); total+=rs.getInt("cnt"); }
    stats.put("total", total);
    // Overdue
    PreparedStatement ov = con.prepareStatement(
        "SELECT COUNT(*) FROM tasks WHERE user_id=? AND is_deleted=0 AND due_date<CURDATE() AND status NOT IN('completed','cancelled')");
    ov.setInt(1, userId);
    ResultSet ovr = ov.executeQuery();
    if(ovr.next()) stats.put("overdue", ovr.getInt(1));

    // Productivity score (% completed of non-cancelled)
    int comp = stats.getOrDefault("completed",0);
    int denom = total - stats.getOrDefault("cancelled",0);
    productivityScore = denom > 0 ? (int)((comp * 100.0) / denom) : 0;

    // Today's tasks
    PreparedStatement td = con.prepareStatement(
        "SELECT t.id,t.title,t.priority,t.status,c.category_name FROM tasks t " +
        "LEFT JOIN categories c ON t.category_id=c.id " +
        "WHERE t.user_id=? AND t.is_deleted=0 AND t.due_date=CURDATE() " +
        "AND t.status NOT IN('completed','cancelled') ORDER BY FIELD(t.priority,'high','medium','low') LIMIT 8");
    td.setInt(1, userId);
    ResultSet tdr = td.executeQuery();
    while(tdr.next()) {
        Map<String,String> m = new LinkedHashMap<>();
        m.put("id",    tdr.getString("id"));
        m.put("title", tdr.getString("title"));
        m.put("priority", tdr.getString("priority"));
        m.put("status",   tdr.getString("status"));
        m.put("category", tdr.getString("category_name") != null ? tdr.getString("category_name") : "");
        todayTasks.add(m);
    }

    // Upcoming (next 7 days)
    PreparedStatement up = con.prepareStatement(
        "SELECT t.id,t.title,t.priority,t.due_date,c.category_name FROM tasks t " +
        "LEFT JOIN categories c ON t.category_id=c.id " +
        "WHERE t.user_id=? AND t.is_deleted=0 " +
        "AND t.due_date BETWEEN DATE_ADD(CURDATE(),INTERVAL 1 DAY) AND DATE_ADD(CURDATE(),INTERVAL 7 DAY) " +
        "AND t.status NOT IN('completed','cancelled') ORDER BY t.due_date ASC LIMIT 6");
    up.setInt(1, userId);
    ResultSet upr = up.executeQuery();
    while(upr.next()) {
        Map<String,String> m = new LinkedHashMap<>();
        m.put("id",       upr.getString("id"));
        m.put("title",    upr.getString("title"));
        m.put("priority", upr.getString("priority"));
        m.put("due_date", upr.getString("due_date"));
        m.put("category", upr.getString("category_name") != null ? upr.getString("category_name") : "");
        upcomingTasks.add(m);
    }

    // Recent activity (last 6)
    PreparedStatement ra = con.prepareStatement(
        "SELECT action, timestamp FROM activity_logs WHERE user_id=? ORDER BY timestamp DESC LIMIT 6");
    ra.setInt(1, userId);
    ResultSet rar = ra.executeQuery();
    while(rar.next()) {
        Map<String,String> m = new LinkedHashMap<>();
        m.put("action", rar.getString("action"));
        m.put("time",   rar.getString("timestamp"));
        recentActivity.add(m);
    }

} catch(Exception ex) {
    out.println("<!-- DB Error: " + h(ex.getMessage()) + " -->");
} finally { if(con!=null) try{con.close();}catch(Exception e){} }
%>
<!DOCTYPE html>
<html lang="en" data-theme="<%=userTheme%>">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dashboard – TaskFlow Pro</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/style.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body class="app-body">
<%@ include file="/includes/nav.jsp" %>

<div class="app-main">
  <!-- Top bar -->
  <header class="topbar">
    <button class="hamburger" onclick="toggleSidebar()" id="hamburger">
      <span></span><span></span><span></span>
    </button>
    <div class="topbar-title">
      <h2>Dashboard</h2>
      <p><%=new java.util.Date().toString().substring(0,10)%></p>
    </div>
    <div class="topbar-actions">
      <a href="<%=request.getContextPath()%>/app/tasks.jsp?action=new" class="btn btn-primary btn-sm">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        New Task
      </a>
    </div>
  </header>

  <div class="page-content">
    <!-- Welcome banner -->
    <div class="welcome-banner glass">
      <div>
        <h3>Good <%=new java.util.Calendar.Builder().build().get(java.util.Calendar.HOUR_OF_DAY)<12?"Morning":new java.util.Calendar.Builder().build().get(java.util.Calendar.HOUR_OF_DAY)<17?"Afternoon":"Evening"%>, <%=h(userFullName.split(" ")[0])%>! 👋</h3>
        <p>You have <strong><%=todayTasks.size()%></strong> task<%=todayTasks.size()!=1?"s":""%> due today.</p>
      </div>
      <div class="productivity-ring">
        <svg viewBox="0 0 60 60" width="80" height="80">
          <circle cx="30" cy="30" r="24" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="6"/>
          <circle cx="30" cy="30" r="24" fill="none" stroke="#6C63FF" stroke-width="6"
            stroke-dasharray="<%=(int)(150.8 * productivityScore / 100.0)%> 150.8"
            stroke-linecap="round" transform="rotate(-90 30 30)"/>
        </svg>
        <div class="ring-label"><%=productivityScore%>%</div>
      </div>
    </div>

    <!-- Stat cards -->
    <div class="stats-grid">
      <div class="stat-card glass animate-up" style="--delay:0.05s">
        <div class="stat-icon" style="background:rgba(108,99,255,0.2)">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#6C63FF" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
        </div>
        <div class="stat-info">
          <p class="stat-label">Total Tasks</p>
          <h3 class="stat-value counter" data-target="<%=stats.get("total")%>">0</h3>
        </div>
      </div>
      <div class="stat-card glass animate-up" style="--delay:0.1s">
        <div class="stat-icon" style="background:rgba(255,193,7,0.2)">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#FFC107" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
        <div class="stat-info">
          <p class="stat-label">Pending</p>
          <h3 class="stat-value counter" data-target="<%=stats.getOrDefault("pending",0)%>">0</h3>
        </div>
      </div>
      <div class="stat-card glass animate-up" style="--delay:0.15s">
        <div class="stat-icon" style="background:rgba(67,203,255,0.2)">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#43CBFF" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
        </div>
        <div class="stat-info">
          <p class="stat-label">In Progress</p>
          <h3 class="stat-value counter" data-target="<%=stats.getOrDefault("in_progress",0)%>">0</h3>
        </div>
      </div>
      <div class="stat-card glass animate-up" style="--delay:0.2s">
        <div class="stat-icon" style="background:rgba(114,239,54,0.2)">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#72EF36" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div class="stat-info">
          <p class="stat-label">Completed</p>
          <h3 class="stat-value counter" data-target="<%=stats.getOrDefault("completed",0)%>">0</h3>
        </div>
      </div>
      <div class="stat-card glass animate-up" style="--delay:0.25s">
        <div class="stat-icon" style="background:rgba(255,101,132,0.2)">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#FF6584" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
        <div class="stat-info">
          <p class="stat-label">Overdue</p>
          <h3 class="stat-value counter" data-target="<%=stats.getOrDefault("overdue",0)%>">0</h3>
        </div>
      </div>
    </div>

    <div class="dashboard-grid">
      <!-- Today's Tasks -->
      <div class="dash-card glass">
        <div class="dash-card-header">
          <h4>Today's Tasks</h4>
          <a href="<%=request.getContextPath()%>/app/tasks.jsp" class="btn-link">View all →</a>
        </div>
        <div class="task-list">
          <% if (todayTasks.isEmpty()) { %>
          <div class="empty-state-sm">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" opacity="0.3"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            <p>No tasks due today. Enjoy! 🎉</p>
          </div>
          <% } else { for(Map<String,String> t : todayTasks) { %>
          <div class="task-item" id="task-<%=t.get("id")%>">
            <button class="task-check <%="completed".equals(t.get("status"))?"checked":""%>"
              onclick="quickComplete(<%=t.get("id")%>,this)" title="Mark complete">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
            </button>
            <div class="task-details">
              <p class="task-title <%="completed".equals(t.get("status"))?"strikethrough":""%>"><%=h(t.get("title"))%></p>
              <% if (!t.get("category").isEmpty()) { %>
              <span class="task-cat"><%=h(t.get("category"))%></span>
              <% } %>
            </div>
            <span class="priority-badge <%=t.get("priority")%>"><%=t.get("priority")%></span>
          </div>
          <% } } %>
        </div>
      </div>

      <!-- Upcoming Tasks -->
      <div class="dash-card glass">
        <div class="dash-card-header">
          <h4>Upcoming (7 days)</h4>
          <a href="<%=request.getContextPath()%>/app/calendar.jsp" class="btn-link">Calendar →</a>
        </div>
        <div class="task-list">
          <% if (upcomingTasks.isEmpty()) { %>
          <div class="empty-state-sm"><p>No upcoming tasks. You're ahead of schedule!</p></div>
          <% } else { for(Map<String,String> t : upcomingTasks) { %>
          <div class="task-item">
            <div class="due-badge">
              <span><%=t.get("due_date") != null ? t.get("due_date").substring(5) : "—"%></span>
            </div>
            <div class="task-details">
              <p class="task-title"><%=h(t.get("title"))%></p>
              <% if (!t.get("category").isEmpty()) { %><span class="task-cat"><%=h(t.get("category"))%></span><% } %>
            </div>
            <span class="priority-badge <%=t.get("priority")%>"><%=t.get("priority")%></span>
          </div>
          <% } } %>
        </div>
      </div>

      <!-- Mini Chart -->
      <div class="dash-card glass">
        <div class="dash-card-header"><h4>Task Overview</h4></div>
        <div style="padding:1rem;max-height:220px">
          <canvas id="overviewChart"></canvas>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="dash-card glass">
        <div class="dash-card-header"><h4>Recent Activity</h4></div>
        <div class="activity-list">
          <% if (recentActivity.isEmpty()) { %>
          <div class="empty-state-sm"><p>No recent activity yet.</p></div>
          <% } else { for(Map<String,String> a : recentActivity) { %>
          <div class="activity-item">
            <div class="activity-dot"></div>
            <div>
              <p class="activity-action"><%=h(a.get("action"))%></p>
              <p class="activity-time"><%=a.get("time") != null ? a.get("time").substring(0,16) : ""%></p>
            </div>
          </div>
          <% } } %>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="<%=request.getContextPath()%>/assets/js/feather.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app.js"></script>
<script>
if(window.feather) feather.replace();

// Counter animation
document.querySelectorAll('.counter').forEach(el => {
    const target = parseInt(el.dataset.target)||0;
    let curr = 0;
    const step = Math.max(1, Math.ceil(target/30));
    const t = setInterval(()=>{
        curr = Math.min(curr+step, target);
        el.textContent = curr;
        if(curr>=target) clearInterval(t);
    }, 40);
});

// Overview doughnut chart
const ctx = document.getElementById('overviewChart');
if(ctx) {
    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Pending','In Progress','Completed','Overdue'],
            datasets: [{
                data: [<%=stats.getOrDefault("pending",0)%>,
                       <%=stats.getOrDefault("in_progress",0)%>,
                       <%=stats.getOrDefault("completed",0)%>,
                       <%=stats.getOrDefault("overdue",0)%>],
                backgroundColor: ['#FFC107','#43CBFF','#72EF36','#FF6584'],
                borderWidth: 0,
                hoverOffset: 6
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: true,
            plugins: { legend: { position:'bottom', labels:{ color:'rgba(255,255,255,0.7)', padding:12, font:{size:11} } } },
            cutout: '65%'
        }
    });
}

// Quick complete task
function quickComplete(taskId, btn) {
    fetch('<%=request.getContextPath()%>/app/task-action.jsp?action=complete&id='+taskId, {method:'POST'})
        .then(r=>r.json()).then(d=>{
            if(d.ok) {
                btn.classList.add('checked');
                const row = document.getElementById('task-'+taskId);
                if(row) { row.style.opacity='0.4'; row.querySelector('.task-title').classList.add('strikethrough'); }
            }
        }).catch(()=>{});
}
</script>
</body>
</html>
