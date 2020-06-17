$(function(){

		$(document).ready(function(){
 			setInterval(function(){cache_clear()},360000);                 
 		});
 		function cache_clear()
		{
 			window.location.reload(true);
		}
    
    function formatDate(date) {
  		var hours = date.getHours();
  		var minutes = date.getMinutes();
  		var ampm = hours >= 12 ? 'pm' : 'am';
  		hours = hours % 12;
  		hours = hours ? hours : 12; // the hour '0' should be '12'
  		minutes = minutes < 10 ? '0'+minutes : minutes;
  		var strTime = (hours) + ':' + minutes + ' ' + ampm;
  		return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
	};
    
     
   function formatShortDateString(dateString) {
    var mnths = { 
        Jan:"01", Feb:"02", Mar:"03", Apr:"04", May:"05", Jun:"06",
        Jul:"07", Aug:"08", Sep:"09", Oct:"10", Nov:"11", Dec:"12"
    },
   date = dateString.split(" ");

    return [ mnths[date[1]], date[2], date[5] ].join("/");
};

    //formatting functions
    	$('.dateFormat').each(function(){
        	var date = new Date($(this).text());
        	$(this).text(formatDate(date));
    	});  
    
    $('.shortDate').each(function(){
        $(this).text(formatShortDateString($(this).text()));
    });
    
        $('.decimal-three').each(function(){
            if(isNaN(parseFloat($(this).text()))){
                $(this).text('');
            }
            else{
                $(this).text(parseFloat($(this).text()).toFixed(3) + '%');
            }
            
            });
        
        $('.decimal').each(function(){
            if(isNaN(parseFloat($(this).text()))){
                $(this).text('');
            }
            else{
                $(this).text(parseFloat($(this).text()).toFixed(2) + '%');
            }
            
            });
        $('.currency').each(function(){
            if(isNaN(parseFloat($(this).text()))){
                $(this).text('');
            }
            else{
                var numberValue = parseFloat($(this).text());
                if(numberValue >= 0){
                    $(this).text('$' + (Math.round(numberValue).toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,"))); 
                    
                }
                else{
                    var textValue = Math.round(numberValue).toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
                    $(this).text('\($' + textValue.replace(/-(?=\d)/,"") + '\)');                   
                }           	   
            }
            });
    
    $('.number').each(function(){
        if(isNaN(parseInt($(this).text()))){
            $(this).text('');
        }
        else{
            $(this).text(parseInt($(this).text()));
        }
    });
        
        $('.slds-tabs__item').on('click', function(){
        	$(this).addClass('slds-active');
        	$(this).find('a').attr('aria-selected', true);
        	var $contentToShow = $('#'+$(this).find('a').attr('aria-controls'));
        	$contentToShow.removeClass('slds-hide');
        	$contentToShow.addClass('slds-show');

        	$(this).siblings().removeClass('slds-active');
        	$(this).siblings().find('a').attr('aria-selected', false);
        	$contentToShow.siblings('.slds-tabs__content').removeClass('slds-show');
        	$contentToShow.siblings('.slds-tabs__content').addClass('slds-hide');          
            
    }); 
    
     		
});