# Analisis Normalisasi Skema Relasional Perpustakaan

**Tema proyek:** Perpustakaan
**NIM:** 25430113
**Nama:** Gustyan Tama Tiyadie

---

## 1. Titik Awal: Bentuk UNF

Data mentah yang saya analisis berasal dari slip peminjaman buku dan catatan pengembalian. Satu lembar slip mencatat peminjam, petugas yang melayani, dan semua buku yang dibawa pulang sekaligus. Saat buku dikembalikan, tanggal kembali aktual dan denda (jika ada) dicatat pada transaksi yang sama:

```text
PEMINJAMAN_UNF (
  no_peminjaman, tgl_pinjam, tgl_jatuh_tempo,
  id_petugas, nama_petugas,
  id_anggota, nama_anggota,
  { kode_buku, judul_buku, penulis_buku, penerbit_buku, tahun_terbit_buku,
    kategori_buku, qty_pinjam, kondisi_buku_pinjam, kondisi_buku_kembali },
  status_peminjaman,
  tgl_kembali_aktual, jumlah_denda, status_denda
)
```

---

## 2. Dependensi Fungsional

Aturan bisnis perpustakaan menghasilkan enam dependensi fungsional:

```text
DF1: no_peminjaman -> tgl_pinjam, tgl_jatuh_tempo, id_petugas, id_anggota, status_peminjaman
DF2: id_petugas -> nama_petugas
DF3: id_anggota -> nama_anggota
DF4: kode_buku -> judul_buku, penulis_buku, penerbit_buku, tahun_terbit_buku, kategori_buku
DF5: (no_peminjaman, kode_buku) -> qty_pinjam, kondisi_buku_pinjam, kondisi_buku_kembali
DF6: no_peminjaman -> tgl_kembali_aktual, jumlah_denda, status_denda
```

DF6 berlaku karena satu transaksi peminjaman dikembalikan satu kali (satu pengembalian per peminjaman).

---

## 3. Tahap Normalisasi

### A. 1NF

Syaratnya sederhana: tiap sel hanya boleh berisi satu nilai. Grup berulang `{}` pada daftar buku saya urai, sehingga satu baris mewakili satu buku dalam satu peminjaman.

```text
PEMINJAMAN_1NF (
  no_peminjaman, kode_buku,
  tgl_pinjam, tgl_jatuh_tempo,
  id_petugas, nama_petugas,
  id_anggota, nama_anggota,
  judul_buku, penulis_buku, penerbit_buku, tahun_terbit_buku, kategori_buku,
  qty_pinjam, kondisi_buku_pinjam, kondisi_buku_kembali,
  status_peminjaman,
  tgl_kembali_aktual, jumlah_denda, status_denda
)
```

Kunci primernya komposit: `(no_peminjaman, kode_buku)`.

### B. 2NF

Relasi harus sudah 1NF, dan setiap atribut non-kunci wajib bergantung pada seluruh kunci primer, bukan hanya sebagiannya. Di sini `judul_buku` cukup ditentukan oleh `kode_buku`, sedangkan `tgl_pinjam` dan `tgl_kembali_aktual` cukup ditentukan oleh `no_peminjaman`; keduanya melanggar aturan itu. Hasil pemecahannya:

```text
PEMINJAMAN        (no_peminjaman, tgl_pinjam, tgl_jatuh_tempo, status_peminjaman,
                   id_petugas, id_anggota,
                   tgl_kembali_aktual, jumlah_denda, status_denda)
DETAIL_PEMINJAMAN (no_peminjaman, kode_buku, qty_pinjam,
                   kondisi_buku_pinjam, kondisi_buku_kembali)
BUKU              (kode_buku, judul_buku, penulis_buku, penerbit_buku,
                   tahun_terbit_buku, kategori_buku)
```

### C. 3NF

Setelah 2NF, ketergantungan transitif masih tersisa: atribut non-kunci tidak boleh ditentukan oleh atribut non-kunci lain. `nama_petugas` dan `nama_anggota` contohnya; keduanya diturunkan lewat `id_petugas` dan `id_anggota`, bukan langsung dari nomor peminjaman. Keduanya saya pisahkan menjadi tabel `petugas` dan `anggota`.

Data pengembalian (`tgl_kembali_aktual`, `jumlah_denda`, `status_denda`) juga saya pisahkan menjadi tabel `pengembalian`. Ini bukan karena pelanggaran 3NF, melainkan keputusan desain: data tersebut baru ada setelah buku dikembalikan, sehingga kalau tetap di `peminjaman` kolomnya akan berisi NULL selama buku masih dipinjam. Pemisahan ini juga sesuai entitas "Pengembalian & Denda" pada p02 dan proses PB-03 pada matriks CRUD.

Skema akhir 3NF:

```text
1. petugas           (id_petugas, kode_petugas, nama_petugas, peran_petugas)
2. anggota           (id_anggota, no_anggota, nim_anggota, nama_anggota, prodi_anggota,
                      no_hp_anggota, status_anggota, tgl_daftar_anggota)
3. buku              (id_buku, kode_buku, judul_buku, penulis_buku, penerbit_buku,
                      tahun_terbit_buku, kategori_buku, stok_buku)
4. peminjaman        (id_peminjaman, no_peminjaman, tgl_pinjam, tgl_jatuh_tempo,
                      id_petugas, id_anggota, status_peminjaman)
5. detail_peminjaman (id_peminjaman, id_buku, qty_pinjam,
                      kondisi_buku_pinjam, kondisi_buku_kembali)
6. pengembalian      (id_pengembalian, id_peminjaman, id_petugas,
                      tgl_kembali_aktual, jumlah_denda, status_denda)
```

Kolom pertama di tiap tabel (`id_petugas`, `id_anggota`, `id_buku`, `id_peminjaman`, `id_pengembalian`) adalah kunci primer. Tabel `detail_peminjaman` memakai kunci komposit `(id_peminjaman, id_buku)`. Pada `pengembalian`, kolom `id_peminjaman` bersifat unik (relasi satu peminjaman ke satu pengembalian) dan menjadi kunci asing, begitu juga `id_petugas`.

---

## 4. Keputusan soal Nilai Turunan

Jumlah hari keterlambatan tidak disimpan. Angkanya bisa dihitung kapan saja dari selisih `tgl_kembali_aktual` dan `tgl_jatuh_tempo`.

Nominal denda (`jumlah_denda`) tetap disimpan di tabel `pengembalian` sebagai nilai yang benar-benar ditagihkan saat pengembalian. Alasannya sama dengan `harga_satuan` pada nota penjualan: kalau tarif harian (Rp5.000) suatu hari berubah, denda transaksi lama tidak boleh ikut berubah. Nilai ini dihitung dari hari terlambat dikali tarif saat transaksi, lalu menjadi catatan historis yang dibutuhkan laporan KI-05.

---

## 5. Pemeriksaan BCNF

Setiap penentu (*determinant*) di skema 3NF di atas sudah merupakan kunci kandidat (termasuk `id_peminjaman` pada `pengembalian`, yang unik). Dengan begitu skema perpustakaan ini memenuhi BCNF.