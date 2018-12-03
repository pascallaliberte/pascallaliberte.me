(function(){
  makeVideosResponsive = function() {
    if (typeof reframe == "undefined") {
      return;
    }

    reframe('iframe');
  }

  makeVideosResponsive();
})()
