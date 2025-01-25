# Schema Design
To design the data storage schema for the data set "Iowa Liquor Sales 2017 thru 2023" I use the Star Schema model:
Dimension Tables:
date_dim: date_id, date, day, month, year, quarter, day_of_week
Purpose: Allows for time-based data analysis, such as sales by day, month, quarter, year.

store_dim: store_id, store_number, store_name, city, snapshot_date, last_update
Purpose: Analyze sales by store and geographic location.

category_dim: category_id, category_name, snapshot_date, last_update
Purpose: Analyze sales by product type.

vendor_dim: vendor_id, vendor_number, vendor_name, snapshot_date, last_update
Purpose: Analyze sales by vendor.

Fact Table:
sales_fact: sales_id, date_id, store_id, category_id, vendor_id, bottles_sold
Purpose: Stores metrics such as the number of bottles sold. This table is related to the dimension tables through foreign keys.

Ensuring Completeness:
Dimension Tables: Dimension tables (date_dim, store_dim, category_dim, vendor_dim) are designed to store descriptive attributes, allowing for analysis of data from multiple perspectives such as time, store, product type, and vendor.
Fact Table: The sales_fact table stores key metrics such as number of bottles sold. This ensures that all information required for analysis is available.

Performance Optimization:
Query Optimization: Star schemas help optimize data analysis queries, as dimension tables are typically small and can be quickly joined to fact tables. This reduces query time and improves performance.

Extensibility:
Design the schema so that new dimension tables or fact tables can be easily added without affecting the existing structure.
New data can be easily added to existing tables without changing the table structure, as long as the new data follows the same format.
Using snapshot_date, last_date in dimension tables allows tracking changes over time, allowing for better historical analysis and data management.
