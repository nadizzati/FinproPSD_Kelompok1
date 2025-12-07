# Final Project PSD Kelompok 01
Kelompok 1 FINPRO PSD
- EUGENIA HUWAIDA IMTINAN (2406421384)
- KAYLA JOANNA IRSY KUSUMAH (2406487014)
- NADIA IZZATI (2406487033)
- SAFINA AMARINA (2406415665)

*Aslab: Bang Bryan (BH)*

## Background
Di era informasi, keamanan digital dan sistem enkripsi yang efisien sangat penting untuk melindungi informasi dari akses tidak sah. Keterbatasan hardware menuntut optimasi proses enkripsi. Caesar Cipher dan Hill Cipher adalah algoritma yang umum digunakan. Caesar Cipher mudah, sementara Hill Cipher lebih aman karena menggunakan matriks kunci. Untuk meningkatkan kecepatan dan efisiensi, Field-Programmable Gate Array (FPGA) dapat digunakan untuk implementasi algoritma enkripsi.

## Deskripsi Proyek
Proyek ini bertujuan mengembangkan sistem enkripsi-dekripsi dua lapis yang mengintegrasikan Caesar Cipher dan Hill Cipher. Sistem ini menerapkan Caesar Cipher untuk enkripsi awal (pergeseran karakter), yang hasilnya kemudian dienkripsi lebih lanjut oleh Hill Cipher menggunakan matriks kunci. Integrasi ini menghasilkan proteksi data yang jauh lebih kuat.

## Cara Kerja
Dalam alur kerjanya, sistem membaca teks dari input.txt, lalu melakukan enkripsi atau dekripsi. Hasil enkripsi disimpan di encryptOutput.txt, dan dekripsi di decryptOutput.txt. Khusus untuk enkripsi, hasil Caesar disimpan sementara di phase.txt sebelum diproses Hill. Pada dekripsi, urutannya dibalik: Hill Cipher dulu, lalu Caesar Cipher untuk memulihkan teks asli. Pemanfaatan File I/O memungkinkan pengguna mengelola data tanpa interaksi langsung dengan kode. Arsitektur terstruktur menjamin pemrosesan karakter yang presisi dan penyimpanan hasil yang benar.
