$( document ).ready(function(){
    
    /**
     * setup
     * 
     * Executed 2s after window loads
     * Adds classes to certain elements to trigger animations
     */
    window.onload = function()
    {
        $("#title_wrap").addClass("underline-center-out-pre");
        setTimeout( function(){ $("#title_wrap").addClass("underline-center-out-post"); }, 500);
        setTimeout( function(){ $("#phrase").addClass("fadein"); }, 800);
       // setTimeout( function(){ $("#test_wrap").css("opacity", 1); }, 800);
    }
});
