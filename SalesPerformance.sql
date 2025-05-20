Create DataBase SalesPerformance;

Use SalesPerformance;

Create Table Accounts
(Account Varchar(100) Primary Key, Sector Varchar(100), Year_Established INT, Revenue Money, Employees INT, Office_Location Varchar(100), 
Subsidiary_of Varchar(100))

Create Table Products
(Product Varchar(100) Primary Key, Series Varchar(100), Sales_Price Money)

Create Table SalesPipeline
(Opportunity_Id INT, Sales_Agent Varchar(100) Foreign Key References SalesTeams(Sales_Agent), Product Varchar(100) Foreign Key References Products(Product),
Account Varchar(100) Foreign Key References Accounts(Account), Deal_Stage Varchar(100), Engage_date	Date, Close_Date Date, 
Close_Value Money)

Create Table SalesTeams
(Sales_Agent Varchar(100) Primary Key, Manager Varchar(100), Regional_office Varchar(100))

-- We have changed it in varchar because data was not adding into it
Alter table SalesPipeline
Alter column Opportunity_Id Varchar(100)

Alter table SalesPipeline
Alter column Engage_date Varchar(100)

Alter table SalesPipeline
Alter column Close_Date Varchar(100)

-- After making changes in datatype we were able to add data by bulk insert in SalesPipeline table

Bulk insert Accounts from 'D:\transfer\Work\LB\Projects\LB Project\April\Accounts.csv'
with (fieldterminator = ',', rowterminator = '\n', firstrow = 2, maxerrors = 20)

Select * from Accounts;

Bulk insert Products from 'D:\transfer\Work\LB\Projects\LB Project\April\Products.CSV'
with (fieldterminator = ',', rowterminator = '\n', firstrow = 2, maxerrors = 20)

Select * from Products;

Bulk insert SalesPipeline from 'D:\transfer\Work\LB\Projects\LB Project\April\Sales_Pipeline.csv'
with (fieldterminator = ',', rowterminator = '\n', firstrow = 2, Maxerrors = 20)

Select * from SalesPipeline;

Bulk Insert SalesTeams from 'D:\transfer\Work\LB\Projects\LB Project\April\sales_teams.csv'
with (fieldterminator = ',', rowterminator = '\n', firstrow = 2, maxerrors = 20)

Select * from SalesTeams;

Select column_name, data_type from INFORMATION_SCHEMA.COLUMNS 

-- We need to change Engage date into date format
Select Engage_date, Convert(Varchar(100), Try_Convert(Date, Engage_date,105), 23) from SalesPipeline
update SalesPipeline set Engage_date = Convert(Varchar(100), Try_Convert(Date, Engage_date,105), 23)

-- Now will convert the datatype
Alter table SalesPipeline
Alter Column Engage_date Date

-- We need to change Close date into date format
Select Close_Date, Convert(Varchar(100), try_convert(Date, Close_date, 105),23) from SalesPipeline
update SalesPipeline Set Close_Date = Convert(Varchar(100), try_convert(date, Close_date, 105),23) 

-- Now will convert the datatype
Alter table SalesPipeline
Alter Column Close_date Date

-- Q. 1) Classifies deals into high, mid, and low-value segments and identifies which sales agents close the most high-value deals.

Select Max(close_value) as MaxVal, Avg(close_value) as AvgVal, Min(close_value) as MinVal from SalesPipeline
-- 0 to 1000 low, 1001 to 3500 mid, 3501 and above high

Select Opportunity_Id, Sales_Agent, Close_Value, Case When Close_Value <= 1000.00 then 'Low Seg'
                                      When Close_Value between 1001.00 and 3500.00 then 'Mid Seg'
						              When Close_Value > 3500.00 then 'High Seg' 
					                  Else Null End as 'Segment' from SalesPipeline
Order by Close_Value Desc
/* These Deals are categories as High, Mid and low segments */

With CTE as
(Select Sales_Agent, Close_Value, Case When Close_Value <= 1000.00 then 'Low Seg'
                                      When Close_Value between 1001.00 and 3500.00 then 'Mid Seg'
						              When Close_Value > 3500.00 then 'High Seg' 
					                  Else Null End as 'Segment' from SalesPipeline)
Select Sales_Agent, Close_Value, Segment from CTE
where Segment = 'High Seg'
Order by Close_Value Desc
/* Here you can see only High Segment Deals */

With CTE as
(Select Sales_Agent, Close_Value, Case When Close_Value <= 1000.00 then 'Low Seg'
                                      When Close_Value between 1001.00 and 3500.00 then 'Mid Seg'
						              When Close_Value > 3500.00 then 'High Seg' 
					                  Else Null End as 'Segment' from SalesPipeline)
Select Top 10 Sales_Agent, Sum(Close_Value) as 'Total Value' from CTE
Group by Sales_Agent
Order by 'Total Value' Desc
/* These are top 10 Agents who closed highest amount of deals and increase the revenue */

-- Q. 2) identify which accounts are moving faster or slower through different deal stages and can highlight bottlenecks.
-- ## Won Deals Analysis ##
Select Top 10 Account, Sum(Close_Value) as TotalValue from SalesPipeline
Where Deal_Stage = 'Won' and Datediff(Day, Engage_Date, Close_Date) Between 1 and 10
Group by Account
Order By TotalValue Desc 
/* These accounts are moving faster, I have mentioned top 10 accounts, Total Value represent revenue from these account in 10 days of time period. These deals won in 10 days */

Select Opportunity_Id, Account, Sales_Agent, Datediff(Day, Engage_Date, Close_Date) As TotalDays, Close_Value from SalesPipeline
Where Deal_Stage = 'Won' and Datediff(Day, Engage_Date, Close_Date) Between 1 and 10
Order By TotalDays, Close_Value Desc 
/* There are total 1267 opportunities which are won in 10 days with their respective accounts, sales agents and close value. */

Select Opportunity_Id, Account, Sales_Agent, Datediff(Day, Engage_Date, Close_Date) As TotalDays, Close_Value from SalesPipeline
Where Deal_Stage = 'Won'
Order By TotalDays, Close_Value Desc
/* There are total 4,238 Opportunities which are Won by Sales agents */

-- ## Lost Deals Analysis ##
Select Top 10 Account, Datediff(Day, Engage_Date, Close_Date) As TotalDays from SalesPipeline
Where Deal_Stage = 'Lost' and Datediff(Day, Engage_Date, Close_Date) > 100
Order By TotalDays desc
/* These are accounts moving slow, which are taking so many days stil lost the opportunities */

Select Opportunity_Id, Account, Sales_Agent, Datediff(Day, Engage_Date, Close_Date) As TotalDays from SalesPipeline
Where Deal_Stage = 'Lost' and Datediff(Day, Engage_Date, Close_Date) > 100
Order By TotalDays desc
/* There are total 247 Opportunities which took more than 100 days but still lost those opportunities */

Select Opportunity_Id, Account, Sales_Agent, Datediff(Day, Engage_Date, Close_Date) As TotalDays from SalesPipeline
Where Deal_Stage = 'Lost'
Order By TotalDays desc
/* There are total 2473 Opportunities which are Lost by Sales agents */

-- ## Engaging Deals Analysis ##
Select Top 10 Account from SalesPipeline
Where Deal_Stage = 'Engaging' and Account Is Not Null
/* There are total 501 opportunities which are in engage state currently. These Accounts are engaged but not yet able to close the deals */

-- ## Prospecting Deals Analysis ##
Select Top 10 Account from SalesPipeline
Where Deal_Stage = 'Prospecting' and Account Is Not Null
/* There are total 163 Opportunities which are prospects and these are top 10 prospects accounts. */

-- Q. 3) Calculate the average number of days taken to close a deal for each industry.
Select A.Sector, Avg(DATEDIFF(Day, S.Engage_date, S.Close_Date)) as 'AvgDays' from SalesPipeline S Join Accounts A On S.Account = A.Account
Group by A.Sector
Order By AvgDays
/* Marketing and Medical sectors requires less days as compared to other sectors whereas entertainment, telecommunications, software requires more days*/

-- Q. 4) This query identifies accounts with a high risk of churn by calculating the lost deal percentage and the time gap since their last won deal.
/* As here we need Opportunity id as int because we need to perform calculations with it so we will add new column for ID*/
Alter table SalesPipeline
Add ID INT Identity(1,1)

Select * from SalesPipeline

GO
With LDP As
(Select Account, Count(ID) as LostDeals from SalesPipeline
Where Deal_Stage = 'Lost'
Group by Account)
Select Account, LostDeals, cast(LostDeals*100.00/Sum(LostDeals) Over () as decimal(10,2)) as LostDealPerc from LDP
Group by Account, LostDeals
Order by LostDealPerc Desc
GO
/* We have Order by percentage in descending to know which account have more lost percentage and more lost deals so you can get ideal about account who has
high risk of churn  */

-- Time gap since their last won deal.
with TG as
(Select Account, max(Case when Deal_Stage = 'Lost' then Close_Date Else Null end) as LastLostDate,
                max(Case when Deal_Stage = 'Won' then Close_Date Else Null end) as LastWonDate 
From SalesPipeline
Group by Account)
Select Account, LastLostDate, LastWonDate, DATEDIFF(Day, LastLostDate, LastWonDate) as TimeGap from TG
Order by TimeGap Desc
/* Here we have order by time gap in descending to understand accounts with high time gap and those accounts are at high risk. We have some negetive number in 
time gap which indicate accounts with last recorded date are lost deal date */

-- We are just showing the lost percentage and time gap together
With LDP As
(Select Account, max(Case when Deal_Stage = 'Lost' then Close_Date Else Null end) as LastLostDate,
                 max(Case when Deal_Stage = 'Won' then Close_Date Else Null end) as LastWonDate, 
				 Count(Case when Deal_Stage = 'Lost' then ID Else Null End) as LostDeals 
From SalesPipeline
Group by Account)
Select Account, LastLostDate, LastWonDate, DATEDIFF(Day, LastLostDate, LastWonDate) as TimeGap, LostDeals, 
cast(LostDeals*100.00/Sum(LostDeals) Over () as decimal(10,2)) as LostDealPerc from LDP
Order by Account

-- Q. 5) This query identifies seasonal trends in sales performance by analyzing revenue fluctuations across months and years.
Select DateName(Month, Close_Date) as 'Month', Sum(Close_Value) as 'Total Revenue' from SalesPipeline
Where Deal_Stage = 'Won'
Group by DateName(Month, Close_Date)
Order by 'Total Revenue' desc
/* Here you can see revenue fluctuation across months, order by total revenue in descending so you can see June, september, march are most profitable months */

Select Account, Sum(Case when month(Close_Date) = 03 then Close_Value Else 0 End) as March,
                Sum(Case when month(Close_Date) = 04 then Close_Value Else 0 End) as April,
				Sum(Case when month(Close_Date) = 05 then Close_Value Else 0 End) as May,
				Sum(Case when month(Close_Date) = 06 then Close_Value Else 0 End) as June, 
				Sum(Case when month(Close_Date) = 07 then Close_Value Else 0 End) as July, 
				Sum(Case when month(Close_Date) = 08 then Close_Value Else 0 End) as August, 
				Sum(Case when month(Close_Date) = 09 then Close_Value Else 0 End) as September, 
				Sum(Case when month(Close_Date) = 10 then Close_Value Else 0 End) as October,
				Sum(Case when month(Close_Date) = 11 then Close_Value Else 0 End) as November,
				Sum(Case when month(Close_Date) = 12 then Close_Value Else 0 End) as December,
				Sum(Close_Value) as AccountRevenue
from SalesPipeline
Where Deal_Stage = 'Won'
Group by Account
Order by AccountRevenue desc
/* Thses table will show you account wise monthly revenue and total of all months revenue for that particular account.
Kan-code, Konex, Condax, Cheers, Hottechi are top 5 highest revenue account respectively*/


