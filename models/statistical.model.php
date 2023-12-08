<?php

include 'db.model.php';


class Statistical
{
    var $statistic_db;

    function __construct()
    {
        global $connect;
        $this->statistic_db = $connect;
    }



    function getStatisticalData()
    {
        // prepare statement
        $stmt = sqlsrv_query($this->statistic_db, "EXEC dbo.getAllRevenueOfProduct");

        if ($stmt === false) {
            die(print_r(sqlsrv_errors(), true));
        }

        // Get all record from return result
        $set_result = array();
        while ($result = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            array_push($set_result, $result);
        }

        return $set_result;
    }
}
