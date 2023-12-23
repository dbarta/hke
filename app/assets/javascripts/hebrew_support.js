document.addEventListener("DOMContentLoaded", function() {
    var rtlDir = (document.documentElement.lang === 'he') ? 'rtl' : 'ltr';
    document.body.setAttribute('dir', rtlDir);
  });
  
  