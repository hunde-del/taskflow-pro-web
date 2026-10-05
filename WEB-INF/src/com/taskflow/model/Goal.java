package com.taskflow.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Goal {

    public enum GoalType { daily, weekly, monthly, annual }
    public enum GoalStatus { active, completed, cancelled }

    private int           id;
    private int           userId;
    private String        goalName;
    private String        description;
    private GoalType      goalType;
    private GoalStatus    status;
    private int           progress;  // 0-100
    private LocalDate     targetDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Goal() {
        this.goalType = GoalType.weekly;
        this.status   = GoalStatus.active;
        this.progress = 0;
    }

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public int getUserId()                      { return userId; }
    public void setUserId(int v)                { this.userId = v; }

    public String getGoalName()                 { return goalName; }
    public void setGoalName(String v)           { this.goalName = v; }

    public String getDescription()              { return description; }
    public void setDescription(String v)        { this.description = v; }

    public GoalType getGoalType()               { return goalType; }
    public void setGoalTypeStr(String v)        {
        try { this.goalType = GoalType.valueOf(v); } catch (Exception e) { this.goalType = GoalType.weekly; }
    }

    public GoalStatus getStatus()               { return status; }
    public void setStatusStr(String v)          {
        try { this.status = GoalStatus.valueOf(v); } catch (Exception e) { this.status = GoalStatus.active; }
    }

    public int getProgress()                    { return progress; }
    public void setProgress(int v)              { this.progress = Math.max(0, Math.min(100, v)); }

    public LocalDate getTargetDate()            { return targetDate; }
    public void setTargetDate(LocalDate v)      { this.targetDate = v; }

    public LocalDateTime getCreatedAt()         { return createdAt; }
    public void setCreatedAt(LocalDateTime v)   { this.createdAt = v; }

    public LocalDateTime getUpdatedAt()         { return updatedAt; }
    public void setUpdatedAt(LocalDateTime v)   { this.updatedAt = v; }

    public String getGoalTypeBadge() {
        if (goalType == null) return "weekly";
        return goalType.name();
    }
}
