$( document ).ready(function(){
    
    /* Constants */
    var nav_height = 80;
        
    //inital setup
    window.onload = function()
    {
        //header height
        $("#header").height(window.innerHeight - nav_height);
        
        //start animations
        $("#title_wrap").addClass("underline-center-out-pre");
        setTimeout( function(){ $("#title_wrap").addClass("underline-center-out-post"); }, 500);
        setTimeout( function(){ $("#phrase").addClass("fadein"); }, 1200);
    }
    
    //resize event
    window.onresize = function()
    {   
        //header
        $("#header").height(window.innerHeight - nav_height);
    }
    
    //click scroll, http://css-tricks.com/snippets/jquery/smooth-scrolling/
    $('a[href*=#]:not([href=#])').click(function() 
    {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') 
         || location.hostname == this.hostname) 
        {
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
            if (target.length) 
            {
                $('html,body').animate({ scrollTop: target.offset().top}, 850);
                return false;
            }
        }
    });
});
