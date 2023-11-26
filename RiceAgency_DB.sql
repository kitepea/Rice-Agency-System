DROP DATABASE IF EXISTS RiceAgency_DB;
GO
CREATE DATABASE RiceAgency_DB;
GO
USE RiceAgency_DB;
GO
-- VKDKhoa

/************************* MẶT_HÀNG *****************************/
-- PK = PMXXXX;  [PREFIX] = PM, id PMXXXX
CREATE TABLE [PRODUCT] (
	id_product CHAR(6) NOT NULL,
	[PName] NVARCHAR(30) NOT NULL,
	[description]  NVARCHAR(80),
	price_kg DECIMAL(10,0) DEFAULT 20000, -- giá gốc(VND) của 1kg gạo đó
	featured VARCHAR(9),
	Original VARCHAR(9),
	picture IMAGE --this is IMAGE type
	CONSTRAINT PR_Pro PRIMARY KEY(id_product),
	CONSTRAINT ProName UNIQUE([PName])
)
/******************************************************/

/************************* LOẠI_BAO *****************************/
--PK: id_type = TBXX, [PREFIX] = TB, XX chỉ loại bao VD Loại 2kg => XX = 02
CREATE TABLE TYPE_OF_BAGS(
	id_pro CHAR(6) NOT NULL,
	id_types CHAR(6) NOT NULL,
	BName CHAR(6) NOT NULL,
	inventory_num INT, 
	price_Bags DECIMAL(10,0), --giá (VND) của mỗi loại bao

	CONSTRAINT PR_TYPEBAGS PRIMARY KEY(id_product, id_types),
	CHECK (
		BName = '2kg' OR BNanme = '5kg' OR BName = '10kg' -- các loại bao gạo gồm 3 loại 2kg,5kg,10kg
		AND inventory_num >= 0 AND inventory_num <= 500 --SL tồn kho không âm và max = 500
		AND price(VND) > 1000 -- giá mỗi loại bao không thấp hơn 1000
	)
)
/******************************************************/

/************************* LÔ_BAO_GẠO *****************************/
CREATE TABLE PHYSICAL_RICEBAG(
	id_product CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	NumOrder CHAR(6) NOT NULL,
	Quantity INT DEFAULT 1,
	NSX DATE,
	HSD DATE,
	CONSTRAINT PK_PHYBAGS PRIMARY KEY(id_product,id_type,NumOrder),
	CHECK (NSX < HSD)
)
/******************************************************/

/************************* ĐƠN_HÀNG *****************************/
-- PK: id_bill = BMXXXX, [PREFIX] = BM,
CREATE TABLE BILL(
	id_bill CHAR(6) NOT NULL,
	date_create DATE,
	[status] VARCHAR(15) DEFAULT 'Unprocessed',
	note VARCHAR(15),
	customer_id CHAR(6) NOT NULL,
	seller_id CHAR(6) NOT NULL,

	house_num varchar(5) NOT NULL,
	street varchar(50) NOT NULL,
	city varchar(50) NOT NULL,

	CONSTRAINT PK_BILL PRIMARY KEY(id_bill),
	CHECK ([status] = 'Unprocessed' OR [status] = 'Process')
)
)
/******************************************************/

/************************* KIỆN_HÀNG *****************************/
CREATE TABLE PACKAGE(
	id_package CHAR(6) NOT NULL,
	id_bill CHAR(6) NOT NULL,
	[status] VARCHAR(15)  DEFAULT 'Not started'
	id_DelivTrip CHAR(6) NOT NULL,
	CONSTRAINT PK_PACKAGES PRIMARY KEY(id_package,id_type,NumOrder),
	CHECK ([status] = 'Not started' OR [status] = 'Started' OR [status] = 'Complete')
)
/******************************************************/

/************************* GỒM (MAPPING TỪ LÔ ĐẾN KIỆN) *****************************/
CREATE TABLE CONTAIN_PACKAGE(
	id_product CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	NumOrder CHAR(6) NOT NULL, -- ????
	id_package CHAR(6) NOT NULL,
	Quantity INT DEFAULT 1, -- số lượng lô trong kiện hàng
	CONSTRAINT PK_CP PRIMARY KEY (id_product,id_type,NumOrder,id_package),
	CHECK (Quantity > 0)
)
/******************************************************/

/************************* CHUYẾN_GIAO_HÀNG *****************************/
CREATE TABLE DELIVERY_TRIP(
	id_DelivTrip CHAR(6) NOT NULL,
	[status] VARCHAR(15)  DEFAULT 'Not started',
	expect_receive_day DATE,
	actual_receive_day DATE,
	shipper_id CHAR(6) NOT NULL,
	id_vechile CHAR(6) NOT NULL,
	CONSTRAINT PK_Deli PRIMARY KEY (id_DelivTrip),
)
/******************************************************/

/************************* GỒM (MAPPING TỪ ĐƠN HÀNG ĐẾN LÔ BAO GẠO) *****************************/
CREATE TABLE CONTAIN_PHYBAGS(
	id_product CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	NumOrder CHAR(6) NOT NULL, -- ????
	id_bill CHAR(6) NOT NULL,
	Quantity INT DEFAULT 1, --số lượng lô trong đơn hàng

	CONSTRAINT PK_CPB PRIMARY KEY (id_product,id_type,NumOrder,id_bill),
	CHECK (Quantity > 0)
)
/******************************************************/

/************************* NHÂN VIÊN VẬN CHUYỂN *****************************/
CREATE TABLE SHIPPER (
	shipper_id CHAR(6) NOT NULL,
	CONSTRAINT PK_SHIPEMP PRIMARY KEY (shipper_id)
)
/******************************************************/

/************************* PHƯƠNG TIỆN *****************************/
CREATE TABLE VECHILE (
	id_vechile CHAR(6) NOT NULL,
	CONSTRAINT PK_VECHILE PRIMARY KEY (id_vechile)
)
/******************************************************/

/************************* SẢN XUẤT *****************************/
CREATE TABLE PRODUCTION (
	id_product CHAR(6) NOT NULL,
	company_name VARCHAR(30) NOT NULL,
	CONSTRAINT PK_PRODUCTION PRIMARY KEY (id_product,company_name)
)
/******************************************************/

/************************* CÔNG TY SẢN SUẤT *****************************/
CREATE TABLE COMPANY_PRODUCT (
	company_name VARCHAR(30) NOT NULL,
	hotline VARCHAR(15),
	CONSTRAINT PK_COMPANY_PRODUCT PRIMARY KEY (company_name)
)
/******************************************************/


