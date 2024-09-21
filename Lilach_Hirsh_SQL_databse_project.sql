use master
go
create database sales
go
use sales
go
create table SpecialOfferProduct
(
			SpecialOfferId int ,
			ProductId int ,
			constraint SpecialOfferProduct_SpecialOfferId_ProductId_pk primary key (SpecialOfferId,ProductId),
			rowguid uniqueidentifier not null,
			ModifiedDate datetime not null,
)
go 
select*
from SpecialOfferProduct
insert into SpecialOfferProduct
select*
from AdventureWorks2017.Sales.SpecialOfferProduct as sop

use sales
go
create table credit_card
(
			CreditCardId int constraint credit_card_CreditCardId_pk primary key,
			CardType nvarchar(50) not null,
			CatrdNumber nvarchar(25) not null,
			ExpMonth tinyint not null,
			ExpYear smallint not null,
			ModifiedDate datetime not null
)
go

select*
from credit_card

select*
from AdventureWorks2017.Sales.CreditCard

insert into credit_card
select*
from AdventureWorks2017.Sales.CreditCard as scr

use sales
go
create table sales_Territory
(
			TerritoryId int constraint sales_Territory_TerritoryId_pk primary key,
			Name nvarchar(50) not null,
			CountryRegionCode nvarchar(3) not null,
			[group] nvarchar (50) not null,
			SalesYTD money not null,
			SalesLastYear money not null,
			CostYTD money not null,
			CostLastYear money not null,
			rowguid uniqueidentifier not null,
			ModifiedDate datetime not null
)
go

insert into  sales_Territory 
select st.TerritoryID, st.Name, st.CountryRegionCode,st.[Group], st.SalesYTD,st.SalesLastYear,st.CostYTD,st.CostLastYear, st.rowguid,st.ModifiedDate
from AdventureWorks2017.Sales.SalesTerritory as st

select*
from sales_Territory

create table person_Adress
(
			AddressID int constraint PA_AddressID_pk primary key,
			AddressLine1 nvarchar(60) not null, 
			AddressLine2 nvarchar(60) ,
			City nvarchar(30) not null,
			StateProvinceID int not null, 
			PostalCode nvarchar(15)not null,
			SpatialLocation geography ,
			rowguid uniqueidentifier not null,
			ModifiedDate datetime not null
)
go

select*
from person_Adress

insert into person_Adress
select*
from AdventureWorks2017.Person.Address

create table customer_sales
(
			CustomerId int  constraint customer_sales_customerid_pk primary key,
			PersonId int ,
			StoreId int,
			TerritoyId int constraint cs_TerritoyId_fk foreign key references sales_Territory(TerritoryId) ,
			AccountNumber varchar(10) not null,
			Rowguid uniqueidentifier not null,
			modifieddate datetime not null
)
go

select*
from customer_sales

select*
from AdventureWorks2017.Sales.Customer

insert into customer_sales
select *
from AdventureWorks2017.Sales.Customer as sc

use sales
go
create table Sales_Person
(
			BusinessEntityId int constraint Sales_Person_BusinessEntityId_pk primary key,
			TerritoyId int constraint sp_TerritoyId_fk foreign key references sales_Territory(TerritoryId),
			SalesQuata money,
			Bonus money not null,
			CommissionPct smallmoney not null,
			SalesYTD money not null,
			SalesLastYear money not null,
			rowguid uniqueidentifier not null,
			ModifiedDate datetime not null
)
go

insert into Sales_Person
select*
from AdventureWorks2017.Sales.SalesPerson

select*
from Sales_Person

select*
from AdventureWorks2017.Sales.SalesPerson

use sales
go
create table sales_CurrencyRate
(
			CurrencyRateID int constraint Scr_CurrencyRateID_pk primary key,
			CurrencyRateDate datetime not null,
			FromCurrencyCode nchar(3)not null,
			ToCurrencyCode nchar(3)not null,
			AverageRate money not null,
			EndOfDayRate money not null,
			ModifiedDate datetime not null
)
go

insert into sales_CurrencyRate
select*
from AdventureWorks2017.Sales.CurrencyRate

select*
from sales_CurrencyRate

use sales
go
create table ShipMethod
(
			ShipMethodID  int constraint Sm_ShipMethodID_pk primary key,
			Name nvarchar(50) not null,
			ShipBase  money not null,
			ShipRate money not null,
			rowguid uniqueidentifier not null,
			ModifiedDate  datetime not null
)
go

select*
from ShipMethod

insert into ShipMethod
select*
from AdventureWorks2017.Purchasing.ShipMethod

use sales
go
create table SalesOrderHeader
(
			SalesOrderID int constraint Soh_SalesOrderID_pk primary key,
			RevisionNumber tinyint not null,
			OrderDate datetime not null,
			DueDate datetime not null,
			ShipDate datetime,
			[status] tinyint not null,
			OnlineOrderFlag bit not null,
			SalesOrderNumber nvarchar(25) not null, 
			PurchaseOrderNumber nvarchar (50) ,
			AccountNumber  nvarchar (50) ,
			CustomerID int  not null constraint soh_CustomerID_fk foreign key references customer_sales(CustomerId),
			SalesPersonID int constraint soh_SalesPersonID_fk foreign key references Sales_Person(BusinessEntityId),
			TerritoryID int constraint soh_TerritoryID_fk foreign key references sales_Territory(TerritoryId),
			BillToAddressID int not null,
			ShipToAddressID int  constraint soh_ShipToAddressID_fk foreign key references person_Adress(AddressID) not null,
			ShipMethodID int  constraint soh_ShipMethodID_fk foreign key references ShipMethod(ShipMethodID) not null,
			CreditCardID int constraint soh_CreditCardID_fk foreign key references credit_card(CreditCardId),
			CreditCardApprovalCode varchar(15),
			CurrencyRateID int constraint soh_CurrencyRateID_fk foreign key references sales_CurrencyRate(CurrencyRateID),
			SubTotal money not null,
			TaxAmt money not null,
			Freight money not null
)
go

select*
from SalesOrderHeader

select*
from AdventureWorks2017.Sales.SalesOrderHeader

insert into SalesOrderHeader
select SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,[status] ,OnlineOrderFlag ,
SalesOrderNumber,PurchaseOrderNumber,AccountNumber,CustomerID,SalesPersonID,TerritoryID,BillToAddressID,
ShipToAddressID,ShipMethodID,CreditCardID,CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,Freight
from AdventureWorks2017.Sales.SalesOrderHeader

use sales
go
create table salesorderdetail
(
			SalesOrderID int  constraint sod_SalesOrderID_FK foreign key references SalesOrderHeader(SalesOrderID),
			SalesOrderDetailID int ,
			CarrierTrackingNumber nvarchar(25),
			OrderQty smallint not null,
			ProductID int ,
			SpecialOfferID int not null,
			UnitPrice money not null,
			UnitPriceDiscount money not null,
			LineTotal money not null,
			rowguid uniqueidentifier not null,
			ModifiedDate datetime not null,
			constraint salesorderdetail_SalesOrderID_SalesOrderDetailID_pk primary key (SalesOrderID,SalesOrderDetailID),
			constraint sod_SpecialOfferID_FK   
			foreign key (SpecialOfferID, ProductID) 
            references  SpecialOfferProduct(SpecialOfferID, ProductID)
)
go

select*
from salesorderdetail

select*
from AdventureWorks2017.Sales.SalesOrderDetail

insert into salesorderdetail
select*
from AdventureWorks2017.Sales.SalesOrderDetail as sod

select*
from salesorderdetail