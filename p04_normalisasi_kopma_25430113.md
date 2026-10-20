# Analisis Normalisasi Skema Kanonik Kopma dan Latihan

**Nama:** Gustyan Tama Tiyadie
**NIM:** 25430113

---

## 1. D.1: Dari UNF ke 1NF

Relasi awalnya berupa nota penjualan yang menyimpan data barang dalam satu grup berulang:

```text
NOTA_UNF (
  no_nota_penjualan, tgl_penjualan,
  kode_petugas, nama_petugas,
  no_anggota, nama_anggota,
  { kode_barang, nama_barang, qty_detail_penjualan,
    harga_satuan_detail_penjualan, subtotal_detail_penjualan },
  jumlah_penjualan, diskon_penjualan, total_penjualan
)
```

Agar masuk 1NF, grup berulang `{}` saya pecah sehingga setiap baris hanya memuat satu barang dalam satu nota. Satu atribut tidak lagi cukup untuk mengidentifikasi baris, jadi kunci primernya menjadi komposit: `(no_nota_penjualan, kode_barang)`.

---

## 2. D.2: Dependensi Fungsional (FD)

Dari relasi 1NF tadi, saya menemukan lima dependensi fungsional:

```text
FD1: no_nota_penjualan -> tgl_penjualan, kode_petugas, no_anggota
FD2: kode_petugas -> nama_petugas
FD3: no_anggota -> nama_anggota
FD4: kode_barang -> nama_barang
FD5: (no_nota_penjualan, kode_barang) -> qty_detail_penjualan, harga_satuan_detail_penjualan
```

---

## 3. D.3: Menuju 2NF dan 3NF

**2NF.** Beberapa atribut hanya bergantung pada sebagian kunci komposit; `nama_barang`, misalnya, cukup ditentukan oleh `kode_barang` tanpa melibatkan nomor nota. Atribut semacam itu saya pisahkan, dan hasilnya tiga tabel: `penjualan`, `barang`, dan `detail_penjualan`.

**3NF.** Tabel `penjualan` masih menyimpan ketergantungan transitif, sebab `nama_petugas` diturunkan lewat `kode_petugas` dan `nama_anggota` lewat `no_anggota`, bukan langsung dari nomor nota. Karena itu `petugas` dan `anggota` saya keluarkan menjadi tabel sendiri.

---

## 4. D.4: Pencocokan Skema Kanonik dan Pemeriksaan BCNF

Skema akhirnya terdiri dari 8 tabel. Hasil pemeriksaan saya menunjukkan tidak ada anomali yang tersisa dan semuanya memenuhi BCNF.

```text
1. petugas          (id_petugas, kode_petugas, nama_petugas, peran_petugas)
2. anggota          (id_anggota, no_anggota, nim_anggota, nama_anggota, prodi_anggota,
                     no_hp_anggota, status_anggota, tgl_daftar_anggota)
3. barang           (id_barang, kode_barang, nama_barang, kategori_barang,
                     harga_jual_barang, stok_barang, stok_min_barang)
4. pemasok          (id_pemasok, nama_pemasok, telepon_pemasok, alamat_pemasok)
5. penjualan        (id_penjualan, no_nota_penjualan, tgl_penjualan,
                     id_petugas, id_anggota, bayar_penjualan)
6. detail_penjualan (id_penjualan, id_barang, qty_detail_penjualan,
                     harga_satuan_detail_penjualan)
7. pembelian        (id_pembelian, no_faktur_pembelian, tgl_pembelian,
                     id_pemasok, status_pembelian)
8. detail_pembelian (id_pembelian, id_barang, qty_detail_pembelian,
                     harga_beli_detail_pembelian)
```

---

## 5. Hasil Latihan dan Modifikasi (Bagian E)

### **Poin 1: Pencatatan Beberapa Nomor Telepon untuk Setiap Pemasok**
* **Analisis Kebutuhan & Normalisasi:**
  * Jika tabel `pemasok` menyimpan beberapa nomor telepon dalam satu kolom, maka akan melanggar bentuk 1NF (*multivalued attribute*).
  * **Solusi Normalisasi:** Memisahkan nomor telepon ke dalam tabel tersendiri sehingga memenuhi aturan 1NF hingga 3NF.
* **Relasi Baru:**
  * `pemasok` (`id_pemasok`, `nama_pemasok`, `alamat_pemasok`)
  * `telepon_pemasok` (`id_pemasok`, `nomor_telepon`) dengan kunci primer komposit `(id_pemasok, nomor_telepon)`.

---

### **Poin 2: Pelanggaran 3NF dan Anomali Ubah pada `nama_anggota`**
* **Contoh Data yang Melanggar 3NF:**
  | id_penjualan | no_nota | id_anggota | nama_anggota | tgl_penjualan |
  | :--- | :--- | :--- | :--- | :--- |
  | 1 | NT-001 | A-05 | Budi Santoso | 2026-10-15 |
  | 2 | NT-002 | A-05 | Budi Santoso | 2026-10-16 |
  | 3 | NT-003 | A-10 | Siti Rahma | 2026-10-16 |

* **Penjelasan Pelanggaran:** 
  Terdapat ketergantungan transitif `id_anggota -> nama_anggota`, di mana atribut non-kunci (`nama_anggota`) bergantung pada atribut non-kunci lainnya (`id_anggota`), bukan bergantung langsung pada kunci primer tabel (`id_penjualan`).

* **Kueri Ubah yang Memperlihatkan Anomali Ubah (*Update Anomaly*):**
  Jika nama anggota ID `A-05` diubah menjadi `Budi Santoso Gunawan`, namun kueri ubah hanya memperbarui satu baris saja:
  ```sql
  UPDATE penjualan 
  SET nama_anggota = 'Budi Santoso Gunawan' 
  WHERE id_penjualan = 1;

  Akibatnya, timbul inkonsistensi data di mana baris id_penjualan = 1 bernama Budi Santoso Gunawan, sementara baris id_penjualan = 2 tetap Budi Santoso. Solusi 3NF mengharuskan nama_anggota dipisah ke tabel anggota.
