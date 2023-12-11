function displayProducts(products) {
    const HTMLcontent = products.map((product) => {
        return `
        <div class="col mb-5 product">
        <div class="card h-100">
            <!-- Product image-->
            <img class="card-img-top mt-2"
                src="${product.imgSrc}" alt="${product.tenGao}" />
            <!-- Product details-->
            <div class="card-body">
                <div class="text-center">
                    <!-- Product name-->
                    <h5 class="fw-bolder product-name">Gạo ${product.tenGao} (túi ${product.loaiBao}kg)</h5>
                    <!-- Product price-->
                    ${parseInt(product.giaTien).toLocaleString()} (VNĐ)
                </div>
            </div>
            <!-- Product actions-->
            <div class="d-flex flex-row justify-content-around card-footer pt-0 border-top-0">
                <div class="text-center"><a class="btn mt-auto bg-primary text-white" style="width: 80px;"
                        href="./view.html?id_product=${product.maGao}&type=${product.loaiBao}">View</a>
                </div>
                <div class="text-center"><a class="btn  mt-auto bg-danger text-white" style="width: 80px;"
                        href="../../services/products/deleteProduct.php?id_product=${product.maGao}">Delete</a>
                </div>
            </div>
        </div>
    </div>`
    }).join('');

    document.querySelector("#products-wrapper").innerHTML = HTMLcontent;
}

function displayProducts1(products) {
    const HTMLcontent = products.map((product) => {
        return `
        <div class="col mb-5 product">
        <div class="card h-100">
            <!-- Product image-->
            <img class="card-img-top mt-2"
                src="${product.picture}" alt="${product.PName}" />
            <!-- Product details-->
            <div class="card-body">
                <div class="text-center">
                    <!-- Product name-->
                    <h5 class="fw-bolder product-name">Gạo ${product.PName} (túi ${product.BName}kg)</h5>
                    <!-- Product price-->
                    ${parseInt(product.price_Bags).toLocaleString()} (VNĐ)
                </div>
            </div>
            <!-- Product actions-->
            <div class="d-flex flex-row justify-content-around card-footer pt-0 border-top-0">
                <div class="text-center"><a class="btn mt-auto bg-primary text-white" style="width: 80px;"
                        href="./view.html?id_product=${product.id_product}&type=${product.BName}">View</a>
                </div>
                <div class="text-center"><a class="btn  mt-auto bg-danger text-white" style="width: 80px;"
                        href="../../services/products/deleteProduct.php?id_product=${product.id_product}">Delete</a>
                </div>
            </div>
        </div>
    </div>`
    }).join('');

    document.querySelector("#products-wrapper").innerHTML = HTMLcontent;
}