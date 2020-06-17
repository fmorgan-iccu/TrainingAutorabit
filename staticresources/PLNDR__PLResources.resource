function cache_clear() {
    window.location.reload(true);
};

//formatting functions
function formatDate(date) {
     var hours = date.getHours();
     var minutes = date.getMinutes();
     var ampm = hours >= 12 ? 'pm' : 'am';
     hours = hours % 12;
     hours = hours ? hours : 12; // the hour '0' should be '12'
     minutes = minutes < 10 ? '0'+minutes : minutes;
     var strTime = hours + ':' + minutes + ' ' + ampm;
     return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
};

function formatShortDateString(dateString) {
   var mnths = { 
       Jan:"01", Feb:"02", Mar:"03", Apr:"04", May:"05", Jun:"06",
       Jul:"07", Aug:"08", Sep:"09", Oct:"10", Nov:"11", Dec:"12"
   };
   var date = dateString.split(" ");
    
   if (isNaN(mnths[date[1]])) return '';

   return [ mnths[date[1]], date[2], date[5] ].join("/");
};

function formatNumberOrEmpty(numberAsString, numberOfDecimals) {
   if(isNaN(parseFloat(numberAsString))){
       return '';
   }
       
   return parseFloat(numberAsString).toFixed(numberOfDecimals);
};

function formatCurrencyOrEmpty(numberAsString) {
   if (isNaN(parseFloat(numberAsString))){
       return '';
   }

   var numberValue = parseFloat(numberAsString);
   var textValue = Math.round(numberValue).toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
   if(numberValue >= 0){
       return '$' + textValue;
   } else {
       return '\($' + textValue.replace(/-(?=\d)/,"") + '\)';                   
   }   
};

$(function(){ //page load

    setInterval(cache_clear,360000); //6 minutes                

    $('.dateFormat').each(function(){
        var $this = $(this);
        var thisText = $this.text();
        var date = new Date(thisText);
        $this.text(formatDate(date));
    });  
    
    $('.shortDate').each(function(){
        var $this = $(this);
        var thisText = $this.text();
        $this.text(formatShortDateString(thisText));
    });
    
    $('.decimal-three').each(function(){
        var $this = $(this);
        var formattedPct = formatNumberOrEmpty($this.text(), 3);
        formattedPct = formattedPct == '' ? formattedPct : formattedPct + '%';
        $this.text(formattedPct);
    });
        
    $('.decimal').each(function(){
        var $this = $(this);
        var formattedPct = formatNumberOrEmpty($this.text(), 2);
        formattedPct = formattedPct == '' ? formattedPct : formattedPct + '%';
        $this.text(formattedPct);
    });

    $('.currency').each(function(){
        var $this = $(this);
        var thisText = $this.text();
        var formattedCurrency = formatCurrencyOrEmpty(thisText);
        $this.text(formattedCurrency);
    });
    
    $('.number').each(function(){
        var $this = $(this);
        var thisText = $this.text();
        var formattedValue = formatNumberOrEmpty(thisText, 0);
        $this.text(formattedValue)
    });
        
    $('.slds-tabs__item').on('click', function(){
        var $this = $(this);
        var $a = $this.find('a');
        var $siblings = $this.siblings();

        $this.addClass('slds-active');
        $a.attr('aria-selected', true);
        
        var ariaControlsId = $a.attr('aria-controls');
        var $contentToShow = $('#'+ariaControlsId);
        $contentToShow.removeClass('slds-hide').addClass('slds-show');

        $siblings.removeClass('slds-active');
        $siblings.find('a').attr('aria-selected', false);

        $contentToShow.siblings('.slds-tabs__content')
            .removeClass('slds-show')
            .addClass('slds-hide'); 
    }); 
   		
});