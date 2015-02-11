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
    $('.nav_link').click(function() 
    {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') 
         || location.hostname == this.hostname) 
        {
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
            if (target.length) 
            {
                $('html,body').animate({ scrollTop: (target.offset().top - nav_height)}, 850);
                return false;
            }
        }
    });
    
    //exclusive for logo link to top
    $("#lemon_link").click(function()
    {
        if ($(this).css("opacity") == 1)
            $('html,body').animate({ scrollTop: 0 }, 800);
    });
    
    //window scrolled event
    $(window).scroll(function()
    {
        var offset = $(window).scrollTop();
        var height = $("#header").height();
        
        if (offset >= height)
        {
            $("#fill").css("display", "block");
            $("#navbar").addClass("sticky_navbar");
            
            $("#lemon_container").addClass("show");
            $("li.nav_item").addClass("shift-right");
        }
        else
        {
            $("#fill").css("display", "none");
            $("#navbar").removeClass("sticky_navbar");
            
            $("#lemon_container").removeClass("show");
            $("li.nav_item").removeClass("shift-right");
        }
    });
});
