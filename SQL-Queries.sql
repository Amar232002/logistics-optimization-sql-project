USE C4_project;

SELECT * FROM delivery_agents;
SELECT * FROM orders;
SELECT * FROM routes;
SELECT * FROM shipments;
SELECT * FROM warehouses;

/* ====== Task 1: Data Cleaning & Preparation =======*/
-- -----------------------------------------TASK 1.1 ------------------------------------------------------------------
-- SELECT Order_ID, COUNT(*) AS duplicate_count
-- FROM orders
-- GROUP BY Order_ID
-- HAVING COUNT(*) > 1;

-- SELECT Shipment_ID, COUNT(*) AS duplicate_count
-- FROM shipments
-- GROUP BY Shipment_ID
-- HAVING COUNT(*) > 1;
-- -----------------------------------------TASK 1.2 ------------------------------------------------
-- SELECT Shipment_ID, Route_ID, Delay_Hours
-- FROM shipments
-- WHERE Delay_Hours IS NULL;

-- Find Average Delay per Route --
 -- SELECT Route_ID, AVG(Delay_Hours) AS avg_delay
-- FROM shipments
-- WHERE Delay_Hours IS NOT NULL
-- GROUP BY Route_ID;
-- --------Replace NULL with Route-wise Average----------------------------------
-- UPDATE shipments s
-- JOIN (
--     SELECT Route_ID, AVG(Delay_Hours) AS avg_delay
--     FROM shipments
--     WHERE Delay_Hours IS NOT NULL
--     GROUP BY Route_ID
-- ) avg_table
-- ON s.Route_ID = avg_table.Route_ID
-- SET s.Delay_Hours = avg_table.avg_delay
-- WHERE s.Delay_Hours IS NULL;

-- SELECT COUNT(*) AS null_count
-- FROM shipments
-- WHERE Delay_Hours IS NULL;

-- --------------------------------TASK 1.3 -----------------------------------------------

-- SELECT * FROM orders;
--  SELECT Order_Date
-- FROM orders
-- LIMIT 5;
-- ALTER TABLE orders
-- MODIFY Order_Date DATETIME;

-- SELECT * FROM shipments;
-- SELECT Pickup_Date, Delivery_Date
-- FROM shipments
-- LIMIT 5;

-- ----------------------TASK 1.4 -----------------------------------------

-- SELECT * FROM shipments;
-- SELECT 
--     Shipment_ID,
--     Pickup_Date,
--     Delivery_Date,
--     'INVALID_DATE' AS status_flag
-- FROM shipments
-- WHERE Delivery_Date < Pickup_Date;

-- ALTER TABLE shipments
-- ADD COLUMN date_validation_status VARCHAR(20);

-- UPDATE shipments
-- SET date_validation_status = 'INVALID'
-- WHERE Delivery_Date < Pickup_Date;

-- UPDATE shipments
-- SET date_validation_status = 'VALID'
-- WHERE Delivery_Date >= Pickup_Date;

-- SELECT Shipment_ID, Pickup_Date, Delivery_Date, date_validation_status
-- FROM shipments
-- WHERE date_validation_status = 'INVALID';

-- --------------------------------------TASK 1.5 -------------------------------------------------------------
-- SELECT s.Shipment_ID, s.Order_ID
-- FROM shipments s
-- LEFT JOIN orders o
-- ON s.Order_ID = o.Order_ID
-- WHERE o.Order_ID IS NULL;

-- SELECT s.Shipment_ID, s.Route_ID
-- FROM shipments s
-- LEFT JOIN routes r
-- ON s.Route_ID = r.Route_ID
-- WHERE r.Route_ID IS NULL;

-- SELECT s.Shipment_ID, s.Warehouse_ID
-- FROM shipments s
-- LEFT JOIN warehouses w
-- ON s.Warehouse_ID = w.Warehouse_ID
-- WHERE w.Warehouse_ID IS NULL;

/* ========  TASK 2: DELIVERY DELAY ANALYSIS ============== */
-- Task 2.1: Calculate Delivery Delay (in Hours) for Each Shipment
-- SELECT 
--     Shipment_ID,
--     Pickup_Date,
--     Delivery_Date,
--     TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date) AS Delivery_Delay_Hours
-- FROM shipments;
-- Task 2.2: Find Top 10 Delayed Routes (Based on Average Delay Hours)
-- SELECT 
--     Route_ID,
--     AVG(Delay_Hours) AS Avg_Delay_Hours
-- FROM shipments
-- GROUP BY Route_ID
-- ORDER BY Avg_Delay_Hours DESC
-- LIMIT 10;
-- Task 2.3: Rank Shipments by Delay within Each Warehouse
-- SELECT 
--     Shipment_ID,
--     Warehouse_ID,
--     Delay_Hours,
--     RANK() OVER (
--         PARTITION BY Warehouse_ID 
--         ORDER BY Delay_Hours DESC
--     ) AS Delay_Rank
-- FROM shipments;

-- Task 2.4: Identify Average Delay per Delivery_Type (Express vs Standard)
-- SELECT 
--     o.Delivery_Type,
--     AVG(s.Delay_Hours) AS Avg_Delay_Hours
-- FROM shipments s
-- JOIN orders o 
-- ON s.Order_ID = o.Order_ID
-- GROUP BY o.Delivery_Type;

/* =========== TASK 3: ROUTE OPTIMIZATION INSIGHTS  ============*/
-- Task 3.1: Calculate Average Transit Time (in Hours) per Route
-- SELECT 
--     s.Route_ID,
--     AVG(TIMESTAMPDIFF(HOUR, s.Pickup_Date, s.Delivery_Date)) AS Avg_Transit_Time_Hours
-- FROM shipments s
-- GROUP BY s.Route_ID;

-- Task 3.2: Calculate Average Delay (in Hours) per Route
-- SELECT 
--     Route_ID,
--     AVG(Delay_Hours) AS Avg_Delay_Hours
-- FROM shipments
-- GROUP BY Route_ID;

-- Task 3.3: Calculate Distance-to-Time Efficiency Ratio per Route
-- SELECT 
--     r.Route_ID,
--     r.Distance_KM,
--     r.Avg_Transit_Time_Hours,
--     (r.Distance_KM / r.Avg_Transit_Time_Hours) AS Efficiency_Ratio
-- FROM routes r;

-- Task 3.4: Identify 3 Routes with Worst Efficiency Ratio
-- SELECT 
--     Route_ID,
--     (Distance_KM / Avg_Transit_Time_Hours) AS Efficiency_Ratio
-- FROM routes
-- ORDER BY Efficiency_Ratio ASC
-- LIMIT 3;

-- Task 3.5: Find Routes with >20% Shipments Delayed Beyond Expected Transit Time
-- SELECT 
--     s.Route_ID,
--     (SUM(CASE 
--         WHEN s.Delay_Hours > r.Avg_Transit_Time_Hours THEN 1 
--         ELSE 0 
--      END) * 100.0 / COUNT(*)) AS Delay_Percentage
-- FROM shipments s
-- JOIN routes r 
-- ON s.Route_ID = r.Route_ID
-- GROUP BY s.Route_ID
-- HAVING Delay_Percentage > 20;

/* ========TASK 4: WAREHOUSE PERFORMANCE ==========*/
-- Task 4.1: Find Top 3 Warehouses with Highest Average Delay
-- SELECT 
--     Warehouse_ID,
--     AVG(Delay_Hours) AS Avg_Delay_Hours
-- FROM shipments
-- GROUP BY Warehouse_ID
-- ORDER BY Avg_Delay_Hours DESC
-- LIMIT 3;

-- Task 4.2: Calculate Total Shipments vs Delayed Shipments per Warehouse
-- SELECT 
--     Warehouse_ID,
--     COUNT(*) AS Total_Shipments,
--     SUM(CASE 
--         WHEN Delay_Hours > 0 THEN 1 
--         ELSE 0 
--     END) AS Delayed_Shipments
-- FROM shipments
-- GROUP BY Warehouse_ID;

-- Task 4.3: Identify Warehouses Exceeding Global Average Delay (Using CTE)
-- WITH Global_Avg AS (
--     SELECT AVG(Delay_Hours) AS Global_Avg_Delay
--     FROM shipments
-- )
-- SELECT 
--     Warehouse_ID,
--     AVG(Delay_Hours) AS Warehouse_Avg_Delay
-- FROM shipments, Global_Avg
-- GROUP BY Warehouse_ID
-- HAVING Warehouse_Avg_Delay > Global_Avg_Delay;

-- Task 4.4: Rank Warehouses by On-Time Delivery Percentage
-- SELECT 
--     Warehouse_ID,
--     (SUM(CASE 
--         WHEN Delay_Hours = 0 THEN 1 
--         ELSE 0 
--      END) * 100.0 / COUNT(*)) AS On_Time_Percentage,
--     RANK() OVER (
--         ORDER BY 
--         (SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) DESC
--     ) AS Warehouse_Rank
-- FROM shipments
-- GROUP BY Warehouse_ID;

/* ======TASK 5: DELIVERY AGENT PERFORMANCE =======*/

-- Task 5.1: Rank Delivery Agents (Per Route) by On-Time Delivery Percentage
-- SELECT 
--     Agent_ID,
--     Route_ID,
--     (SUM(CASE 
--         WHEN Delay_Hours = 0 THEN 1 
--         ELSE 0 
--      END) * 100.0 / COUNT(*)) AS On_Time_Percentage,
--     RANK() OVER (
--         PARTITION BY Route_ID 
--         ORDER BY 
--         (SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) DESC
--     ) AS Agent_Rank
-- FROM shipments
-- GROUP BY Agent_ID, Route_ID;

-- Task 5.2: Find Agents with On-Time % Below 85%
-- SELECT 
--     Agent_ID,
--     (SUM(CASE 
--         WHEN Delay_Hours = 0 THEN 1 
--         ELSE 0 
--      END) * 100.0 / COUNT(*)) AS On_Time_Percentage
-- FROM shipments
-- GROUP BY Agent_ID
-- HAVING On_Time_Percentage < 85;

-- Task 5.3: Compare Avg Rating & Experience of Top 5 vs Bottom 5 Agents (Using Subqueries)
/* == Top 5 Agents (Lowest Average Delay) == */
-- SELECT 
--     AVG(da.Avg_Rating) AS Avg_Rating_Top5,
--     AVG(da.Experience_Years) AS Avg_Experience_Top5
-- FROM delivery_agents da
-- JOIN (
--     SELECT Agent_ID
--     FROM shipments
--     GROUP BY Agent_ID
--     ORDER BY AVG(Delay_Hours) ASC
--     LIMIT 5
-- ) t
-- ON da.Agent_ID = t.Agent_ID;

/* ==Bottom 5 Agents (Highest Average Delay) == */
-- SELECT 
--     AVG(da.Avg_Rating) AS Avg_Rating_Bottom5,
--     AVG(da.Experience_Years) AS Avg_Experience_Bottom5
-- FROM delivery_agents da
-- JOIN (
--     SELECT Agent_ID
--     FROM shipments
--     GROUP BY Agent_ID
--     ORDER BY AVG(Delay_Hours) DESC
--     LIMIT 5
-- ) b
-- ON da.Agent_ID = b.Agent_ID;

/* =======TASK 6: SHIPMENT TRACKING ANALYTICS=====*/
-- Task 6.1: Display Latest Status & Latest Delivery_Date for Each Shipment

-- SELECT 
--     Shipment_ID,
--     Delivery_Status,
--     Delivery_Date AS Latest_Delivery_Date
-- FROM shipments;

-- Task 6.2: Identify Routes Where Majority of Shipments are “In Transit” or “Returned”
-- SELECT 
--     Route_ID,
--     COUNT(*) AS Total_Shipments,
--     SUM(CASE 
--         WHEN Delivery_Status IN ('In Transit', 'Returned') THEN 1 
--         ELSE 0 
--     END) AS Problem_Shipments
-- FROM shipments
-- GROUP BY Route_ID
-- HAVING Problem_Shipments > COUNT(*) / 2;

-- Task 6.3: Find Most Frequent Delay Reasons (Using Delay Flags / Status)

-- SELECT 
--     Delivery_Status AS Delay_Reason,
--     COUNT(*) AS Occurrence_Count
-- FROM shipments
-- WHERE Delay_Hours > 0
-- GROUP BY Delivery_Status
-- ORDER BY Occurrence_Count DESC;

-- Task 6.4: Identify Orders with Exceptionally High Delay (>120 Hours)
-- SELECT 
--     Order_ID,
--     Shipment_ID,
--     Delay_Hours
-- FROM shipments
-- WHERE Delay_Hours > 120;

/* == TASK 7: ADVANCED KPI REPORTING ==*/

-- Task 7.1: Average Delivery Delay per Source_Country
-- SELECT 
--     r.Source_Country,
--     AVG(s.Delay_Hours) AS Avg_Delivery_Delay_Hours
-- FROM shipments s
-- JOIN routes r 
--     ON s.Route_ID = r.Route_ID
-- GROUP BY r.Source_Country;

-- Task 7.2: On-Time Delivery Percentage

-- SELECT 
--     COUNT(*) AS Total_Deliveries,
--     SUM(CASE 
--         WHEN Delay_Hours = 0 THEN 1 
--         ELSE 0 
--     END) AS On_Time_Deliveries,
--     ROUND(
--         SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
--         2
--     ) AS On_Time_Delivery_Percentage
-- FROM shipments;

-- Task 7.3: Average Delay (in Hours) per Route_ID
-- SELECT 
--     Route_ID,
--     AVG(Delay_Hours) AS Avg_Delay_Hours
-- FROM shipments
-- GROUP BY Route_ID;

-- Task 7.4: Warehouse Utilization Percentage

-- SELECT 
--     w.Warehouse_ID,
--     COUNT(s.Shipment_ID) AS Shipments_Handled,
--     w.Capacity_per_day,
--     ROUND(
--         COUNT(s.Shipment_ID) * 100.0 / w.Capacity_per_day,
--         2
--     ) AS Warehouse_Utilization_Percentage
-- FROM warehouses w
-- JOIN shipments s 
--     ON w.Warehouse_ID = s.Warehouse_ID
-- GROUP BY w.Warehouse_ID, w.Capacity_per_day;


/* ================================================================================================END==========================================================================================*/








