USE Rice_Agency;
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
	WHERE BName = CAST('02' AS INT)
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
	SELECT company_name, PRODUCT.id_product, PName, featured, origin, picture, BName, inventory_num, price_Bags 
	FROM (PRODUCT JOIN TYPE_OF_BAGS ON id_pro = id_product) JOIN PRODUCTION ON PRODUCT.id_product = PRODUCTION.id_product
	WHERE id_pro = @id_product AND BName = CAST(@type as INT)
);
