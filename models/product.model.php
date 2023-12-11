<?php
include 'db.model.php';


class Product {
    var $product_db;

    function __construct()
    {
        global $connect;
        $this->product_db = $connect;
    }

    function addProduct($pname, $desc, $featured, $origin, $picture, $cname, $type, $price, $nsx, $hsd) {
        $sql = sqlsrv_query($this->product_db, "EXEC InsertProduct @PName = N'$pname', @description = N'$desc', @featured = N'$featured', @origin = N'$origin', @picture = '$picture', @company_name = N'$cname', @type = '$type', @price = $price, @NSX = '$nsx', @HSD = '$hsd';");
        if ($sql) {
            return "Added successfully";
        } else {
            return sqlsrv_errors(SQLSRV_ERR_ERRORS);
        }
    }

    function deleteProduct($id_product) {
        $sql = sqlsrv_query($this->product_db, "EXEC DeleteProduct @id_product = '$id_product'");
        if ($sql) {
            return "Deleted successfully";
        } else {
            return sqlsrv_errors(SQLSRV_ERR_ERRORS);
        }
    }

    function updateProduct($id_product, $pname, $desc, $featured, $origin, $picture, $cname, $type, $price) {
        $sql = sqlsrv_query($this->product_db, "EXEC EditProduct @id_product = '$id_product', @PName = N'$pname', @description = N'$desc', @featured = N'$featured', @origin = N'$origin', @picture = '$picture', @company_name = '$cname', @type = '$type', @price = $price;");
        if ($sql) {
            return "Updated successfully";
        } else {
            return sqlsrv_errors(SQLSRV_ERR_ERRORS);
        }
    }

    function getAllProducts()
    {
        $stmt = sqlsrv_query($this->product_db, "EXEC getAllProducts");
        if ($stmt === false) {
            die(print_r(sqlsrv_errors(), true));
        }
        $ret_object = array();
        while ($result = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            array_push($ret_object, $result);
        }
        return $ret_object;
    }
    
    function getProductDetails($id_product, $type)
    {
        $sql = "SELECT * FROM GetProductDetails(?, ?)";
        $stmt = sqlsrv_query($this->product_db, $sql, array($id_product, $type));
        
        if ($stmt) {
            $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
            return json_encode($row, JSON_UNESCAPED_UNICODE);
        } else {
            die(print_r(sqlsrv_errors(SQLSRV_ERR_ERRORS)));
        }
    }
}
