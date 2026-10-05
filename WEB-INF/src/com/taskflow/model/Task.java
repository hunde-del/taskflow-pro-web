package com.taskflow.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Task model representing the `tasks` table.
 */
public class Task {

    public enum Priority { high, medium, low }
    public enum Status   { pending, in_progress, completed, cancelled, overdue }

    private int           id;
    private int           userId;
    private Integer       categoryId;
    private String        categoryName;
    private String        title;
    private String        description;
    private Priority      priority;
    private Status        status;
    private LocalDate     dueDate;
    private LocalDate     startDate;
    private Integer       estimatedTime; // minutes
    private Integer       actualTime;    // minutes
    private String        notes;
    private boolean       isDeleted;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<String>  tags;

    public Task() {
        this.priority = Priority.medium;
        this.status   = Status.pending;
        this.isDeleted = false;
    }

    // ---- Getters & Setters ----

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public int getUserId()                      { return userId; }
    public void setUserId(int v)                { this.userId = v; }

    public Integer getCategoryId()              { return categoryId; }
    public void setCategoryId(Integer v)        { this.categoryId = v; }

    public String getCategoryName()             { return categoryName; }
    public void setCategoryName(String v)       { this.categoryName = v; }

    public String getTitle()                    { return title; }
    public void setTitle(String v)              { this.title = v; }

    public String getDescription()              { return description; }
    public void setDescription(String v)        { this.description = v; }

    public Priority getPriority()               { return priority; }
    public void setPriority(Priority v)         { this.priority = v; }
    public void setPriorityStr(String v)        {
        try { this.priority = Priority.valueOf(v); } catch (Exception e) { this.priority = Priority.medium; }
    }

    public Status getStatus()                   { return status; }
    public void setStatus(Status v)             { this.status = v; }
    public void setStatusStr(String v)          {
        try { this.status = Status.valueOf(v); } catch (Exception e) { this.status = Status.pending; }
    }

    public LocalDate getDueDate()               { return dueDate; }
    public void setDueDate(LocalDate v)         { this.dueDate = v; }

    public LocalDate getStartDate()             { return startDate; }
    public void setStartDate(LocalDate v)       { this.startDate = v; }

    public Integer getEstimatedTime()           { return estimatedTime; }
    public void setEstimatedTime(Integer v)     { this.estimatedTime = v; }

    public Integer getActualTime()              { return actualTime; }
    public void setActualTime(Integer v)        { this.actualTime = v; }

    public String getNotes()                    { return notes; }
    public void setNotes(String v)              { this.notes = v; }

    public boolean isDeleted()                  { return isDeleted; }
    public void setDeleted(boolean v)           { this.isDeleted = v; }

    public LocalDateTime getCompletedAt()       { return completedAt; }
    public void setCompletedAt(LocalDateTime v) { this.completedAt = v; }

    public LocalDateTime getCreatedAt()         { return createdAt; }
    public void setCreatedAt(LocalDateTime v)   { this.createdAt = v; }

    public LocalDateTime getUpdatedAt()         { return updatedAt; }
    public void setUpdatedAt(LocalDateTime v)   { this.updatedAt = v; }

    public List<String> getTags()               { return tags; }
    public void setTags(List<String> v)         { this.tags = v; }

    // ---- Helper methods ----

    public String getPriorityLabel() {
        return priority != null ? priority.name().substring(0,1).toUpperCase()
                + priority.name().substring(1) : "Medium";
    }

    public String getPriorityCss() {
        if (priority == null) return "medium";
        return priority.name();
    }

    public boolean isOverdue() {
        if (dueDate == null) return false;
        if (status == Status.completed || status == Status.cancelled) return false;
        return dueDate.isBefore(LocalDate.now());
    }

    public boolean isCompleted() { return status == Status.completed; }
}
