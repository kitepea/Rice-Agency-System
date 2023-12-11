IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Rice_Agency')
    PRINT 'Exist'
ELSE
    PRINT 'No exist'

USE Rice_Agency
GO
SELECT DB_NAME() AS [Current Database];


Go
SELECT *
FROM [USER]
WHERE [USER].[user_id] = 'CM1013'

UPDATE BILL
Set [status] = 'Done' --Cập nhập trạng thái đơn hàng của đơn có mã BM1013 từ 'Waiting' sang 'Done'
Where id_bill = 'BM1013'

Go
SELECT *
FROM [USER]
WHERE [USER].[user_id] = 'CM1013'
	


