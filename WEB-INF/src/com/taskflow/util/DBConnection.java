package com.taskflow.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Logger;

/**
 * DBConnection - Manages MySQL database connections for TaskFlow Pro.
 * Uses a simple singleton connection pool pattern suitable for Tomcat deployment.
 */
public class DBConnection {

    private static final Logger logger = Logger.getLogger(DBConnection.class.getName());

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/taskflow_pro"
            + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=utf8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";   // Change if XAMPP MySQL has a password

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            logger.info("MySQL JDBC Driver registered successfully.");
        } catch (ClassNotFoundException e) {
            logger.severe("MySQL JDBC Driver not found: " + e.getMessage());
            throw new ExceptionInInitializerError(e);
        }
    }

    /**
     * Returns a new MySQL connection. Caller is responsible for closing it.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    /**
     * Quietly closes a connection.
     */
    public static void close(Connection conn) {
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignored) {}
        }
    }
}
