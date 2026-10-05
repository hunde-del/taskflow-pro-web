<%@ page import="java.sql.*, java.security.*, javax.crypto.*, javax.crypto.spec.*, java.util.Base64" %>
<%!
/*
 * db.jsp - Shared helpers for TaskFlow Pro
 * NOTE: No static blocks used - plain instance methods only (Tomcat 8.5 compatible)
 */

public Connection db() throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    return DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/taskflow_pro" +
        "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=utf8",
        "root", "");
}

public String hashPwd(String password) throws Exception {
    byte[] salt = new byte[16];
    new SecureRandom().nextBytes(salt);
    PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 65536, 256);
    SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
    byte[] hash = skf.generateSecret(spec).getEncoded();
    spec.clearPassword();
    return Base64.getEncoder().encodeToString(salt)
         + ":" + Base64.getEncoder().encodeToString(hash);
}

public boolean checkPwd(String password, String stored) {
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

public String h(String s) {
    if (s == null) return "";
    return s.replace("&","&amp;").replace("<","&lt;")
            .replace(">","&gt;").replace("\"","&quot;").replace("'","&#x27;");
}

public String csrfToken(javax.servlet.http.HttpSession sess) {
    String tok = (String) sess.getAttribute("_csrf");
    if (tok == null) {
        byte[] b = new byte[24];
        new SecureRandom().nextBytes(b);
        tok = Base64.getUrlEncoder().withoutPadding().encodeToString(b);
        sess.setAttribute("_csrf", tok);
    }
    return tok;
}

public String jsonStr(String s) {
    if (s == null) return "null";
    return "\"" + s.replace("\\","\\\\").replace("\"","\\\"")
                   .replace("\n","\\n").replace("\r","\\r") + "\"";
}
%>
