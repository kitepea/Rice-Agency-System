async function fetchDataProductPHP() {
    const response = await fetch(`/services/getAllProducts.php`);
    const json = await response.json();
    return json.data;
}

async function displayProducts() {
    const products = await fetchDataProductPHP();
    const HTMLcontent = products.map((product) => {
        return `
        <div class="col mb-5">
        <div class="card h-100">
            <!-- Product image-->
            <img class="card-img-top mt-2"
                src="${product.imgSrc}" alt="${product.tenGao}" />
            <!-- Product details-->
            <div class="card-body">
                <div class="text-center">
                    <!-- Product name-->
                    <h5 class="fw-bolder">Gạo ${product.tenGao} (túi ${product.loaiBao}kg)</h5>
                    <!-- Product price-->
                    ${parseInt(product.giaTien).toLocaleString()} (VNĐ)
                </div>
            </div>
            <!-- Product actions-->
            <div class="d-flex flex-row justify-content-around card-footer pt-0 border-top-0">
                <div class="text-center"><a class="btn mt-auto bg-primary text-white" style="width: 80px;"
                        href="./view.html?">View</a>
                </div>
                <div class="text-center"><a class="btn  mt-auto bg-danger text-white" style="width: 80px;"
                        href="#">Delete</a>
                </div>
            </div>
        </div>
    </div>`
    }).join('');

    document.querySelector("#products-wrapper").innerHTML = HTMLcontent;
}

