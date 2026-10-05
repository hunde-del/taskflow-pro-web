<%-- nav.jsp – Sidebar navigation, included in all app pages --%>
<%
String currentPage = request.getRequestURI();
boolean isAdmin = "admin".equals(userRole);
String navCtx = request.getContextPath();
String avatar = (userAvatar != null && !userAvatar.isEmpty())
    ? navCtx + "/uploads/" + h(userAvatar)
    : navCtx + "/assets/img/default-avatar.svg";
%>
<nav class="sidebar" id="sidebar">
  <div class="sidebar-brand">
    <div class="brand-logo"><i data-feather="check-square"></i></div>
    <span class="brand-name">TaskFlow<span class="brand-pro">Pro</span></span>
  </div>

  <div class="sidebar-user">
    <img src="<%=avatar%>" alt="avatar" class="user-avatar-sm" onerror="this.src='<%=navCtx%>/assets/img/default-avatar.svg'">
    <div class="user-info">
      <p class="user-name"><%=h(userFullName)%></p>
      <p class="user-role"><%=isAdmin?"Administrator":"Member"%></p>
    </div>
  </div>

  <ul class="nav-list">
    <li class="nav-item <%=currentPage.contains("dashboard")?"active":""%>">
      <a href="<%=navCtx%>/app/dashboard.jsp"><i data-feather="grid"></i><span>Dashboard</span></a>
    </li>
    <li class="nav-item <%=currentPage.contains("tasks")?"active":""%>">
      <a href="<%=navCtx%>/app/tasks.jsp"><i data-feather="check-circle"></i><span>My Tasks</span></a>
    </li>
    <li class="nav-item <%=currentPage.contains("calendar")?"active":""%>">
      <a href="<%=navCtx%>/app/calendar.jsp"><i data-feather="calendar"></i><span>Calendar</span></a>
    </li>
    <li class="nav-item <%=currentPage.contains("goals")?"active":""%>">
      <a href="<%=navCtx%>/app/goals.jsp"><i data-feather="target"></i><span>Goals</span></a>
    </li>
    <li class="nav-item <%=currentPage.contains("analytics")?"active":""%>">
      <a href="<%=navCtx%>/app/analytics.jsp"><i data-feather="bar-chart-2"></i><span>Analytics</span></a>
    </li>
    <% if (isAdmin) { %>
    <li class="nav-section-title">Admin</li>
    <li class="nav-item <%=currentPage.contains("/admin/")?"active":""%>">
      <a href="<%=navCtx%>/admin/dashboard.jsp"><i data-feather="shield"></i><span>Admin Panel</span></a>
    </li>
    <% } %>
    <li class="nav-section-title">Account</li>
    <li class="nav-item <%=currentPage.contains("profile")?"active":""%>">
      <a href="<%=navCtx%>/app/profile.jsp"><i data-feather="user"></i><span>Profile</span></a>
    </li>
    <li class="nav-item <%=currentPage.contains("settings")?"active":""%>">
      <a href="<%=navCtx%>/app/settings.jsp"><i data-feather="settings"></i><span>Settings</span></a>
    </li>
    <li class="nav-item">
      <a href="<%=navCtx%>/logout.jsp"><i data-feather="log-out"></i><span>Logout</span></a>
    </li>
  </ul>
</nav>
<div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>
