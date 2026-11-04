-- ===================================================
-- Modul 5 - DDL Skema Kanonik Kopma (8 tabel)
-- NIM: 25430113
-- Basis data: kopma_113 (akun mhs_113)
-- Pola nama constraint: pk_, fk_, uq_, ck_ + nama tabel
-- ===================================================

USE kopma_113;

DROP TABLE IF EXISTS detail_pembelian;
DROP TABLE IF EXISTS detail_penjualan;
DROP TABLE IF EXISTS pembelian;
DROP TABLE IF EXISTS penjualan;
DROP TABLE IF EXISTS pemasok;
DROP TABLE IF EXISTS barang;
DROP TABLE IF EXISTS anggota;
DROP TABLE IF EXISTS petugas;

-- 1. petugas (master)
CREATE TABLE petugas (
  id_petugas     SMALLINT                      NOT NULL AUTO_INCREMENT,
  kode_petugas   CHAR(3)                       NOT NULL,
  nama_petugas   VARCHAR(100)                  NOT NULL,
  peran_petugas  ENUM('kasir','gudang','ketua') NOT NULL,
  CONSTRAINT pk_petugas PRIMARY KEY (id_petugas),
  CONSTRAINT uq_petugas_kode UNIQUE (kode_petugas)
) ENGINE=InnoDB;

-- 2. anggota (master)
CREATE TABLE anggota (
  id_anggota          INT                       NOT NULL AUTO_INCREMENT,
  no_anggota          CHAR(6)                   NOT NULL,   -- format A-0457
  nim_anggota         CHAR(8)                   NOT NULL,   -- kode, bukan angka hitung
  nama_anggota        VARCHAR(100)              NOT NULL,
  prodi_anggota       VARCHAR(60)               NOT NULL,
  no_hp_anggota       VARCHAR(15)               NULL,       -- data pribadi, boleh kosong
  status_anggota      ENUM('aktif','nonaktif')  NOT NULL DEFAULT 'aktif',  -- AB-02
  tgl_daftar_anggota  DATE                      NOT NULL,
  CONSTRAINT pk_anggota PRIMARY KEY (id_anggota),
  CONSTRAINT uq_anggota_no  UNIQUE (no_anggota),            -- AB-05
  CONSTRAINT uq_anggota_nim UNIQUE (nim_anggota)            -- AB-05
) ENGINE=InnoDB;

-- 3. barang (master)
CREATE TABLE barang (
  id_barang          INT                              NOT NULL AUTO_INCREMENT,
  kode_barang        VARCHAR(10)                      NOT NULL,
  nama_barang        VARCHAR(100)                     NOT NULL,
  kategori_barang    ENUM('ATK','makanan','minuman')  NOT NULL,
  harga_jual_barang  DECIMAL(12,2)                    NOT NULL,
  stok_barang        INT                              NOT NULL DEFAULT 0,
  stok_min_barang    INT                              NOT NULL DEFAULT 5,   -- AB-06
  CONSTRAINT pk_barang PRIMARY KEY (id_barang),
  CONSTRAINT uq_barang_kode UNIQUE (kode_barang),
  CONSTRAINT ck_barang_stok  CHECK (stok_barang >= 0),        -- AB-03
  CONSTRAINT ck_barang_harga CHECK (harga_jual_barang >= 0)
) ENGINE=InnoDB;

-- 4. pemasok (master)
CREATE TABLE pemasok (
  id_pemasok       SMALLINT      NOT NULL AUTO_INCREMENT,
  nama_pemasok     VARCHAR(100)  NOT NULL,
  telepon_pemasok  VARCHAR(15)   NULL,
  alamat_pemasok   VARCHAR(200)  NULL,
  CONSTRAINT pk_pemasok PRIMARY KEY (id_pemasok)
) ENGINE=InnoDB;

-- 5. penjualan (kepala transaksi)
CREATE TABLE penjualan (
  id_penjualan       INT           NOT NULL AUTO_INCREMENT,
  no_nota_penjualan  CHAR(12)      NOT NULL,                  -- format PJ-2609-0142
  tgl_penjualan      DATETIME      NOT NULL,
  id_petugas         SMALLINT      NOT NULL,                  -- nota wajib punya kasir
  id_anggota         INT           NULL,                      -- NULL = pembeli umum (AB-02)
  bayar_penjualan    DECIMAL(12,2) NOT NULL,
  CONSTRAINT pk_penjualan PRIMARY KEY (id_penjualan),
  CONSTRAINT uq_penjualan_nota UNIQUE (no_nota_penjualan),    -- AB-01
  CONSTRAINT fk_penjualan_petugas FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas),
  CONSTRAINT fk_penjualan_anggota FOREIGN KEY (id_anggota) REFERENCES anggota (id_anggota),
  CONSTRAINT ck_penjualan_bayar CHECK (bayar_penjualan >= 0)
) ENGINE=InnoDB;

-- 6. detail_penjualan (detail transaksi)
CREATE TABLE detail_penjualan (
  id_penjualan                   INT           NOT NULL,
  id_barang                      INT           NOT NULL,
  qty_detail_penjualan           SMALLINT      NOT NULL,
  harga_satuan_detail_penjualan  DECIMAL(12,2) NOT NULL,      -- AB-04: salinan harga saat transaksi
  CONSTRAINT pk_detail_penjualan PRIMARY KEY (id_penjualan, id_barang),
  CONSTRAINT fk_detail_penjualan FOREIGN KEY (id_penjualan)
    REFERENCES penjualan (id_penjualan) ON DELETE CASCADE,    -- nota batal, rincian ikut terhapus
  CONSTRAINT fk_detail_barang FOREIGN KEY (id_barang)
    REFERENCES barang (id_barang),
  CONSTRAINT ck_detail_qty   CHECK (qty_detail_penjualan > 0),
  CONSTRAINT ck_detail_penjualan_harga CHECK (harga_satuan_detail_penjualan >= 0)
) ENGINE=InnoDB;

-- 7. pembelian (kepala faktur pemasok)
CREATE TABLE pembelian (
  id_pembelian         INT          NOT NULL AUTO_INCREMENT,
  no_faktur_pembelian  VARCHAR(20)  NOT NULL,                 -- dari pemasok, sengaja tidak UNIQUE
  tgl_pembelian        DATE         NOT NULL,
  id_pemasok           SMALLINT     NOT NULL,
  status_pembelian     ENUM('dipesan','diterima') NOT NULL DEFAULT 'dipesan',  -- AB-06
  CONSTRAINT pk_pembelian PRIMARY KEY (id_pembelian),
  CONSTRAINT fk_pembelian_pemasok FOREIGN KEY (id_pemasok) REFERENCES pemasok (id_pemasok)
) ENGINE=InnoDB;

-- 8. detail_pembelian (detail faktur)
CREATE TABLE detail_pembelian (
  id_pembelian                 INT           NOT NULL,
  id_barang                    INT           NOT NULL,
  qty_detail_pembelian         SMALLINT      NOT NULL,
  harga_beli_detail_pembelian  DECIMAL(12,2) NOT NULL,
  CONSTRAINT pk_detail_pembelian PRIMARY KEY (id_pembelian, id_barang),
  CONSTRAINT fk_detail_pembelian FOREIGN KEY (id_pembelian)
    REFERENCES pembelian (id_pembelian) ON DELETE CASCADE,
  CONSTRAINT fk_detail_pembelian_barang FOREIGN KEY (id_barang)
    REFERENCES barang (id_barang),
  CONSTRAINT ck_detail_pembelian_qty   CHECK (qty_detail_pembelian > 0),
  CONSTRAINT ck_detail_pembelian_harga CHECK (harga_beli_detail_pembelian >= 0)
) ENGINE=InnoDB;

-- Verifikasi
SHOW TABLES;
SHOW CREATE TABLE penjualan;