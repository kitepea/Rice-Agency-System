-- FULL DATABASE OF RICE AGENCY --
-- QUAN --
USE master;
GO
DROP DATABASE IF EXISTS Rice_Agency;
GO
CREATE DATABASE Rice_Agency;
GO
USE Rice_Agency;
GO

set dateformat dmy;

CREATE TABLE [USER]
(
	userid CHAR(6),
	FMName VARCHAR(30) NOT NULL,
	[Name] VARCHAR(10) NOT NULL,
	Phone CHAR(10) UNIQUE,
	Email VARCHAR(50) UNIQUE,
	[Address] VARCHAR(50),
	PRIMARY KEY(userid),
	CHECK (
        (LEFT(userid, 2) = 'EM' OR LEFT(userid, 2) = 'CM') AND
		ISNUMERIC(RIGHT(userid, 4)) = 1 AND
		LEN(userid) = 6
    )
);


create table [ADDRESS]
(
	userid char(6),
	house_num varchar(5) not null,
	street varchar(50) not null,
	city varchar(50) not null,
	primary key (userid, house_num, street, city),
	constraint fk_uid_address foreign key (userid) references [user] (userid) 
	-- on delete cascade
	on update cascade
);

CREATE TABLE [ACCOUNT]
(
	Username varchar(30),
	[Password] varchar(20) not null,
	[Type] VARCHAR(20) CHECK ([TYPE] IN ('Employee', 'Customer')) NOT NULL,
	userid char(6),
	PRIMARY KEY(Username),
	constraint fk_uid_account foreign key (userid) references [user] (userid)
	-- on delete cascade
	on update cascade
);

create table EMPLOYEE
(
	employee_id char(6) NOT NULL,
	manager_id char(6) NOT NULL,
	primary key (employee_id),
	constraint fk_empid_uid foreign key (employee_id) references [user] (userid)
	-- on delete cascade
	on update cascade
);

create table CUSTOMER
(
	customer_id char(6) PRIMARY KEY,
	constraint fk_uid_customer foreign key (customer_id) references [user] (userid)
	-- on delete cascade
	on update cascade
);

create table SELLER
(
	seller_id char(6) PRIMARY KEY,
	constraint fk_empid_seller foreign key (seller_id) references employee (employee_id)
	-- on delete cascade
	on update cascade
);

-- VKDKhoa
/************************* MẶT_HÀNG *****************************/
-- PK = PMXXXX;  [PREFIX] = PM, id PMXXXX
CREATE TABLE [PRODUCT]
(
	id_product CHAR(6) NOT NULL,
	[PName] NVARCHAR(30) NOT NULL,
	[description] ntext,
	--[description] NVARCHAR(255),
	featured NVARCHAR(255),
	Original VARCHAR(9),
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



/******************************************************/

CREATE TABLE PHYSICAL_RICEBAG
(
	id_product CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	NumOrder CHAR(6) NOT NULL,
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
	[status] VARCHAR(15) DEFAULT 'Unprocessed',
	note NVARCHAR(200),
	customer_id CHAR(6) NOT NULL,
	seller_id CHAR(6) NOT NULL,
	house_num varchar(5) NOT NULL,
	street nvarchar(50) NOT NULL,
	city nvarchar(50) NOT NULL,

	CONSTRAINT PK_BILL PRIMARY KEY(id_bill),
	CHECK ([status] = 'Unprocessed' OR [status] = 'Processed')
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
	id_vechile CHAR(6) NOT NULL,

	CONSTRAINT PK_Deli PRIMARY KEY (id_DelivTrip)
)
/******************************************************/

/************************* KIỆN_HÀNG *****************************/
CREATE TABLE PACKAGE
(
	id_package CHAR(6) NOT NULL,
	id_bill CHAR(6) NOT NULL,
	[status] VARCHAR(15) DEFAULT 'Not started',
	id_DelivTrip CHAR(6) NOT NULL,

	CONSTRAINT PK_PACKAGES PRIMARY KEY(id_package),

	CONSTRAINT FK_PACKAGE_TO_BILL FOREIGN KEY (id_bill) REFERENCES BILL(id_bill),
	CONSTRAINT FK_PACKAGE_TO_DELTRIP FOREIGN KEY (id_DelivTrip) REFERENCES DELIVERY_TRIP(id_DelivTrip),

	CHECK ([status] = 'Not started' OR [status] = 'Started' OR [status] = 'Complete')
)
/******************************************************/

/************************* GỒM (MAPPING TỪ LÔ ĐẾN KIỆN) *****************************/
CREATE TABLE CONTAIN_PACKAGE
(
	id_product CHAR(6) NOT NULL,
	id_type CHAR(6) NOT NULL,
	NumOrder CHAR(6) NOT NULL,
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
	NumOrder CHAR(6) NOT NULL,
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
	id_vechile CHAR(6) NOT NULL,
	CONSTRAINT PK_VECHILE PRIMARY KEY (id_vechile)
)
/******************************************************/

/************************* CÔNG TY SẢN SUẤT *****************************/
CREATE TABLE COMPANY_PRODUCT
(
	company_name VARCHAR(30) NOT NULL,
	hotline VARCHAR(15),
	CONSTRAINT PK_COMPANY_PRODUCT PRIMARY KEY (company_name)
)
/******************************************************/

/************************* SẢN XUẤT *****************************/
CREATE TABLE PRODUCTION
(
	id_product CHAR(6) NOT NULL,
	company_name VARCHAR(30) NOT NULL,
	CONSTRAINT PK_PRODUCTION PRIMARY KEY (id_product,company_name),

	CONSTRAINT FK_PRODUCTION_TO_PRODUCT FOREIGN KEY(id_product) REFERENCES [PRODUCT](id_product),
	CONSTRAINT FK_PRODUCTION_TO_COMPANY FOREIGN KEY(company_name) REFERENCES COMPANY_PRODUCT(company_name)
)
/******************************************************/

-- alter
alter table employee
add constraint fk_manager_id foreign key (manager_id) references employee (employee_id);

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

alter table bill nocheck constraint all;
insert into bill
values
	('BM1001', '01-02-2023', 'Processed', null, 'CM1001', 'EM1001', '32', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1002', '01-02-2023', 'Processed', null, 'CM1002', 'EM1002', '234', N'Hoàng Diệu 2', N'TP Hồ Chí Minh'),
	('BM1003', '21-02-2023', 'Processed', null, 'CM1003', 'EM1001', '124', N'Võ Nguyên Giáp', N'TP Hồ Chí Minh'),
	('BM1004', '20-04-2023', 'Processed', null, 'CM1004', 'EM1002', '412', N'Nguyễn Thị Minh Khai', N'Bình Dương'),
	('BM1005', '10-06-2023', 'Processed', null, 'CM1005', 'EM1002', '512', N'Đường 3 tháng 2', N'TP Hồ Chí Minh'),
	('BM1006', '18-07-2023', 'Processed', null, 'CM1006', 'EM1001', '611', N'Cách mạng tháng 8', N'TP Hồ Chí Minh'),
	('BM1007', '15-08-2023', 'Processed', null, 'CM1007', 'EM1002', '712', N'Đường Cộng hoà', N'TP Hồ Chí Minh'),
	('BM1008', '05-09-2023', 'Processed', null, 'CM1008', 'EM1001', '811', N'Võ Văn Ngân', N'TP Hồ Chí Minh'),
	('BM1009', '23-10-2023', 'Unprocessed', null, 'CM1009', 'EM1003', '913', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1010', '18-11-2023', 'Unprocessed', null, 'CM1010', 'EM1002', '144', N'Đường Cộng hoà', N'TP Hồ Chí Minh'),
	('BM1011', '14-12-2023', 'Unprocessed', N'Giao vào buổi sáng', 'CM1011', 'EM1003', '356', N'Võ Nguyên Giáp', N'TP Hồ Chí Minh'),
	('BM1012', '05-01-2023', 'Processed', N'Giao vào buổi chiều', 'CM1012', 'EM1001', '126', N'Đường Cộng hoà', N'TP Hồ Chí Minh'),
	('BM1013', '17-12-2023', 'Unprocessed', null, 'CM1013', 'EM1003', '543', N'Nguyễn Văn Trỗi', N'Cần Thơ'),
	('BM1014', '15-10-2023', 'Unprocessed', null, 'CM1014', 'EM1002', '6556', N'Cách mạng tháng 8', N'TP Hồ Chí Minh'),
	('BM1015', '10-09-2023', 'Processed', null, 'CM1015', 'EM1001', '1256', N'Lê Lợi', N'Đồng Nai'),
	('BM1016', '11-07-2023', 'Processed', null, 'CM1016', 'EM1004', '2', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1017', '01-06-2023', 'Processed', null, 'CM1017', 'EM1003', '11', N'Võ Văn Ngân', N'TP Hồ Chí Minh'),
	('BM1018', '10-05-2023', 'Processed', null, 'CM1018', 'EM1001', '111', N'Cách mạng tháng 8', N'TP Hồ Chí Minh'),
	('BM1019', '10-04-2023', 'Processed', null, 'CM1019', 'EM1004', '423', N'Lê Lai', N'TP Hồ Chí Minh'),
	('BM1020', '07-03-2023', 'Processed', null, 'CM1020', 'EM1002', '236', N'Cách mạng tháng 8', N'TP Hồ Chí Minh'),
	('BM1021', '10-02-2023', 'Processed', null, 'CM1021', 'EM1004', '128', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1022', '21-10-2023', 'Unprocessed', null, 'CM1022', 'EM1001', '421', N'Võ Văn Ngân', N'TP Hồ Chí Minh'),
	('BM1023', '12-08-2023', 'Processed', N'Giao vào giờ hành chính', 'CM1023', 'EM1004', '68', N'Mari Curie', N'TP Hồ Chí Minh'),
	('BM1024', '13-01-2023', 'Processed', N'Chỉ nhận sau ngày 20-01', 'CM1024', 'EM1003', '64', N'Võ Văn Ngân', N'TP Hồ Chí Minh'),
	('BM1025', '07-01-2023', 'Processed', N'Giao vào buổi trưa', 'CM1025', 'EM1003', '72', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1026', '11-07-2023', 'Processed', null, 'CM1026', 'EM1002', '90', N'Cách mạng tháng 8', N'TP Hồ Chí Minh'),
	('BM1027', '14-12-2023', 'Unprocessed', null, 'CM1027', 'EM1003', '100', N'Đường Đất đỏ Bazan', N'Đăk Lăk'),
	('BM1028', '10-06-2023', 'Processed', null, 'CM1028', 'EM1004', '5', N'Đường 621', N'TP Hồ Chí Minh'),
	('BM1029', '10-04-2023', 'Processed', null, 'CM1029', 'EM1002', '127', N'Đường 621', N'TP Hồ Chí Minh'),
	('BM1030', '05-09-2023', 'Processed', null, 'CM1030', 'EM1004', '623', N'Đường Song hành Xa lộ Hà Nội', N'TP Hồ Chí Minh'),
	('BM1031', '01-06-2023', 'Processed', null, 'CM1031', 'EM1003', '4376', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1032', '05-09-2023', 'Processed', null, 'CM1032', 'EM1004', '1262', N'Đường Song hành Xa lộ Hà Nội', N'TP Hồ Chí Minh'),
	('BM1033', '12-08-2023', 'Processed', null, 'CM1033', 'EM1002', '7462', N'Ngô Gia Tự', N'TP Hồ Chí Minh'),
	('BM1034', '07-03-2023', 'Processed', null, 'CM1034', 'EM1004', '6266', N'Nguyễn Chí Thanh', N'TP Hồ Chí Minh'),
	('BM1035', '01-06-2023', 'Processed', null, 'CM1035', 'EM1003', '7436', N'Ngô Gia Tự', N'TP Hồ Chí Minh'),
	('BM1036', '15-10-2023', 'Unprocessed', null, 'CM1036', 'EM1004', '5326', N'Hùng Vương', N'TP Hồ Chí Minh'),
	('BM1037', '18-11-2023', 'Unprocessed', null, 'CM1037', 'EM1003', '2378', N'Lê Văn Việt', N'TP Hồ Chí Minh'),
	('BM1038', '05-09-2023', 'Processed', null, 'CM1038', 'EM1002', '2356', N'Lê Văn Việt', N'TP Hồ Chí Minh'),
	('BM1039', '17-12-2023', 'Unprocessed', null, 'CM1039', 'EM1003', '2322', N'Trần Thủ Độ', N'TP Hồ Chí Minh');
alter table bill check constraint all;


ALTER TABLE CONTAIN_PHYBAGS nocheck constraint all;
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
alter table contain_phybags check constraint all;

ALTER TABLE TYPE_OF_BAGS nocheck constraint all;
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

ALTER TABLE TYPE_OF_BAGS check constraint all;



ALTER TABLE [PRODUCT] NOCHECK CONSTRAINT ALL;
insert into [PRODUCT]
values
	('PM1001', N'thơm Thái', N'Khi nấu xong, gạo sẽ có độ dẻo mềm vừa phải và rất thơm.', N'Hạt dài, màu trắng trong và ít bạc bụng', 'Vietnam', 'https://khogaomientay.com.vn/uploads/images/image(4).png'),
	('PM1002', N'Bắc Hương', N'Hạt gạo Bắc Hương nhỏ dài và có màu trắng trong. Khi nấu xong gạo có độ dẻo nhiều và độ dính cao. Cơm khi để nguội vẫn giữ được độ dẻo và mùi thơm đặc trưng.', N'Hạt nhỏ dài và có màu trắng trong', 'Vietnam', 'https://gaogiasi.com.vn/uploads/noidung/gao-bac-huong-0-167.jpg'),
	('PM1003', N'Tám Xoan', N'Với hạt gạo hơi dài, thon nhỏ và vẹo một đầu, bạn sẽ dễ dàng nhận ra gạo Tám Xoan. Hạt của chúng có màu trong xanh, không bị bạc bụng, mùi thơm lại dịu và rất tự nhiên.', N'Hạt nhỏ dài và có màu trắng trong, dẻo và độ dính', 'Vietnam', 'https://down-vn.img.susercontent.com/file/f37eb203adc72dbc2ad840f956eba3dc'),
	('PM1004', N'ST24', N'Gạo ST24 có dáng dài và dẹt, màu trắng trong, mang mùi thơm lá dứa tự nhiên. Khi nấu cho cơm mềm dẻo với hương thơm của lá dứa. Điều đặc biệt ở gạo ST24 là càng để nguội ăn càng ngon, hạt gạo vẫn giữ được độ mềm dẻo mà không bị cứng.', N'Hạt có dáng dài và dẹt, màu trắng trong', 'Vietnam', 'https://giagao.com/wp-content/uploads/2021/08/gao-ST24_AAN.jpg'),
	('PM1005', N'Hàm Châu', N'Với dáng vẻ bên ngoài giống như các loại gạo khác, gạo Hàm Châu với hương thơm tự nhiên, vị ngọt đậm. Gạo khi nấu xong nở và xốp, rất thích hợp để làm món cơm chiên.', N'Hạt có hương thơm tự nhiên, vị ngọt đậm', 'Vietnam', 'https://gaosachonline.com/wp-content/uploads/2018/05/gao-ham-chau-dong-tui.png'),
	('PM1006', N'Nàng Xuân', N'Là sự lai tạo của hai giống lúa Tám Xoan và KhaoDawk Mali (Thái Lan), gạo Nàng Xuân có hạt thon dài. Cơm khi nấu xong mềm dẻo, ngọt và có mùi thơm đặc trưng.', N'Hạt thon dài, khi nấu mềm dẻo, ngọt', 'Vietnam', 'https://gaochatluong.com/wp-content/uploads/2023/03/gao-nang-xuan-removebg-preview.png'),
	('PM1007', N'Tài Nguyên', N'Khác với những hạt gạo trắng trong, hạt gạo Tài Nguyên có màu trắng đục. Khi nấu sẽ cho cơm ráo, mềm, xốp, ngọt cơm. Đặc biệt, cơm vẫn ngon khi để nguội.', N'Hạt có màu trắng đục', 'Vietnam', 'https://product.hstatic.net/1000362335/product/14_9eedb99655254a0dbdaa78657657cfbf_master.png'),
	('PM1008', N'thơm Jasmine', N'Hạt gạo thơm Jasmine dài và màu trắng bóng rất đẹp mắt. Khi nấu cho cơm dẻo vừa và có mùi thơm nhẹ, được nhiều người ưa chuộng.', N'Hạt gạo thơm lài dài và màu trắng bóng ', 'Vietnam', 'https://giagao.com/wp-content/uploads/2021/08/gao-Jasmine_AAN.jpg'),
	('PM1009', N'ST25', N'Hạt gạo ST25 có mùi thơm đặc trưng của lá dứa hòa quyện với mùi thơm của cốm non rất dễ ngửi thấy kể cả khi gạo còn sống. Hơn thế nữa cơm được nấu từ gạo ST25 là loại cơm "cực phẩm" với hạt cơm khô ráo, độ dẻo, thơm nhất định và vị ngọt thanh đến từ tinh bột gạo hảo hạng, khi để nguội cũng khô bị khô cứng.', N'Hạt có mùi thơm đặc trưng', 'Vietnam', 'https://giagao.com/wp-content/uploads/2021/10/gao-ST25-hut-chan-khong-5kg-600x600.jpg'),
	('PM1010', N'Tám Thái đỏ', N'Được lai tạo từ gạo Hom Mali (Thái Lan), gạo Tám Thái đỏ có hạt nhỏ, dài đều, căng bóng, màu đục. Cơm chín có vị dẻo dai, màu cơm trắng hồng và có độ kết dính vừa phải.', N'Hạt nhỏ, dài đều, căng bóng, màu đục', 'Vietnam', 'http://cefvina.com.vn/wp-content/uploads/2018/07/3vFQHlMPPapyM2tj56Z1_simg_de2fe0_250x250_maxb.jpg'),
	('PM1011', N'Lứt', N'Gạo lứt với lớp cám gạo chưa được xay xát, có màu tím hoặc đỏ, mang đến hàm lượng dinh dưỡng dồi dào cho người tiêu dùng. Gạo lứt có các loại như: gạo lứt đỏ, gạo lứt đen, gạo lứt tẻ, gạo lứt nếp. Khi nấu, gạo cũng cần được nấu lâu hơn gạo trắng để đạt được độ mềm như mong muốn.', N'Hạt có màu tím hoặc đỏ', 'Vietnam', 'https://gaophuongnam.vn/thumbs/560x640x1/upload/product/gao-lut-dien-bien-do-4618.jpg'),
	('PM1012', N'Tám Điện Biên', N'Nổi tiếng với hương thơm và độ dẻo như nếp, tám Điện Biên có gạt gạo nhỏ, đều, căng bóng và hơi đục. Dù bề ngoài không được bắt mắt, cơm khi nấu xong lại cho ra những chén cơm thơm phức, dẻo ngọt khiến ai cũng phải thay đổi suy nghĩ về loại gạo này.', N'Hạt gạo nhỏ, đều, căng bóng và hơi đục', 'Vietnam', 'https://gaogiasi.com.vn/uploads/noidung/gao-tam-dien-bien-0-400.jpg');

ALTER TABLE [PRODUCT] CHECK CONSTRAINT ALL;

--------------------------------------------------------------------------------

GO
create function cost_bill (@bill_id char(6))
returns decimal(15,3)
as
begin
	declare @final_cost decimal(15,3);
	-- giá trả về
	if (LEFT(@bill_id,2) = 'BM')		-- parameter validation, only accept id with 'BM' PREFIX
		begin

		declare @gia_soLuong table(gia decimal(10,0),
			soLuong int);

		insert into @gia_soLuong
		select loaiBao.price_Bags, rela_gom_donHang_loBaoGao.Quantity
		from CONTAIN_PHYBAGS as rela_gom_donHang_loBaoGao join TYPE_OF_BAGS as loaiBao on rela_gom_donHang_loBaoGao.id_product = loaiBao.id_pro
		where rela_gom_donHang_loBaoGao.id_bill = @bill_id;

		set @final_cost = (select sum(gia*soLuong)
		from @gia_soLuong);
		if (@final_cost > 0)
				return @final_cost;
			else 
				return null;
	end
	return null;
end

/*	Function to calculate total value of all bills for each type of rice ()
*/
GO
create or alter function total_revenue ()
returns @ret_table table
(
	-- columns returned by the function
	maGao char(6) primary key not null,
	soLuongDon int not null,
	doanhThu decimal(10,2) not null	
)
as
begin
	declare @tempTable table (
		maGao char(6),
		maHoaDon char(6),
		cost_bill decimal(15,3)
							)
	insert into @tempTable
	select id_product as maGao, id_bill as maHoaDon, dbo.cost_bill(id_bill) as cost_bill
	from CONTAIN_PHYBAGS
	group by id_product, id_bill;

	insert into @ret_table
	select maGao, COUNT(maHoaDon) as soLuongDon, SUM(cost_bill) as doanhThu
	from @tempTable
	group by maGao;

	return
end
