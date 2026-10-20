# Analisis Normalisasi Skema Relasional Perpustakaan

**Tema proyek:** Perpustakaan
**NIM:** 25430113
**Nama:** Gustyan Tama Tiyadie

---

## 1. Titik Awal: Bentuk UNF

Data mentah yang saya analisis berasal dari slip peminjaman buku. Satu lembar slip mencatat peminjam, petugas yang melayani, dan semua buku yang dibawa pulang sekaligus:

```text
PEMINJAMAN_UNF (
  no_peminjaman, tgl_pinjam, tgl_jatuh_tempo,
  id_petugas, nama_petugas,
  id_anggota, nama_anggota,
  { kode_buku, judul_buku, pengarang, kategori_buku, kondisi_buku_pinjam },
  status_peminjaman
)
```

---

## 2. Dependensi Fungsional

Aturan bisnis perpustakaan menghasilkan lima dependensi fungsional:

```text
DF1: no_peminjaman -> tgl_pinjam, tgl_jatuh_tempo, id_petugas, id_anggota, status_peminjaman
DF2: id_petugas -> nama_petugas
DF3: id_anggota -> nama_anggota
DF4: kode_buku -> judul_buku, pengarang, kategori_buku
DF5: (no_peminjaman, kode_buku) -> kondisi_buku_pinjam
```

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
  judul_buku, pengarang, kategori_buku,
  kondisi_buku_pinjam, status_peminjaman
)
```

Kunci primernya komposit: `(no_peminjaman, kode_buku)`.

### B. 2NF

Relasi harus sudah 1NF, dan setiap atribut non-kunci wajib bergantung pada seluruh kunci primer, bukan hanya sebagiannya. Di sini `judul_buku` cukup ditentukan oleh `kode_buku`, sedangkan `tgl_pinjam` cukup ditentukan oleh `no_peminjaman`; keduanya melanggar aturan itu. Hasil pemecahannya:

```text
PEMINJAMAN        (no_peminjaman, tgl_pinjam, tgl_jatuh_tempo, status_peminjaman,
                   id_petugas, id_anggota)
DETAIL_PEMINJAMAN (no_peminjaman, kode_buku, kondisi_buku_pinjam)
BUKU              (kode_buku, judul_buku, pengarang, kategori_buku)
```

### C. 3NF

Setelah 2NF, ketergantungan transitif masih tersisa: atribut non-kunci tidak boleh ditentukan oleh atribut non-kunci lain. `nama_petugas` dan `nama_anggota` contohnya; keduanya diturunkan lewat `id_petugas` dan `id_anggota`, bukan langsung dari nomor peminjaman. Skema akhir 3NF:

```text
1. petugas           (id_petugas, nama_petugas, peran_petugas)
2. anggota           (id_anggota, no_anggota, nim_anggota, nama_anggota, prodi_anggota,
                      no_hp_anggota, status_anggota, tgl_daftar_anggota)
3. buku              (id_buku, kode_buku, judul_buku, pengarang, kategori_buku, stok_buku)
4. peminjaman        (id_peminjaman, no_peminjaman, tgl_pinjam, tgl_jatuh_tempo,
                      id_petugas, id_anggota, status_peminjaman)
5. detail_peminjaman (id_peminjaman, id_buku, kondisi_buku_pinjam)
```

Kolom pertama di tiap tabel (`id_petugas`, `id_anggota`, `id_buku`, `id_peminjaman`) adalah kunci primer. Tabel `detail_peminjaman` memakai kunci komposit `(id_peminjaman, id_buku)`.

---

## 4. Keputusan soal Nilai Turunan

Total denda keterlambatan tidak saya simpan di tabel peminjaman. Angkanya bisa dihitung kapan saja: selisih hari antara tanggal pengembalian dan tanggal jatuh tempo, dikalikan tarif denda harian. Kalau disimpan, tarif atau tanggal yang berubah akan membuat nilainya tidak cocok lagi dengan data asalnya.

---

## 5. Pemeriksaan BCNF

Setiap penentu (*determinant*) di skema 3NF di atas sudah merupakan kunci kandidat. Dengan begitu skema perpustakaan ini memenuhi BCNF.
