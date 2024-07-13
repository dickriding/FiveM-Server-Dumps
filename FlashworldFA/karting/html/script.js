var currentShop = "";
$(function () {
  window.addEventListener("message", function (event) {
    if (event.data.type == "enableui") {
      document.body.style.display = event.data.enable ? "flex" : "none";
      currentShop = event.data.shop;
      // console.log("shop : "+currentShop)
    }
  });

  document.onkeyup = function (data) {
    if (data.which == 27) {
      // Escape key
      $.post("https://karting/escape", JSON.stringify({}));
    }
  };

  $("#close").click(function () {
    $.post("https://karting/escape", JSON.stringify({}));
  });

  $("#register").submit(function (event) {
    event.preventDefault(); // Prevent form from submitting

    // Verify date

    $.post(
      "https://karting/validate",
      JSON.stringify({
        sessionname: $("#sessionName").val(),
        gamemode: $("#GameMode").val(),
        maps: "PlasmaRace 1",
        nblap: $("#NbLap").val(),
        cylindre: $("#cylindre").val(),
        curshop: currentShop,
      })
    );
  });
});
