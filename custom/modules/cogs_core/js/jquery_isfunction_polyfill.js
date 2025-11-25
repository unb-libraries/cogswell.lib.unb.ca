(function (window, jQuery) {
  'use strict';
  // Polyfill for removed jQuery helpers in jQuery 4
  if (typeof jQuery !== 'undefined' && typeof jQuery.isFunction !== 'function') {
    jQuery.isFunction = function (obj) {
      return typeof obj === 'function';
    };
  }
})(window, window.jQuery);