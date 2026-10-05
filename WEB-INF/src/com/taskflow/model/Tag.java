package com.taskflow.model;

public class Tag {
    private int    id;
    private int    userId;
    private String tagName;
    private String color;

    public Tag() {}

    public int getId()              { return id; }
    public void setId(int id)       { this.id = id; }

    public int getUserId()          { return userId; }
    public void setUserId(int v)    { this.userId = v; }

    public String getTagName()      { return tagName; }
    public void setTagName(String v){ this.tagName = v; }

    public String getColor()        { return color; }
    public void setColor(String v)  { this.color = v; }
}
