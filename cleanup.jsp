<%@ page contentType="text/html;charset=UTF-8" %>
<%
/* Deletes all stale compiled JSP classes from Tomcat's work folder for this app */
java.nio.file.Path workPath = java.nio.file.Paths.get(System.getProperty("catalina.home"), "work", "Catalina", "localhost", "to-do-list");
int deleted = 0;
if (java.nio.file.Files.exists(workPath)) {
    try (java.util.stream.Stream<java.nio.file.Path> walk = java.nio.file.Files.walk(workPath)) {
        java.util.List<java.nio.file.Path> toDelete = walk.filter(p -> {
            String n = p.getFileName().toString();
            return n.endsWith(".class") || n.endsWith(".java");
        }).collect(java.util.stream.Collectors.toList());
        for (java.nio.file.Path p : toDelete) {
            try { java.nio.file.Files.delete(p); deleted++; } catch(Exception ignored){}
        }
    } catch(Exception ignored){}
}
out.println("<h3 style='font-family:monospace;color:lime;background:#111;padding:20px'>");
out.println("Cleared " + deleted + " stale class files from work directory.<br>");
out.println("Now <a href='login.jsp' style='color:#6C63FF'>click here to open the Login page</a>.");
out.println("</h3>");
%>
