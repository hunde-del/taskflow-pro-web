-- ============================================================
-- TaskFlow Pro - MySQL Database Schema (JDBC-compatible)
-- No DELIMITER commands - safe for execution via JDBC
-- ============================================================

CREATE DATABASE IF NOT EXISTS taskflow_pro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE taskflow_pro;

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100)  NOT NULL,
    username        VARCHAR(50)   NOT NULL UNIQUE,
    email           VARCHAR(150)  NOT NULL UNIQUE,
    password_hash   VARCHAR(512)  NOT NULL,
    profile_picture VARCHAR(500)  DEFAULT NULL,
    role            ENUM('user','admin') NOT NULL DEFAULT 'user',
    is_verified     TINYINT(1)    NOT NULL DEFAULT 1,
    is_active       TINYINT(1)    NOT NULL DEFAULT 1,
    theme_pref      ENUM('dark','light') DEFAULT 'dark',
    timezone        VARCHAR(50)   DEFAULT 'UTC',
    reset_token     VARCHAR(255)  DEFAULT NULL,
    reset_token_exp DATETIME      DEFAULT NULL,
    last_login      DATETIME      DEFAULT NULL,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email    (email),
    INDEX idx_username (username),
    INDEX idx_role     (role)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: categories
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT          NOT NULL,
    category_name VARCHAR(80)  NOT NULL,
    color         VARCHAR(20)  DEFAULT '#6C63FF',
    icon          VARCHAR(50)  DEFAULT 'folder',
    is_default    TINYINT(1)   NOT NULL DEFAULT 0,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: tasks
-- ============================================================
CREATE TABLE IF NOT EXISTS tasks (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT           NOT NULL,
    category_id     INT           DEFAULT NULL,
    title           VARCHAR(200)  NOT NULL,
    description     TEXT          DEFAULT NULL,
    priority        ENUM('high','medium','low') NOT NULL DEFAULT 'medium',
    status          ENUM('pending','in_progress','completed','cancelled','overdue') NOT NULL DEFAULT 'pending',
    due_date        DATE          DEFAULT NULL,
    start_date      DATE          DEFAULT NULL,
    estimated_time  INT           DEFAULT NULL COMMENT 'minutes',
    actual_time     INT           DEFAULT NULL COMMENT 'minutes',
    notes           TEXT          DEFAULT NULL,
    is_deleted      TINYINT(1)    NOT NULL DEFAULT 0,
    completed_at    DATETIME      DEFAULT NULL,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)     REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_user_id    (user_id),
    INDEX idx_status     (status),
    INDEX idx_priority   (priority),
    INDEX idx_due_date   (due_date),
    INDEX idx_is_deleted (is_deleted)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: tags
-- ============================================================
CREATE TABLE IF NOT EXISTS tags (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    user_id  INT         NOT NULL,
    tag_name VARCHAR(50) NOT NULL,
    color    VARCHAR(20) DEFAULT '#6C63FF',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_tag (user_id, tag_name)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: task_tags
-- ============================================================
CREATE TABLE IF NOT EXISTS task_tags (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    tag_id  INT NOT NULL,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id)  REFERENCES tags(id)  ON DELETE CASCADE,
    UNIQUE KEY uq_task_tag (task_id, tag_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: goals
-- ============================================================
CREATE TABLE IF NOT EXISTS goals (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT           NOT NULL,
    goal_name   VARCHAR(200)  NOT NULL,
    description TEXT          DEFAULT NULL,
    goal_type   ENUM('daily','weekly','monthly','annual') NOT NULL DEFAULT 'weekly',
    status      ENUM('active','completed','cancelled') NOT NULL DEFAULT 'active',
    progress    INT           NOT NULL DEFAULT 0,
    target_date DATE          DEFAULT NULL,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT           NOT NULL,
    title      VARCHAR(150)  NOT NULL,
    message    TEXT          NOT NULL,
    type       ENUM('task_reminder','due_alert','goal_reminder','system') DEFAULT 'system',
    is_read    TINYINT(1)    NOT NULL DEFAULT 0,
    created_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_unread (user_id, is_read)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: activity_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS activity_logs (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT           NOT NULL,
    action      VARCHAR(200)  NOT NULL,
    entity_type VARCHAR(50)   DEFAULT NULL,
    entity_id   INT           DEFAULT NULL,
    ip_address  VARCHAR(45)   DEFAULT NULL,
    timestamp   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_time (user_id, timestamp)
) ENGINE=InnoDB;
