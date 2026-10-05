package com.taskflow.model;

import java.time.LocalDateTime;

/**
 * User model representing the `users` table.
 */
public class User {

    private int           id;
    private String        fullName;
    private String        username;
    private String        email;
    private String        passwordHash;
    private String        profilePicture;
    private String        role;          // "user" | "admin"
    private boolean       isVerified;
    private boolean       isActive;
    private String        themePref;     // "dark" | "light"
    private String        timezone;
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public User() {}

    // ------- Getters & Setters -------

    public int getId()                        { return id; }
    public void setId(int id)                 { this.id = id; }

    public String getFullName()               { return fullName; }
    public void setFullName(String v)         { this.fullName = v; }

    public String getUsername()               { return username; }
    public void setUsername(String v)         { this.username = v; }

    public String getEmail()                  { return email; }
    public void setEmail(String v)            { this.email = v; }

    public String getPasswordHash()           { return passwordHash; }
    public void setPasswordHash(String v)     { this.passwordHash = v; }

    public String getProfilePicture()         { return profilePicture; }
    public void setProfilePicture(String v)   { this.profilePicture = v; }

    public String getRole()                   { return role; }
    public void setRole(String v)             { this.role = v; }

    public boolean isVerified()               { return isVerified; }
    public void setVerified(boolean v)        { this.isVerified = v; }

    public boolean isActive()                 { return isActive; }
    public void setActive(boolean v)          { this.isActive = v; }

    public String getThemePref()              { return themePref; }
    public void setThemePref(String v)        { this.themePref = v; }

    public String getTimezone()               { return timezone; }
    public void setTimezone(String v)         { this.timezone = v; }

    public LocalDateTime getLastLogin()       { return lastLogin; }
    public void setLastLogin(LocalDateTime v) { this.lastLogin = v; }

    public LocalDateTime getCreatedAt()       { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }

    public LocalDateTime getUpdatedAt()       { return updatedAt; }
    public void setUpdatedAt(LocalDateTime v) { this.updatedAt = v; }

    public boolean isAdmin()                  { return "admin".equals(this.role); }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', email='" + email + "', role='" + role + "'}";
    }
}
