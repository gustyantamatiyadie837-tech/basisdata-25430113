-- ===================================================
-- Skrip Setup Modul 1 - Tema Perpustakaan
-- NIM: 25430113
-- ===================================================

ALTER USER 'root'@'localhost' IDENTIFIED BY 'YOUR_PASSWORD';
CREATE DATABASE IF NOT EXISTS kopma_113 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS perpus_113 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'mhs_113'@'localhost' IDENTIFIED BY 'YOUR_PASSWORD';
CREATE USER IF NOT EXISTS 'dev_113'@'localhost' IDENTIFIED BY 'YOUR_PASSWORD';
CREATE USER IF NOT EXISTS 'tamu_113'@'localhost' IDENTIFIED BY 'YOUR_PASSWORD';
GRANT ALL PRIVILEGES ON kopma_113.* TO 'mhs_113'@'localhost';
GRANT ALL PRIVILEGES ON perpus_113.* TO 'dev_113'@'localhost';
GRANT SELECT ON kopma_113.* TO 'tamu_113'@'localhost';
FLUSH PRIVILEGES;
SELECT schema_name AS 'Database (%113)' 
FROM information_schema.schemata 
WHERE schema_name LIKE '%\_113';

SELECT User, Host 
FROM mysql.user 
WHERE User LIKE '%\_113';