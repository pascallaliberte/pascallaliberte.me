(function(){
  if (typeof ScrollReveal == "undefined") {
    alert("no ScrollReveal")
    return;
  }

  addScrollReveal = function() {
    var sr = ScrollReveal({ scale: 1, distance: "50px", delay: 250 });
    sr.reveal('.scroll-reveal');
  }

  addScrollReveal()
})()
