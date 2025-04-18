--- Memahami tabel ---
SELECT * FROM orders_1 limit 5;
SELECT 
    *
FROM
    orders_2
LIMIT 5;
SELECT 
    *
FROM
    customer
LIMIT 5;

--- Total Penjualan dan Revenue pada Quarter-1 (Jan, Feb, Mar) dan Quarter-2 (Apr,Mei,Jun) ---
SELECT 
SUM(quantity) AS total_penjualan,
SUM(priceEach*quantity) AS revenue
FROM Orders_1;

SELECT 
    SUM(quantity) AS total_penjualan,
    SUM(priceEach * quantity) AS revenue
FROM
    Orders_2
WHERE
    status = 'Shipped'
;

--- Menghitung persentasi keseluruhan penjualan ---
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

--- Apakah jumlah customers xyz.com semakin bertambah? ---
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
GROUP BY quarter;

--- Seberapa banyak customers tersebut yang sudah melakukan transaksi? ---
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

--- Category produk apa saja yang paling banyak di-order oleh customers di Quarter-2? ---
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

--- Seberapa banyak customers yang tetap aktif bertransaksi setelah transaksi pertamanya? ---
#Menghitung total unik customers yang transaksi di quarter_1
SELECT COUNT(DISTINCT customerID) as total_customers FROM orders_1;
SELECT 
    1 AS QUARTER, COUNT(DISTINCT customerID) / 25 * 100 AS Q2
FROM
    orders_1
WHERE
    customerID IN (SELECT DISTINCT
            customerID
        FROM
            orders_2)
















