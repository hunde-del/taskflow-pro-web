<%@ page import="java.sql.*, java.nio.file.*, java.security.*, javax.crypto.*, javax.crypto.spec.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%!
public static String hashForSetup(String password) {
    try {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 65536, 256);
        SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] hash = skf.generateSecret(spec).getEncoded();
        spec.clearPassword();
        return java.util.Base64.getEncoder().encodeToString(salt)
             + ":" + java.util.Base64.getEncoder().encodeToString(hash);
    } catch (Exception e) { return "err:" + e.getMessage(); }
}
%><!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>TaskFlow Pro - Setup</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif}
body{min-height:100vh;background:linear-gradient(135deg,#0f111a,#1a1c2e);display:flex;align-items:center;justify-content:center}
.card{background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:16px;padding:40px;width:100%;max-width:580px;color:#fff}
h1{font-size:24px;margin-bottom:8px;color:#6C63FF}
p{color:#a0a4b8;margin-bottom:20px;font-size:14px}
.log{background:rgba(0,0,0,.3);border-radius:8px;padding:16px;font-size:13px;font-family:monospace;max-height:340px;overflow-y:auto;line-height:1.9}
.ok{color:#72EF36}.er{color:#FF6584}.in{color:#43CBFF}
.btn{display:inline-block;margin-top:20px;padding:12px 28px;background:#6C63FF;color:#fff;border-radius:8px;text-decoration:none;font-weight:600}
</style>
</head>
<body>
<div class="card">
<h1>TaskFlow Pro - Database Setup</h1>
<p>Creating tables, trigger, and admin account...</p>
<div class="log" id="log">
<%
String dbRoot = "jdbc:mysql://localhost:3306/?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=utf8";
String dbApp  = "jdbc:mysql://localhost:3306/taskflow_pro?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=utf8";
String dbUser = "root";
String dbPass = "";
java.sql.Connection con = null;
int okCount = 0;
int errCount = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    out.print("<span class='ok'>&#10003; MySQL Driver loaded</span><br>"); out.flush();

    con = java.sql.DriverManager.getConnection(dbRoot, dbUser, dbPass);
    con.createStatement().execute(
        "CREATE DATABASE IF NOT EXISTS taskflow_pro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    out.print("<span class='ok'>&#10003; Database 'taskflow_pro' ready</span><br>"); out.flush();
    con.close();

    con = java.sql.DriverManager.getConnection(dbApp, dbUser, dbPass);
    java.sql.Statement st = con.createStatement();

    String sqlFile = application.getRealPath("/database/taskflow_schema.sql");
    String sqlText = new String(Files.readAllBytes(Paths.get(sqlFile)), "UTF-8");
    sqlText = sqlText.replaceAll("--[^\n]*", "").replaceAll("/\\*[^*]*\\*/", "");
    String[] stmts = sqlText.split(";");

    for (int i = 0; i < stmts.length; i++) {
        String s = stmts[i].trim();
        if (s.length() == 0) continue;
        String u = s.toUpperCase();
        if (u.startsWith("CREATE DATABASE") || u.startsWith("USE ")) continue;
        try {
            st.execute(s);
            String lbl = u.contains("CREATE TABLE") ? "Table created" : "Statement executed";
            out.print("<span class='ok'>&#10003; " + lbl + "</span><br>");
            okCount++;
        } catch (Exception ex2) {
            String em = ex2.getMessage();
            if (em != null && em.toLowerCase().contains("already exists")) {
                out.print("<span class='in'>&#8505; Already exists - skipped</span><br>");
            } else {
                out.print("<span class='er'>&#10007; " + (em != null ? em.replace("<","&lt;") : "?") + "</span><br>");
                errCount++;
            }
        }
        out.flush();
    }

    try {
        st.execute("DROP TRIGGER IF EXISTS after_user_insert");
        st.execute(
            "CREATE TRIGGER after_user_insert AFTER INSERT ON users FOR EACH ROW BEGIN " +
            "INSERT INTO categories(user_id,category_name,color,icon,is_default) VALUES" +
            "(NEW.id,'Work','#6C63FF','briefcase',1)," +
            "(NEW.id,'Personal','#FF6584','user',1)," +
            "(NEW.id,'Study','#43CBFF','book',1)," +
            "(NEW.id,'Health','#72EF36','heart',1)," +
            "(NEW.id,'Shopping','#FFD166','shopping-cart',1)," +
            "(NEW.id,'Finance','#F4845F','dollar-sign',1);" +
            " END");
        out.print("<span class='ok'>&#10003; Trigger created</span><br>"); out.flush();
    } catch (Exception tex) {
        out.print("<span class='er'>&#10007; Trigger: " + tex.getMessage() + "</span><br>"); out.flush();
    }

    try {
        java.sql.ResultSet chk = st.executeQuery("SELECT COUNT(*) FROM users WHERE email='admin@taskflow.pro'");
        chk.next();
        if (chk.getInt(1) == 0) {
            java.sql.PreparedStatement ins = con.prepareStatement(
                "INSERT INTO users(full_name,username,email,password_hash,role,is_verified,is_active,theme_pref)" +
                " VALUES('System Admin','admin','admin@taskflow.pro',?,'admin',1,1,'dark')");
            ins.setString(1, hashForSetup("Admin@123"));
            ins.executeUpdate();
            out.print("<span class='ok'>&#10003; Admin created: admin@taskflow.pro / Admin@123</span><br>");
        } else {
            out.print("<span class='in'>&#8505; Admin already exists</span><br>");
        }
        out.flush();
    } catch (Exception aex) {
        out.print("<span class='er'>&#10007; Admin: " + aex.getMessage() + "</span><br>"); out.flush();
    }

    out.print("<br><span class='ok'>&#127881; DONE! " + okCount + " OK");
    if (errCount > 0) out.print(", " + errCount + " errors");
    out.print("</span><br>");

} catch (ClassNotFoundException cnf) {
    out.print("<span class='er'>&#10007; Driver missing - visit copy-jar.jsp first</span><br>");
} catch (Exception ex) {
    out.print("<span class='er'>&#10007; Fatal: " + ex.getMessage() + "</span><br>");
} finally {
    if (con != null) try { con.close(); } catch (Exception ig) {}
}
%>
</div>
<a class="btn" href="<%=request.getContextPath()%>/login.jsp">Open TaskFlow Pro &rarr;</a>
</div>
<script>document.getElementById('log').scrollTop=99999;</script>
</body>
</html>
