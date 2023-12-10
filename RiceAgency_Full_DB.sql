-- FULL DATABASE OF RICE AGENCY --
-- QUAN --
USE master;
GO
IF EXISTS (SELECT name
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
	Username VARCHAR(30),
	[Password] VARCHAR(20) not null,
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
	('DM1001','Cancelled',null,null,'EM2002','29F3-11111'),
	('DM1002','Done','27-02-2023','27-02-2023','EM2006','33A1-67890'),
	('DM1003','Delivering','28-02-2023',NULL,'EM2003','34A8-88888'),
	('DM1004','Waiting','29-04-2023',null,'EM2004','23G7-69176'),
	('DM1005','Waiting','23-06-2023',NULL,'EM2005','80C8-77777'),
	('DM1006','Done','25-07-2023','25-07-2023','EM2006','79F5-18877'),
	('DM1007','Delivering','23-08-2023',NULL,'EM2007','51G8-66554'),
	('DM1008','Done','12-09-2023','12-09-2023','EM2001','51G8-12345'),
	('DM1009','Waiting','31-10-2023',NULL,'EM2008','80C8-77777'),
	('DM1010','Waiting','28-11-2023',NULL,'EM2001','51G8-12345'),
	('DM1011','Delivering','25-12-2023',NULL,'EM2001','23G7-69176'),
	('DM1012','Cancelled',null,NULL,'EM2007','51G8-12345'),
	('DM1013','Waiting','17-12-2023',NULL,'EM2003','51G8-12345'),
	('DM1014','Cancelled',null,NULL,'EM2008','79F5-18877'),
	('DM1015','Delivering','20-09-2023',NULL,'EM2008','23G7-69176'),
	('DM1016','Delivering','25-07-2023',NULL,'EM2008','80C8-77777'),
	('DM1017','Waiting','30-06-2023',NULL,'EM2008','23G7-69176'),
	('DM1018','Done','20-05-2023','20-05-2023','EM2008','80C8-77777'),
	('DM1019','Done','18-04-2023','17-04-2023','EM2008','80C8-77777'),
	('DM1020','Waiting','25-03-2023',NULL,'EM2008','51G8-66554');
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
--INSERT USER CUSTOMER
go
alter table [USER] NOCHECK CONSTRAINT ALL;
insert into [USER]
values
	('CM1001','Nguyen Van','A','0123456789','nguyenvanA@gmail.com',N'32 Nguyễn Chí Thanh TP Hồ Chí Minh'),
	('CM1002','Nguyen Thi','B','0111111111','nguyenthiB@gmail.com',N'234 Hoàng Diệu 2 TP Hồ Chí Minh'),
	('CM1003','Le Hoang','C','0222222222','lehoangC@gmail.com',N'124 Võ Nguyên Giáp TP Hồ Chí Minh'),
	('CM1004','Lai Nhu','Y','0987654321','lainhuY@gmail.com',N'412 Nguyễn Thị Minh Khai Bình Dương'),
	('CM1005','Lac Thi','D','0333333333','lacThiD@gmail.com', N'512 Đường 3 tháng 2 TP Hồ Chí Minh'),
	('CM1006','Vuong Vu','Han','0444444444','vuongvuHan@gmail.com',N'611 Cách mạng tháng 8 TP Hồ Chí Minh'),
	('CM1007','Van','L','0555555555','VanL@gmail.com',N'712 Đường Cộng hoà TP Hồ Chí Minh'),
	('CM1008','Le Vo','Yen','0666666666','leVoYen@gmail.com',N'811 Võ Văn Ngân TP Hồ Chí Minh'),
	('CM1009','Hoang Thi','Thu','0777777777','HoangThiThu@gmail.com',N'913 Nguyễn Chí Thanh TP Hồ Chí Minh'),
	('CM1010','Thi Le','T','0888888888','ThileT@gmail.com',N'144 Đường Cộng hoà TP Hồ Chí Minh'),
	('CM1011','Nguyen Minh','K','0999999999','NguyenMinhK@gmail.com',N'356 Võ Nguyên Giáp TP Hồ Chí Minh'),
	('CM1012','Hoang Van','B','0111111112','hoangvanB@gmail.com',N'126 Đường Cộng hoà TP Hồ Chí Minh'),
	('CM1013','Nguyen Lan','S','0111111113','nguyenlanA@gmail.com',N'543 Nguyễn Văn Trỗi Cần Thơ'),
	('CM1014','Cao Van','X','0111111114','CaovanX@gmail.com',N'6556 Cách mạng tháng 8 TP Hồ Chí Minh'),
	('CM1015','Duc Thi','Q','0388888881','DucThiQ@gmail.com',N'1256 Lê Lợi Đồng Nai'),
	('CM1016','Nguyen Binh','Trong','0222233344','nguyenbinhTrong@gmail.com',N'2 Nguyễn Chí Thanh TP Hồ Chí Minh'),
	('CM1017','Nguyen Van','Dang','0777666555','nguyenvanDang@gmail.com', N'11 Võ Văn Ngân TP Hồ Chí Minh'),
	('CM1018','Nguyen Thanh','Hai','0123556789','nguyenThanhhai@gmail.com',N'111 Cách mạng tháng 8 TP Hồ Chí Minh'),
	('CM1019','Tran','Dan','0135791357','trandan@gmail.com',N'423 Lê Lai TP Hồ Chí Minh'),
	('CM1020','Le Van','Y','0246824682','levanYA@gmail.com',N'236 Cách mạng tháng 8 TP Hồ Chí Minh');
alter table [USER] CHECK CONSTRAINT ALL;

go
insert into CUSTOMER
	values
	('CM1001'),
	('CM1002'),
	('CM1003'),
	('CM1004'),
	('CM1005'),
	('CM1006'),
	('CM1007'),
	('CM1008'),
	('CM1009'),
	('CM1010'),
	('CM1011'),
	('CM1012'),
	('CM1013'),
	('CM1014'),
	('CM1015'),
	('CM1016'),
	('CM1017'),
	('CM1018'),
	('CM1019'),
	('CM1020');
-- INSERT [USER] EMPLOYEE
alter table [USER] nocheck constraint all;
insert into [USER]
values 
	('EM1001','Tran Van','An','0333222111 ',' example1@gmail.com',N'123 Điện Biên Phủ TP Hồ Chí Minh'),
	('EM1002','Nguyen Thi','Bao','0555666777',' example2@gmail.com',N'56 Lê Lợi TP Hà Nội'),
	('EM1003','Hoang Van','Cuong',' 044433322','example3@gmail.com',N'789 Nguyễn Huệ TP Đà Nẵng'),
	('EM1004','Le Thanh','Dung','0666777888','example4@gmail.com',N'102 Trần Hưng Đạo TP Hải Phòng'),
	('EM2001','Pham Hong','Khanh','0876565656','example5@gmail.com', N'457 Lý Thường Kiệt TP Cần Thơ'),
	('EM2002','Vo Ngoc','Linh','0912345678','example6@gmail.com',N'234 Lê Duẩn TP Nha Trang'),
	('EM2003','Nguyen Tien','Minh','0987123456','example7@gmail.com',N'999 Nguyễn Công Trứ TP Đà Lạt'),
	('EM2004','Tran Thanh','Nga','0955555555','example8@gmail.com',N'222 Nguyễn Văn Linh tp Cần Thơ'),
	('EM2005','Vo Van','Xuan','0999999991','example9@gmail.com',N'555 Võ Văn Kiệt TP Đà Nẵng'),
	('EM2006','Le Van','Huy','0922222222','example10@gmail.com',N'7777 Lê Thánh Tôn TP Hồ Chí Minh'),
	('EM2007','Pham Van','Trung','0944444444','example11@gmail.com',N'321 Hai Bà Trưng TP Huế'),
	('EM2008','Hoang Thi','My','011111112','example12@gmail.com',N'356 Nguyễn Thị Minh Khai TP Vũng Tàu');

insert into [EMPLOYEE]
values
	('EM1001','EM1001'),
	('EM1002','EM1001'),
	('EM1003','EM1001'),
	('EM1004','EM1001'),
	('EM2001','EM2008'),
	('EM2002','EM2008'),
	('EM2003','EM2008'),
	('EM2004','EM2008'),
	('EM2005','EM2004'),
	('EM2006','EM2004'),
	('EM2007','EM2004'),
	('EM2008','EM2008');

insert into SELLER
values
	('EM1001'),
	('EM1002'),
	('EM1003'),
	('EM1004');

insert into SHIPPER
values
	('EM2001'),
	('EM2002'),
	('EM2003'),
	('EM2004'),
	('EM2005'),
	('EM2006'),
	('EM2007'),
	('EM2008');

------------------------------------------------------------------------
go
insert PHYSICAL_RICEBAG (id_product, id_type, Quantity, NSX, HSD)
values 
	('PM1001','TB1002',5,'13-01-2022','13-01-2024'),
	('PM1001','TB1005',10,'31-01-2022','31-01-2024'),
	('PM1001','TB1010',5,'17-01-2022','17-01-2024'),
	('PM1002','TB1002',2,'28-02-2022','28-02-2024'),
	('PM1002','TB1005',5,'19-02-2022','19-02-2024'),
	('PM1002','TB1010',10,'30-04-2022','30-04-2024'),
	('PM1003','TB1002',5,'07-01-2022','07-01-2024'),
	('PM1003','TB1005',10,'21-07-2022','21-07-2024'),
	('PM1003','TB1010',20,'13-06-2022','13-06-2024'),
	('PM1004','TB1002',5,'13-05-2022','13-05-2024'),
	('PM1004','TB1005',10,'14-12-2022','14-12-2024'),
	('PM1004','TB1010',7,'17-11-2022','17-11-2024'),
	('PM1005','TB1002',5,'18-01-2022','18-01-2024'),
	('PM1005','TB1005',1,'28-10-2022','28-10-2024'),
	('PM1005','TB1010',1,'04-06-2022','04-06-2024'),
	('PM1006','TB1002',10,'15-07-2022','15-07-2024'),
	('PM1006','TB1005',15,'23-08-2022','23-08-2024'),
	('PM1006','TB1010',20,'14-02-2022','14-02-2024'),
	('PM1007','TB1002',10,'18-09-2022','18-09-2024'),
	('PM1007','TB1005',10,'17-05-2022','17-05-2024'),
	('PM1007','TB1010',5,'31-01-2022','31-01-2024'),
	('PM1008','TB1002',5,'28-06-2022','28-06-2024'),
	('PM1008','TB1005',5,'13-05-2022','13-05-2024'),
	('PM1008','TB1010',20,'14-07-2022','14-07-2024'),
	('PM1009','TB1002',30,'24-09-2022','24-09-2024'),
	('PM1009','TB1005',30,'13-02-2022','13-02-2024'),
	('PM1009','TB1010',30,'21-04-2022','21-04-2024'),
	('PM1010','TB1002',20,'13-07-2022','13-07-2024'),
	('PM1010','TB1005',20,'03-10-2022','03-10-2024'),
	('PM1010','TB1010',20,'01-04-2022','01-04-2024'),
	('PM1011','TB1002',1,'13-01-2022','13-01-2024'),
	('PM1011','TB1005',4,'12-09-2022','12-09-2024'),
	('PM1011','TB1010',8,'31-05-2022','31-05-2024'),
	('PM1012','TB1002',7,'13-08-2022','13-08-2024'),
	('PM1012','TB1005',15,'23-09-2022','23-09-2024'),
	('PM1012','TB1010',10,'13-11-2022','13-11-2024');

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
		GROUP BY rela_gom_donHang_loBaoGao.id_product, PRODUCT.PName, loaiBao.id_type, id_bill;
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

    SELECT @id_bill = id_bill FROM INSERTED;
	SELECT @status = [status] FROM INSERTED;

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
END;

GO
--  trigger to update points when the bill.status = 'Done'
--create computed attribted
ALTER TABLE [USER]
ADD Point INT;

GO
CREATE OR ALTER TRIGGER UpdatePointCustomer
ON BILL
AFTER UPDATE
AS
BEGIN
    IF UPDATE([status])
    BEGIN
        UPDATE [USER]

        SET Point = (
            SELECT COUNT(*) 
            FROM BILL B 
            WHERE B.customer_id = CUSTOMER.customer_id 
				AND B.[status] = 'Done'
        )
        FROM [USER]
        INNER JOIN CUSTOMER ON [USER].[user_id] = CUSTOMER.customer_id
        INNER JOIN inserted i ON CUSTOMER.customer_id = i.customer_id
        WHERE i.[status] = 'Done';
    END
END;


/*
UPDATE PACKAGE
SET status = 'Done'
where id_package = 'PK1016';
go

SELECT * FROM BILL;
SELECT * FROM PACKAGE;
go
*/
