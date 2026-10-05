<%@ page import="java.sql.*, java.security.*, javax.crypto.*, javax.crypto.spec.*, java.util.Base64" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%!
/* ---- Password hash (PBKDF2) ---- */
public String hashPassword(String password) {
    try {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 65536, 256);
        SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] hash = skf.generateSecret(spec).getEncoded();
        spec.clearPassword();
        return Base64.getEncoder().encodeToString(salt) + ":" + Base64.getEncoder().encodeToString(hash);
    } catch (Exception e) { return ""; }
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
if (session.getAttribute("userId") != null) {
    response.sendRedirect(request.getContextPath() + "/app/dashboard.jsp");
    return;
}

String error = "", success = "";
String fnameVal = "", emailVal = "";

if ("POST".equals(request.getMethod())) {
    String fname = request.getParameter("full_name");
    String email = request.getParameter("email");
    String pass  = request.getParameter("password");
    String term  = request.getParameter("terms");

    if (fname == null || fname.trim().isEmpty() || email == null || email.trim().isEmpty() || pass == null || pass.isEmpty()) {
        error = "Please fill in all required fields.";
    } else if (term == null) {
        error = "You must agree to the Terms of Service.";
    } else if (pass.length() < 8) {
        error = "Password must be at least 8 characters long.";
    } else {
        fnameVal = fname.trim();
        emailVal = email.trim().toLowerCase();
        String uname = emailVal.split("@")[0].replaceAll("[^a-zA-Z0-9]", "") + new java.util.Random().nextInt(1000);
        Connection con = null;
        try {
            con = openDB();
            // Check if email exists
            PreparedStatement chk = con.prepareStatement("SELECT id FROM users WHERE email = ?");
            chk.setString(1, emailVal);
            if (chk.executeQuery().next()) {
                error = "An account with this email already exists.";
            } else {
                PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO users (full_name, username, email, password_hash, role, theme_pref) VALUES (?, ?, ?, ?, 'user', 'dark')");
                ins.setString(1, fnameVal);
                ins.setString(2, uname);
                ins.setString(3, emailVal);
                ins.setString(4, hashPassword(pass));
                ins.executeUpdate();

                success = "Account created successfully! You can now sign in.";
                fnameVal = ""; emailVal = "";
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
<title>Sign Up – TaskFlow Pro</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
:root{--primary:#6C63FF;--primary-h:#5A52D5;--danger:#FF6584;--success:#72EF36;--bg:#0f111a;--glass:rgba(25,28,41,0.7);--border:rgba(255,255,255,0.09);--text:#f1f3fa;--muted:#a0a4b8}
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif}
body{min-height:100vh;background:var(--bg);display:flex;align-items:center;justify-content:center;position:relative;overflow:hidden;color:var(--text)}
.orbs{position:fixed;inset:0;pointer-events:none;z-index:0}
.orb{position:absolute;border-radius:50%;filter:blur(90px);opacity:.45;animation:drift 18s ease-in-out infinite alternate}
.o1{width:500px;height:500px;background:var(--primary);top:-150px;right:-120px}
.o2{width:380px;height:380px;background:var(--danger);bottom:-100px;left:-80px;animation-delay:-6s}
@keyframes drift{to{transform:translate(40px,-60px) scale(1.12)}}
.wrap{position:relative;z-index:1;width:100%;max-width:440px;padding:24px}
.card{background:var(--glass);border:1px solid var(--border);border-radius:20px;padding:42px 36px;backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);box-shadow:0 24px 64px rgba(0,0,0,.35);animation:rise .5s ease both}
@keyframes rise{from{opacity:0;transform:translateY(28px)}to{opacity:1;transform:none}}
.brand{display:flex;align-items:center;justify-content:center;gap:12px;margin-bottom:24px}
.brand-icon{width:40px;height:40px;border-radius:10px;background:linear-gradient(135deg,var(--primary),var(--danger));display:flex;align-items:center;justify-content:center}
.brand-icon svg{width:20px;height:20px}
.brand-name{font-size:20px;font-weight:800;letter-spacing:-.5px}
.brand-name span{color:var(--primary)}
h1{font-size:22px;font-weight:700;text-align:center;margin-bottom:6px}
.sub{color:var(--muted);text-align:center;font-size:13.5px;margin-bottom:26px}
.alert{padding:12px 15px;border-radius:10px;font-size:13.5px;font-weight:500;margin-bottom:20px;background:rgba(255,101,132,.1);color:var(--danger);border:1px solid rgba(255,101,132,.25)}
.alert.success{background:rgba(114,239,54,.1);color:var(--success);border-color:rgba(114,239,54,.25)}
.fg{margin-bottom:18px}
.fg label{display:block;font-size:12.5px;font-weight:500;color:var(--muted);margin-bottom:8px}
.iw{position:relative;display:flex;align-items:center}
.iw svg.ic{position:absolute;left:13px;color:var(--muted);pointer-events:none;width:16px;height:16px}
.iw input{width:100%;background:rgba(0,0,0,.25);border:1px solid var(--border);color:var(--text);border-radius:10px;padding:12px 14px 12px 40px;font-size:14px;transition:.2s;outline:none}
.iw input:focus{border-color:var(--primary);background:rgba(0,0,0,.35);box-shadow:0 0 0 3px rgba(108,99,255,.2)}
.eye{position:absolute;right:12px;background:none;border:none;color:var(--muted);cursor:pointer;padding:4px;display:flex;align-items:center;transition:.2s}
.eye:hover{color:var(--text)}
.row{display:flex;align-items:flex-start;gap:10px;margin-bottom:20px;margin-top:6px}
.row input[type=checkbox]{width:16px;height:16px;accent-color:var(--primary);cursor:pointer;margin-top:2px}
.row span{font-size:13px;color:var(--muted);line-height:1.5}
.row a{color:var(--primary);text-decoration:none;font-weight:600}
.btn{width:100%;padding:13px;background:var(--primary);color:#fff;border:none;border-radius:10px;font-size:15px;font-weight:600;cursor:pointer;transition:.2s;letter-spacing:.2px;box-shadow:0 6px 20px rgba(108,99,255,.3)}
.btn:hover{background:var(--primary-h);transform:translateY(-2px);box-shadow:0 8px 24px rgba(108,99,255,.4)}
.btn:active{transform:translateY(0)}
.footer{text-align:center;margin-top:22px;font-size:13.5px;color:var(--muted)}
.footer a{color:var(--primary);font-weight:600;text-decoration:none}
</style>
</head>
<body>
<div class="orbs"><div class="orb o1"></div><div class="orb o2"></div></div>
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

    <h1>Create an account</h1>
    <p class="sub">Join TaskFlow Pro to manage your tasks efficiently</p>

    <% if (!error.isEmpty()) { %><div class="alert">&#9888; <%=error%></div><% } %>
    <% if (!success.isEmpty()) { %><div class="alert success">&#10003; <%=success%></div><% } %>

    <form method="POST" action="">
      <div class="fg">
        <label>Full Name</label>
        <div class="iw">
          <svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
          <input type="text" name="full_name" value="<%=esc(fnameVal)%>" placeholder="John Doe" required>
        </div>
      </div>

      <div class="fg">
        <label>Email Address</label>
        <div class="iw">
          <svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,12 2,6"/></svg>
          <input type="email" name="email" value="<%=esc(emailVal)%>" placeholder="you@example.com" required>
        </div>
      </div>

      <div class="fg">
        <label>Password</label>
        <div class="iw">
          <svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          <input type="password" name="password" id="pwd" placeholder="At least 8 characters" required minlength="8">
          <button type="button" class="eye" onclick="var f=document.getElementById('pwd');f.type=f.type==='password'?'text':'password'">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
          </button>
        </div>
      </div>

      <div class="row">
        <input type="checkbox" name="terms" required>
        <span>I agree to the <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a></span>
      </div>

      <button type="submit" class="btn">Create Account</button>
    </form>

    <p class="footer">Already have an account? <a href="<%=ctx%>/login.jsp">Sign In &rarr;</a></p>
  </div>
</div>
</body>
</html>
