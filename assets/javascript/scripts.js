(function(){
  if (typeof ScrollReveal == "undefined") {
    return;
  }

  dressUpPage = function(elScrolledTo) {
    var sectionInView = elScrolledTo.getAttribute('id');
    var htmlTag = document.querySelector('html');
    if (sectionInView) {
      htmlTag.setAttribute('data-section-in-view', sectionInView);
    }
  }

  addScrollReveal = function() {
    var sr = ScrollReveal({
      scale: 0.95,
      opacity: 0.1,
      distance: "50px",
      reset: true,
      viewFactor: 0.3,
      delay: 300,
      afterReveal: dressUpPage
    });
    sr.reveal('.scroll-reveal');
  }

  addScrollReveal()
})()
