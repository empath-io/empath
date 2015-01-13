$(function(){

    BrowserDetect.init();

	$('.minifyme').on("navminified", function() { 
		// $('td.expand,th.expand').toggle();
	});

    // Activate all popovers (if NOT mobile)
    if ( !BrowserDetect.isMobile() ) {
        $('[data-toggle="popover"]').popover();
    }

});
 
$.fn.pressEnter = function(fn) {  

    return this.each(function() {  
        $(this).bind('enterPress', fn);
        $(this).keyup(function(e){
            if(e.keyCode == 13)
            {
              $(this).trigger("enterPress");
            }
        })
    });  
 };  

 
function ensureHeightOfSidebar() {
    $('#left-panel').css('height',$('#main').height());
}

BrowserDetect = 
// From http://stackoverflow.com/questions/13478303/correct-way-to-use-modernizr-to-detect-ie
{
    init: function () 
    {
        this.browser = this.searchString(this.dataBrowser) || "Other";
        this.version = this.searchVersion(navigator.userAgent) ||       this.searchVersion(navigator.appVersion) || "Unknown";
    },

    isMobile: function ()
    {
        if (navigator.userAgent.search(/(Android|Touch|iPhone|iPad)/) == -1) {
            return false;
        } else {
            return true;
        }
   
    },

    searchString: function (data) 
    {
        for (var i=0 ; i < data.length ; i++)   
        {
            var dataString = data[i].string;
            this.versionSearchString = data[i].subString;

            if (dataString.indexOf(data[i].subString) != -1)
            {
                return data[i].identity;
            }
        }
    },

    searchVersion: function (dataString) 
    {
        var index = dataString.indexOf(this.versionSearchString);
        if (index == -1) return;
        return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
    },

    dataBrowser: 
    [
        { string: navigator.userAgent, subString: "Chrome",  identity: "Chrome" },
        { string: navigator.userAgent, subString: "MSIE",    identity: "Explorer" },
        { string: navigator.userAgent, subString: "Firefox", identity: "Firefox" },
        { string: navigator.userAgent, subString: "Safari",  identity: "Safari" },
        { string: navigator.userAgent, subString: "Opera",   identity: "Opera" }
    ]
};