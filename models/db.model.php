<?php
$serverName = "localhost";
$connectInfo = array(
    "Database" => "Rice_Agency",
    "CharacterSet" => "UTF-8"
);

$connect = sqlsrv_connect($serverName, $connectInfo);

if (!$connect) {
    echo "<h1>Connection could not be established.</h1><br />";
    die(print_r(sqlsrv_errors(), true));
} else {
    date_default_timezone_set('Asia/Ho_Chi_Minh');
}
