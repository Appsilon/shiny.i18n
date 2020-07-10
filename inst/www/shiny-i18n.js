var shinyi18n = new Shiny.InputBinding();

// based on https://github.com/rstudio/shiny/blob/master/inst/www/shared/shiny.js
$.extend(shinyi18n, {
  find: function find(scope) {
    return $(scope).find('.i18n');
  },
  getValue: function getValue(el) {
      return "abc";
  },
  setValue: function setValue(el, value) {
    el.value = value;
  },
  subscribe: function subscribe(el, callback) {
      
  },
  receiveMessage: function receiveMessage(el, data) {

    $(el).trigger('change');
  },
  getRatePolicy: function getRatePolicy() {
    return {
      policy: 'debounce',
      delay: 250
    };
  }
});
Shiny.inputBindings.register(shinyi18n, 'shiny.shinyi18n');