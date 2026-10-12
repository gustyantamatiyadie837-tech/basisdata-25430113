# Dokumen Kebutuhan Data Perpustakaan Cakrawala GT

## 1. Latar belakang dan aktivitas organisasi
"Perpustakaan Cakrawala adalah sistem informasi perpustakaan berbasis digital yang melayani civitas akademika dalam hal pendaftaran anggota, pencatatan peminjaman buku, pengembalian, hingga pengelolaan denda keterlambatan."

## 2. Aktor dan proses bisnis
| Kode | Proses Bisnis | Aktor | Pemicu |
|---|---|---|---|
| PB-01 | Mendaftarkan anggota baru | Pustakawan | Mahasiswa ingin mendaftar menjadi anggota perpustakaan |
| PB-02 | Mencatat peminjaman buku | Pustakawan | Anggota mengajukan peminjaman buku |
| PB-03 | Pengembalian buku dan denda | Pustakawan | Anggota mengembalikan buku (bisa tepat waktu atau terlambat) |
| PB-04 | Pengadaan / pencatatan buku baru | Pustakawan / Admin | Masuknya kiriman buku baru atau penambahan koleksi |

## 3. Dokumen sumber yang dianalisis
Dokumen sumber yang dianalisis dalam perancangan sistem Perpustakaan Cakrawala GT meliputi:
1. **Formulir Pendaftaran Anggota:** Lembar isian atau formulir digital yang diisi oleh mahasiswa untuk mencatat data diri pendaftaran (NIM, nama lengkap, program studi, dan nomor HP).
2. **Slip Peminjaman Buku:** Bukti transaksi yang dicetak atau dicatat saat anggota meminjam buku. Berisi nomor peminjaman, tanggal pinjam, batas tanggal pengembalian, kode petugas, NIM anggota, serta daftar buku yang dipinjam beserta jumlahnya.
3. **Kuitansi / Catatan Denda Pengembalian:** Dokumen atau catatan kasir saat anggota mengembalikan buku melewati batas waktu, memuat rincian hari keterlambatan dan nominal denda yang harus dibayar.

## 4. Entitas kandidat dan elemen data
Berdasarkan analisis dokumen sumber (formulir anggota dan slip peminjaman), berikut adalah entitas kandidat beserta elemen data utamanya untuk Perpustakaan Cakrawala GT:

1. **Anggota**
   * Elemen data: nomor anggota, NIM, nama lengkap, program studi, nomor HP, status keaktifan, tanggal daftar.
   * Sumber: Formulir Pendaftaran Anggota.

2. **Buku**
   * Elemen data: kode buku, judul buku, penulis, penerbit, tahun terbit, kategori, jumlah stok.
   * Sumber: Katalog / Inventaris Perpustakaan.

3. **Petugas**
   * Elemen data: kode petugas, nama petugas, peran petugas (pustakawan/admin).
   * Sumber: Kebijakan operasional internal.

4. **Peminjaman (Kepala Transaksi)**
   * Elemen data: nomor peminjaman, tanggal pinjam, batas tanggal pengembalian, referensi petugas, referensi anggota.
   * Sumber: Slip Peminjaman Buku.

5. **Detail Peminjaman**
   * Elemen data: nomor peminjaman, buku yang dipinjam, jumlah (qty), kondisi buku saat dipinjam.
   * Sumber: Slip Peminjaman Buku.

6. **Pengembalian & Denda**
   * Elemen data: tanggal kembali aktual, jumlah hari keterlambatan, nominal denda, status pembayaran denda.
   * Sumber: Catatan denda / Kuitansi pengembalian.

## 5. Aturan bisnis
Berikut adalah aturan bisnis yang berlaku di Perpustakaan Cakrawala GT:

* **AB-01:** Setiap transaksi peminjaman memiliki nomor nota/peminjaman unik dan minimal mencakup satu buku.
* **AB-02:** Anggota perpustakaan harus berstatus aktif untuk dapat melakukan peminjaman buku.
* **AB-03:** Batas maksimal jumlah buku yang dapat dipinjam dalam satu kali transaksi adalah 7 buku (berdasarkan parameter $P = 5$, di mana batas maksimal item = $P + 2$).
* **AB-04:** Batas waktu peminjaman buku adalah 7 hari; keterlambatan pengembalian akan dikenakan denda harian sebesar Rp5.000 per hari.
* **AB-05:** NIM anggota bersifat unik, dan pencarian data anggota dapat dilakukan melalui nomor anggota atau NIM.
* **AB-06:** Stok buku berkurang secara otomatis saat dipinjam dan bertambah kembali setelah buku tersebut dikembalikan.
* **AB-07:** Buku yang stoknya habis atau sedang dalam status rusak/hilang tidak dapat dipinjam.
* **AB-08:** Petugas/pustakawan wajib mencatat kondisi fisik buku (baik atau rusak) saat peminjaman dan pengembalian.

## 6. Kebutuhan informasi
Berikut adalah daftar kebutuhan informasi (laporan) yang dapat dihasilkan oleh sistem Perpustakaan Cakrawala GT:

| Kode | Kebutuhan Informasi | Data yang Diperlukan |
|---|---|---|
| KI-01 | Laporan rekapitulasi jumlah peminjaman dan pengembalian buku per hari dan per bulan | Peminjaman, Pengembalian |
| KI-02 | Daftar 5 buku yang paling sering dipinjam setiap bulannya | Buku, Detail Peminjaman, Peminjaman |
| KI-03 | Daftar buku yang stoknya habis atau berada di bawah batas minimum | Buku |
| KI-04 | Daftar anggota teraktif dengan jumlah peminjaman terbanyak per bulan | Anggota, Peminjaman |
| KI-05 | Laporan rekapitulasi nominal denda keterlambatan pengembalian buku per periode | Pengembalian, Anggota |

## 7. Matriks CRUD
Berikut adalah matriks pemetaan proses bisnis terhadap entitas pada Perpustakaan Cakrawala GT:

| Proses Bisnis | Anggota | Buku | Petugas | Peminjaman | Detail Peminjaman | Pengembalian |
|---|---|---|---|---|---|---|
| **PB-01** Mendaftarkan anggota baru | C | R | R | - | - | - |
| **PB-02** Mencatat peminjaman buku | R | R, U | R | C | C | - |
| **PB-03** Pengembalian buku & denda | R | R, U | R | R | R | C, U |
| **PB-04** Pengadaan / pencatatan buku | - | C, U | R | - | - | - |

*Keterangan: C = Create (Membuat), R = Read (Membaca), U = Update (Mengubah), D = Delete (Menghapus).*

## 8. Kamus data awal
Berikut adalah kamus data awal yang merinci elemen-elemen penting dalam sistem Perpustakaan Cakrawala GT:

| No | Elemen Data | Arti / Deskripsi | Contoh Nilai | Aturan / Format | Penanggung Jawab |
|---|---|---|---|---|---|
| 1 | `id_anggota` | Pengenal unik internal anggota | 1 | Bilangan bulat auto-increment | Kepala Perpustakaan |
| 2 | `no_anggota` | Nomor kartu anggota | A-0123 | Unik, format A-4 digit | Kepala Perpustakaan |
| 3 | `nim_anggota` | Nomor Induk Mahasiswa | 25430113 | Unik, 10 digit angka | Kepala Perpustakaan |
| 4 | `nama_anggota` | Nama lengkap anggota | Budi Santoso | Huruf dan spasi, NOT NULL | Kepala Perpustakaan |
| 5 | `prodi_anggota` | Program studi anggota | Ilmu Komputer | Sesuai daftar prodi resmi | Kepala Perpustakaan |
| 6 | `no_hp_anggota` | Nomor telepon / WhatsApp | 081234567890 | Data pribadi, akses terbatas | Kepala Perpustakaan |
| 7 | `status_anggota` | Status keaktifan anggota | aktif | ENUM ('aktif', 'nonaktif') | Kepala Perpustakaan |
| 8 | `tgl_daftar_anggota` | Tanggal pendaftaran anggota | 2026-10-01 | Format DATE (YYYY-MM-DD) | Kepala Perpustakaan |
| 9 | `id_buku` | Pengenal unik internal buku | 10 | Bilangan bulat auto-increment | Pustakawan |
| 10 | `kode_buku` | Kode unik / ISBN buku | BK-ATK-001 | Unik, string alfanumerik | Pustakawan |
| 11 | `judul_buku` | Judul resmi buku | Basis Data Lanjut | Teks, NOT NULL | Pustakawan |
| 12 | `penulis_buku` | Nama pengarang buku | Dedi Irawan | Teks, NOT NULL | Pustakawan |
| 13 | `penerbit_buku` | Nama penerbit buku | Penerbit Andi | Teks, nullable | Pustakawan |
| 14 | `stok_buku` | Jumlah ketersediaan buku | 15 | Bilangan bulat $\ge 0$ | Pustakawan |
| 15 | `id_petugas` | Pengenal unik petugas/pustakawan | 3 | Bilangan bulat auto-increment | Kepala Perpustakaan |
| 16 | `kode_petugas` | Kode singkatan petugas | P01 | Unik, format 3 karakter | Kepala Perpustakaan |
| 17 | `nama_petugas` | Nama lengkap petugas | Siska Wulandari | Teks, NOT NULL | Kepala Perpustakaan |
| 18 | `id_peminjaman` | Pengenal transaksi peminjaman | 102 | Bilangan bulat auto-increment | Pustakawan |
| 19 | `no_peminjaman` | Nomor nota/bukti peminjaman | PJ-2610-001 | Unik, format khusus | Pustakawan |
| 20 | `tgl_pinjam` | Tanggal dan jam peminjaman | 2026-10-07 10:30:00 | Format DATETIME | Pustakawan |
| 21 | `tgl_jatuh_tempo` | Batas tanggal pengembalian | 2026-10-14 23:59:59 | Format DATETIME (7 hari dari pinjam)| Pustakawan |
| 22 | `qty_pinjam` | Jumlah eksemplar buku dipinjam | 2 | Bilangan bulat $> 0$ | Pustakawan |
| 23 | `tgl_kembali_aktual` | Tanggal riil buku dikembalikan | 2026-10-15 | Format DATE | Pustakawan |
| 24 | `jumlah_denda` | Nominal denda keterlambatan | 5000 | Bilangan $\ge 0$ (Rupiah) | Pustakawan |

## 9. Kebutuhan non-fungsional data
* **Perhitungan Parameter $P$:**  $P = (13 \pmod 9) + 1 = 4 + 1 = 5$
* **Volume Transaksi:** Perkiraan volume transaksi harian di Perpustakaan Cakrawala GT adalah $40 + (5 \times P) = 65$ transaksi per hari[cite: 51].
* **Batas Maksimal Peminjaman:** Batas maksimal buku yang dapat dipinjam dalam satu transaksi adalah $P + 2 = 7$ buku[cite: 51].
* **Besaran Denda:** Besaran denda harian keterlambatan pengembalian buku ditetapkan sebesar $P$ ribu rupiah, yaitu Rp5.000 per hari[cite: 51].
* **Retensi Data:** Seluruh catatan transaksi peminjaman dan pengembalian perpustakaan wajib disimpan minimal selama 5 tahun untuk keperluan audit.
* **Privasi dan Keamanan Data:** Nomor telepon dan data pribadi anggota dikategorikan sebagai informasi privat yang hanya dapat diakses oleh Kepala Perpustakaan atau petugas yang berwenang, sejalan dengan prinsip pelindungan data pribadi[cite: 50].

## 10. Isu kualitas data yang diantisipasi
* **Duplikasi Data Anggota:** Potensi pendaftaran berulang menggunakan NIM yang sama.
* **Inkonsistensi Penulisan:** Variasi penulisan nama program studi atau nomor HP yang tidak seragam dari formulir pendaftaran.
* **Kelengkapan Data:** Anggota yang mengosongkan kolom nomor HP saat mendaftar, sehingga menyulitkan proses konfirmasi peminjaman.