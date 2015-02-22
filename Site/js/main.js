$( document ).ready(function(){
    
    /* Constants */
    var nav_height = 80;
        
    /* Events */
    window.onload = setup;
    window.onresize = adjustToResize;
    $(window).scroll(function(){ adjustToScroll(); });
    
    /**
     * @function setup 
     * 
     * Called upon first load.
     * Set header height accordingly,
     * and add classes if scroll is already lower.
     * Do start animations anyways.
     */
    function setup()
    {
        //header height
        $("#header").height(window.innerHeight - nav_height);
        
        //add/drop classes
        adjustToScroll();
        
        //start animations
        $("#title_wrap").addClass("underline-center-out-pre");
        setTimeout( function(){ $("#title_wrap").addClass("underline-center-out-post"); }, 500);
        setTimeout( function(){ $("#phrase").addClass("fadein"); }, 1200);
    }
    
    /**
     * @function adjustToResize
     *
     * Adjusts header's height according to window height.
     * Takes window height and subtracts navbar's height.
     */
    function adjustToResize()
    {   
        $("#header").height(window.innerHeight - nav_height);
    }
    
    /**
     * @function adjustToScroll
     * 
     * Adjusts appropriate classes upon scrolling.
     * If current offset is lower than header's height,
     * add classes to modify navbar.
     * Otherwise, reverse those changes.
     */
    function adjustToScroll()
    {
        var offset = $(window).scrollTop();
        var height = $("#header").height();
        
        if (offset >= height/2)
        {
            $("#lemon_container").addClass("show");
            $("li.nav_item").addClass("shift-right");
        }
        else
        {
            $("#lemon_container").removeClass("show");
            $("li.nav_item").removeClass("shift-right");
        }
        
        if (offset >= height)
        {
            $("#fill").css("display", "block");
            $("#navbar").addClass("sticky_navbar");
        }
        else
        {
            $("#fill").css("display", "none");
            $("#navbar").removeClass("sticky_navbar");
        }
    };
    
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
    
    
    //features nav
    var captionIndex = 0;
    var numCaptions = $("#caption_list li").length;
    $("#content_left").click(function(event)
    {
        event.preventDefault();
        if (captionIndex > 0)
        {
            captionIndex--;
            var left_offset = captionIndex * -100;
            $("#caption_list").css("left", left_offset.toString() + "%");
        }
    });
    $("#content_right").click(function(event)
    {
        event.preventDefault();
        if (captionIndex < numCaptions - 1)
        {
            captionIndex++;
            var left_offset = captionIndex * -100;
            $("#caption_list").css("left", left_offset.toString() + "%");
        }
    });
    $(".content_link").click(function(event)
    {
        event.preventDefault();
        var index = $("a.content_link").index(this);
        var left_offset = index * -100;
        $("#caption_list").css("left", left_offset.toString() + "%");
        
        $(".content_link").removeClass("active");
        $(this).addClass("active");
    });
});
