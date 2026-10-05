package com.taskflow.model;

import java.time.LocalDateTime;

public class Category {
    private int           id;
    private int           userId;
    private String        categoryName;
    private String        color;
    private String        icon;
    private boolean       isDefault;
    private LocalDateTime createdAt;
    private int           taskCount; // populated by JOIN queries

    public Category() {}

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public int getUserId()                      { return userId; }
    public void setUserId(int v)                { this.userId = v; }

    public String getCategoryName()             { return categoryName; }
    public void setCategoryName(String v)       { this.categoryName = v; }

    public String getColor()                    { return color; }
    public void setColor(String v)              { this.color = v; }

    public String getIcon()                     { return icon; }
    public void setIcon(String v)               { this.icon = v; }

    public boolean isDefault()                  { return isDefault; }
    public void setDefault(boolean v)           { this.isDefault = v; }

    public LocalDateTime getCreatedAt()         { return createdAt; }
    public void setCreatedAt(LocalDateTime v)   { this.createdAt = v; }

    public int getTaskCount()                   { return taskCount; }
    public void setTaskCount(int v)             { this.taskCount = v; }
}
