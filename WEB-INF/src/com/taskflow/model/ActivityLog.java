package com.taskflow.model;

import java.time.LocalDateTime;

public class ActivityLog {
    private int           id;
    private int           userId;
    private String        action;
    private String        entityType;
    private Integer       entityId;
    private String        ipAddress;
    private LocalDateTime timestamp;

    public ActivityLog() {}

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public int getUserId()                      { return userId; }
    public void setUserId(int v)                { this.userId = v; }

    public String getAction()                   { return action; }
    public void setAction(String v)             { this.action = v; }

    public String getEntityType()               { return entityType; }
    public void setEntityType(String v)         { this.entityType = v; }

    public Integer getEntityId()                { return entityId; }
    public void setEntityId(Integer v)          { this.entityId = v; }

    public String getIpAddress()                { return ipAddress; }
    public void setIpAddress(String v)          { this.ipAddress = v; }

    public LocalDateTime getTimestamp()         { return timestamp; }
    public void setTimestamp(LocalDateTime v)   { this.timestamp = v; }
}
