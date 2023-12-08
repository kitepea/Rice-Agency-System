<?php


include '../models/db.model.php';
include '../config/httpConfig.config.php';

include '../models/bill.model.php';

global $connect;

$bill = new Bill();

$names = $bill->getAllRiceNameHasBeenSold();

echo json_encode($names,JSON_UNESCAPED_UNICODE);