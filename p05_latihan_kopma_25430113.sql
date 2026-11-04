-- ===================================================
-- Modul 5 - Latihan E dan langkah D.4 (basis data kopma_113)
-- NIM: 25430113
-- Jalankan SETELAH p05_uji_25430113.sql (bagian A Kopma).
-- Perintah bertanda "DITOLAK" sengaja gagal: jalankan sendiri dan tangkap layarnya.
-- ===================================================
USE kopma_113;

-- D.4 langkah 6: tambah lalu batalkan kolom tgl_kedaluwarsa
ALTER TABLE barang ADD COLUMN tgl_kedaluwarsa DATE NULL AFTER stok_min_barang;
SHOW COLUMNS FROM barang;
ALTER TABLE barang DROP COLUMN tgl_kedaluwarsa;

-- E.1 CHECK stok_min_barang tidak negatif
ALTER TABLE barang ADD CONSTRAINT ck_barang_stok_min CHECK (stok_min_barang >= 0);
-- DITOLAK -> ERROR 4025
UPDATE barang SET stok_min_barang = -5 WHERE kode_barang = 'ATK-001';

-- E.2 ON DELETE SET NULL pada fk_penjualan_anggota
ALTER TABLE penjualan DROP FOREIGN KEY fk_penjualan_anggota;
ALTER TABLE penjualan ADD CONSTRAINT fk_penjualan_anggota
  FOREIGN KEY (id_anggota) REFERENCES anggota (id_anggota) ON DELETE SET NULL;

INSERT INTO anggota (no_anggota, nim_anggota, nama_anggota, prodi_anggota, tgl_daftar_anggota)
VALUES ('A-0001','25430113','Budi Santoso','Ilmu Komputer','2026-10-01');
SET @ag = LAST_INSERT_ID();
SET @pt = (SELECT id_petugas FROM petugas WHERE kode_petugas = 'K01');
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0002', NOW(), @pt, @ag, 5000);
SELECT no_nota_penjualan, id_anggota FROM penjualan;      -- sebelum
DELETE FROM anggota WHERE id_anggota = @ag;
SELECT no_nota_penjualan, id_anggota FROM penjualan;      -- sesudah: id_anggota menjadi NULL