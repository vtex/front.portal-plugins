$(window).load(function() {
  if(console && console.log) console.log("v2-portal-topbar");
	if ($('meta[name=vtex-version]').length > 0) {
		var floatingBar = $(".floatingTopBar");
		var smartCart = $(".vtexsc-cart");
		$(window).bind("scroll", function() {
			var $this = $(this);
			if ($this.scrollTop() > 140) 
			{
				floatingBar.fadeTo(300, 1);
				$(".vtexsc-cart").addClass("floatingCart").css("left", (floatingBar.find(".cartInfo").offset().left - 178));
			} 
			else 
			{
				floatingBar.stop(true).fadeTo(200, 0, function() {
					floatingBar.hide();
				});
				$(".vtexsc-cart").removeClass("floatingCart").css("left", "auto");
			}
		});
	}
});