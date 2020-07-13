
function sendObject2Translate(id) {
  var arr = $.find(".i18n").map((x) => $(x).html());
  Shiny.onInputChange("i18nValues", arr);
}

function receiveTranslated(translated) {
  var dict = Object.fromEntries( $.find(".i18n").map( x => [$(x).html(), x]) );
  for (const key in translated) {
    console.log($(dict[key]).html());
    console.log(key);
    $(dict[key]).html(translated[key]);
  }
}

Shiny.addCustomMessageHandler("handleri18nout", sendObject2Translate);
Shiny.addCustomMessageHandler("handleri18nin", receiveTranslated);
