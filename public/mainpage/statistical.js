var chart1;
var chart2;
var TenGao = undefined;
var statisticalData = undefined;


async function fetchAllPriceName() {
    const response = await fetch('/services/getAllRiceName.php');
    const json = await response.json();
    const elements = json.reduce((accumulator, prod) => {
        return accumulator + `<li onclick="show('${prod.Pname}')"><a class="dropdown-item" id="#stastical" >${prod.Pname}</a>`;
    }, [])
    document.querySelector("#product-selection").innerHTML = elements;
}


async function fetchDataStatisticalPHP(TenGao) {
    const response = await fetch(`/services/statistical.php?TenGao=${TenGao}`);
    const json = await response.json();
    return json.data;
}


async function show(Pname) {
    var stasticalDiv = document.getElementById('statistical-container');
    TenGao = Pname;
    statisticalData = await fetchDataStatisticalPHP(Pname);
    if (stasticalDiv.style.display === 'none') {
        stasticalDiv.style.display = 'block';
    }
    document.querySelector("#Tong-so-bao").innerHTML = statisticalData.soBaoLoai2 + statisticalData.soBaoLoai5 + statisticalData.soBaoLoai10;
    document.querySelector("#Tong-doanh-thu").innerHTML = statisticalData.doanhThuTong;

    
    resetChart(chart1, [statisticalData.soBaoLoai2, statisticalData.soBaoLoai5, statisticalData.soBaoLoai10],null);
    resetChart(chart2, [statisticalData.doanhThuLoai2, statisticalData.doanhThuLoai5, statisticalData.doanhThuLoai10],null);
}

function resetChart(chart, datas, labels) {
    while (chart.data.datasets[0].data.length != 0) {
        chart.data.datasets[0].data.pop();

    }
    chart.data.datasets[0].data.push(...datas);
    chart.update();
}


