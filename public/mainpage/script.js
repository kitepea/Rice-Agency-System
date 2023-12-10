// Get the input elements
let manufacturingDateInput = document.getElementById("manufacture");
let expiryDateInput = document.getElementById("expiry");
let today = new Date();

// Add an event listener to the input elements
manufacturingDateInput.addEventListener("change", validateDates);
expiryDateInput.addEventListener("change", validateDates);

function validateDates() {
  let manufacturingDate = new Date(manufacturingDateInput.value);
  let expiryDate = new Date(expiryDateInput.value);

  if (manufacturingDate >= expiryDate) {
    alert("The manufacturing date must be earlier than the expiry date");
  }

  if (expiryDate < today) {
    alert("Product already or about to be expired");
    return;
  }
}
