<?php
$serverName = "localhost";
$connectInfo = array(
    "Database" => "Rice_Agency"
);

$connect = sqlsrv_connect($serverName,$connectInfo);

if (!$connect) {
    echo "<h1>Connection could not be established.</h1><br />";
    die( print_r( sqlsrv_errors(), true));
} else {
    
}