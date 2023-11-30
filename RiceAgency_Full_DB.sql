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

CREATE TABLE [USER] (
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


create table [ADDRESS] (
	userid char(6),
	house_num varchar(5) not null,
	street varchar(50) not null,
	city varchar(50) not null,
	primary key (userid, house_num, street, city),
	constraint fk_uid_address foreign key (userid) references [user] (userid) 
	on delete cascade
	on update cascade
);

CREATE TABLE [ACCOUNT](
	Username varchar(30),
    [Password] varchar(20) not null,
 	[Type] VARCHAR(20) CHECK ([TYPE] IN ('Employee', 'Customer')) NOT NULL,
	userid char(6),
    PRIMARY KEY(Username),
	constraint fk_uid_account foreign key (userid) references [user] (userid)
	on delete cascade
	on update cascade
);

create table EMPLOYEE (
	employee_id char(6) NOT NULL,
	manager_id char(6) NOT NULL,
	primary key (employee_id),
	constraint fk_empid_uid foreign key (employee_id) references [user] (userid)
	on delete cascade
	on update cascade
);

create table CUSTOMER (
	customer_id char(6) PRIMARY KEY,
	constraint fk_uid_customer foreign key (customer_id) references [user] (userid)
	on delete cascade
	on update cascade
);

create table SELLER (
	seller_id char(6) PRIMARY KEY,
	constraint fk_empid_seller foreign key (seller_id) references employee (employee_id)
	on delete cascade
	on update cascade
);

-- VKDKhoa
/************************* MẶT_HÀNG *****************************/
-- PK = PMXXXX;  [PREFIX] = PM, id PMXXXX
CREATE TABLE [PRODUCT] (
	id_product CHAR(6) NOT NULL,
	[PName] NVARCHAR(30) NOT NULL,
	[description]  NVARCHAR(80),
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
	id_type CHAR(6) NOT NULL,
	BName INT NOT NULL DEFAULT 2,
	inventory_num INT, 
	price_Bags DECIMAL(10,0), --giá (VND) của mỗi loại bao

	CONSTRAINT PR_TYPEBAGS PRIMARY KEY(id_pro, id_type),

	CONSTRAINT FK_TOBPRO_TO_IDPRO FOREIGN KEY (id_pro) REFERENCES [PRODUCT](id_product)
	ON DELETE CASCADE
	ON UPDATE CASCADE,

	CHECK (
		(BName = 2 OR BName = 5 OR BName = 10) -- các loại bao gạo gồm 3 loại 2kg,5kg,10kg
		AND inventory_num >= 0 AND inventory_num <= 500 --SL tồn kho không âm và max = 500
		AND price_Bags > 1000 -- giá mỗi loại bao không thấp hơn 1000
	)
)
/******************************************************/

CREATE TABLE PHYSICAL_RICEBAG (
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
	CHECK ([status] = 'Unprocessed' OR [status] = 'Processed')
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

	CONSTRAINT PK_Deli PRIMARY KEY (id_DelivTrip)
)
/******************************************************/

/************************* KIỆN_HÀNG *****************************/
CREATE TABLE PACKAGE(
	id_package CHAR(6) NOT NULL,
	id_bill CHAR(6) NOT NULL,
	[status] VARCHAR(15)  DEFAULT 'Not started',
	id_DelivTrip CHAR(6) NOT NULL,

	CONSTRAINT PK_PACKAGES PRIMARY KEY(id_package),

	CONSTRAINT FK_PACKAGE_TO_BILL FOREIGN KEY (id_bill) REFERENCES BILL(id_bill),
	CONSTRAINT FK_PACKAGE_TO_DELTRIP FOREIGN KEY (id_DelivTrip) REFERENCES DELIVERY_TRIP(id_DelivTrip),

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

	CONSTRAINT FK_CONPACK_TO_PHYBAGS 
		FOREIGN KEY (id_product,id_type,NumOrder) 
		REFERENCES PHYSICAL_RICEBAG(id_product,id_type,NumOrder),

	CONSTRAINT FK_CONPACK_TO_PACK FOREIGN KEY (id_package) REFERENCES PACKAGE(id_package),
	CHECK (Quantity > 0)
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

	CONSTRAINT FK_CONPHY_TO_PHYBAGS
		FOREIGN KEY (id_product,id_type,NumOrder) 
		REFERENCES PHYSICAL_RICEBAG(id_product,id_type,NumOrder),
	CONSTRAINT FK_CONPHY_TO_BILL FOREIGN KEY (id_bill) REFERENCES BILL(id_bill),

	CHECK (Quantity > 0)
)
/******************************************************/

/************************* NHÂN VIÊN VẬN CHUYỂN *****************************/
CREATE TABLE SHIPPER (
	shipper_id CHAR(6) NOT NULL,
	CONSTRAINT PK_SHIPEMP PRIMARY KEY (shipper_id),

	CONSTRAINT SHIPER_TO_EMPLOY FOREIGN KEY (shipper_id) REFERENCES employee (employee_id)
)
/******************************************************/

/************************* PHƯƠNG TIỆN *****************************/
CREATE TABLE VECHILE (
	id_vechile CHAR(6) NOT NULL,
	CONSTRAINT PK_VECHILE PRIMARY KEY (id_vechile)
)
/******************************************************/

/************************* CÔNG TY SẢN SUẤT *****************************/
CREATE TABLE COMPANY_PRODUCT (
	company_name VARCHAR(30) NOT NULL,
	hotline VARCHAR(15),
	CONSTRAINT PK_COMPANY_PRODUCT PRIMARY KEY (company_name)
)
/******************************************************/

/************************* SẢN XUẤT *****************************/
CREATE TABLE PRODUCTION (
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
	ON DELETE CASCADE
	ON UPDATE CASCADE;

alter table BILL
add CONSTRAINT FK_BILL_TO_SELLER FOREIGN KEY (seller_id) REFERENCES seller(seller_id)

alter table DELIVERY_TRIP
add CONSTRAINT FK_DELTRP_TO_SHIPER FOREIGN KEY (shipper_id) REFERENCES SHIPPER(shipper_id)

alter table DELIVERY_TRIP
add CONSTRAINT FK_DELTRP_TO_VECHILE FOREIGN KEY (id_vechile) REFERENCES VECHILE(id_vechile)

-- add prefix auto_increment (procedure and trigger)


-- function to calculate cost of a bill bases on bill id
GO
create function cost_bill (@bill_id char(6))
returns decimal(15,3)
as
begin
	declare @final_cost decimal(15,3);	-- giá trả về
	if (LEFT(@bill_id,2) = 'BM') -- parameter validation, only accept id with 'BM' PREFIX
		begin
			
			declare @gia_soLuong table(gia decimal(10,0), soLuong int);			-- mã gạo

			insert into @gia_soLuong
			select loaiBao.price_Bags, rela_gom_donHang_loBaoGao.Quantity
			from CONTAIN_PHYBAGS as rela_gom_donHang_loBaoGao join TYPE_OF_BAGS as loaiBao on rela_gom_donHang_loBaoGao.id_product = loaiBao.id_pro
			where rela_gom_donHang_loBaoGao.id_bill = @bill_id;

			set @final_cost = (select sum(gia*soLuong) from @gia_soLuong);
			if (@final_cost > 0)
				return @final_cost;
			else 
				return null;
		end
	return null;
end

