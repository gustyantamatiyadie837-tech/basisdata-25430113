-- ===================================================
-- Modul 5 - Pembuktian constraint (langkah D.3 + uji proyek)
-- NIM: 25430113
-- BAGIAN A aman dijalankan sekaligus.
-- BAGIAN B: setiap perintah SENGAJA ditolak.

-- ############ KOPMA ############
USE kopma_113;

-- BAGIAN A: data induk secukupnya + satu nota sah
INSERT INTO petugas (kode_petugas, nama_petugas, peran_petugas)
VALUES ('K01','Siska Wulandari','kasir'), ('G01','Rudi Hartono','gudang');
INSERT INTO barang (kode_barang, nama_barang, kategori_barang, harga_jual_barang, stok_barang)
VALUES ('ATK-001','Pulpen Biru','ATK',4000,35), ('MKN-001','Roti Cokelat','makanan',5000,20);

SET @pt  = (SELECT id_petugas FROM petugas WHERE kode_petugas = 'K01');
SET @brg = (SELECT id_barang  FROM barang  WHERE kode_barang  = 'ATK-001');
SET @brg2 = (SELECT id_barang FROM barang  WHERE kode_barang  = 'MKN-001');
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0001', NOW(), @pt, NULL, 8000);
SET @nota = LAST_INSERT_ID();
INSERT INTO detail_penjualan VALUES (@nota, @brg, 2, 4000);

-- BAGIAN B (satu per satu, semuanya harus ditolak)
-- B1. FK: petugas 99 tidak ada                          -> ERROR 1452
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0199', NOW(), 99, NULL, 5000);
-- B2. CHECK: stok negatif                               -> ERROR 4025 (AB-03)
UPDATE barang SET stok_barang = -1 WHERE id_barang = @brg;
-- B3. UNIQUE: kode barang kembar                        -> ERROR 1062
INSERT INTO barang (kode_barang, nama_barang, kategori_barang, harga_jual_barang)
VALUES ('ATK-001','Duplikat','ATK',1000);
-- B4. CHECK: qty nol                                    -> ERROR 4025
INSERT INTO detail_penjualan VALUES (@nota, @brg2, 0, 5000);
-- B5. Hapus petugas yang sudah dipakai nota             -> ERROR 1451
DELETE FROM petugas WHERE id_petugas = @pt;
-- B6. Hapus barang yang sudah dipakai detail (Titik Analisis 1) -> ERROR 1451
DELETE FROM barang WHERE id_barang = @brg;

-- ############ PERPUSTAKAAN ############
USE perpus_113;

-- BAGIAN A
INSERT INTO petugas (kode_petugas, nama_petugas, peran_petugas) VALUES ('P01','Siska Wulandari','pustakawan');
INSERT INTO anggota (no_anggota, nim_anggota, nama_anggota, prodi_anggota, tgl_daftar_anggota)
VALUES ('A-0123','25430113','Budi Santoso','Ilmu Komputer','2026-10-01');
INSERT INTO buku (kode_buku, judul_buku, penulis_buku, kategori_buku, stok_buku)
VALUES ('BK-ATK-001','Basis Data Lanjut','Dedi Irawan','Teknologi Informasi',15);
SET @pg = (SELECT id_petugas FROM petugas WHERE kode_petugas = 'P01');
SET @ag = (SELECT id_anggota FROM anggota WHERE nim_anggota = '25430113');
SET @bk = (SELECT id_buku    FROM buku    WHERE kode_buku  = 'BK-ATK-001');
INSERT INTO peminjaman (no_peminjaman, tgl_pinjam, tgl_jatuh_tempo, id_petugas, id_anggota)
VALUES ('PJ-2610-001','2026-10-07 10:30:00','2026-10-14 23:59:59',@pg,@ag);
SET @pj = LAST_INSERT_ID();
INSERT INTO pengembalian (id_peminjaman, id_petugas, tgl_kembali_aktual, jumlah_denda, status_denda)
VALUES (@pj, @pg, '2026-10-15', 5000, 'belum_lunas');

-- BAGIAN B (satu per satu, semuanya harus ditolak)
-- P1. CHECK: qty > 7 (batas P+2 = 7 per baris, AB-03)   -> ERROR 4025
INSERT INTO detail_peminjaman (id_peminjaman, id_buku, qty_pinjam) VALUES (@pj, @bk, 8);
-- P2. CHECK: stok negatif (AB-06/AB-07)                 -> ERROR 4025
UPDATE buku SET stok_buku = -1 WHERE id_buku = @bk;
-- P3. UNIQUE: NIM kembar (AB-05)                        -> ERROR 1062
INSERT INTO anggota (no_anggota, nim_anggota, nama_anggota, prodi_anggota, tgl_daftar_anggota)
VALUES ('A-0124','25430113','Dobel','Ilmu Komputer','2026-10-02');
-- P4. CHECK: jatuh tempo sebelum tanggal pinjam (AB-04) -> ERROR 4025
INSERT INTO peminjaman (no_peminjaman, tgl_pinjam, tgl_jatuh_tempo, id_petugas, id_anggota)
VALUES ('PJ-2610-002','2026-10-07','2026-10-01',@pg,@ag);
-- P5. FK: anggota 99 tidak ada                          -> ERROR 1452
INSERT INTO peminjaman (no_peminjaman, tgl_pinjam, tgl_jatuh_tempo, id_petugas, id_anggota)
VALUES ('PJ-2610-003','2026-10-07','2026-10-14',@pg,99);
-- P6. UNIQUE: satu peminjaman dikembalikan dua kali     -> ERROR 1062
INSERT INTO pengembalian (id_peminjaman, id_petugas, tgl_kembali_aktual) VALUES (@pj, @pg, '2026-10-16');