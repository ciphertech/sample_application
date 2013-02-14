//Added by Jalendra Bhanarkar
//For centering any block on screen

jQuery.fn.center = function () {
    return this.each(function(){
	$(this).css("position","fixed");
	$(this).css("top", ( $(window).height() - $(this).height() ) / 2+ "px");
	$(this).css("left", ( $(window).width() - $(this).width() ) / 2+ "px");
    });
}
