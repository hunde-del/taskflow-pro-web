<%@ include file="/includes/auth.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,java.time.*" %>
<%
/* ===== CALENDAR PAGE ===== */
String ctx = request.getContextPath();
int year  = LocalDate.now().getYear();
int month = LocalDate.now().getMonthValue();
try {
    if (request.getParameter("y") != null) year  = Integer.parseInt(request.getParameter("y"));
    if (request.getParameter("m") != null) month = Integer.parseInt(request.getParameter("m"));
} catch(Exception e) {}
if (month < 1) { month = 12; year--; }
if (month > 12){ month = 1;  year++; }

LocalDate firstOfMonth = LocalDate.of(year, month, 1);
int daysInMonth = firstOfMonth.lengthOfMonth();
int startDow    = firstOfMonth.getDayOfWeek().getValue() % 7; // 0=Sun

// Load tasks for this month
Map<Integer, List<Map<String,String>>> tasksByDay = new HashMap<>();
Connection con = null;
try {
    con = db();
    PreparedStatement ps = con.prepareStatement(
        "SELECT id,title,priority,status,DAY(due_date) AS day FROM tasks " +
        "WHERE user_id=? AND is_deleted=0 AND YEAR(due_date)=? AND MONTH(due_date)=? ORDER BY FIELD(priority,'high','medium','low')");
    ps.setInt(1,userId); ps.setInt(2,year); ps.setInt(3,month);
    ResultSet rs = ps.executeQuery();
    while(rs.next()) {
        int d = rs.getInt("day");
        if (!tasksByDay.containsKey(d)) {
            tasksByDay.put(d, new ArrayList<Map<String,String>>());
        }
        Map<String,String> m = new LinkedHashMap<>();
        m.put("id",rs.getString("id")); m.put("title",rs.getString("title"));
        m.put("priority",rs.getString("priority")); m.put("status",rs.getString("status"));
        tasksByDay.get(d).add(m);
    }
} catch(Exception ex) {
} finally { if(con!=null) try{con.close();}catch(Exception e){} }

String[] monthNames = {"","January","February","March","April","May","June","July","August","September","October","November","December"};
int prevMonth = month-1, prevYear=year; if(prevMonth<1){prevMonth=12;prevYear--;}
int nextMonth = month+1, nextYear=year; if(nextMonth>12){nextMonth=1;nextYear++;}
%>
<!DOCTYPE html>
<html lang="en" data-theme="<%=userTheme%>">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Calendar – TaskFlow Pro</title>
<link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body class="app-body">
<%@ include file="/includes/nav.jsp" %>
<div class="app-main">
  <header class="topbar">
    <button class="hamburger" onclick="toggleSidebar()"><span></span><span></span><span></span></button>
    <div class="topbar-title"><h2>Calendar</h2></div>
    <div class="topbar-actions">
      <a href="<%=ctx%>/app/tasks.jsp?action=new" class="btn btn-primary btn-sm">＋ New Task</a>
    </div>
  </header>
  <div class="page-content">
    <div class="calendar-container glass">
      <div class="calendar-nav">
        <a href="?y=<%=prevYear%>&m=<%=prevMonth%>" class="btn btn-ghost btn-sm">‹ Prev</a>
        <h3 class="calendar-title"><%=monthNames[month]%> <%=year%></h3>
        <a href="?y=<%=nextYear%>&m=<%=nextMonth%>" class="btn btn-ghost btn-sm">Next ›</a>
      </div>
      <div class="calendar-grid">
        <% for(String dow : new String[]{"Sun","Mon","Tue","Wed","Thu","Fri","Sat"}) { %>
        <div class="cal-dow"><%=dow%></div>
        <% } %>
        <% for(int i=0;i<startDow;i++) { %><div class="cal-empty"></div><% } %>
        <% for(int d=1;d<=daysInMonth;d++) {
           boolean isToday = (d==LocalDate.now().getDayOfMonth() && month==LocalDate.now().getMonthValue() && year==LocalDate.now().getYear());
           List<Map<String,String>> dayTasks = tasksByDay.get(d);
           if (dayTasks == null) dayTasks = new ArrayList<Map<String,String>>();
        %>
        <div class="cal-day <%=isToday?"today":""%>">
          <span class="cal-day-num"><%=d%></span>
          <div class="cal-tasks">
            <% int shown=0; for(Map<String,String> t : dayTasks) { if(shown>=3) break; shown++; %>
            <a href="<%=ctx%>/app/tasks.jsp?action=edit&id=<%=t.get("id")%>" class="cal-task-pill <%=t.get("priority")%> <%="completed".equals(t.get("status"))?"done":""%>" title="<%=h(t.get("title"))%>"><%=h(t.get("title").length()>18?t.get("title").substring(0,18)+"…":t.get("title"))%></a>
            <% } %>
            <% if(dayTasks.size()>3) { %><span class="cal-more">+<%=dayTasks.size()-3%> more</span><% } %>
          </div>
        </div>
        <% } %>
      </div>
    </div>
  </div>
</div>
<script src="<%=ctx%>/assets/js/feather.min.js"></script>
<script src="<%=ctx%>/assets/js/app.js"></script>
<script>if(window.feather)feather.replace();</script>
</body>
</html>
