IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Rice_Agency')
    PRINT 'Exist'
ELSE
    PRINT 'No exist'

USE Rice_Agency
GO
SELECT DB_NAME() AS [Current Database];

/*TEST TRIGGER UPDATEPOINT*/
Go
--Ban đầu khi chưa insert và update
SELECT *
FROM [ACCOUNT]
WHERE [ACCOUNT].[user_id] = 'CM1013'
	OR [ACCOUNT].[user_id] = 'CM1002'

--Cập nhập trạng thái đơn hàng của đơn có mã BM1013 từ 'Waiting' sang 'Done'
go
UPDATE BILL
Set [status] = 'Done'
Where id_bill = 'BM1013'

--Insert một đơn có trạng thái là 'Done'
go
INSERT INTO BILL
VALUES ('BM1023', '03-02-2023', 'Done', null, 'CM1002', 'EM1002', '234', N'Hoàng Diệu 2', N'TP Hồ Chí Minh');

-- Điểm của account sau khi đơn hàng được cập nhập done
Go
SELECT *
FROM [ACCOUNT]
WHERE [ACCOUNT].[user_id] = 'CM1013'
	OR [ACCOUNT].[user_id] = 'CM1002'

-- XÓA TEST
DELETE [BILL] WHERE [BILL].id_bill = 'BM1023'

-- Thử xóa account
DELETE [ACCOUNT] WHERE [ACCOUNT].[user_id] = 'CM1013'
SELECT *
FROM [ACCOUNT]
WHERE [ACCOUNT].[user_id] = 'CM1013'
	OR [ACCOUNT].[user_id] = 'CM1002'
	


