// Get the input elements
let manufacturingDateInput = document.getElementById("manufacture");
let expiryDateInput = document.getElementById("expiry");
let today = new Date();

function validateDates() {
  let manufacturingDate = new Date(manufacturingDateInput.value);
  let expiryDate = new Date(expiryDateInput.value);
  
  if (manufacturingDate > today) {
    alert("Ngày sản xuất phải sớm hơn hôm nay");
    return 1;
  }
  
  if (expiryDate < today) {
    alert("Mặt hàng đã hết hạn");
    return 1;
  }
  
  if (manufacturingDate >= expiryDate) {
    alert("NSX phải sớm hơn HSD");
    return 1;
  }
  
  return 0;
}

// Add an event listener to the input elements
manufacturingDateInput.addEventListener("change", validateDates);
expiryDateInput.addEventListener("change", validateDates);