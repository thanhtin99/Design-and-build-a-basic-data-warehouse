-- Data Model
CREATE TABLE store_dim (
    store_id INT,
    store_number INT,
    store_name NVARCHAR(255),
    city NVARCHAR(255),
    snapshot_date DATE,
    last_update DATETIME,
    PRIMARY KEY (store_id, snapshot_date)
);

CREATE TABLE category_dim (
    category_id INT,
    category_name NVARCHAR(255),
    snapshot_date DATE,
    last_update DATETIME,
    PRIMARY KEY (category_id, snapshot_date)
);

CREATE TABLE vendor_dim (
    vendor_id INT,
    vendor_number INT,
    vendor_name NVARCHAR(255),
    snapshot_date DATE,
    last_update DATETIME,
    PRIMARY KEY (vendor_id, snapshot_date)
);

CREATE TABLE date_dim (
    date_id INT PRIMARY KEY,
    date DATE,
    day INT,
    month INT,
    year INT,
    quarter INT,
    day_of_week INT
);

CREATE TABLE sales_fact (
    sales_id INT PRIMARY KEY,
    date_id INT,
    store_id INT,
    category_id INT,
    vendor_id INT,
    bottles_sold INT
);




-- Answer the questions:
-- 1. Total Bottles Sold per Year
SELECT 
    date_dim.year, 
    SUM(Bottles_Sold) AS Total_Bottles_Sold
FROM 
    sales_fact
JOIN 
    date_dim ON sales_fact.date_id = date_dim.date_id
GROUP BY 
    date_dim.year
ORDER BY 
    date_dim.year;

-- 2. Top 3 Vendors per City
WITH VendorSales AS (
    SELECT 
        vendor_dim.vendor_name, 
        store_dim.city, 
        SUM(sales_fact.bottles_sold) AS Total_Bottles_Sold
    FROM 
        sales_fact
    JOIN 
        vendor_dim ON sales_fact.vendor_id = vendor_dim.vendor_id
    JOIN 
        store_dim ON sales_fact.store_id = store_dim.store_id
	WHERE 
        vendor_dim.snapshot_date IN (SELECT MAX(snapshot_date) FROM vendor_dim)
    GROUP BY 
        vendor_dim.vendor_name, store_dim.city
),
RankedVendors AS (
    SELECT 
        vendor_name, 
        city, 
        Total_Bottles_Sold,
        ROW_NUMBER() OVER (PARTITION BY city ORDER BY Total_Bottles_Sold DESC) AS Rank
    FROM 
        VendorSales
)
SELECT 
    vendor_name, 
    city, 
    Total_Bottles_Sold
FROM 
    RankedVendors
WHERE 
    Rank <= 3;


-- 3. Sales Analysis by Category
WITH RankedData AS (
    SELECT 
        date_dim.year as Year, 
        category_dim.category_name, 
        SUM(sales_fact.bottles_sold) AS Total_Bottles_Sold,
        ROW_NUMBER() OVER (PARTITION BY date_dim.year ORDER BY SUM(sales_fact.bottles_sold) DESC) AS Rank
    FROM 
        sales_fact
    JOIN 
        date_dim ON sales_fact.date_id = date_dim.date_id
    JOIN 
        category_dim ON sales_fact.category_id = category_dim.category_id
	WHERE 
        category_dim.snapshot_date IN (SELECT MAX(snapshot_date) FROM category_dim)
    GROUP BY 
        date_dim.year, category_dim.category_name
)
SELECT 
    Year, 
    category_name, 
    Total_Bottles_Sold
FROM 
    RankedData
WHERE 
    Rank = 1;

-- 4. Top Stores by Sales per City in 2023
WITH RankedStores AS (
    SELECT 
        store_dim.store_name, 
        store_dim.city, 
        SUM(sales_fact.bottles_sold) AS Total_Bottles_Sold,
        ROW_NUMBER() OVER (
            PARTITION BY store_dim.city 
            ORDER BY SUM(sales_fact.bottles_sold) DESC
        ) AS Rank
    FROM 
        sales_fact
    JOIN 
        store_dim ON sales_fact.store_id = store_dim.store_id
    JOIN 
        date_dim ON sales_fact.date_id = date_dim.date_id

    WHERE 
        date_dim.year = 2023 and 
        store_dim.snapshot_date IN (SELECT MAX(snapshot_date) FROM store_dim)
    GROUP BY 
        store_dim.store_name, store_dim.city
)
SELECT 
    store_name, 
    city, 
    Total_Bottles_Sold
FROM 
    RankedStores
WHERE 
    Rank = 1;

-- 5. Vendor Sales Share
WITH TotalSales AS (
    SELECT 
        SUM(bottles_sold) AS Overall_Total_Bottles_Sold
    FROM 
        sales_fact
),
VendorSales AS (
    SELECT 
        vendor_dim.vendor_name, 
        SUM(sales_fact.bottles_sold) AS Vendor_Total_Bottles_Sold
    FROM 
        sales_fact
    JOIN 
        vendor_dim ON sales_fact.vendor_id = vendor_dim.vendor_id
	WHERE 
        vendor_dim.snapshot_date IN (SELECT MAX(snapshot_date) FROM vendor_dim)
    GROUP BY 
        vendor_dim.vendor_name
)
SELECT 
    vendor_name, 
    Vendor_Total_Bottles_Sold, 
    (Vendor_Total_Bottles_Sold * 100.0 / Overall_Total_Bottles_Sold) AS Sales_Share_Percentage
FROM 
    VendorSales, TotalSales
ORDER BY 
    Sales_Share_Percentage DESC;