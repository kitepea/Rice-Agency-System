-- Thêm, xóa sửa thông tin mặt hàng
-- Test InsertProduct procedure
GO
DECLARE 
    @PName NVARCHAR(30) = N'Loại gạo 1',
	@description NVARCHAR(1000) = N'Mô tả 1',
	@featured NVARCHAR(255) = N'Đặc tính 1',
	@origin NVARCHAR(20) = N'Nguồn gốc',
	@picture VARCHAR(255) = 'Link ảnh',
	@company_name NVARCHAR(30) = N'Công ty 1',
	@type CHAR(2) = '05',
	@price DECIMAL(10, 0) = 10000,
	@NSX DATE = '2023-01-01',
	@HSD DATE = '2023-12-31';

-- Execute the stored procedure
EXEC InsertProduct
	@PName,
	@description,
	@featured,
	@origin,
	@picture,
	@company_name,
	@type,
	@price,
	@NSX,
	@HSD;

-- Display new db
SELECT * FROM PRODUCT;
SELECT * FROM PRODUCTION;
SELECT * FROM COMPANY_PRODUCT;

-- Test DeleteProduct
GO
DECLARE @id_product CHAR(6) = 'PM1013';
-- Execute the stored procedure
EXEC DeleteProduct @id_product;

-- Display new db
SELECT * FROM PRODUCT;
SELECT * FROM TYPE_OF_BAGS;
SELECT * FROM PHYSICAL_RICEBAG;
SELECT * FROM PRODUCTION;
SELECT * FROM COMPANY_PRODUCT;

-- Test EditProduct procedure
GO
DECLARE
	@id_product CHAR(6) = 'PM1014',
    @PName NVARCHAR(30) = N'Loại gạo 1',
	@description NVARCHAR(1000) = N'Mô tả 2',
	@featured NVARCHAR(255) = N'Đặc tính 1',
	@origin NVARCHAR(20) = N'Nguồn gốc',
	@picture VARCHAR(255) = 'Link ảnh',
	@company_name NVARCHAR(30) = N'Công ty 1',
	@type CHAR(2) = '05',
	@price DECIMAL(10, 0) = 20000;

-- Execute the stored procedure
EXEC EditProduct
	@id_product,
	@PName,
	@description,
	@featured,
	@origin,
	@picture,
	@company_name,
	@type,
	@price;


SELECT * FROM PRODUCT;
SELECT * FROM TYPE_OF_BAGS;
SELECT * FROM PHYSICAL_RICEBAG;
SELECT * FROM PRODUCTION;
SELECT * FROM COMPANY_PRODUCT;