<?php

include '../config/httpConfig.config.php';

include '../models/statistical.model.php';

header('Access-Control-Allow-Method: GET');


if ($_SERVER['REQUEST_METHOD'] == 'GET') {
        $statistical_info = new Statistical();
        $set_result = $statistical_info->getStatisticalData();
    if (!empty($set_result)) {
        //Has result set => process result
        $Total_revenue = 0;
        $Total_type_2 = 0;
        $Total_type_5 = 0;
        $Total_type_10 = 0;
        $revenue_2 = 0;
        $revenue_5 = 0;
        $revenue_10 = 0;
        $object_return = array();


        if (isset($_GET['TenGao'])) {
            $object_return['tenGao'] = $_GET['TenGao'];

            foreach ($set_result as $r) {
                if ($r['TenGao'] == $_GET['TenGao']) {
                    $object_return['maGao'] = $r['maGao'];
                    switch ((int)substr($r['maLoai'], 4)) {
                        case 2:
                            $Total_type_2 += $r['soBao'];
                            $revenue_2 += $r['doanhThu'] * $r['soBao'];
                            break;
                        case 5:
                            $Total_type_5 += $r['soBao'];
                            $revenue_5 += $r['doanhThu'] * $r['soBao'];
                            break;
                        case 10:
                            $Total_type_10 += $r['soBao'];
                            $revenue_10 += $r['doanhThu'] * $r['soBao'];
                            break;
                    }
                }
            }

            $Total_revenue = $revenue_2 + $revenue_5 + $revenue_10;
           
            $object_return["soBaoLoai2"] = $Total_type_2;
            $object_return["soBaoLoai5"] = $Total_type_5;
            $object_return["soBaoLoai10"] = $Total_type_10;
            $object_return["doanhThuLoai2"] = $revenue_2;
            $object_return["doanhThuLoai5"] = $revenue_5;
            $object_return["doanhThuLoai10"] = $revenue_10;
            $object_return['doanhThuTong'] = $Total_revenue;



            $data = array(
                "status_code" => 200,
                "status_message" => "Fetch Statistical Information Successfully",
                "data" => $object_return
            );
        } else {
            $data = array(
                "status_code" => 400,
                "status_message" => "Please Specify Pname You Want",
            );
        }
    } else {
        $data = array(
            "status_code" => 404,
            "status_message" => "Not Found Statistical Information",
        );
    }
} else {
    $data = array(
        "status_code" => 405,
        "status_message" => "Method Not Allowed"
    );
}

http_response_code($data['status_code']);
echo json_encode($data, JSON_UNESCAPED_UNICODE);
