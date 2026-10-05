<%@ page import="java.io.*, java.nio.file.*" %>
<%
    try {
        Path src = Paths.get("c:/xampp/tomcat/webapps/javaProject/WEB-INF/lib/mysql-connector-j-8.0.33.jar");
        Path destDir = Paths.get(application.getRealPath("/WEB-INF/lib"));
        if(!Files.exists(destDir)) Files.createDirectories(destDir);
        Path dest = destDir.resolve("mysql-connector-j-8.0.33.jar");
        
        Files.copy(src, dest, StandardCopyOption.REPLACE_EXISTING);
        out.println("<h3>JAR copied successfully!</h3>");
        out.println("<p>Please <a href='setup.jsp'>click here</a> to restart setup.</p>");
    } catch(Exception e) {
        out.println("Error copying JAR: " + e.getMessage());
    }
%>
