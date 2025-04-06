# Project-Data-Analysis-for-B2B-retail-Customer-Analytics-Report
Project dari DQLab Melakukan analisis Performance dengan menggunakan MySQL

xyz.com adalah perusahan rintisan B2B yang menjual berbagai produk tidak langsung kepada end user tetapi ke bisnis/perusahaan lainnya. Sebagai data-driven company, maka setiap pengambilan keputusan di xyz.com selalu berdasarkan data. Setiap quarter xyz.com akan mengadakan townhall dimana seluruh atau perwakilan divisi akan berkumpul untuk me-review performance perusahaan selama quarter terakhir.

Beberapa pertanyaan yang dijawab pada customer analytics report ini

1. Bagaimana pertumbuhan penjualan saat ini?
2. Apakah jumlah customers xyz.com semakin bertambah ?
3. Dan seberapa banyak customers tersebut yang sudah melakukan transaksi?
4. Category produk apa saja yang paling banyak dibeli oleh customers?
5. Seberapa banyak customers yang tetap aktif bertransaksi?

Tabel yang akan digunakan pada project kali ini adalah sebagai berikut.

1. Tabel orders_1 : Berisi data terkait transaksi penjualan periode quarter 1 (Jan – Mar 2004)
2. Tabel Orders_2 : Berisi data terkait transaksi penjualan periode quarter 2 (Apr – Jun 2004)
3. Tabel Customer : Berisi data profil customer yang mendaftar menjadi customer xyz.com


![image](https://github.com/user-attachments/assets/2dba91b9-a891-4ed8-9e2d-25622bd519a0)

**Memahami table**

Sebelum memulai menyusun query SQL dan membuat Analisa dari hasil query, hal pertama yang perlu dilakukan adalah menjadi familiar dengan tabel yang akan digunakan.
```
SELECT * FROM orders_1 limit 5;
SELECT * FROM orders_2 limit 5;
SELECT * FROM customer limit 5;
```
Output:

![image](https://github.com/user-attachments/assets/aaecb116-76c0-41da-b11b-e5bdb962b25f)

### 1. Total Penjualan dan Revenue pada Quarter-1 (Jan, Feb, Mar) dan Quarter-2 (Apr,Mei,Jun)
1. Dari tabel orders_1 lakukan penjumlahan pada kolom quantity dengan fungsi aggregate sum() dan beri nama “total_penjualan”, kalikan kolom quantity dengan kolom priceEach kemudian jumlahkan hasil perkalian kedua kolom tersebut dan beri nama “revenue”.
2. Perusahaan hanya ingin menghitung penjualan dari produk yang terkirim saja, jadi kita perlu mem-filter kolom ‘status’ sehingga hanya menampilkan order dengan status “Shipped”.
3. Lakukan Langkah 1 & 2, untuk tabel orders_2.
```
SELECT 
SUM(quantity) AS total_penjualan,
SUM(priceEach*quantity) AS revenue
FROM Orders_1;

SELECT 
SUM(quantity) AS total_penjualan,
SUM(priceEach*quantity) AS revenue
FROM Orders_2
WHERE status = 'Shipped'
;
```
Output:

![image](https://github.com/user-attachments/assets/b0c7d52c-b728-43fb-941b-0abbafb6348a)

### 2. Menghitung persentasi keseluruhan penjualan
Karena kedua tabel orders_1 dan orders_2 masih terpisah, untuk menghitung persentasi keseluruhan penjualan dari kedua tabel tersebut perlu digabungkan :

1. Pilihlah kolom “orderNumber”, “status”, “quantity”, “priceEach” pada tabel orders_1, dan tambahkan kolom baru dengan nama “quarter” dan isi dengan value “1”. Lakukan yang sama dengan tabel orders_2, dan isi dengan value “2”, kemudian gabungkan kedua tabel tersebut.
2. Gunakan statement dari Langkah 1 sebagai subquery dan beri alias “tabel_a”.
3. Dari “tabel_a”, lakukan penjumlahan pada kolom “quantity” dengan fungsi aggregate sum() dan beri nama “total_penjualan”, dan kalikan kolom quantity dengan kolom priceEach kemudian jumlahkan hasil perkalian kedua kolom tersebut dan beri nama “revenue”.
4. Filter kolom ‘status’ sehingga hanya menampilkan order dengan status “Shipped”.
5. Kelompokkan total_penjualan berdasarkan kolom “quarter”, dan jangan lupa menambahkan kolom ini pada bagian select.

```
SELECT
    quarter,
    SUM(quantity) AS total_penjualan,
    SUM(quantity*priceEach) AS revenue
from
   (SELECT
       orderNumber, 
       status, 
       quantity,
       priceEach,
       1 as quarter
   FROM orders_1
   UNION ALL
   SELECT
      orderNumber, 
      status, 
      quantity,
      priceEach,
      2 as quarter
   FROM orders_2) tabel_a
WHERE status = 'Shipped'
GROUP BY quarter;
```
Output:

![image](https://github.com/user-attachments/assets/e935d102-7b78-4673-b758-f9b55545aa36)

sehingga perhitungan pertumbuhan penjualan adalah sebagai berikut:

**%Growth Penjualan** = (6717 – 8694)/8694 = -22%
**%Growth Revenue**   = (607548320 – 799579310)/ 799579310 = -24%

### 3. Apakah jumlah customers xyz.com semakin bertambah?
Penambahan jumlah customers dapat diukur dengan membandingkan total jumlah customers yang registrasi di periode saat ini dengan total jumlah customers yang registrasi diakhir periode sebelumnya.
```
SELECT 
   quarter,
   COUNT(Distinct(customerID)) AS total_customers
FROM
   (SELECT 
       customerID, 
       createDate,
       QUARTER(createDate) AS quarter
    FROM customer
    WHERE createDate BETWEEN '2004-01-01' and '2004-06-30') tabel_b
GROUP BY quarter
```
Output:

![image](https://github.com/user-attachments/assets/e99cdd91-e194-44ec-a180-71a2fabddebc)

### 4. Seberapa banyak customers tersebut yang sudah melakukan transaksi?
Problem ini merupakan kelanjutan dari problem sebelumnya yaitu dari sejumlah customer yang registrasi di periode quarter-1 dan quarter-2, berapa banyak yang sudah melakukan transaksi
```
SELECT 
    quarter,
    COUNT(DISTINCT customerID) AS total_customers
FROM (
    SELECT
        customerID, 
        createDate,
        QUARTER(createDate) AS quarter
    FROM customer
    WHERE createDate BETWEEN '2004-01-01' AND '2004-06-30'
) AS tabel_b
WHERE customerID IN (
    SELECT DISTINCT customerID FROM orders_1
    UNION
    SELECT DISTINCT customerID FROM orders_2
)
GROUP BY quarter;
```
Output:

![image](https://github.com/user-attachments/assets/82c803b1-2819-4b0b-9733-4c2d2fcaa797)

### 5. Category produk apa saja yang paling banyak di-order oleh customers di Quarter-2?
Untuk mengetahui kategori produk yang paling banyak dibeli, maka dapat dilakukan dengan menghitung total order dan jumlah penjualan dari setiap kategori produk.
```
SELECT
    LEFT(productCode,3) AS categoryID,
    COUNT(DISTINCT orderNumber) total_order,
    SUM(quantity) total_penjualan
FROM (
    SELECT
        productCode,
        orderNumber,
        quantity,
        status
    FROM orders_2
    WHERE status = 'Shipped') tabel_c
GROUP BY categoryID
ORDER BY total_order DESC;
```
Output:

![image](https://github.com/user-attachments/assets/4c1d0fd4-8d5c-4af1-aa6f-6b51b0db0f87)

### 6. Seberapa banyak customers yang tetap aktif bertransaksi setelah transaksi pertamanya?
Mengetahui seberapa banyak customers yang tetap aktif menunjukkan apakah xyz.com tetap digemari oleh customers untuk memesan kebutuhan bisnis mereka. Hal ini juga dapat menjadi dasar bagi tim product dan business untuk pengembangan product dan business kedepannya. Adapun metrik yang digunakan disebut retention cohort. Untuk project ini, kita akan menghitung retention dengan query SQL sederhana, sedangkan cara lain yaitu JOIN dan SELF JOIN akan dibahas dimateri selanjutnya :

Oleh karena baru terdapat 2 periode yang Quarter 1 dan Quarter 2, maka retention yang dapat dihitung adalah retention dari customers yang berbelanja di Quarter 1 dan kembali berbelanja di Quarter 2, sedangkan untuk customers yang berbelanja di Quarter 2 baru bisa dihitung retentionnya di Quarter 3.
```
#Menghitung total unik customers yang transaksi di quarter_1
SELECT COUNT(DISTINCT customerID) as total_customers FROM orders_1;
#output = 25

SELECT 
  1 AS QUARTER,
  COUNT(DISTINCT customerID)/25*100 AS Q2
FROM orders_1
WHERE customerID IN
                  (SELECT 
                      DISTINCT customerID
                  FROM orders_2)
```
Output:

![image](https://github.com/user-attachments/assets/5682f2d3-9dae-4c07-9334-35e0bb3415c4)

### Kesimpulan
Berdasarkan data yang telah diperoleh melalui query SQL, Kita dapat menarik kesimpulan bahwa :

1. Performance xyz.com menurun signifikan di quarter ke-2, terlihat dari nilai penjualan dan revenue yang drop hingga 20% dan 24%,
2. perolehan customer baru juga tidak terlalu baik, dan sedikit menurun dibandingkan quarter sebelumnya.
3. Ketertarikan customer baru untuk berbelanja di xyz.com masih kurang, hanya sekitar 56% saja yang sudah bertransaksi. Disarankan tim Produk untuk perlu mempelajari behaviour customer dan melakukan product improvement, sehingga conversion rate (register to transaction) dapat meningkat.
4. Produk kategori S18 dan S24 berkontribusi sekitar 50% dari total order dan 60% dari total penjualan, sehingga xyz.com sebaiknya fokus untuk pengembangan category S18 dan S24.
5. Retention rate customer xyz.com juga sangat rendah yaitu hanya 24%, artinya banyak customer yang sudah bertransaksi di quarter-1 tidak kembali melakukan order di quarter ke-2 (no repeat order).
6. xyz.com mengalami pertumbuhan negatif di quarter ke-2 dan perlu melakukan banyak improvement baik itu di sisi produk dan bisnis marketing, jika ingin mencapai target dan positif growth di quarter ke-3. Rendahnya retention rate dan conversion rate bisa menjadi diagnosa awal bahwa customer tidak tertarik/kurang puas/kecewa berbelanja di xyz.com.

Project ini dapat diakses melalui https://academy.dqlab.id/main/package/practice/246.

____________________________________________________________________________________________________________________________________________________________________________________________________________________

![Project Data Analysis for B2B retail Customer Analytics Report_page-0001](https://github.com/user-attachments/assets/2a8a3eb2-448f-4be9-bad3-627233954d90)

