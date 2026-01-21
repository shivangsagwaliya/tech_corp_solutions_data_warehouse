DROP TABLE IF  EXISTS silver.dim_customers;

CREATE TABLE silver.dim_customers(
	Customer_ID nvarchar(50) ,
	Company_Name nvarchar(50) ,
	Industry nvarchar(50) ,
	Segment nvarchar(50) ,
	Region nvarchar(50) ,
	State nvarchar(50) ,
	Credit_Limit_USD int ,
	Payment_Terms nvarchar(50) ,
	Account_Manager nvarchar(50) ,
	Email nvarchar(100) ,
	Acquisition_Date datetime2 ,
	Status nvarchar(50) 
) 

DROP TABLE IF  EXISTS silver.dim_employees
CREATE TABLE silver.dim_employees(
	Employee_ID nvarchar(50) ,
	First_Name nvarchar(50) ,
	Last_Name nvarchar(50) ,
	Email nvarchar(50) ,
	Department nvarchar(50) ,
	Title nvarchar(50) ,
	Hire_Date datetime2(7) ,
	Manager_ID nvarchar(50) ,
	Office_Location nvarchar(50) ,
	Employment_Status nvarchar(50) 
)

DROP TABLE IF  EXISTS silver.dim_products
CREATE TABLE silver.dim_products(
	Product_ID nvarchar(50) ,
	SKU nvarchar(50) ,
	UPC float ,
	Product_Name nvarchar(50) ,
	Category nvarchar(50) ,
	Brand nvarchar(50) ,
	Unit_Cost_USD float ,
	Unit_Price_USD float ,
	Supplier_ID nvarchar(50) ,
	Stock_Status nvarchar(50) ,
	Warranty_Months int 
)

DROP TABLE IF EXISTS silver.fact_orders
CREATE TABLE silver.fact_orders(
	Order_ID nvarchar(50) ,
	Order_Date datetime2(7) ,
	Customer_ID nvarchar(50) ,
	Product_ID nvarchar(50) ,
	Quantity int ,
	Unit_Price_USD float ,
	Subtotal_USD float ,
	Discount_Percent float ,
	Discount_Amount_USD float ,
	Tax_Amount_USD float ,
	Total_Amount_USD float ,
	Order_Status nvarchar(50) ,
	Payment_Method nvarchar(50) ,
	Sales_Employee_ID nvarchar(50) ,
	Ship_Date date ,
	Delivery_Date date
) 

DROP TABLE IF  EXISTS silver.dim_suppliers
CREATE TABLE silver.dim_suppliers(
	Supplier_ID nvarchar(50) ,
	Supplier_Name nvarchar(50) ,
	Category nvarchar(50) ,
	City nvarchar(50) ,
	Country nvarchar(50) ,
	Lead_Time_Days int ,
	Payment_Terms nvarchar(50) ,
	Supplier_Rating float ,
	Active_Status nvarchar(50) 
) 