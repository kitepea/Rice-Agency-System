-- FULL DATABASE OF RICE AGENCY --
-- QUAN --
USE master;
GO
IF EXISTS (
SELECT name
FROM master.sys.databases
WHERE name = N'Rice_Agency')
BEGIN
	ALTER DATABASE Rice_Agency SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Rice_Agency;
END;
GO
CREATE DATABASE Rice_Agency;
GO
USE Rice_Agency;
GO

set dateformat dmy;

CREATE TABLE [USER]
(
	[user_id] CHAR(6),
	FMName VARCHAR(30) NOT NULL,
	[Name] VARCHAR(10) NOT NULL,
	Phone CHAR(10) UNIQUE,
	Email VARCHAR(50) UNIQUE,
	[Address] VARCHAR(50),
	PRIMARY KEY([user_id]),
	CHECK (
        (LEFT([user_id], 2) = 'EM' OR LEFT([user_id], 2) = 'CM') AND
		ISNUMERIC(RIGHT([user_id], 4)) = 1 AND
		LEN([user_id]) = 6
    )
);


CREATE TABLE [ADDRESS]
(
	[user_id] CHAR(6),
	house_num VARCHAR(5) not null,
	street VARCHAR(50) not null,
	city VARCHAR(50) not null,
	PRIMARY KEY ([user_id], house_num, street, city),
	CONSTRAINT fk_uid_address FOREIGN KEY ([user_id]) REFERENCES [user] ([user_id]) 
	-- on delete cascade
	ON UPDATE CASCADE
);

CREATE TABLE [ACCOUNT]
(
	Username varchar(30),
	[Password] varchar(65) not null,
	[Type] VARCHAR(20) CHECK ([TYPE] IN ('Employee', 'Customer')) NOT NULL,
	[user_id] CHAR(6),
	PRIMARY KEY(Username),
	CONSTRAINT fk_uid_account FOREIGN KEY ([user_id]) REFERENCES [user] ([user_id])
	-- on delete cascade
	ON UPDATE CASCADE
);

CREATE TABLE EMPLOYEE
(
	employee_id CHAR(6) NOT NULL,
	manager_id CHAR(6) NOT NULL,
	PRIMARY KEY (employee_id),
	CONSTRAINT fk_empid_uid FOREIGN KEY (employee_id) REFERENCES [user] ([user_id])
	-- on delete cascade
	ON UPDATE CASCADE
);

CREATE TABLE CUSTOMER
(
	customer_id CHAR(6) PRIMARY KEY,
	CONSTRAINT fk_uid_customer FOREIGN KEY (customer_id) REFERENCES [user] ([user_id])
	-- on delete cascade
	ON UPDATE CASCADE
);

CREATE TABLE SELLER
(
	seller_id CHAR(6) PRIMARY KEY,
	CONSTRAINT fk_empid_seller FOREIGN KEY (seller_id) REFERENCES employee (employee_id)
	-- on delete cascade
	ON UPDATE CASCADE
);

-- VKDKhoa
/************************* MẶT_HÀNG *****************************/
-- PK = PMXXXX;  [PREFIX] = PM, id PMXXXX
CREATE TABLE [PRODUCT]
(
	id_product CHAR(6) NOT NULL,
	[PName] NVARCHAR(30) NOT NULL,
	[description] NVARCHAR(1000),
	featured NVARCHAR(255),
	origin NVARCHAR(20),
	picture varchar(255) --this is IMAGE type
	CONSTRAINT PR_Pro PRIMARY KEY(id_product),
	CONSTRAINT ProName UNIQUE([PName])
)


/******************************************************/

/************************* LOẠI_BAO *****************************/
--PK: id_type = TBXX, [PREFIX] = TB, XX chỉ loại bao VD Loại 2kg => XX = 02
CREATE TABLE TYPE_OF_BAGS
(
	id_pro CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	BName INT NOT NULL DEFAULT 2,
	inventory_num INT,
	price_Bags DECIMAL(10,0),
	--giá (VND) của mỗi loại bao

	CONSTRAINT PR_TYPEBAGS PRIMARY KEY(id_pro, id_type),

	CONSTRAINT FK_TOBPRO_TO_IDPRO FOREIGN KEY (id_pro) REFERENCES [PRODUCT](id_product)
	-- on delete cascade
	ON UPDATE CASCADE,

	CHECK (
		(BName = 2 OR BName = 5 OR BName = 10) -- các loại bao gạo gồm 3 loại 2kg,5kg,10kg
		AND inventory_num >= 0 AND inventory_num <= 500 --SL tồn kho không âm và max = 500
		AND price_Bags > 1000 -- giá mỗi loại bao không thấp hơn 1000
	)
)



/*********************** LÔ BAO GẠO *******************************/

CREATE TABLE PHYSICAL_RICEBAG
(
	id_product CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	NumOrder INT NOT NULL IDENTITY(1,1),
	Quantity INT DEFAULT 1,
	NSX DATE,
	HSD DATE,
	CONSTRAINT PK_PHYBAGS PRIMARY KEY(id_product, id_type, NumOrder),

	CONSTRAINT FK_PHYBAGS_TO_TYPEBAGS
	FOREIGN KEY (id_product, id_type) 
	REFERENCES TYPE_OF_BAGS(id_pro,id_type),

	CHECK (NSX < HSD)
);

/******************************************************/

/************************* ĐƠN_HÀNG *****************************/
-- PK: id_bill = BMXXXX, [PREFIX] = BM,
CREATE TABLE BILL
(
	id_bill CHAR(6) NOT NULL,
	date_create DATE,
	[status] VARCHAR(15) DEFAULT 'Waiting',
	note NVARCHAR(200),
	customer_id CHAR(6) NOT NULL,
	seller_id CHAR(6) NOT NULL,
	house_num VARCHAR(5) NOT NULL,
	street nvarchar(50) NOT NULL,
	city nvarchar(50) NOT NULL,

	CONSTRAINT PK_BILL PRIMARY KEY(id_bill),
	CHECK ([status] = 'Waiting' OR [status] = 'Delivering' OR [status] = 'Done' OR [status] = 'Cancelled')
)

/******************************************************/

/************************* CHUYẾN_GIAO_HÀNG *****************************/
CREATE TABLE DELIVERY_TRIP
(
	id_DelivTrip CHAR(6) NOT NULL,
	[status] VARCHAR(15) DEFAULT 'Not started',
	expect_receive_day DATE,
	actual_receive_day DATE,
	shipper_id CHAR(6) NOT NULL,
	id_vechile CHAR(11) NOT NULL,

	CONSTRAINT PK_Deli PRIMARY KEY (id_DelivTrip),
	CHECK ([status] = 'Waiting' OR [status] = 'Delivering' OR [status] = 'Done' OR [status] = 'Cancelled')
)
/******************************************************/

/************************* KIỆN_HÀNG *****************************/
CREATE TABLE PACKAGE
(
	id_package CHAR(6) NOT NULL,
	id_bill CHAR(6) NOT NULL,
	[status] VARCHAR(15) DEFAULT 'Waiting',
	id_DelivTrip CHAR(6) NOT NULL,

	CONSTRAINT PK_PACKAGES PRIMARY KEY(id_package),

	CONSTRAINT FK_PACKAGE_TO_BILL FOREIGN KEY (id_bill) REFERENCES BILL(id_bill),
	CONSTRAINT FK_PACKAGE_TO_DELTRIP FOREIGN KEY (id_DelivTrip) REFERENCES DELIVERY_TRIP(id_DelivTrip),

	CHECK ([status] = 'Waiting' OR [status] = 'Delivering' OR [status] = 'Done' OR [status] = 'Cancelled')
)
/******************************************************/

/************************* GỒM (MAPPING TỪ LÔ ĐẾN KIỆN) *****************************/
CREATE TABLE CONTAIN_PACKAGE
(
	id_product CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	NumOrder INT NOT NULL,
	-- ????
	id_package CHAR(6) NOT NULL,
	Quantity INT DEFAULT 1,
	-- số lượng lô trong kiện hàng
	CONSTRAINT PK_CP PRIMARY KEY (id_product,id_type,NumOrder,id_package),

	CONSTRAINT FK_CONPACK_TO_PHYBAGS 
		FOREIGN KEY (id_product,id_type,NumOrder) 
		REFERENCES PHYSICAL_RICEBAG(id_product,id_type,NumOrder),

	CONSTRAINT FK_CONPACK_TO_PACK FOREIGN KEY (id_package) REFERENCES PACKAGE(id_package),
	CHECK (Quantity > 0)
)
/******************************************************/

/************************* GỒM (MAPPING TỪ ĐƠN HÀNG ĐẾN LÔ BAO GẠO) *****************************/
CREATE TABLE CONTAIN_PHYBAGS
(
	id_product CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	NumOrder INT NOT NULL,
	-- ????
	id_bill CHAR(6) NOT NULL,
	Quantity INT DEFAULT 1,
	--số lượng lô trong đơn hàng

	CONSTRAINT PK_CPB PRIMARY KEY (id_product,id_type,NumOrder,id_bill),

	CONSTRAINT FK_CONPHY_TO_PHYBAGS
		FOREIGN KEY (id_product,id_type,NumOrder) 
		REFERENCES PHYSICAL_RICEBAG(id_product,id_type,NumOrder),
	CONSTRAINT FK_CONPHY_TO_BILL FOREIGN KEY (id_bill) REFERENCES BILL(id_bill),

	CHECK (Quantity > 0)
)


/******************************************************/

/************************* NHÂN VIÊN VẬN CHUYỂN *****************************/
CREATE TABLE SHIPPER
(
	shipper_id CHAR(6) NOT NULL,
	CONSTRAINT PK_SHIPEMP PRIMARY KEY (shipper_id),

	CONSTRAINT SHIPER_TO_EMPLOY FOREIGN KEY (shipper_id) REFERENCES employee (employee_id)
)
/******************************************************/

/************************* PHƯƠNG TIỆN *****************************/
CREATE TABLE VECHILE
(
	id_vechile CHAR(11) NOT NULL,
	CONSTRAINT PK_VECHILE PRIMARY KEY (id_vechile)
)
/******************************************************/

/************************* CÔNG TY SẢN SUẤT *****************************/
CREATE TABLE COMPANY_PRODUCT
(
	company_name NVARCHAR(30) NOT NULL,
	CONSTRAINT PK_COMPANY_PRODUCT PRIMARY KEY (company_name)
)
/******************************************************/

/************************* SẢN XUẤT *****************************/
CREATE TABLE PRODUCTION
(
	id_product CHAR(6) NOT NULL,
	company_name NVARCHAR(30) NOT NULL,
	CONSTRAINT PK_PRODUCTION PRIMARY KEY (id_product,company_name),

	CONSTRAINT FK_PRODUCTION_TO_PRODUCT FOREIGN KEY(id_product) REFERENCES [PRODUCT](id_product),
	CONSTRAINT FK_PRODUCTION_TO_COMPANY FOREIGN KEY(company_name) REFERENCES COMPANY_PRODUCT(company_name)
)
/******************************************************/

-- alter
alter table employee
add CONSTRAINT fk_manager_id FOREIGN KEY (manager_id) REFERENCES employee (employee_id);

alter table BILL
add CONSTRAINT FK_BILL_TO_CUSTOMER FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
	-- on delete cascade
	ON UPDATE CASCADE;

alter table BILL
add CONSTRAINT FK_BILL_TO_SELLER FOREIGN KEY (seller_id) REFERENCES seller(seller_id)

alter table DELIVERY_TRIP
add CONSTRAINT FK_DELTRP_TO_SHIPER FOREIGN KEY (shipper_id) REFERENCES SHIPPER(shipper_id)

alter table DELIVERY_TRIP
add CONSTRAINT FK_DELTRP_TO_VECHILE FOREIGN KEY (id_vechile) REFERENCES VECHILE(id_vechile)

-- add prefix auto_increment (procedure and trigger)

-- insert data ---

alter table bill nocheck CONSTRAINT all;
insert into bill
values
	('BM1001', '01-02-2023', 'Cancelled', null, 'CM1001', 'EM1001', '32', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1002', '01-02-2023', 'Done', null, 'CM1002', 'EM1002', '234', N'Hoàng Diệu 2', N'TP Hồ Chí Minh'),
	('BM1003', '21-02-2023', 'Delivering', null, 'CM1003', 'EM1001', '124', N'Võ Nguyên Giáp', N'TP Hồ Chí Minh'),
	('BM1004', '20-04-2023', 'Waiting', null, 'CM1004', 'EM1002', '412', N'Nguyễn Thị Minh Khai', N'Bình Dương'),
	('BM1005', '10-06-2023', 'Waiting', null, 'CM1005', 'EM1002', '512', N'Đường 3 tháng 2', N'TP Hồ Chí Minh'),
	('BM1006', '18-07-2023', 'Done', null, 'CM1006', 'EM1001', '611', N'Cách mạng tháng 8', N'TP Hồ Chí Minh'),
	('BM1007', '15-08-2023', 'Delivering', null, 'CM1007', 'EM1002', '712', N'Đường Cộng hoà', N'TP Hồ Chí Minh'),
	('BM1008', '05-09-2023', 'Done', null, 'CM1008', 'EM1001', '811', N'Võ Văn Ngân', N'TP Hồ Chí Minh'),
	('BM1009', '23-10-2023', 'Waiting', null, 'CM1009', 'EM1003', '913', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1010', '18-11-2023', 'Waiting', null, 'CM1010', 'EM1002', '144', N'Đường Cộng hoà', N'TP Hồ Chí Minh'),
	('BM1011', '14-12-2023', 'Delivering', N'Giao vào buổi sáng', 'CM1011', 'EM1003', '356', N'Võ Nguyên Giáp', N'TP Hồ Chí Minh'),
	('BM1012', '05-01-2023', 'Cancelled', N'Giao vào buổi chiều', 'CM1012', 'EM1001', '126', N'Đường Cộng hoà', N'TP Hồ Chí Minh'),
	('BM1013', '17-12-2023', 'Waiting', null, 'CM1013', 'EM1003', '543', N'Nguyễn Văn Trỗi', N'Cần Thơ'),
	('BM1014', '15-10-2023', 'Cancelled', null, 'CM1014', 'EM1002', '6556', N'Cách mạng tháng 8', N'TP Hồ Chí Minh'),
	('BM1015', '10-09-2023', 'Delivering', null, 'CM1015', 'EM1001', '1256', N'Lê Lợi', N'Đồng Nai'),
	('BM1016', '11-07-2023', 'Delivering', null, 'CM1016', 'EM1004', '2', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1017', '01-06-2023', 'Waiting', null, 'CM1017', 'EM1003', '11', N'Võ Văn Ngân', N'TP Hồ Chí Minh'),
	('BM1018', '10-05-2023', 'Done', null, 'CM1018', 'EM1001', '111', N'Cách mạng tháng 8', N'TP Hồ Chí Minh'),
	('BM1019', '10-04-2023', 'Done', null, 'CM1019', 'EM1004', '423', N'Lê Lai', N'TP Hồ Chí Minh'),
	('BM1020', '07-03-2023', 'Waiting', null, 'CM1020', 'EM1002', '236', N'Cách mạng tháng 8', N'TP Hồ Chí Minh');
alter table bill check CONSTRAINT all;
/*********INSERT PHƯƠNG TIỆN, CHUYẾN GIAO HÀNG********/
GO
insert into VECHILE
values
	('51G8-12345'),
	('29F3-11111'),
	('33A1-67890'),
	('23G7-69176'),
	('80C8-77777'),
	('79F5-18877');

Alter table DELIVERY_TRIP NOCHECK CONSTRAINT ALL;
insert into DELIVERY_TRIP
values
	('DM1001', 'Cancelled', null, null, 'EM2002', '29F3-11111'),
	('DM1002', 'Done', '27-02-2023', '27-02-2023', 'EM2006', '33A1-67890'),
	('DM1003', 'Delivering', '28-02-2023', NULL, 'EM2003', '34A8-88888'),
	('DM1004', 'Waiting', '29-04-2023', null, 'EM2004', '23G7-69176'),
	('DM1005', 'Waiting', '23-06-2023', NULL, 'EM2005', '80C8-77777'),
	('DM1006', 'Done', '25-07-2023', '25-07-2023', 'EM2006', '79F5-18877'),
	('DM1007', 'Delivering', '23-08-2023', NULL, 'EM2007', '51G8-66554'),
	('DM1008', 'Done', '12-09-2023', '12-09-2023', 'EM2001', '51G8-12345'),
	('DM1009', 'Waiting', '31-10-2023', NULL, 'EM2008', '80C8-77777'),
	('DM1010', 'Waiting', '28-11-2023', NULL, 'EM2001', '51G8-12345'),
	('DM1011', 'Delivering', '25-12-2023', NULL, 'EM2001', '23G7-69176'),
	('DM1012', 'Cancelled', null, NULL, 'EM2007', '51G8-12345'),
	('DM1013', 'Waiting', '17-12-2023', NULL, 'EM2003', '51G8-12345'),
	('DM1014', 'Cancelled', null, NULL, 'EM2008', '79F5-18877'),
	('DM1015', 'Delivering', '20-09-2023', NULL, 'EM2008', '23G7-69176'),
	('DM1016', 'Delivering', '25-07-2023', NULL, 'EM2008', '80C8-77777'),
	('DM1017', 'Waiting', '30-06-2023', NULL, 'EM2008', '23G7-69176'),
	('DM1018', 'Done', '20-05-2023', '20-05-2023', 'EM2008', '80C8-77777'),
	('DM1019', 'Done', '18-04-2023', '17-04-2023', 'EM2008', '80C8-77777'),
	('DM1020', 'Waiting', '25-03-2023', NULL, 'EM2008', '51G8-66554');
Alter table DELIVERY_TRIP CHECK CONSTRAINT ALL;

GO
ALTER TABLE PACKAGE nocheck CONSTRAINT all;
insert into PACKAGE
values
	('PK1001', 'BM1001', 'Cancelled', 'DM1001'),
	('PK1002', 'BM1002', 'Done', 'DM1002'),
	('PK1003', 'BM1003', 'Delivering', 'DM1003'),
	('PK1004', 'BM1004', 'Waiting', 'DM1004'),
	('PK1005', 'BM1005', 'Waiting', 'DM1005'),
	('PK1006', 'BM1006', 'Done', 'DM1006'),
	('PK1007', 'BM1007', 'Delivering', 'DM1007'),
	('PK1008', 'BM1008', 'Done', 'DM1008'),
	('PK1009', 'BM1009', 'Waiting', 'DM1009'),
	('PK1010', 'BM1010', 'Waiting', 'DM1010'),
	('PK1011', 'BM1011', 'Delivering', 'DM1011'),
	('PK1023', 'BM1011', 'Delivering', 'DM1011'),
	('PK1012', 'BM1012', 'Cancelled', 'DM1012'),
	('PK1013', 'BM1013', 'Waiting', 'DM1013'),
	('PK1014', 'BM1014', 'Cancelled', 'DM1014'),
	('PK1015', 'BM1015', 'Delivering', 'DM1015'),
	('PK1016', 'BM1016', 'Delivering', 'DM1016'),
	('PK1021', 'BM1016', 'Delivering', 'DM1016'),
	('PK1022', 'BM1016', 'Delivering', 'DM1016'),
	('PK1017', 'BM1017', 'Waiting', 'DM1017'),
	('PK1018', 'BM1018', 'Done', 'DM1018'),
	('PK1019', 'BM1019', 'Done', 'DM1019'),
	('PK1020', 'BM1020', 'Waiting', 'DM1020');
alter table package check CONSTRAINT all;

ALTER TABLE CONTAIN_PHYBAGS nocheck CONSTRAINT all;
insert into CONTAIN_PHYBAGS
values
	('PM1003', 'TB1010', 2, 'BM1001', 2),
	('PM1001', 'TB1002', 3, 'BM1009', 2),
	('PM1002', 'TB1005', 4, 'BM1001', 1),
	('PM1003', 'TB1002', 5, 'BM1009', 1),
	('PM1004', 'TB1010', 6, 'BM1004', 3),
	('PM1005', 'TB1005', 7, 'BM1001', 2),
	('PM1006', 'TB1005', 8, 'BM1009', 1),
	('PM1007', 'TB1010', 9, 'BM1020', 1),
	('PM1008', 'TB1002', 10, 'BM1019', 3),
	('PM1009', 'TB1010', 11, 'BM1015', 2),
	('PM1010', 'TB1005', 12, 'BM1014', 2),
	('PM1011', 'TB1002', 13, 'BM1010', 3),
	('PM1012', 'TB1005', 14, 'BM1008', 1),
	('PM1011', 'TB1010', 15, 'BM1009', 2),
	('PM1011', 'TB1002', 16, 'BM1008', 3),
	('PM1007', 'TB1005', 17, 'BM1020', 1),
	('PM1004', 'TB1005', 18, 'BM1005', 2),
	('PM1004', 'TB1005', 19, 'BM1006', 2),
	('PM1001', 'TB1002', 20, 'BM1002', 1),
	('PM1001', 'TB1002', 21, 'BM1005', 3),
	('PM1009', 'TB1002', 22, 'BM1014', 3),
	('PM1002', 'TB1005', 23, 'BM1005', 3),
	('PM1005', 'TB1010', 24, 'BM1002', 2),
	('PM1006', 'TB1002', 25, 'BM1005', 2),
	('PM1009', 'TB1005', 26, 'BM1014', 3),
	('PM1005', 'TB1010', 27, 'BM1009', 2),
	('PM1002', 'TB1002', 28, 'BM1003', 1),
	('PM1009', 'TB1005', 29, 'BM1013', 2),
	('PM1005', 'TB1002', 30, 'BM1003', 3),
	('PM1009', 'TB1005', 31, 'BM1012', 1),
	('PM1006', 'TB1002', 32, 'BM1007', 3),
	('PM1009', 'TB1005', 33, 'BM1011', 2),
	('PM1010', 'TB1002', 34, 'BM1014', 3),
	('PM1012', 'TB1010', 35, 'BM1008', 2),
	('PM1008', 'TB1002', 36, 'BM1020', 3),
	('PM1012', 'TB1005', 37, 'BM1009', 1),
	('PM1008', 'TB1002', 38, 'BM1003', 2),
	('PM1008', 'TB1002', 39, 'BM1005', 1),
	('PM1010', 'TB1010', 40, 'BM1014', 2),
	('PM1012', 'TB1010', 41, 'BM1010', 1),
	('PM1001', 'TB1002', 42, 'BM1003', 2),
	('PM1012', 'TB1010', 43, 'BM1002', 2);
alter table contain_phybags check CONSTRAINT all;

ALTER TABLE TYPE_OF_BAGS nocheck CONSTRAINT all;
insert into TYPE_OF_BAGS
values
	('PM1001', 'TB1002', 2, 20, 40000),
	('PM1001', 'TB1005', 5, 31, 100000),
	('PM1001', 'TB1010', 10, 15, 200000),
	('PM1002', 'TB1002', 2, 14, 42000),
	('PM1002', 'TB1005', 5, 12, 105000),
	('PM1002', 'TB1010', 10, 42, 210000),
	('PM1003', 'TB1002', 2, 12, 40000),
	('PM1003', 'TB1005', 5, 45, 100000),
	('PM1003', 'TB1010', 10, 23, 200000),
	('PM1004', 'TB1002', 2, 26, 36000),
	('PM1004', 'TB1005', 5, 13, 90000),
	('PM1004', 'TB1010', 10, 45, 180000),
	('PM1005', 'TB1002', 2, 52, 38000),
	('PM1005', 'TB1005', 5, 12, 95000),
	('PM1005', 'TB1010', 10, 53, 190000),
	('PM1006', 'TB1002', 2, 31, 44000),
	('PM1006', 'TB1005', 5, 30, 110000),
	('PM1006', 'TB1010', 10, 20, 220000),
	('PM1007', 'TB1002', 2, 21, 42000),
	('PM1007', 'TB1005', 5, 21, 105000),
	('PM1007', 'TB1010', 10, 22, 210000),
	('PM1008', 'TB1002', 2, 22, 38000),
	('PM1008', 'TB1005', 5, 12, 95000),
	('PM1008', 'TB1010', 10, 46, 190000),
	('PM1009', 'TB1002', 2, 56, 50000),
	('PM1009', 'TB1005', 5, 54, 125000),
	('PM1009', 'TB1010', 10, 44, 250000),
	('PM1010', 'TB1002', 2, 45, 36000),
	('PM1010', 'TB1005', 5, 46, 90000),
	('PM1010', 'TB1010', 10, 43, 180000),
	('PM1011', 'TB1002', 2, 42, 50000),
	('PM1011', 'TB1005', 5, 41, 125000),
	('PM1011', 'TB1010', 10, 45, 250000),
	('PM1012', 'TB1002', 2, 21, 34000),
	('PM1012', 'TB1005', 5, 22, 85000),
	('PM1012', 'TB1010', 10, 23, 170000)

ALTER TABLE TYPE_OF_BAGS check CONSTRAINT all;

ALTER TABLE [PRODUCT] NOCHECK CONSTRAINT ALL;
insert into [PRODUCT]
values
	('PM1001', N'thơm Thái', N'Khi nấu xong, gạo sẽ có độ dẻo mềm vừa phải và rất thơm.', N'Hạt dài, màu trắng trong và ít bạc bụng', 'Vietnam', 'https://khogaomientay.com.vn/uploads/images/image(4).png'),
	('PM1002', N'Bắc Hương', N'Hạt gạo Bắc Hương nhỏ dài và có màu trắng trong. Khi nấu xong gạo có độ dẻo nhiều và độ dính cao. Cơm khi để nguội vẫn giữ được độ dẻo và mùi thơm đặc trưng.', N'Hạt nhỏ dài và có màu trắng trong', 'Vietnam', 'https://gaogiasi.com.vn/uploads/noidung/gao-bac-huong-0-167.jpg'),
	('PM1003', N'Tám Xoan', N'Với hạt gạo hơi dài, thon nhỏ và vẹo một đầu, bạn sẽ dễ dàng nhận ra gạo Tám Xoan. Hạt của chúng có màu trong xanh, không bị bạc bụng, mùi thơm lại dịu và rất tự nhiên.', N'Hạt nhỏ dài và có màu trắng trong, dẻo và độ dính', 'Vietnam', 'https://down-vn.img.susercontent.com/file/f37eb203adc72dbc2ad840f956eba3dc'),
	('PM1004', N'ST24', N'Gạo ST24 có dáng dài và dẹt, màu trắng trong, mang mùi thơm lá dứa tự nhiên. Khi nấu cho cơm mềm dẻo với hương thơm của lá dứa. Điều đặc biệt ở gạo ST24 là càng để nguội ăn càng ngon, hạt gạo vẫn giữ được độ mềm dẻo mà không bị cứng.', N'Hạt có dáng dài và dẹt, màu trắng trong', 'Vietnam', 'https://giagao.com/wp-content/uploads/2021/08/gao-ST24_AAN.jpg'),
	('PM1005', N'Hàm Châu', N'Với dáng vẻ bên ngoài giống như các loại gạo khác, gạo Hàm Châu với hương thơm tự nhiên, vị ngọt đậm. Gạo khi nấu xong nở và xốp, rất thích hợp để làm món cơm chiên.', N'Hạt có hương thơm tự nhiên, vị ngọt đậm', 'Vietnam', 'https://gaosachonline.com/wp-content/uploads/2018/05/gao-ham-chau-dong-tui.png'),
	('PM1006', N'Nàng Xuân', N'Là sự lai tạo của hai giống lúa Tám Xoan và KhaoDawk Mali (Thái Lan), gạo Nàng Xuân có hạt thon dài. Cơm khi nấu xong mềm dẻo, ngọt và có mùi thơm đặc trưng.', N'Hạt thon dài, khi nấu mềm dẻo, ngọt', 'Vietnam', 'https://gaochatluong.com/wp-content/uploads/2023/03/gao-nang-xuan-removebg-preview.png'),
	('PM1007', N'Tài Nguyên', N'Khác với những hạt gạo trắng trong, hạt gạo Tài Nguyên có màu trắng đục. Khi nấu sẽ cho cơm ráo, mềm, xốp, ngọt cơm. Đặc biệt, cơm vẫn ngon khi để nguội.', N'Hạt có màu trắng đục', 'Vietnam', 'https://product.hstatic.net/1000362335/product/14_9eedb99655254a0dbdaa78657657cfbf_master.png'),
	('PM1008', N'thơm Jasmine', N'Hạt gạo thơm Jasmine dài và màu trắng bóng rất đẹp mắt. Khi nấu cho cơm dẻo vừa và có mùi thơm nhẹ, được nhiều người ưa chuộng.', N'Hạt gạo thơm lài dài và màu trắng bóng', 'Vietnam', 'https://giagao.com/wp-content/uploads/2021/08/gao-Jasmine_AAN.jpg'),
	('PM1009', N'ST25', N'Hạt gạo ST25 có mùi thơm đặc trưng của lá dứa hòa quyện với mùi thơm của cốm non rất dễ ngửi thấy kể cả khi gạo còn sống. Hơn thế nữa cơm được nấu từ gạo ST25 là loại cơm "cực phẩm" với hạt cơm khô ráo, độ dẻo, thơm nhất định và vị ngọt thanh đến từ tinh bột gạo hảo hạng, khi để nguội cũng khô bị khô cứng.', N'Hạt có mùi thơm đặc trưng', 'Vietnam', 'https://giagao.com/wp-content/uploads/2021/10/gao-ST25-hut-chan-khong-5kg-600x600.jpg'),
	('PM1010', N'Tám Thái đỏ', N'Được lai tạo từ gạo Hom Mali (Thái Lan), gạo Tám Thái đỏ có hạt nhỏ, dài đều, căng bóng, màu đục. Cơm chín có vị dẻo dai, màu cơm trắng hồng và có độ kết dính vừa phải.', N'Hạt nhỏ, dài đều, căng bóng, màu đục', 'Vietnam', 'http://cefvina.com.vn/wp-content/uploads/2018/07/3vFQHlMPPapyM2tj56Z1_simg_de2fe0_250x250_maxb.jpg'),
	('PM1011', N'Lứt', N'Gạo lứt với lớp cám gạo chưa được xay xát, có màu tím hoặc đỏ, mang đến hàm lượng dinh dưỡng dồi dào cho người tiêu dùng. Gạo lứt có các loại như: gạo lứt đỏ, gạo lứt đen, gạo lứt tẻ, gạo lứt nếp. Khi nấu, gạo cũng cần được nấu lâu hơn gạo trắng để đạt được độ mềm như mong muốn.', N'Hạt có màu tím hoặc đỏ', 'Vietnam', 'https://gaophuongnam.vn/thumbs/560x640x1/upload/product/gao-lut-dien-bien-do-4618.jpg'),
	('PM1012', N'Tám Điện Biên', N'Nổi tiếng với hương thơm và độ dẻo như nếp, tám Điện Biên có gạt gạo nhỏ, đều, căng bóng và hơi đục. Dù bề ngoài không được bắt mắt, cơm khi nấu xong lại cho ra những chén cơm thơm phức, dẻo ngọt khiến ai cũng phải thay đổi suy nghĩ về loại gạo này.', N'Hạt gạo nhỏ, đều, căng bóng và hơi đục', 'Vietnam', 'https://gaogiasi.com.vn/uploads/noidung/gao-tam-dien-bien-0-400.jpg');

ALTER TABLE [PRODUCT] CHECK CONSTRAINT ALL;

ALTER TABLE [ACCOUNT] NOCHECK CONSTRAINT ALL;
insert into [ACCOUNT]
values
	('admin', '$2y$10$MEZI7Xj5aWA9tdAMMG4Jl.cVTPRD2MbhmMaoHXEYsvvDPZp8/2bNi', 'Employee', 'EM1000'),
	('employee1', '$2y$10$z3CHupY4MItjXQIgaznt1OPYQ3m.KrKyJpvsp0mamul8X6wZrtjtW', 'Employee', 'EM1001'),
	('employee2', '$2y$10$cmrV4TmtJ6XMcGRn0H8CPe9Nd7rFXMj.k8io2e3rMDEwq5zCtMpbi', 'Employee', 'EM1002'),
	('employee3', '$2y$10$75RDiT/Ej170nuNxVFTqUucVxHnsGO79q30CH3VuBvm2ZscTCrlVq', 'Employee', 'EM1003'),
	('employee4', '$2y$10$hKDzBii6X5/cv5zpvu7eMuf0Pp7YxadaJWQRDN.WuINJBdnYADrBC', 'Employee', 'EM1004'),
	('customer1', '$2y$10$63h5LObr.SoGslMqFx06puehh8idFeR0AnFINQhqtfxs.n8BovKza', 'Customer', 'CM1001'),
	('customer2', '$2y$10$HYCJ2RJkdUo7HqEhYwGc6ebl7cMKa6ABild20lvZu8X5fopzxBasK', 'Customer', 'CM1002'),
	('customer3', '$2y$10$awCS6ZEcl6zIWrweGrbXLem6eYqGa/TJAgZw5U8jDv.aNXXqP2iee', 'Customer', 'CM1003'),
	('customer4', '$2y$10$zVR1wWmB6I3zmKevbnR.LOOBilEFPI33GARRUwzpWAnQfKSniBp3W', 'Customer', 'CM1004'),
	('customer5', '$2y$10$gsxAVqYdgPG7u35RL3pwUOGqyq73EabC.4Ymk3YpfNOnZTdcz3uSC', 'Customer', 'CM1005'),
	('customer6', '$2y$10$2e2Lz3o/xCqnjEfadq4.deh8WZR4CPXTQqeTIXtGJU6Gs3z21nbyq', 'Customer', 'CM1006'),
	('customer7', '$2y$10$NXOzUKdXy4Y.9n7sMWp76OXRt4VzrNSpZO3ovICvLiAqCpdQ/ZSMe', 'Customer', 'CM1007'),
	('customer8', '$2y$10$SUKX09fMRe961sDDLBynXOKs2Lc8D3IYFGYIqU6kuDh/.rmDn32D6', 'Customer', 'CM1008'),
	('customer9', '$2y$10$PNrDqqgK0AhRP0H./J8zV.PLa5IFuzTcZ0Tyal5SUnB7WoHfekTBm', 'Customer', 'CM1009'),
	('customer10', '$2y$10$TnJ/PRA7u1aVkQFj/2qZbuASHqZxy/Rn1y3jpThf.U1/oC1hfni6C', 'Customer', 'CM1010'),
	('customer11', '$2y$10$qQZG/4k5hoy0WfoK4LbfY.PCs689gVS2n3GZPVfZqXNANBWLqZVWq', 'Customer', 'CM1011'),
	('customer12', '$2y$10$.sIWOr9SopfUI6YwCDM9SOEHl0qlrVpoRG3Mj6e.KP7tiPgx.IjiS', 'Customer', 'CM1012'),
	('customer13', '$2y$10$Mb.zxT0jUenBUfxuofqv..6s..zSIFmPSIiBYykAEdDqKetZtrrS.', 'Customer', 'CM1013'),
	('customer14', '$2y$10$ZNLvGb66YwSbd9vWdIqGBuQpCAISXSXcVyq24mTZDpI0OpHzpRnPG', 'Customer', 'CM1014'),
	('customer15', '$2y$10$GG.ADgV9EQ315H6X49ggqO0gBAMwK5UngFA7oPyV0eBTiI2QnT2Yu', 'Customer', 'CM1015'),
	('customer16', '$2y$10$Us6dMLqu6qyWAMSXZGIwXOn0tJxQVxxp/8gDwDpMrtfg4BTOPPVqy', 'Customer', 'CM1016'),
	('customer17', '$2y$10$RzdY3x4J9Hp0/.fsK.vQdec1CaMdRKSPVEgbEkwRw48G1VynaifgS', 'Customer', 'CM1017'),
	('customer18', '$2y$10$qagD1fc87oKMtLGjLAQjUOG.lCSPC1.tUafnF/LvcCG0932Mar6j6', 'Customer', 'CM1018'),
	('customer19', '$2y$10$FCGLij.n/OpxGDv7pfZkFe7aeTNjWGx2dc4Jb7dGsVjHQO/KMCm2C', 'Customer', 'CM1019'),
	('customer20', '$2y$10$yQs.v4iCVBo2e/4r1fTcRubWq1C0/9H2lPOl.MDGFJwd0pQqdLcza', 'Customer', 'CM1020'),
	('customer21', '$2y$10$FhRGgcHKsgmUpZ3QLyfTW.ncuA8v1Gx1DW7kGO0bHW22RVlA9IfU2', 'Customer', 'CM1021'),
	('customer22', '$2y$10$tI82tqkyzuLZ9ik.5H3xS.pNESos5vtre3klz3p.A4/1W6wlPJnBO', 'Customer', 'CM1022'),
	('customer23', '$2y$10$FKYrdkQPZL1Ey3SF4Bqv2.5sEH5B1iMifBSv9dWXdcBQW6Ku0njl.', 'Customer', 'CM1023'),
	('customer24', '$2y$10$wfj926znuj0uMi9FzfYjheE2hVGwgtPqk8vPvOe.T5CBcI3X8Gfuy', 'Customer', 'CM1024'),
	('customer25', '$2y$10$DXSV.RqUw/snV.3mQg3bkOdNj8nCdVbMCRxiYUGo.vU5nfJfaf9A2', 'Customer', 'CM1025'),
	('customer26', '$2y$10$yzTsD89Q0kQJtgAyy1hu0uDpbCo3yzfZ5cCPOwVZBfhV/SFlm3l8y', 'Customer', 'CM1026'),
	('customer27', '$2y$10$VAbgqjZ2BKBFObsSlnrcaeQEkSg6L0wcu2cByNNKsicoDHI4xatp2', 'Customer', 'CM1027'),
	('customer28', '$2y$10$mLviibNiO0YnQlPfpuqsnu3709yw36vybKIkKFffGUJcg9cYlTQEa', 'Customer', 'CM1028'),
	('customer29', '$2y$10$ESXCLwusUDO2GX13iPUvzu0L7fP1kfO.PLQhUeXcmGVVmMvdkJVyK', 'Customer', 'CM1029'),
	('customer30', '$2y$10$hxNKoshULXHBZgwM.4zZveU7dy410ZFPNwOYhJjP6T2jjKQOhbMHK', 'Customer', 'CM1030'),
	('customer31', '$2y$10$GZD/mQI05qg23S0B8Z6g5.9ZU7tpWP.1CdID8srCXP2kTj.iSTstO', 'Customer', 'CM1031'),
	('customer32', '$2y$10$vCJnaxyu5BS5IKIK8nCAVeb68s2OwHk2FeIF3m/XN8.it3pInSePu', 'Customer', 'CM1032'),
	('customer33', '$2y$10$r6s2E45b0h0VNNq.lYNtFOG/0X5Ldlml9YLRJhhYAzMNJhNZk3mxm', 'Customer', 'CM1033'),
	('customer34', '$2y$10$fAv8FdqpYDazrlcgyejb.uNRUHoXjcKyYx8Jq0TWp4YOPiblRErRy', 'Customer', 'CM1034'),
	('customer35', '$2y$10$nxT33ddGIW6OsaL0HMwOzuuAXsENb3lAGPmRehzzfALIOvj7riM4q', 'Customer', 'CM1035'),
	('customer36', '$2y$10$jaL5D2hX0OWRg3IRycVGbO61GbIElpKGcqvTxI4Ikp5ou29V/Y8S2', 'Customer', 'CM1036'),
	('customer37', '$2y$10$ZLBelnFnjZKZTfq21sDE6utufx8sdG8uCAForY8C6ZiE7pq1JnylO', 'Customer', 'CM1037'),
	('customer38', '$2y$10$yps.OOI3SmCy2/aPleFLzO5/HjbbzbpPeizS3GGUraXa/7LJIjkyy', 'Customer', 'CM1038'),
	('customer39', '$2y$10$9F5fb3L9mLC8Lv0WZwCAjubJKzQYJ0x/J1TM5H//OP1rgr3Zm83gK', 'Customer', 'CM1039');
ALTER TABLE [ACCOUNT] CHECK CONSTRAINT ALL;

INSERT INTO COMPANY_PRODUCT (company_name)
VALUES 
	('Vinafood'),
	('Ngọc Đồng'),
	('Việt Hưng'),
	('Sunrise');

INSERT INTO PRODUCTION (company_name, id_product)
VALUES
	('Vinafood', 'PM1001'),
	('Vinafood', 'PM1002'),
	('Vinafood', 'PM1003'),
	('Vinafood', 'PM1004'),
	('Ngọc Đồng', 'PM1005'),
	('Ngọc Đồng', 'PM1006'),
	('Ngọc Đồng', 'PM1007'),
	('Ngọc Đồng', 'PM1008'),
	('Việt Hưng', 'PM1009'),
	('Việt Hưng', 'PM1010'),
	('Sunrise', 'PM1011'),
	('Sunrise', 'PM1012');

GO
create or alter function getRevenueOfProduct (@maGao CHAR(6))
returns @ret_table table
(
	-- columns returned by the function
	maGao CHAR(6) not null,
	maBao CHAR(6) not null,
	soLuongBao int ,
	doanhThu decimal(10,2)
		PRIMARY KEY(maGao, maBao)
)
as
begin

	if (LEFT(@maGao,2) = 'PM') 
		BEGIN
		insert into @ret_table
		select id_product AS maGao, loaiBao.id_type AS maLoai, SUM(Quantity) AS soBao, SUM(loaibao.price_Bags) AS doanhThu
		from
			CONTAIN_PHYBAGS as rela_gom_donHang_loBaoGao
			join
			TYPE_OF_BAGS as loaiBao on (
				rela_gom_donHang_loBaoGao.id_product = loaiBao.id_pro
				AND rela_gom_donHang_loBaoGao.id_type = loaiBao.id_type
			)
		WHERE id_product = @maGao
		GROUP BY id_product, loaiBao.id_type;
	END
	ELSE
		BEGIN
		INSERT INTO @ret_table
		VALUES
			('------', '------', null, null);
	END
	return
end

GO
-- Create the stored procedure to print revenue of all id_product
CREATE OR ALTER PROCEDURE getAllRevenueOfProduct
AS
BEGIN
	select rela_gom_donHang_loBaoGao.id_product AS maGao, PRODUCT.PName AS TenGao, loaiBao.id_type AS maLoai, SUM(Quantity) AS soBao, SUM(loaibao.price_Bags) AS doanhThu, id_bill
	from
		CONTAIN_PHYBAGS AS rela_gom_donHang_loBaoGao
		JOIN
		TYPE_OF_BAGS AS loaiBao ON (
				rela_gom_donHang_loBaoGao.id_product = loaiBao.id_pro
			AND rela_gom_donHang_loBaoGao.id_type = loaiBao.id_type
			)
		JOIN PRODUCT ON rela_gom_donHang_loBaoGao.id_product = PRODUCT.id_product
	GROUP BY rela_gom_donHang_loBaoGao.id_product, PRODUCT.PName, loaiBao.id_type, id_bill
	ORDER BY rela_gom_donHang_loBaoGao.id_product;
END

GO
CREATE OR ALTER PROCEDURE getAllPnameHasBeenSold
AS
BEGIN
	SELECT PRODUCT.Pname
	FROM CONTAIN_PHYBAGS JOIN PRODUCT ON CONTAIN_PHYBAGS.id_product = PRODUCT.id_product
	GROUP BY PRODUCT.Pname;
END

GO
CREATE OR ALTER TRIGGER UpdateBillStatus
ON PACKAGE
AFTER UPDATE
AS
BEGIN
	DECLARE @id_bill CHAR(6);
	DECLARE @status VARCHAR(15);
	DECLARE @packageCount INT;

	SELECT @id_bill = id_bill
	FROM INSERTED;
	SELECT @status = [status]
	FROM INSERTED;

	IF UPDATE([status]) AND @status = 'Done'
    BEGIN
		SELECT @packageCount = COUNT(*)
		FROM PACKAGE
		WHERE id_bill = @id_bill AND status <> 'Done';

		IF @packageCount = 0
        BEGIN
			UPDATE BILL SET [status] = 'Done'
            WHERE id_bill = @id_bill;
		END
	END
END 



GO
CREATE OR ALTER FUNCTION findUserWith (@Username varchar(30))
returns @ret_table TABLE 
(
	Username varchar(30) ,
	[Password] nvarchar(65)
)
AS
BEGIN
	insert into @ret_table
	SELECT Username, convert(nvarchar(65), [Password],0)
	FROM ACCOUNT
	WHERE Username = @Username;
	RETURN
END;
GO

GO
CREATE OR ALTER PROCEDURE getAllProducts 
AS
BEGIN	
	SELECT matHang.id_product AS maGao, matHang.Pname AS tenGao, loaiBao.BName AS loaiBao, matHang.picture AS imgSrc, loaiBao.price_Bags AS giaTien 
	FROM PRODUCT AS matHang JOIN TYPE_OF_BAGS AS loaiBao ON matHang.id_product = loaiBao.id_pro
	ORDER BY matHang.Pname;
END

GO
-- a) Thêm, xóa, sửa thông tin mặt hàng
-- Thêm mặt hàng
IF EXISTS (SELECT * FROM sys.objects WHERE name='InsertProduct' AND [type]= 'P')
BEGIN
	DROP PROCEDURE InsertProduct
END;
GO
CREATE PROCEDURE InsertProduct
	@PName NVARCHAR(30),
	@description NVARCHAR(1000),
	@featured NVARCHAR(255),
	@origin NVARCHAR(20),
	@picture VARCHAR(255),
	@company_name NVARCHAR(30),
	@type CHAR(2),
	@price DECIMAL(10, 0),
	@NSX DATE,
	@HSD DATE
AS
BEGIN
	-- Prefix: PM, ID: Phần số ở sau, id_product: Kết hợp lại
	DECLARE @Prefix CHAR(2) = 'PM';
	DECLARE @ID INT;
	DECLARE @id_product CHAR(6);

	-- 1.1. Nếu mặt hàng chưa tồn tại -> Thêm mặt hàng mới
	IF NOT EXISTS (
		SELECT *
		FROM PRODUCT JOIN PRODUCTION ON PRODUCT.id_product = PRODUCTION.id_product
		WHERE PName=@PName AND company_name=@company_name
	)
	BEGIN
		-- Lấy ID lớn nhất hiện tại
		SELECT @ID = MAX(CAST(SUBSTRING(id_product, 3, LEN(id_product) - 2) AS INT))
		FROM PRODUCT;
		-- Tăng ID lên 1
		SET @ID = ISNULL(@ID, 1000) + 1;
		-- Nối với prefix tạo ra id_product
		SET @id_product = @Prefix + CAST(@ID AS CHAR(4));

		-- Thêm mặt hàng mới vào bảng mặt hàng
		INSERT INTO PRODUCT (id_product, PName, [description], featured, origin, picture)
		VALUES (@id_product, @PName, @description, @featured, @origin, @picture);
		-- Thêm công ty sản xuất vào bảng công ty sản xuất nếu chưa tồn tại
		IF NOT EXISTS (SELECT * FROM COMPANY_PRODUCT WHERE company_name=@company_name)
		INSERT INTO COMPANY_PRODUCT (company_name)
		VALUES (@company_name);
		-- Thêm mặt hàng và công ty vào bảng sản xuất (mối quan hệ)
		INSERT INTO PRODUCTION (id_product, company_name)
		VALUES (@id_product, @company_name);
	END;
	-- 1.2. Nếu mặt hàng đã tồn tại -> Lấy id mặt hàng
	ELSE
	BEGIN
		SELECT @id_product=PRODUCT.id_product
		FROM PRODUCT JOIN PRODUCTION ON PRODUCT.id_product = PRODUCTION.id_product
		WHERE PName=@PName AND company_name=@company_name;
	END;

	-- Tính id_type
	DECLARE @id_type CHAR(6);

	-- 2.1. Nếu loại bao chưa tồn tại -> Thêm loại bao mới
	IF NOT EXISTS (
		SELECT *
		FROM TYPE_OF_BAGS
		WHERE id_pro=@id_product AND BName=CAST(@type AS INT)
	)
	-- Nếu loại bao chưa tồn tại -> Thêm loại bao mới
	BEGIN
	SET @Prefix = 'TB';
	SET @id_type = @Prefix + '10' + @type;
	-- Thêm vào bảng loại bao
	INSERT INTO TYPE_OF_BAGS (id_pro, id_type, BName, inventory_num, price_Bags)
	VALUES (@id_product, @id_type, CAST(@type AS INT), 100, @price);
	END;
	-- 2.2 Nếu loại bao đã tồn tại -> Lấy id loại bao
	ELSE
	BEGIN
		SELECT @id_type=id_type
		FROM TYPE_OF_BAGS
		WHERE id_pro=@id_product AND BName=CAST(@type AS INT)

		UPDATE TYPE_OF_BAGS
		SET inventory_num = inventory_num + 100
		WHERE id_pro=@id_product AND id_type=@id_type
	END;


	-- Thêm lô mới tương ứng với loại bao
	INSERT INTO PHYSICAL_RICEBAG (id_product, id_type, quantity, NSX, HSD)
	VALUES (@id_product, @id_type, 100, @NSX, @HSD);
END;

-- Xóa mặt hàng
GO
IF EXISTS (SELECT * FROM sys.objects WHERE name='DeleteProduct' AND [type]= 'P')
BEGIN
	DROP PROCEDURE DeleteProduct
END;
GO
CREATE PROCEDURE DeleteProduct
	@id_product CHAR(6)
AS
BEGIN
	-- Xóa mặt hàng trong kiện hàng 
	DELETE FROM CONTAIN_PACKAGE
	WHERE id_product = @id_product;
	-- Xóa mặt hàng trong đơn hàng
	DELETE FROM CONTAIN_PHYBAGS
	WHERE id_product = @id_product;
	-- Xóa mặt hàng trong lô bao gạo
	DELETE FROM PHYSICAL_RICEBAG
	WHERE id_product = @id_product;
	-- Xóa mặt hàng trong loại bao
	DELETE FROM TYPE_OF_BAGS
	WHERE id_pro = @id_product;
	-- Xóa mặt hàng trong mối quan hệ với công ty sản xuất
	DELETE FROM PRODUCTION
	WHERE id_product = @id_product;
	-- Xóa mặt hàng trong bảng mặt hàng
	DELETE FROM PRODUCT
	WHERE id_product = @id_product;
END;

-- Sửa thông tin mặt hàng
GO
IF EXISTS (SELECT * FROM sys.objects WHERE name='EditProduct' AND [type]= 'P')
BEGIN
	DROP PROCEDURE EditProduct
END;
GO
CREATE PROCEDURE EditProduct
	@id_product CHAR(6),
	@PName NVARCHAR(30),
	@description NVARCHAR(1000),
	@featured NVARCHAR(255),
	@origin NVARCHAR(20),
	@picture VARCHAR(255),
	@company_name NVARCHAR(30),
	@type CHAR(2),
	@price DECIMAL(10,0)
AS
BEGIN
	-- Cập nhật thông tin mặt hàng
	UPDATE PRODUCT
	SET PName = @PName,
		[description] = @description,
		origin = @origin,
		picture = @picture
	WHERE id_product = @id_product;
	-- Cập nhật giá tùy theo loại
	UPDATE TYPE_OF_BAGS
	SET price_Bags = @price
	WHERE id_pro = @id_product AND BName = CAST(@type AS INT);
	-- Cập nhật thông tin công ty sản xuất
	IF NOT EXISTS (SELECT * FROM COMPANY_PRODUCT WHERE company_name = @company_name)
	BEGIN
		INSERT INTO COMPANY_PRODUCT
		VALUES (@company_name)
	END;
	UPDATE PRODUCTION
	SET company_name = @company_name
	WHERE id_product = @id_product;
END;

-- b) Tìm kiếm thông tin bằng tên, công ty sx, mô tả - Filter & Sort
GO
IF EXISTS (SELECT * FROM sys.objects WHERE name='FilterProduct' AND [type]= 'P')
BEGIN
	DROP PROCEDURE FilterProduct
END;
GO
CREATE PROCEDURE FilterProduct
	@type CHAR(2),
	@sort CHAR(1)
AS
BEGIN
	SELECT *
	FROM PRODUCT JOIN TYPE_OF_BAGS ON id_pro = id_product
	WHERE BName = CAST(@type AS INT)
	ORDER BY price_Bags * CASE WHEN @sort = 'A' THEN 1 ELSE -1 END
END;

-- d) Xem chi tiết loại gạo - Details
GO
IF EXISTS (SELECT * FROM sys.objects WHERE name='GetProductDetails' AND [type]= 'IF')
BEGIN
	DROP FUNCTION GetProductDetails
END;
GO
CREATE OR ALTER FUNCTION GetProductDetails (@id_product CHAR(6), @type CHAR(2))
RETURNS TABLE
AS
RETURN (
	SELECT company_name, [description], PRODUCT.id_product, PName, featured, origin, picture, BName, inventory_num, price_Bags 
	FROM (PRODUCT JOIN TYPE_OF_BAGS ON id_pro = id_product) JOIN PRODUCTION ON PRODUCT.id_product = PRODUCTION.id_product
	WHERE id_pro = @id_product AND BName = CAST(@type as INT)
);