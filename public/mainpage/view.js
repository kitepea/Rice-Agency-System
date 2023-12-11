function fetchDataAndFillTemplate() {
    const params = new URLSearchParams(window.location.search);
    fetch(`/services/products/getProductDetails.php?id_product=${params.get('id_product')}&type=${params.get('type')}`, {
        method: 'GET'
    })
        .then(response => response.json())
        .then(data => {
            $("#picture").attr("src", data.picture);
            $("#PName-BName").text(`Gạo ${data.PName} (túi ${data.BName} kg)`);
            $("#id_product").text(data.id_product);
            $("#price_Bags").text(`${parseInt(data.price_Bags).toLocaleString()} VNĐ`);
            $("#description").text(data.description);
            $("#origin").text(data.origin);
            $("#BName").text(data.BName);
            $("#inventory_num").text(`${data.inventory_num} bao`);
            $("#featured").text(data.featured);
        })
}