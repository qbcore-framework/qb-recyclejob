-- =============================================
-- QB-RecycleJob Ranking System Database Schema
-- =============================================

CREATE TABLE IF NOT EXISTS `recyclejob_ranking` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `citizenid` VARCHAR(50) NOT NULL,
    `name` VARCHAR(100) NOT NULL DEFAULT 'Unknown',
    `level` INT(11) NOT NULL DEFAULT 1,
    `current_xp` BIGINT(20) NOT NULL DEFAULT 0,
    `total_xp` BIGINT(20) NOT NULL DEFAULT 0,
    `total_deliveries` INT(11) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `citizenid` (`citizenid`),
    INDEX `idx_level` (`level` DESC),
    INDEX `idx_total_xp` (`total_xp` DESC),
    INDEX `idx_total_deliveries` (`total_deliveries` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
