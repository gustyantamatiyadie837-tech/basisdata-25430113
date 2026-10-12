# Dokumen Kebutuhan Data Koperasi Mahasiswa Sejahtera (Kopma 113)

## 1. Latar belakang dan aktivitas organisasi
Koperasi Mahasiswa Sejahtera (Kopma) adalah unit usaha yang bergerak di bidang penyediaan alat tulis, makanan ringan, dan minuman bagi civitas akademika di lingkungan kampus. Sebelum menggunakan sistem basis data, pencatatan dilakukan secara manual menggunakan buku tulis dan spreadsheet, yang sering kali menimbulkan kendala seperti hilangnya riwayat harga lama dan kesalahan pencatatan stok minus. Dokumen ini disusun untuk menganalisis kebutuhan pengelolaan data Kopma guna perancangan sistem basis data yang andal.

## 2. Aktor dan proses bisnis
* **Aktor:** Anggota (Mahasiswa), Kasir, Petugas Gudang, dan Ketua Koperasi.
* **Proses Bisnis (PB):**
  * `PB-01`: Mendaftarkan anggota baru (oleh Kasir atas permintaan mahasiswa).
  * `PB-02`: Mencatat transaksi penjualan (oleh Kasir saat pembeli membayar).
  * `PB-03`: Memesan barang ke pemasok (oleh Petugas Gudang saat stok di bawah batas minimum).
  * `PB-04`: Menerima barang dari pemasok beserta faktur (oleh Petugas Gudang).
  * `PB-05`: Menyusun laporan bulanan (oleh Ketua Koperasi setiap awal bulan).

## 3. Dokumen sumber yang dianalisis
Dokumen utama yang dianalisis adalah **Nota Penjualan Kopma**, yang mencakup:
* Identitas transaksi: No. Nota, Tanggal-Jam, Kasir, Anggota.
* Rincian barang: Nama Barang, Qty, Harga Satuan, dan Subtotal.
* Ringkasan pembayaran: Jumlah, Diskon anggota (5%), Total, Bayar tunai, dan Kembali.

## 4. Entitas kandidat dan elemen data
1. **Anggota:** nomor anggota, NIM, nama, program studi, nomor HP, status aktif, tanggal daftar.
2. **Barang:** kode barang, nama barang, kategori, harga jual, stok, batas minimum stok.
3. **Petugas:** kode petugas, nama petugas, peran (kasir/gudang/ketua).
4. **Pemasok:** kode/id pemasok, nama, telepon, alamat.
5. **Penjualan (Kepala):** nomor nota, tanggal-jam, kasir, anggota (opsional), bayar.
6. **Detail Penjualan:** nomor nota, barang, qty, harga saat transaksi.
7. **Pembelian & Detail Pembelian:** nomor faktur, tanggal, pemasok, barang, qty, harga beli.

## 5. Aturan bisnis
* `AB-01`: Setiap nota memiliki nomor unik dan minimal satu baris barang.
* `AB-02`: Penjualan boleh tanpa anggota (pembeli umum); jika ada, anggota harus berstatus aktif untuk memperoleh diskon 5%.
* `AB-03`: Stok barang tidak boleh negatif; penjualan ditolak bila qty melebihi stok tersedia.
* `AB-04`: Harga jual yang dipakai pada nota disimpan per baris dan tidak berubah meski harga barang kemudian naik.
* `AB-05`: NIM anggota unik; pencarian anggota dapat dilakukan lewat nomor anggota atau NIM.
* `AB-06`: Pesanan pembelian dibuat bila stok kurang dari batas minimum barang tersebut.

## 6. Kebutuhan informasi
* `KI-01`: Omzet dan jumlah nota per hari dan per bulan.
* `KI-02`: Lima barang terlaris per bulan berdasarkan qty.
* `KI-03`: Barang dengan stok di bawah batas minimum.
* `KI-04`: Sepuluh anggota dengan belanja terbesar per bulan.

## 7. Matriks CRUD
| Proses Bisnis | Anggota | Barang | Penjualan | Detail Penjualan | Pemasok | Pembelian |
|---|---|---|---|---|---|---|
| `PB-01` Daftar anggota | C | - | - | - | - | - |
| `PB-02` Catat penjualan | R | R, U | C | C | - | - |
| `PB-03` Pesan ke pemasok | - | R | - | - | R | C |
| `PB-04` Terima barang | - | U | - | - | U | U |
| `PB-05` Laporan bulanan | R | R | R | R | - | R |

## 8. Kamus data awal
| Elemen Data | Arti / Deskripsi | Contoh Nilai | Aturan | Penanggung Jawab |
|---|---|---|---|---|
| `no_anggota` | Nomor anggota koperasi | A-0457 | Unik, format A-4 digit | Ketua |
| `nim_anggota` | NIM anggota | 25430113 | Unik, 10 digit | Ketua |
| `no_hp_anggota` | Nomor HP anggota | 0812xxxx | Data pribadi, akses terbatas | Ketua |
| `no_nota_penjualan` | Nomor nota penjualan | PJ-2609-0142 | Unik per nota | Kasir |
| `harga_satuan_detail_penjualan` | Harga jual saat transaksi | 4000 | Bilangan bulat $\ge 0$ (Rupiah) | Kasir |
| `stok_barang` | Jumlah barang tersedia | 35 | Bilangan bulat $\ge 0$ (AB-03) | Petugas Gudang |

## 9. Kebutuhan non-fungsional data
* **Perhitungan Parameter P:** 
  Dua digit terakhir NIM = `13`. 
  $P = (13 \pmod 9) + 1 = 4 + 1 = 5$.
* **Volume & Retensi:** Perkiraan $\pm 65$ nota per hari ($40 + 5 \times 5$), data transaksi disimpan minimal 5 tahun.
* **Privasi:** Nomor HP anggota hanya boleh dilihat oleh Ketua sesuai ketentuan pelindungan data pribadi.

## 10. Isu kualitas data yang diantisipasi
* Terdapat potensi duplikasi NIM atau perbedaan ejaan nama anggota saat pencatatan manual.
* Inkonsistensi penulisan nama pemasok atau kategori barang.