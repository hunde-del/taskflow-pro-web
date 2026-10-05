<%@ page import="java.sql.*, java.security.*, javax.crypto.*, javax.crypto.spec.*, java.util.Base64" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%!
/* ---- Password verify (PBKDF2 - no external JARs) ---- */
public boolean verifyPassword(String password, String stored) {
    try {
        String[] parts = stored.split(":");
        if (parts.length != 2) return false;
        byte[] salt = Base64.getDecoder().decode(parts[0]);
        byte[] hash = Base64.getDecoder().decode(parts[1]);
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 65536, 256);
        SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] test = skf.generateSecret(spec).getEncoded();
        spec.clearPassword();
        if (test.length != hash.length) return false;
        int diff = 0;
        for (int i = 0; i < test.length; i++) diff |= test[i] ^ hash[i];
        return diff == 0;
    } catch (Exception e) { return false; }
}
public Connection openDB() throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    return DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/taskflow_pro?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=utf8",
        "root", "");
}
public String esc(String s) {
    if (s == null) return "";
    return s.replace("&","&amp;").replace("<","&lt;").replace("\"","&quot;");
}
%>
<%
/* ===== Redirect if already logged in ===== */
if (session.getAttribute("userId") != null) {
    response.sendRedirect(request.getContextPath() + "/app/dashboard.jsp");
    return;
}

String error = "";
String emailVal = "";

if ("POST".equals(request.getMethod())) {
    String emailIn = request.getParameter("email");
    String passIn  = request.getParameter("password");

    if (emailIn == null || emailIn.trim().isEmpty() || passIn == null || passIn.isEmpty()) {
        error = "Please enter your email and password.";
    } else {
        emailVal = emailIn.trim().toLowerCase();
        Connection con = null;
        try {
            con = openDB();
            PreparedStatement ps = con.prepareStatement(
                "SELECT id, full_name, email, password_hash, role, theme_pref, profile_picture, is_active " +
                "FROM users WHERE email = ?");
            ps.setString(1, emailVal);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if (rs.getInt("is_active") == 0) {
                    error = "Your account has been suspended.";
                } else if (verifyPassword(passIn, rs.getString("password_hash"))) {
                    session.setAttribute("userId",       rs.getInt("id"));
                    session.setAttribute("userFullName", rs.getString("full_name"));
                    session.setAttribute("userEmail",    rs.getString("email"));
                    session.setAttribute("userRole",     rs.getString("role"));
                    String theme = rs.getString("theme_pref");
                    session.setAttribute("userTheme",    (theme != null ? theme : "dark"));
                    session.setAttribute("userAvatar",   rs.getString("profile_picture"));
                    /* Update last login */
                    PreparedStatement upd = con.prepareStatement(
                        "UPDATE users SET last_login = NOW() WHERE id = ?");
                    upd.setInt(1, rs.getInt("id"));
                    upd.executeUpdate();
                    /* Activity log */
                    try {
                        PreparedStatement log = con.prepareStatement(
                            "INSERT INTO activity_logs(user_id, action, ip_address) VALUES(?, ?, ?)");
                        log.setInt(1,    rs.getInt("id"));
                        log.setString(2, "User logged in");
                        log.setString(3, request.getRemoteAddr());
                        log.executeUpdate();
                    } catch (Exception le) { /* non-fatal */ }
                    response.sendRedirect(request.getContextPath() + "/app/dashboard.jsp");
                    return;
                } else {
                    error = "Incorrect email or password.";
                }
            } else {
                error = "No account found with that email.";
            }
        } catch (Exception ex) {
            error = "Database error: " + esc(ex.getMessage());
        } finally {
            if (con != null) try { con.close(); } catch (Exception ig) {}
        }
    }
}
String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sign In – TaskFlow Pro</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
:root{--primary:#6C63FF;--primary-h:#5A52D5;--danger:#FF6584;--success:#72EF36;--bg:#0f111a;--glass:rgba(25,28,41,0.7);--border:rgba(255,255,255,0.09);--text:#f1f3fa;--muted:#a0a4b8}
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif}
body{min-height:100vh;background:var(--bg);display:flex;align-items:center;justify-content:center;position:relative;overflow:hidden;color:var(--text)}
.orbs{position:fixed;inset:0;pointer-events:none;z-index:0}
.orb{position:absolute;border-radius:50%;filter:blur(90px);opacity:.45;animation:drift 18s ease-in-out infinite alternate}
.o1{width:500px;height:500px;background:var(--primary);top:-150px;left:-120px}
.o2{width:380px;height:380px;background:var(--danger);bottom:-100px;right:-80px;animation-delay:-6s}
.o3{width:300px;height:300px;background:#43CBFF;top:45%;left:55%;animation-delay:-12s}
@keyframes drift{to{transform:translate(40px,-60px) scale(1.12)}}
.wrap{position:relative;z-index:1;width:100%;max-width:420px;padding:24px}
.card{background:var(--glass);border:1px solid var(--border);border-radius:20px;padding:42px 36px;backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);box-shadow:0 24px 64px rgba(0,0,0,.35);animation:rise .5s ease both}
@keyframes rise{from{opacity:0;transform:translateY(28px)}to{opacity:1;transform:none}}
.brand{display:flex;align-items:center;justify-content:center;gap:12px;margin-bottom:28px}
.brand-icon{width:44px;height:44px;border-radius:12px;background:linear-gradient(135deg,var(--primary),var(--danger));display:flex;align-items:center;justify-content:center}
.brand-icon svg{width:22px;height:22px}
.brand-name{font-size:22px;font-weight:800;letter-spacing:-.5px}
.brand-name span{color:var(--primary)}
h1{font-size:22px;font-weight:700;text-align:center;margin-bottom:6px}
.sub{color:var(--muted);text-align:center;font-size:13.5px;margin-bottom:26px}
.alert{padding:12px 15px;border-radius:10px;font-size:13.5px;font-weight:500;margin-bottom:20px;background:rgba(255,101,132,.1);color:var(--danger);border:1px solid rgba(255,101,132,.25)}
.fg{margin-bottom:18px}
.fg label{display:flex;justify-content:space-between;align-items:center;font-size:12.5px;font-weight:500;color:var(--muted);margin-bottom:8px}
.fg label a{color:var(--primary);text-decoration:none;font-weight:600}
.iw{position:relative;display:flex;align-items:center}
.iw svg.ic{position:absolute;left:13px;color:var(--muted);pointer-events:none;width:16px;height:16px}
.iw input{width:100%;background:rgba(0,0,0,.25);border:1px solid var(--border);color:var(--text);border-radius:10px;padding:12px 14px 12px 40px;font-size:14px;transition:.2s;outline:none}
.iw input:focus{border-color:var(--primary);background:rgba(0,0,0,.35);box-shadow:0 0 0 3px rgba(108,99,255,.2)}
.eye{position:absolute;right:12px;background:none;border:none;color:var(--muted);cursor:pointer;padding:4px;display:flex;align-items:center;transition:.2s}
.eye:hover{color:var(--text)}
.row{display:flex;align-items:center;gap:8px;margin-bottom:6px}
.row input[type=checkbox]{width:15px;height:15px;accent-color:var(--primary);cursor:pointer}
.row span{font-size:13px;color:var(--muted)}
.btn{width:100%;padding:13px;background:var(--primary);color:#fff;border:none;border-radius:10px;font-size:15px;font-weight:600;cursor:pointer;transition:.2s;margin-top:8px;letter-spacing:.2px;box-shadow:0 6px 20px rgba(108,99,255,.3)}
.btn:hover{background:var(--primary-h);transform:translateY(-2px);box-shadow:0 8px 24px rgba(108,99,255,.4)}
.btn:active{transform:translateY(0)}
.footer{text-align:center;margin-top:22px;font-size:13.5px;color:var(--muted)}
.footer a{color:var(--primary);font-weight:600;text-decoration:none}
</style>
</head>
<body>
<div class="orbs">
  <div class="orb o1"></div><div class="orb o2"></div><div class="orb o3"></div>
</div>
<div class="wrap">
  <div class="card">
    <div class="brand">
      <div class="brand-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
      </div>
      <span class="brand-name">TaskFlow<span>Pro</span></span>
    </div>

    <h1>Welcome back</h1>
    <p class="sub">Sign in to your account to continue</p>

    <% if (!error.isEmpty()) { %>
    <div class="alert">&#9888; <%=error%></div>
    <% } %>

    <form method="POST" action="">
      <div class="fg">
        <label>Email Address</label>
        <div class="iw">
          <svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,12 2,6"/></svg>
          <input type="email" name="email" value="<%=esc(emailVal)%>" placeholder="you@example.com" required autocomplete="email">
        </div>
      </div>

      <div class="fg">
        <label>Password <a href="<%=ctx%>/forgot-password.jsp">Forgot password?</a></label>
        <div class="iw">
          <svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          <input type="password" name="password" id="pwd" placeholder="Your password" required autocomplete="current-password">
          <button type="button" class="eye" onclick="var f=document.getElementById('pwd');f.type=f.type==='password'?'text':'password'">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
          </button>
        </div>
      </div>

      <div class="row">
        <input type="checkbox" name="remember" id="rem">
        <span>Remember me for 30 days</span>
      </div>

      <button type="submit" class="btn">Sign In</button>
    </form>

    <p class="footer">Don't have an account? <a href="<%=ctx%>/register.jsp">Create one free &rarr;</a></p>
  </div>
</div>
</body>
</html>
