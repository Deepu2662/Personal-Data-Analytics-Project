CREATE DATABASE amazon_sales_db;

USE amazon_sales_db;

/*=========================================================
 Project Workflow
=========================================================*/

-- CSV Dataset
--      ↓
-- Python Cleaning & Validation
--      ↓
-- MySQL Business Analysis
--      ↓
-- Power BI Dashboard

/*=========================================================
                AMAZON SALES ANALYTICS PROJECT
                  Section 1 : Data Validation
=========================================================*/

-- Validate that the cleaned dataset has been imported correctly into MySQL before starting analysis.

-- Total records imported
SELECT COUNT(*) AS Total_Rows FROM amazon_sales;
-- 128746

---------------------------------------------------------

-- Analysis Period
SELECT MIN(order_date) AS First_Order_Date, MAX(order_date) AS Last_Order_Date FROM amazon_sales;
-- 2022-03-31 00:00:00	2022-06-29 00:00:00

---------------------------------------------------------

-- Total Unique Orders
SELECT COUNT(DISTINCT order_id) AS Total_Orders FROM amazon_sales;
-- 120255

---------------------------------------------------------

-- Total Unique Products
SELECT COUNT(DISTINCT sku) AS Unique_Products FROM amazon_sales;
-- 7185

---------------------------------------------------------

/*=========================================================
              Section 2 : Executive KPIs
=========================================================*/

/*-------------------------------------------------------
Query 2.1 : Total Revenue
-------------------------------------------------------*/

-- Business Question: How much revenue did the company generate during the analysis period?

SELECT ROUND(SUM(amount),2) AS Total_Revenue FROM amazon_sales;
-- 78592678.3

-- Insight:
-- The business generated approximately ₹78.59 million
-- in sales revenue between March 31 and June 29, 2022.

-- Recommendation:
-- Use this value as the baseline KPI for future performance comparisons. 
-- Compare monthly and quarterly revenue trends to evaluate business growth and the impact of promotional campaigns.

/*-------------------------------------------------------
Query 2.2 : Total Orders
-------------------------------------------------------*/

-- Business Question: How many unique orders were placed?

SELECT COUNT(DISTINCT order_id) AS Total_Orders FROM amazon_sales;
-- 120255

-- Insight:
-- More than 120 thousand unique customer orders were processed.

-- Recommendation:
-- Track order growth over time and compare it with revenue.
-- If order volume increases without a proportional increase in revenue, pricing or product mix should be reviewed.

/*-------------------------------------------------------
Query 2.3 : Total Quantity Sold
-------------------------------------------------------*/

-- Business Question: How many products were sold during the analysis period?

SELECT SUM(qty) AS Total_Quantity_Sold FROM amazon_sales;
-- 116483

-- Insight:
-- A total of 116,483 product units were sold during the analysis period.

-- Recommendation:
-- Monitor the gap between total orders and total units sold.
-- Reducing cancelled orders can improve overall sales volume without increasing customer acquisition efforts.

/*-------------------------------------------------------
Query 2.4 : Average Order Value
-------------------------------------------------------*/

-- Business Question: What is the average order value?

SELECT ROUND(AVG(amount),2) AS Average_Order_Value FROM amazon_sales WHERE amount IS NOT NULL;
-- 648.56

-- Insight:
-- On average, each revenue-generating order generated ₹648.56.

-- Recommendation:
-- Increase the average order value by promoting bundled products, cross-selling complementary items, and offering discounts above a minimum purchase value.

/*-------------------------------------------------------
Query 2.5 : Order Status Distribution
-------------------------------------------------------*/

-- Business Question: What is the distribution of order statuses?

SELECT status, COUNT(*) AS Total_Orders FROM amazon_sales GROUP BY status ORDER BY Total_Orders DESC;
/* Shipped	77596
Shipped - Delivered to Buyer	28761
Cancelled	18332
Shipped - Returned to Seller	1950
Shipped - Picked Up	973
Pending	656
Pending - Waiting for Pick Up	281
Shipped - Returning to Seller	145
Shipped - Out for Delivery	35
Shipped - Rejected by Buyer	11
Shipped - Lost in Transit	5
Shipped - Damaged	1 */

-- Insight:
-- The majority of orders were successfully shipped, while cancellations accounted for the second-largest category.

-- Recommendation:
-- Continuously monitor order status distribution and prioritize reducing cancellations while improving order fulfillment efficiency.

/*-------------------------------------------------------
Query 2.6 : Cancellation Rate
-------------------------------------------------------*/

-- Business Question: What percentage of orders were cancelled?

SELECT ROUND(SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END)* 100.0 / COUNT(*),2) AS Cancellation_Rate FROM amazon_sales;
-- 14.24

-- Insight:
-- Approximately one out of every seven orders was cancelled, indicating an opportunity to improve order fulfillment and customer retention.

-- Recommendation:
-- Investigate the primary causes of cancellations, such as inventory shortages, payment failures, or customer behavior, and implement corrective measures to reduce revenue loss.

/*=========================================================
 Section 3 : Product Performance Analysis
=========================================================*/

/*-------------------------------------------------------
Query 3.1 : Revenue by Category
-------------------------------------------------------*/

-- Business Question: Which product category generated the highest revenue?

SELECT category, FORMAT(SUM(amount),2) AS Total_Revenue FROM amazon_sales GROUP BY category ORDER BY SUM(amount) DESC;
/* Set	39,204,124.03
Kurta	21,299,546.70
Western Dress	11,216,072.69
Top	5,347,792.30
Ethnic Dress	791,217.66
Blouse	458,408.18
Bottom	150,667.98
Saree	123,933.76
Dupatta	915.00 */

-- Insight:
-- 'Set' is the highest revenue-generating category, contributing nearly 50% of the total revenue.
-- The top four categories (Set, Kurta, Western Dress and Top) dominate the business revenue.

/*-------------------------------------------------------
Query 3.2 : Units Sold by Category
-------------------------------------------------------*/

-- Business Question: Which product category sold the highest number of units?

SELECT category, SUM(qty) AS Units_Sold FROM amazon_sales GROUP BY category ORDER BY Units_Sold DESC;
/* Set	45226
Kurta	44970
Western Dress	13939
Top	9899
Ethnic Dress	1053
Blouse	844
Bottom	397
Saree	152
Dupatta	3 */

-- Insight:
-- The ranking of units sold closely matches the revenue ranking, indicating that higher revenue is mainly driven by higher sales volume rather than unusually high prices.

/*-------------------------------------------------------
Query 3.3 : Average Selling Price
-------------------------------------------------------*/

-- Business Question: What is the average selling price of each category?

SELECT category, ROUND(AVG(amount),2) AS Average_Price FROM amazon_sales WHERE amount IS NOT NULL GROUP BY category ORDER BY Average_Price DESC;
/* Set	833.39
Saree	799.57
Western Dress	762.79
Ethnic Dress	723.9
Top	526.1
Blouse	520.33
Kurta	455.93
Bottom	358.73
Dupatta	305 */

-- Insight:
-- 'Set' products have the highest average selling price among high-volume categories. 
-- Combined with strong unit sales, this explains why the Set category generates the highest overall revenue.

/*-------------------------------------------------------
Query 3.4 : Top Products
-------------------------------------------------------*/

-- Business Question: Which products generated the highest revenue?

SELECT sku, category, FORMAT(SUM(amount),2) AS Revenue FROM amazon_sales GROUP BY sku, category ORDER BY SUM(amount) DESC LIMIT 10;
/* J0230-SKD-M	Set	527,699.20
JNE3797-KR-L	Western Dress	524,581.77
J0230-SKD-S	Set	479,937.14
JNE3797-KR-M	Western Dress	454,290.16
JNE3797-KR-S	Western Dress	407,302.57
JNE3797-KR-XL	Western Dress	332,155.24
J0230-SKD-L	Set	305,616.95
JNE3797-KR-XS	Western Dress	303,616.70
SET268-KR-NP-XL	Set	284,058.96
JNE3797-KR-XXXL	Western Dress	276,375.80 */

-- Insight:
-- A small number of SKUs consistently generate high revenue, indicating strong customer demand. These products should be prioritized for inventory management and promotional campaigns.

/*-------------------------------------------------------
Query 3.5 : Size Distribution
-------------------------------------------------------*/

-- Business Question: Which product sizes are most popular?

SELECT size, SUM(qty) AS Units_Sold FROM amazon_sales GROUP BY size ORDER BY Units_Sold DESC;
/* M	20427
L	19972
XL	18901
XXL	16491
S	15313
3XL	13506
XS	9929
6XL	687
5XL	512
4XL	398
Free	347 */

-- Insight:
-- Medium, Large and Extra Large sizes account for the highest sales volume. 
-- Maintaining adequate inventory for these sizes can help reduce stock shortages and improve customer satisfaction.

/*=========================================================
              Section 4 : Geographic Analysis
=========================================================*/

/*-------------------------------------------------------
Query 4.1 : Revenue by State
-------------------------------------------------------*/

-- Business Question: Which states generated the highest revenue?

SELECT ship_state, FORMAT(SUM(amount),2) AS Total_Revenue FROM amazon_sales GROUP BY ship_state ORDER BY SUM(amount) DESC;
/* Maharashtra	13,335,534.14
Karnataka	10,481,114.37
Telangana	6,916,615.65
Uttar Pradesh	6,816,642.08
Tamil Nadu	6,515,650.11
Delhi	4,346,412.46
Kerala	3,830,227.58
West Bengal	3,507,880.44
Andhra Pradesh	3,219,831.72
Haryana	2,882,092.99
Gujarat	2,728,651.82
Rajasthan	1,761,131.16
Madhya Pradesh	1,592,382.98
Bihar	1,415,613.32
Odisha	1,386,372.39
Punjab	1,211,098.84
Assam	1,018,136.20
Uttarakhand	974,143.55
Jharkhand	919,088.21
Goa	637,685.85
Chhattisgarh	570,485.83
Himachal Pradesh	503,364.51
Jammu & Kashmir	456,932.74
Manipur	213,981.99
Chandigarh	211,740.67
Puducherry	192,573.24
Andaman & Nicobar 	158,723.62
Nagaland	144,094.67
Sikkim	140,828.66
Meghalaya	119,871.81
Arunachal Pradesh	97,772.00
Tripura	92,548.40
New Delhi	47,109.95
Dadra And Nagar	42,138.92
Mizoram	41,948.71
Ladakh	38,388.43
	18,671.00
Lakshadweep	3,175.29
Nl	961.00
Punjab/Mohali/Zirakpur	568.00
Ar	493.00
Apo	NULL */

-- Insight:
-- Maharashtra generated the highest revenue (₹13.34 million), followed by Karnataka (₹10.48 million) and Telangana (₹6.92 million). 
-- Together, these states represent the largest regional markets and should be considered priority regions for business growth.

-- Recommendation:
-- Prioritize inventory allocation, marketing campaigns, and warehouse operations in the top revenue-generating states to maximize sales opportunities.

-- Business Impact:
-- Better regional resource allocation can improve product availability, customer satisfaction, and revenue growth.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 4.2 : Orders by State
-------------------------------------------------------*/

-- Business Question: Which states placed the highest number of orders?

SELECT ship_state, COUNT(DISTINCT order_id) AS Total_Orders FROM amazon_sales GROUP BY ship_state ORDER BY Total_Orders DESC;
/* Maharashtra	20780
Karnataka	16182
Tamil Nadu	10519
Telangana	10405
Uttar Pradesh	10062
Delhi	6533
Kerala	6105
West Bengal	5653
Andhra Pradesh	4979
Haryana	4142
Gujarat	4046
Rajasthan	2512
Madhya Pradesh	2375
Odisha	2024
Bihar	2017
Punjab	1808
Assam	1601
Uttarakhand	1480
Jharkhand	1382
Goa	1081
Chhattisgarh	873
Himachal Pradesh	750
Jammu & Kashmir	670
Chandigarh	315
Puducherry	310
Manipur	287
Andaman & Nicobar 	242
Sikkim	197
Meghalaya	194
Nagaland	168
Tripura	143
Arunachal Pradesh	133
New Delhi	76
Mizoram	72
Dadra And Nagar	60
Ladakh	42
	28
Lakshadweep	4
Nl	2
Ar	1
Apo	1
Punjab/Mohali/Zirakpur	1 */

-- Insight:
-- Maharashtra also recorded the highest number of customer orders, followed by Karnataka and Tamil Nadu. 
-- The order distribution closely aligns with the revenue distribution, indicating strong customer demand in these regions.

-- Recommendation:
-- Continue strengthening logistics and inventory management in the highest-order states while exploring opportunities to increase order volume in underperforming regions.

-- Business Impact:
-- Efficient fulfillment in high-demand states can improve customer experience and support sustained business growth.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 4.3 : Revenue by City
-------------------------------------------------------*/

-- Business Question: Which cities generated the highest revenue?

SELECT ship_city, FORMAT(SUM(amount),2) AS Total_Revenue FROM amazon_sales GROUP BY ship_city ORDER BY SUM(amount) DESC LIMIT 10;
/* Bengaluru	7,257,748.80
Hyderabad	5,599,822.35
Mumbai	4,293,210.16
New Delhi	3,952,690.20
Chennai	3,606,917.94
Pune	2,794,975.79
Kolkata	1,682,046.99
Gurugram	1,280,854.78
Thane	1,111,506.35
Lucknow	1,049,983.10 */

-- Insight:
-- Bengaluru generated the highest city-level revenue, followed by Hyderabad and Mumbai. These metropolitan cities represent major sales hubs for the business.

-- Recommendation:
-- Focus city-level marketing initiatives, promotional campaigns, and inventory planning on the highest revenue-generating metropolitan areas.

-- Business Impact:
-- Targeted investments in key cities can increase market penetration and improve overall sales performance.

-- Recommendation Priority:
-- Medium

/*-------------------------------------------------------
Query 4.4 : Orders by City
-------------------------------------------------------*/

-- Business Question: Which cities placed the highest number of orders?

SELECT ship_city, COUNT(DISTINCT order_id) AS Total_Orders FROM amazon_sales GROUP BY ship_city ORDER BY Total_Orders DESC LIMIT 10;
/* Bengaluru	11096
Hyderabad	8369
Mumbai	6572
New Delhi	5948
Chennai	5726
Pune	4317
Kolkata	2687
Gurugram	1855
Thane	1770
Lucknow	1556 */

-- Insight:
-- Bengaluru received the highest number of customer orders, followed by Hyderabad, Mumbai, and Chennai.
-- Large metropolitan cities dominate customer demand.

-- Recommendation:
-- Maintain efficient last-mile delivery operations and sufficient stock availability in major cities to meet consistently high customer demand.

-- Business Impact:
-- Improved fulfillment efficiency in high-volume cities can reduce delivery delays and enhance customer loyalty.

-- Recommendation Priority:
-- Medium

/*-------------------------------------------------------
Query 4.5 : Cancellation Rate by State
-------------------------------------------------------*/

-- Business Question: Which states have the highest cancellation rates?

SELECT ship_state, COUNT(*) AS Total_Orders, SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
ROUND( SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END) *100.0 /COUNT(*), 2) AS Cancellation_Rate 
FROM amazon_sales GROUP BY ship_state HAVING COUNT(*) >= 100 ORDER BY Cancellation_Rate DESC;
/* Himachal Pradesh	788	146	18.53
Kerala	6582	1175	17.85
Andaman & Nicobar 	257	45	17.51
Jammu & Kashmir	702	119	16.95
Andhra Pradesh	5421	892	16.45
Meghalaya	207	34	16.43
Odisha	2134	346	16.21
Bihar	2113	341	16.14
Jharkhand	1454	231	15.89
Sikkim	205	31	15.12
Uttar Pradesh	10633	1604	15.09
Uttarakhand	1551	234	15.09
Madhya Pradesh	2529	380	15.03
Assam	1661	248	14.93
Puducherry	350	52	14.86
West Bengal	5958	884	14.84
Tripura	151	22	14.57
Telangana	11323	1634	14.43
Tamil Nadu	11471	1594	13.90
Chhattisgarh	909	126	13.86
Rajasthan	2704	374	13.83
Arunachal Pradesh	146	20	13.70
Gujarat	4364	591	13.54
Maharashtra	22237	2966	13.34
Delhi	6963	909	13.05
Karnataka	17321	2245	12.96
Punjab	1915	247	12.90
Haryana	4410	563	12.77
Nagaland	185	22	11.89
Goa	1134	130	11.46
Manipur	316	36	11.39
Chandigarh	331	36	10.88 */

-- Insight:
-- Cancellation rates vary across states, with Himachal Pradesh (18.53%) and Kerala (17.85%) recording the highest rates among states with significant order volumes. 
-- The overall project cancellation rate is 14.24%, indicating that these states exceed the average and may require operational investigation.

-- Recommendation:
-- Investigate the root causes of cancellations in high-cancellation states, including inventory availability, delivery performance, and customer behavior. 
-- Implement corrective measures to reduce cancellations in these regions.

-- Business Impact:
-- Lower cancellation rates can improve realized revenue, reduce operational costs, and enhance customer satisfaction.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 4.6 : B2B vs B2C
-------------------------------------------------------*/

-- Business Question: How do B2B and B2C orders compare?

SELECT b2b, COUNT(*) AS Orders,FORMAT(SUM(amount),2) AS Revenue, ROUND(AVG(amount),2) AS Average_Order_Value FROM amazon_sales GROUP BY b2b;
/* 0	127876	78,001,457.51	648.19
1	870	591,220.79	701.33 */

-- Insight:
-- Consumer (B2C) orders accounted for the overwhelming majority of transactions and revenue. 
-- Business (B2B) orders represented a very small proportion of total sales but recorded a higher average order value.

-- Recommendation:
-- Continue prioritizing the B2C customer segment while exploring opportunities to expand B2B partnerships through targeted sales strategies.

-- Business Impact:
-- Diversifying the customer base may improve revenue stability and create additional growth opportunities.

-- Recommendation Priority:
-- Medium 

/*-------------------------------------------------------
		Geographic Data Quality Observation
-------------------------------------------------------*/

-- During geographic analysis, several inconsistencies were identified in the ship_state column.

-- Standardized:
-- • Odisha / Orissa 
-- • Rajasthan spelling variations
-- • Puducherry / Pondicherry
-- • Punjab spelling variations

-- Retained:
-- • 28 blank state values
-- • 5 ambiguous geographic entries

-- These records were retained because the correct state could not be determined with confidence. */

/*=========================================================
 Section 5 : Fulfilment & Logistics Analysis
=========================================================*/

/*-------------------------------------------------------
Query 5.1 : Revenue by Fulfilment
-------------------------------------------------------*/

-- Business Question: Which fulfilment method generated the highest revenue?

SELECT fulfilment, FORMAT(SUM(amount),2) AS Total_Revenue FROM amazon_sales GROUP BY fulfilment ORDER BY SUM(amount) DESC;
/* Amazon	54,322,151.00
Merchant	24,270,527.30 */

-- Insight:
-- Amazon fulfilment generated approximately 69.1% of the total revenue, significantly outperforming Merchant fulfilment. 
-- This indicates that Amazon's fulfilment network handles the majority of high-value sales.

-- Recommendation:
-- Continue prioritizing Amazon Fulfilment for products with high demand while evaluating opportunities to improve Merchant fulfilment performance.

-- Business Impact:
-- Higher revenue through Amazon fulfilment suggests better operational efficiency and customer preference.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 5.2 : Orders by Fulfilment
-------------------------------------------------------*/

-- Business Question: Which fulfilment method processed the highest number of orders?

SELECT fulfilment, COUNT(*) AS Total_Orders FROM amazon_sales GROUP BY fulfilment ORDER BY Total_Orders DESC;
/* Amazon	89480
Merchant	39266 */

-- Insight:
-- Amazon fulfilled nearly 70% of all orders, demonstrating its dominant role in order processing and logistics operations.

-- Recommendation:
-- Maintain adequate inventory levels within Amazon fulfilment centers while reviewing Merchant fulfilment capacity for potential improvements.

-- Business Impact:
-- Efficient fulfilment operations help improve delivery performance and customer satisfaction.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 5.3 – Average Order Value by Fulfilment
-------------------------------------------------------*/

-- Business Question: Which fulfilment method has the highest average order value?

SELECT fulfilment, ROUND(AVG(amount),2) AS Average_Order_Value FROM amazon_sales GROUP BY fulfilment ORDER BY Average_Order_Value DESC;
/* Amazon	649.48
Merchant	646.51 */

-- Insight:
-- The average order values are nearly identical, with Amazon fulfilment showing only a marginally higher value. 
-- This suggests that differences in total revenue are primarily driven by order volume rather than higher-value transactions.

-- Recommendation:
-- Focus on increasing order volume through operational improvements rather than attempting to increase order value based solely on fulfilment method.

-- Business Impact:
-- Understanding revenue drivers helps allocate resources more effectively.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 5.4 – Cancellation Rate by Fulfilment
-------------------------------------------------------*/

-- Business Question: Which fulfilment method experiences the highest cancellation rate?

SELECT fulfilment, COUNT(*) AS Total_Orders, SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
ROUND( SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END)*100.0/COUNT(*), 2 ) AS Cancellation_Rate 
FROM amazon_sales GROUP BY fulfilment ORDER BY Cancellation_Rate DESC;
/* Merchant	39266	6861	17.47
Amazon	89480	11471	12.82 */

-- Insight:
-- Merchant fulfilment experiences a considerably higher cancellation rate than Amazon fulfilment. 
-- This suggests potential issues related to inventory availability, fulfilment efficiency, or seller operations.

-- Recommendation:
-- Investigate Merchant fulfilment processes to identify causes of cancellations and implement corrective measures to reduce failed orders.

-- Business Impact:
-- Reducing Merchant cancellations can improve realized revenue, operational efficiency, and customer satisfaction.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 5.5 – Revenue by Shipping Service
-------------------------------------------------------*/

-- Business Question: Which shipping service generated the highest revenue?

SELECT  ship_service_level, FORMAT(SUM(amount), 2) AS Total_Revenue FROM amazon_sales GROUP BY ship_service_level ORDER BY SUM(amount) DESC;
/* Expedited	54,285,183.00
Standard	24,307,495.30 */

-- Insight:
-- Expedited shipping contributed approximately 69% of total revenue, indicating that it is the primary shipping service used across customer orders.

-- Recommendation:
-- Continue prioritizing Expedited shipping for products with high demand while monitoring Standard shipping performance.

-- Business Impact:
-- Efficient premium shipping supports customer satisfaction and business growth.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 5.6 – Orders by Shipping Service
-------------------------------------------------------*/

-- Business Question: Which shipping service processed the highest number of orders?

SELECT ship_service_level, COUNT(*) AS Total_Orders FROM amazon_sales GROUP BY ship_service_level ORDER BY Total_Orders DESC;
/* Expedited	88520
Standard	40226 */

-- Insight:
-- Expedited shipping handled more than twice the number of orders compared to Standard shipping, making it the company's primary delivery method.

-- Recommendation:
-- Ensure sufficient logistics capacity for Expedited shipments during peak demand periods.

-- Business Impact:
-- Maintaining efficient shipping operations helps sustain customer satisfaction and timely deliveries.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 5.7 – Cancellation Rate by Shipping Service
-------------------------------------------------------*/

-- Business Question: Which shipping service has the highest cancellation rate?

SELECT ship_service_level, COUNT(*) AS Total_Orders, SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
ROUND( SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END)*100.0/COUNT(*), 2 ) AS Cancellation_Rate 
FROM amazon_sales GROUP BY ship_service_level ORDER BY Cancellation_Rate DESC;
/* Standard	40226	6909	17.18
Expedited	88520	11423	12.90 */

-- Insight:
-- Standard shipping records a noticeably higher cancellation rate than Expedited shipping, suggesting differences in operational efficiency or service quality.

-- Recommendation:
-- Review Standard shipping operations to identify process improvements that can reduce cancellations and improve fulfilment reliability.

-- Business Impact:
-- Reducing cancellations directly contributes to increased realized revenue and improved customer experience.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 5.8 – Courier Status Distribution
-------------------------------------------------------*/

-- Business Question: What is the distribution of courier statuses?

SELECT courier_status, COUNT(*) AS Total_Orders, ROUND(COUNT(*)*100.0/ (SELECT COUNT(*) FROM amazon_sales),2) AS Percentage 
FROM amazon_sales GROUP BY courier_status ORDER BY Total_Orders DESC;
/* Shipped	109487	85.04
Not Assigned	6861	5.33
Unshipped	6558	5.09
Cancelled	5840	4.54 */

-- Insight:
-- The majority of orders (85.04%) were successfully shipped, indicating a strong fulfilment performance. 
-- Only a small proportion remained unshipped, cancelled, or without an assigned courier.

-- Recommendation:
-- Continue monitoring orders without assigned couriers and unshipped orders to minimize operational delays.

-- Business Impact:
-- Improved courier assignment and shipment tracking can further enhance delivery performance.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 5.9 – Fulfilment vs Shipping Service
-------------------------------------------------------*/

-- Business Question: How does cancellation performance differ across fulfilment method and shipping service combinations?

SELECT fulfilment, ship_service_level, COUNT(*) AS Total_Orders, SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
ROUND( SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END) *100.0/COUNT(*), 2 ) AS Cancellation_Rate 
FROM amazon_sales GROUP BY fulfilment, ship_service_level ORDER BY Cancellation_Rate DESC;
/* Merchant	Standard	39266	6861	17.47
Amazon	Expedited	88520	11423	12.90
Amazon	Standard	960	48	5.00 */

-- Insight:
-- Merchant orders shipped using the Standard service recorded the highest cancellation rate (17.47%).
-- In contrast, Amazon fulfilment with Standard shipping exhibited the lowest cancellation rate (5.00%), although it represented a relatively small number of orders.
-- Amazon fulfilment with Expedited shipping maintained a lower cancellation rate while processing the highest order volume.

-- Recommendation:
-- Prioritize operational improvements for Merchant Standard shipments, including inventory management and fulfilment processes, to reduce cancellations and improve service reliability.

-- Business Impact:
-- Optimizing the weakest fulfilment-shipping combination can significantly improve customer satisfaction and reduce revenue loss.

-- Recommendation Priority: High

/*-------------------------------------------------------
		Geographic Data Quality Observation
-------------------------------------------------------*/

-- This section reveals a consistent pattern:
-- • Amazon performs better than Merchant.
-- • Expedited performs better than Standard.
-- • The Merchant + Standard combination performs the worst.

/*
| Metric                           | Observation         |
| -------------------------------- | ------------------- |
| Highest Revenue Fulfilment       | Amazon              |
| Highest Orders Fulfilment        | Amazon              |
| Higher Average Order Value       | Amazon (slightly)   |
| Lowest Cancellation Rate         | Amazon Fulfilment   |
| Highest Revenue Shipping         | Expedited           |
| Lowest Cancellation Rate         | Expedited           |
| Highest Cancellation Combination | Merchant + Standard |
*/

/*=========================================================
 Section 6 : Time Series Analysis
=========================================================*/

/*-------------------------------------------------------
Query 6.1 – Monthly Revenue
-------------------------------------------------------*/

-- Business Question: How did revenue vary across different months during the analysis period?

SELECT MONTHNAME(order_date) AS Month, FORMAT(SUM(amount),2) AS Total_Revenue 
FROM amazon_sales GROUP BY MONTH(order_date), MONTHNAME(order_date) ORDER BY MONTH(order_date);
/* March	101,683.85
April	28,838,708.32
May	26,226,476.75
June	23,425,809.38 */

-- Insight:
-- April generated the highest monthly revenue, followed by May and June.
-- Revenue gradually declined after April, while March contained only one day of data and is not suitable for comparison.

-- Recommendation:
-- Investigate the factors contributing to declining monthly revenue after April and introduce targeted marketing campaigns to sustain sales momentum.

-- Business Impact:
-- Identifying seasonal sales patterns enables better forecasting, inventory planning, and marketing decisions.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 6.2 – Monthly Orders
-------------------------------------------------------*/

-- Business Question: How did customer order volume change over the analysis period?

SELECT MONTHNAME(order_date) AS Month, COUNT(DISTINCT order_id) AS Total_Orders
FROM amazon_sales GROUP BY MONTH(order_date), MONTHNAME(order_date) ORDER BY MONTH(order_date);
/* March	158
April	45806
May	39180
June	35111 */

-- Insight:
-- Customer order volume followed the same trend as revenue, with April recording the highest number of orders before gradually declining in May and June.

-- Recommendation:
-- Analyze customer demand and promotional activities after April to improve order volume during subsequent months.

-- Business Impact:
-- Maintaining customer order volume directly supports revenue growth and business sustainability.

-- Recommendation Priority: High

/*-------------------------------------------------------
Query 6.3 – Monthly Average Order Value
-------------------------------------------------------*/

-- Business Question: Did the average order value change across different months?

SELECT MONTHNAME(order_date) AS Month, ROUND(AVG(amount),2) AS Average_Order_Value 
FROM amazon_sales GROUP BY MONTH(order_date), MONTHNAME(order_date) ORDER BY MONTH(order_date);
/* March	627.68
April	626
May	663.36
June	661.48 */

-- Insight:
-- Despite declining revenue and order volume, the average order value remained stable and slightly increased during May and June.
-- This indicates that revenue decline was driven primarily by fewer customer orders rather than lower-value purchases.

-- Recommendation:
-- Focus on increasing customer acquisition and purchase frequency while maintaining the current pricing strategy.

-- Business Impact:
-- Improving customer acquisition can increase revenue without requiring changes to product pricing.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 6.4 – Daily Revenue Trend
-------------------------------------------------------*/

-- Business Question: What is the day-to-day revenue trend during the analysis period?

SELECT order_date, ROUND(SUM(amount),2) AS Daily_Revenue FROM amazon_sales GROUP BY order_date ORDER BY order_date;
/* 2022-03-31 00:00:00	101683.85
2022-04-01 00:00:00	865478.6
2022-04-02 00:00:00	913101.53
2022-04-03 00:00:00	1011763.38
2022-04-04 00:00:00	882059.17
2022-04-05 00:00:00	950544.05
2022-04-06 00:00:00	886985.26
2022-04-07 00:00:00	909899.35
2022-04-08 00:00:00	1018617.61
2022-04-09 00:00:00	972076.48
2022-04-10 00:00:00	1075234.03
2022-04-11 00:00:00	949559.27
2022-04-12 00:00:00	887194.03
2022-04-13 00:00:00	977017.3
2022-04-14 00:00:00	1113487.56
2022-04-15 00:00:00	1024542.13
2022-04-16 00:00:00	1010056.23
2022-04-17 00:00:00	940843.9
2022-04-18 00:00:00	885403.46
2022-04-19 00:00:00	960055.36
2022-04-20 00:00:00	1091926.41
2022-04-21 00:00:00	971966.58
2022-04-22 00:00:00	978033.62
2022-04-23 00:00:00	1093536.62
2022-04-24 00:00:00	1082483.95
2022-04-25 00:00:00	977764.88
2022-04-26 00:00:00	910749.81
2022-04-27 00:00:00	850676.58
2022-04-28 00:00:00	838362.09
2022-04-29 00:00:00	839654.65
2022-04-30 00:00:00	969634.43
2022-05-01 00:00:00	1079957.52
2022-05-02 00:00:00	1172327.06
2022-05-03 00:00:00	1190672.59
2022-05-04 00:00:00	1209364.17
2022-05-05 00:00:00	894704.17
2022-05-06 00:00:00	909530.13
2022-05-07 00:00:00	911693.76
2022-05-08 00:00:00	902173.06
2022-05-09 00:00:00	810945.89
2022-05-10 00:00:00	723616.88
2022-05-11 00:00:00	740395.52
2022-05-12 00:00:00	693445.93
2022-05-13 00:00:00	736609.76
2022-05-14 00:00:00	768171.9
2022-05-15 00:00:00	894645.67
2022-05-16 00:00:00	763146.91
2022-05-17 00:00:00	764918.63
2022-05-18 00:00:00	797542.08
2022-05-19 00:00:00	778026.25
2022-05-20 00:00:00	704908.01
2022-05-21 00:00:00	697790.62
2022-05-22 00:00:00	777552.83
2022-05-23 00:00:00	755930.56
2022-05-24 00:00:00	759458.39
2022-05-25 00:00:00	819478.34
2022-05-26 00:00:00	767619.6
2022-05-27 00:00:00	813334.57
2022-05-28 00:00:00	850986.6
2022-05-29 00:00:00	816996.49
2022-05-30 00:00:00	817463.77
2022-05-31 00:00:00	903069.09
2022-06-01 00:00:00	935430.21
2022-06-02 00:00:00	896672.82
2022-06-03 00:00:00	738190.19
2022-06-04 00:00:00	892476.1
2022-06-05 00:00:00	989093.03
2022-06-06 00:00:00	955276.13
2022-06-07 00:00:00	965557.26
2022-06-08 00:00:00	965472.09
2022-06-09 00:00:00	959183.09
2022-06-10 00:00:00	798796.94
2022-06-11 00:00:00	863796.34
2022-06-12 00:00:00	955246.82
2022-06-13 00:00:00	877674.46
2022-06-14 00:00:00	899234.01
2022-06-15 00:00:00	785089.32
2022-06-16 00:00:00	778813.5
2022-06-17 00:00:00	747349.1
2022-06-18 00:00:00	741802.38
2022-06-19 00:00:00	729840.6
2022-06-20 00:00:00	756764.91
2022-06-21 00:00:00	804470.44
2022-06-22 00:00:00	778915.31
2022-06-23 00:00:00	654729.48
2022-06-24 00:00:00	630349.29
2022-06-25 00:00:00	654234.58
2022-06-26 00:00:00	773610.02
2022-06-27 00:00:00	714124.67
2022-06-28 00:00:00	772085.53
2022-06-29 00:00:00	411530.76 */

-- Insight:
-- Daily revenue fluctuated throughout the analysis period, with several high-performing sales days during April and early May.
-- Revenue gradually declined toward the end of June.

-- Recommendation:
-- Utilize daily sales trends for demand forecasting, inventory planning, and scheduling promotional campaigns.

-- Business Impact:
-- Better demand forecasting improves inventory management and reduces stock shortages or overstocking.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 6.5 – Daily Order Trend
-------------------------------------------------------*/

-- Business Question: How did daily customer order volume fluctuate over time?

SELECT order_date, COUNT(DISTINCT order_id) AS Daily_Orders FROM amazon_sales GROUP BY order_date ORDER BY order_date;
/* 2022-03-31 00:00:00	158
2022-04-01 00:00:00	1363
2022-04-02 00:00:00	1452
2022-04-03 00:00:00	1565
2022-04-04 00:00:00	1375
2022-04-05 00:00:00	1505
2022-04-06 00:00:00	1448
2022-04-07 00:00:00	1435
2022-04-08 00:00:00	1570
2022-04-09 00:00:00	1511
2022-04-10 00:00:00	1646
2022-04-11 00:00:00	1482
2022-04-12 00:00:00	1373
2022-04-13 00:00:00	1556
2022-04-14 00:00:00	1753
2022-04-15 00:00:00	1733
2022-04-16 00:00:00	1613
2022-04-17 00:00:00	1479
2022-04-18 00:00:00	1456
2022-04-19 00:00:00	1565
2022-04-20 00:00:00	1709
2022-04-21 00:00:00	1631
2022-04-22 00:00:00	1542
2022-04-23 00:00:00	1698
2022-04-24 00:00:00	1698
2022-04-25 00:00:00	1558
2022-04-26 00:00:00	1460
2022-04-27 00:00:00	1360
2022-04-28 00:00:00	1314
2022-04-29 00:00:00	1385
2022-04-30 00:00:00	1571
2022-05-01 00:00:00	1663
2022-05-02 00:00:00	1906
2022-05-03 00:00:00	1941
2022-05-04 00:00:00	1892
2022-05-05 00:00:00	1382
2022-05-06 00:00:00	1297
2022-05-07 00:00:00	1325
2022-05-08 00:00:00	1369
2022-05-09 00:00:00	1219
2022-05-10 00:00:00	1109
2022-05-11 00:00:00	1103
2022-05-12 00:00:00	1047
2022-05-13 00:00:00	1038
2022-05-14 00:00:00	1135
2022-05-15 00:00:00	1281
2022-05-16 00:00:00	1120
2022-05-17 00:00:00	1125
2022-05-18 00:00:00	1185
2022-05-19 00:00:00	1150
2022-05-20 00:00:00	1032
2022-05-21 00:00:00	1002
2022-05-22 00:00:00	1132
2022-05-23 00:00:00	1113
2022-05-24 00:00:00	1107
2022-05-25 00:00:00	1202
2022-05-26 00:00:00	1147
2022-05-27 00:00:00	1211
2022-05-28 00:00:00	1242
2022-05-29 00:00:00	1209
2022-05-30 00:00:00	1196
2022-05-31 00:00:00	1300
2022-06-01 00:00:00	1417
2022-06-02 00:00:00	1328
2022-06-03 00:00:00	1162
2022-06-04 00:00:00	1325
2022-06-05 00:00:00	1474
2022-06-06 00:00:00	1432
2022-06-07 00:00:00	1424
2022-06-08 00:00:00	1471
2022-06-09 00:00:00	1460
2022-06-10 00:00:00	1201
2022-06-11 00:00:00	1281
2022-06-12 00:00:00	1447
2022-06-13 00:00:00	1309
2022-06-14 00:00:00	1322
2022-06-15 00:00:00	1180
2022-06-16 00:00:00	1180
2022-06-17 00:00:00	1085
2022-06-18 00:00:00	1107
2022-06-19 00:00:00	1099
2022-06-20 00:00:00	1157
2022-06-21 00:00:00	1217
2022-06-22 00:00:00	1207
2022-06-23 00:00:00	1005
2022-06-24 00:00:00	950
2022-06-25 00:00:00	977
2022-06-26 00:00:00	1116
2022-06-27 00:00:00	1042
2022-06-28 00:00:00	1130
2022-06-29 00:00:00	606 */

-- Insight:
-- Daily customer order volume closely mirrored the daily revenue trend, confirming that sales performance was primarily driven by customer demand.

-- Recommendation:
-- Continuously monitor daily order patterns to identify unusual fluctuations and respond quickly with operational or marketing initiatives.

-- Business Impact:
-- Early identification of changing demand enables faster business decision-making.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 6.6 – Revenue by Weekday
-------------------------------------------------------*/

-- Business Question: Which day of the week generated the highest revenue?

SELECT DAYNAME(order_date) AS Weekday, FORMAT(SUM(amount),2) AS Revenue FROM amazon_sales GROUP BY DAYNAME(order_date), WEEKDAY(order_date) ORDER BY WEEKDAY(order_date);
/* Monday	11,318,441.14
Tuesday	11,491,626.07
Wednesday	11,249,823.35
Thursday	10,358,594.27
Friday	10,805,394.60
Saturday	11,339,357.57
Sunday	12,029,441.30 */

-- Insight:
-- Sunday generated the highest revenue, while Thursday recorded the lowest.
-- Weekend sales were slightly stronger than weekday sales.

-- Recommendation:
-- Increase promotional campaigns, inventory availability, and staffing during weekends while introducing targeted offers to improve Thursday sales.

-- Business Impact:
-- Optimizing promotions based on customer purchasing patterns can improve weekly revenue distribution.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 6.7 – Orders by Weekday
-------------------------------------------------------*/

-- Business Question: Which day of the week received the highest number of customer orders?

SELECT DAYNAME(order_date) AS Weekday, COUNT(DISTINCT order_id) AS Orders FROM amazon_sales GROUP BY DAYNAME(order_date), WEEKDAY(order_date) ORDER BY WEEKDAY(order_date);
/* Monday	17365
Tuesday	17578
Wednesday	17336
Thursday	15990
Friday	16569
Saturday	17239
Sunday	18178 */

-- Insight:
-- Sunday received the highest customer order volume, while Thursday recorded the fewest orders.
-- Order volume closely followed the weekly revenue trend.

-- Recommendation:
-- Strengthen customer engagement strategies during lower-performing weekdays to improve overall order volume.

-- Business Impact:
-- Increasing weekday orders contributes to more balanced business performance throughout the week.

-- Recommendation Priority: Medium

/*-------------------------------------------------------
Query 6.8 – Cancellation Rate by Month
-------------------------------------------------------*/

-- Business Question: How did the cancellation rate vary across different months?

SELECT MONTHNAME(order_date) AS Month, COUNT(*) AS Total_Orders, SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
ROUND( SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END)*100.0/COUNT(*),2 ) AS Cancellation_Rate
FROM amazon_sales GROUP BY MONTH(order_date), MONTHNAME(order_date) ORDER BY MONTH(order_date);
/* March	170	18	10.59
April	48976	7137	14.57
May	41968	5874	14.00
June	37632	5303	14.09 */

-- Insight:
-- Cancellation rates remained relatively stable throughout the analysis period.
-- April recorded the highest cancellation rate, while May and June showed nearly identical operational performance.

-- Recommendation:
-- Continue monitoring cancellation trends and investigate any future increases beyond the normal operating range.

-- Business Impact:
-- Maintaining consistent cancellation rates helps preserve customer satisfaction and operational efficiency.

-- Recommendation Priority: Low

/*-------------------------------------------------------
Query 6.9 – Highest Revenue Day
-------------------------------------------------------*/

-- Business Question: Which individual date generated the highest revenue during the analysis period?

SELECT order_date, ROUND(SUM(amount),2) AS Revenue FROM amazon_sales GROUP BY order_date ORDER BY Revenue DESC LIMIT 10;
/* 2022-05-04 00:00:00	1209364.17
2022-05-03 00:00:00	1190672.59
2022-05-02 00:00:00	1172327.06
2022-04-14 00:00:00	1113487.56
2022-04-23 00:00:00	1093536.62
2022-04-20 00:00:00	1091926.41
2022-04-24 00:00:00	1082483.95
2022-05-01 00:00:00	1079957.52
2022-04-10 00:00:00	1075234.03
2022-04-15 00:00:00	1024542.13 */

-- Insight:
-- The highest-performing sales days occurred during late April and early May.
-- 4 May 2022 recorded the highest daily revenue of approximately ₹1.21 million.

-- Recommendation:
-- Analyze promotional campaigns, customer demand, or seasonal factors during these peak-performing days and replicate successful strategies in future sales events.

-- Business Impact:
-- Replicating successful sales periods can increase future revenue and improve campaign effectiveness.

-- Recommendation Priority: High