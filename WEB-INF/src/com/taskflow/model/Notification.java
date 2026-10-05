package com.taskflow.model;

import java.time.LocalDateTime;

public class Notification {
    private int           id;
    private int           userId;
    private String        title;
    private String        message;
    private String        type;
    private boolean       isRead;
    private LocalDateTime createdAt;

    public Notification() { this.isRead = false; }

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public int getUserId()                      { return userId; }
    public void setUserId(int v)                { this.userId = v; }

    public String getTitle()                    { return title; }
    public void setTitle(String v)              { this.title = v; }

    public String getMessage()                  { return message; }
    public void setMessage(String v)            { this.message = v; }

    public String getType()                     { return type; }
    public void setType(String v)               { this.type = v; }

    public boolean isRead()                     { return isRead; }
    public void setRead(boolean v)              { this.isRead = v; }

    public LocalDateTime getCreatedAt()         { return createdAt; }
    public void setCreatedAt(LocalDateTime v)   { this.createdAt = v; }

    public String getTimeAgo() {
        if (createdAt == null) return "";
        long minutes = java.time.temporal.ChronoUnit.MINUTES.between(createdAt, LocalDateTime.now());
        if (minutes < 1)  return "Just now";
        if (minutes < 60) return minutes + "m ago";
        long hours = minutes / 60;
        if (hours < 24)   return hours + "h ago";
        long days = hours / 24;
        if (days < 7)     return days + "d ago";
        return createdAt.toLocalDate().toString();
    }
}
