window.addEventListener('load', function(){
  window.cookieconsent.initialise({
   revokeBtn: "<div class='cc-revoke'></div>",
   type: "opt-in",
   theme: "classic",
   palette: {
       popup: {
           background: "#000",
           text: "#fff"
        },
       button: {
           background: "#fd0",
           text: "#000"
        }
    },
   content: {
       link: "About consent",
       "message": "This website uses cookies to ensure you get the best experience here!",
       href: "https://kerszl.github.io/terms/"
    },
    onInitialise: function(status) {
      if(status == cookieconsent.status.allow) myScripts();
    },
    onStatusChange: function(status) {
      if (this.hasConsented()) myScripts();
    }
  })
});

function myScripts() {

   // Paste here your scripts that use cookies requiring consent. See examples below

   // Google Analytics, you need to change 'UA-00000000-1' to your ID
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
      ga('create', 'UA-199157698-1', 'auto');
      ga('send', 'pageview');



}
