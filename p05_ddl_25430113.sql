-- ===================================================
-- Modul 5 - Milestone Proyek 5: DDL Perpustakaan Cakrawala GT (6 tabel)
-- NIM: 25430113
-- Basis data: perpus_113 (akun dev_113)
-- Pola nama constraint: pk_, fk_, uq_, ck_ + nama tabel
-- Komentar AB-xx merujuk p02_kebutuhan_data_25430113.md
-- ===================================================

USE perpus_113;

DROP TABLE IF EXISTS pengembalian;
DROP TABLE IF EXISTS detail_peminjaman;
DROP TABLE IF EXISTS peminjaman;
DROP TABLE IF EXISTS buku;
DROP TABLE IF EXISTS anggota;
DROP TABLE IF EXISTS petugas;

-- 1. petugas (master)
CREATE TABLE petugas (
  id_petugas     SMALLINT                         NOT NULL AUTO_INCREMENT,
  kode_petugas   CHAR(3)                          NOT NULL,
  nama_petugas   VARCHAR(100)                     NOT NULL,
  peran_petugas  ENUM('pustakawan','admin')       NOT NULL,
  CONSTRAINT pk_petugas PRIMARY KEY (id_petugas),
  CONSTRAINT uq_petugas_kode UNIQUE (kode_petugas)
) ENGINE=InnoDB;

-- 2. anggota (master)
CREATE TABLE anggota (
  id_anggota          INT                       NOT NULL AUTO_INCREMENT,
  no_anggota          CHAR(6)                   NOT NULL,   -- format A-0123
  nim_anggota         CHAR(8)                   NOT NULL,
  nama_anggota        VARCHAR(100)              NOT NULL,
  prodi_anggota       VARCHAR(60)               NOT NULL,
  no_hp_anggota       VARCHAR(15)               NULL,       -- data pribadi, boleh kosong
  status_anggota      ENUM('aktif','nonaktif')  NOT NULL DEFAULT 'aktif',  -- AB-02
  tgl_daftar_anggota  DATE                      NOT NULL,
  CONSTRAINT pk_anggota PRIMARY KEY (id_anggota),
  CONSTRAINT uq_anggota_no  UNIQUE (no_anggota),            -- AB-05
  CONSTRAINT uq_anggota_nim UNIQUE (nim_anggota)            -- AB-05
) ENGINE=InnoDB;

-- 3. buku (master)
CREATE TABLE buku (
  id_buku            INT           NOT NULL AUTO_INCREMENT,
  kode_buku          VARCHAR(20)   NOT NULL,                -- contoh BK-ATK-001
  judul_buku         VARCHAR(200)  NOT NULL,
  penulis_buku       VARCHAR(100)  NOT NULL,
  penerbit_buku      VARCHAR(100)  NULL,
  tahun_terbit_buku  YEAR          NULL,
  kategori_buku      VARCHAR(50)   NOT NULL,
  stok_buku          INT           NOT NULL DEFAULT 0,
  CONSTRAINT pk_buku PRIMARY KEY (id_buku),
  CONSTRAINT uq_buku_kode UNIQUE (kode_buku),
  CONSTRAINT ck_buku_stok CHECK (stok_buku >= 0)            -- AB-06, AB-07
) ENGINE=InnoDB;

-- 4. peminjaman (kepala transaksi)
CREATE TABLE peminjaman (
  id_peminjaman      INT        NOT NULL AUTO_INCREMENT,
  no_peminjaman      CHAR(11)   NOT NULL,                   -- format PJ-2610-001
  tgl_pinjam         DATETIME   NOT NULL,
  tgl_jatuh_tempo    DATETIME   NOT NULL,                   -- AB-04: 7 hari dari tgl_pinjam
  id_petugas         SMALLINT   NOT NULL,
  id_anggota         INT        NOT NULL,
  status_peminjaman  ENUM('dipinjam','dikembalikan') NOT NULL DEFAULT 'dipinjam',
  CONSTRAINT pk_peminjaman PRIMARY KEY (id_peminjaman),
  CONSTRAINT uq_peminjaman_no UNIQUE (no_peminjaman),       -- AB-01
  CONSTRAINT fk_peminjaman_petugas FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas),
  CONSTRAINT fk_peminjaman_anggota FOREIGN KEY (id_anggota) REFERENCES anggota (id_anggota),
  CONSTRAINT ck_peminjaman_tempo CHECK (tgl_jatuh_tempo >= tgl_pinjam)  -- AB-04
) ENGINE=InnoDB;

-- 5. detail_peminjaman (detail transaksi)
CREATE TABLE detail_peminjaman (
  id_peminjaman         INT       NOT NULL,
  id_buku               INT       NOT NULL,
  qty_pinjam            SMALLINT  NOT NULL,
  kondisi_buku_pinjam   ENUM('baik','rusak')         NOT NULL DEFAULT 'baik',  -- AB-08
  kondisi_buku_kembali  ENUM('baik','rusak','hilang') NULL,                    -- AB-08, NULL sebelum kembali
  CONSTRAINT pk_detail_peminjaman PRIMARY KEY (id_peminjaman, id_buku),        -- AB-01: tiap buku sekali per transaksi
  CONSTRAINT fk_detail_peminjaman_peminjaman FOREIGN KEY (id_peminjaman)
    REFERENCES peminjaman (id_peminjaman) ON DELETE CASCADE,
  CONSTRAINT fk_detail_peminjaman_buku FOREIGN KEY (id_buku)
    REFERENCES buku (id_buku),
  -- AB-03 (P + 2 = 7): hanya sisi per baris yang dapat dijaga CHECK
  CONSTRAINT ck_detail_peminjaman_qty CHECK (qty_pinjam > 0 AND qty_pinjam <= 7)
) ENGINE=InnoDB;

-- 6. pengembalian (satu peminjaman dikembalikan satu kali)
CREATE TABLE pengembalian (
  id_pengembalian     INT            NOT NULL AUTO_INCREMENT,
  id_peminjaman       INT            NOT NULL,
  id_petugas          SMALLINT       NOT NULL,
  tgl_kembali_aktual  DATE           NOT NULL,
  jumlah_denda        DECIMAL(12,2)  NOT NULL DEFAULT 0,    -- AB-04: Rp5.000 per hari terlambat
  status_denda        ENUM('tidak_ada','belum_lunas','lunas') NOT NULL DEFAULT 'tidak_ada',
  CONSTRAINT pk_pengembalian PRIMARY KEY (id_pengembalian),
  CONSTRAINT uq_pengembalian_peminjaman UNIQUE (id_peminjaman),   -- relasi 1:0..1
  CONSTRAINT fk_pengembalian_peminjaman FOREIGN KEY (id_peminjaman) REFERENCES peminjaman (id_peminjaman),
  CONSTRAINT fk_pengembalian_petugas FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas),
  CONSTRAINT ck_pengembalian_denda CHECK (jumlah_denda >= 0)
) ENGINE=InnoDB;

-- ===================================================
-- Aturan bisnis yang TIDAK dapat dijaga constraint (diselesaikan di Modul 14):
--  AB-02  anggota harus berstatus aktif untuk meminjam (lintas tabel)
--  AB-03  maksimal 7 buku per transaksi (melibatkan banyak baris)
--  AB-06  stok berkurang saat dipinjam dan bertambah saat kembali
--  AB-07  buku stok habis / rusak / hilang tidak dapat dipinjam
-- ===================================================

-- Verifikasi
SHOW TABLES;
SHOW CREATE TABLE peminjaman;