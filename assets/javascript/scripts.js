(function(){
  if (typeof ScrollReveal == "undefined") {
    return;
  }

  afterReveal = function(elScrolledTo) {
    elScrolledTo.setAttribute('data-sr-revealed', true);
  }

  afterReset = function(elScrolledTo) {
    elScrolledTo.setAttribute('data-sr-revealed', false);
    var elInView = document.querySelector('[data-sr-revealed="true"]');
    if (!elInView) {
      return;
    }

    var sectionInView = elInView.getAttribute('id');
    var htmlTag = document.querySelector('html');

    if (!sectionInView) {
      return;
    }
    htmlTag.setAttribute('data-section-in-view', sectionInView);
  }

  addScrollReveal = function() {
    var sr = ScrollReveal({
      scale: 0.95,
      opacity: 0.1,
      distance: "50px",
      reset: true,
      viewFactor: 0.3,
      delay: 300,
      afterReveal: afterReveal,
      afterReset: afterReset
    });
    sr.reveal('.scroll-reveal');
  }

  addScrollReveal()
})()
