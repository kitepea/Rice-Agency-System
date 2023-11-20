-- QUAN --
USE master;
GO
DROP DATABASE IF EXISTS Rice_Agency;
GO
CREATE DATABASE Rice_Agency;
GO
USE Rice_Agency;
GO

CREATE TABLE [user] (
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


create table [address] (
	userid char(6),
	house_num varchar(5) not null,
	street varchar(50) not null,
	city varchar(50) not null,
	primary key (userid, house_num, street, city),
	constraint fk_uid_address foreign key (userid) references [user] (userid) 
	on delete cascade
	on update cascade
);

CREATE TABLE Account(
	Username varchar(30),
    [Password] varchar(20) not null,
    [Type] varchar(20) not null,
	userid char(6),
    PRIMARY KEY(Username),
	constraint fk_uid_account foreign key (userid) references [user] (userid)
	on delete cascade
	on update cascade
);

create table employee (
	employee_id char(6),
	manager_id char(6),
	primary key (employee_id),
	constraint fk_empid_uid foreign key (employee_id) references [user] (userid)
	on delete cascade
	on update cascade
);

create table customer (
	customer_id char(6),
	primary key (customer_id),
	constraint fk_uid_customer foreign key (customer_id) references [user] (userid)
	on delete cascade
	on update cascade
);

create table seller (
	seller_id char(6),
	primary key (seller_id),
	constraint fk_empid_seller foreign key (seller_id) references employee (employee_id)
	on delete cascade
	on update cascade
);

-- alter
alter table employee
add constraint fk_manager_id foreign key (manager_id) references employee (employee_id);
-- add prefix auto_increment (procedure and trigger)