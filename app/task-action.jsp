<%@ include file="/includes/auth.jsp" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
/* AJAX task action endpoint — returns JSON */
String action = request.getParameter("action");
String idStr  = request.getParameter("id");
int taskId = 0;
try { taskId = Integer.parseInt(idStr); } catch(Exception e){}

boolean ok = false;
String errMsg = "";

if (taskId > 0) {
    Connection con = null;
    try {
        con = db();
        if ("complete".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE tasks SET status='completed', completed_at=NOW() WHERE id=? AND user_id=?");
            ps.setInt(1, taskId); ps.setInt(2, userId);
            ok = ps.executeUpdate() > 0;
        } else if ("delete".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE tasks SET is_deleted=1 WHERE id=? AND user_id=?");
            ps.setInt(1, taskId); ps.setInt(2, userId);
            ok = ps.executeUpdate() > 0;
        } else if ("status".equals(action)) {
            String newStatus = request.getParameter("status");
            if (newStatus != null) {
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE tasks SET status=?, completed_at=CASE WHEN ?='completed' THEN NOW() ELSE NULL END WHERE id=? AND user_id=?");
                ps.setString(1, newStatus); ps.setString(2, newStatus);
                ps.setInt(3, taskId); ps.setInt(4, userId);
                ok = ps.executeUpdate() > 0;
            }
        }
    } catch(Exception ex) { errMsg = ex.getMessage(); }
    finally { if(con!=null) try{con.close();}catch(Exception e){} }
}
response.setHeader("Cache-Control","no-store");
out.print("{\"ok\":" + ok + ",\"msg\":" + jsonStr(errMsg) + "}");
%>
