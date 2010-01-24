var rest_in_place = {
  "main" :  function() {
    var e = this;
    var options = rest_in_place.resolveOptionsFor(e)

    function clickHandler() {
      var oldValue = e.html();
      e.html('<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' + oldValue + '"></form>')
      e.find("input")[0].select();
      e.unbind('click', clickHandler)
      e.find("input").blur(function inputBlurHandler(){
        e.html(oldValue).click(clickHandler);
      })
      e.find("form").submit(function submitHandler(){
        jQuery.ajax({
          "url"        : options.url,
          "type"       : "post",
          "dataType"   : "text",
          "beforeSend" : function(xhr){ xhr.setRequestHeader("Accept", "application/json"); },
          "data"       : rest_in_place.requestData(options, e.find("input").val()),
          "success"    : function saveSuccessCallback(data, textStatus){
            jQuery.ajax({
              "url"        : options.url,
              "beforeSend" : function(xhr){ xhr.setRequestHeader("Accept", "application/json"); },
              "success"    : function loadSuccessCallback(data){
                //jq14: data as JS object, not string.
                if (jQuery.fn.jquery < "1.4") data = eval('(' + data + ')' );
                e.html(data[options.objectName][options.attributeName]);
                e.click(clickHandler);
              }
            });
          }
        });
        e.html("saving...");
        return false;
      })
    }
    this.click(clickHandler);
    return this;
  },

  "resolveOptionsFor" :  function(e){
    var url, objectName, attributeName;
    // Try parent supplied info
    e.parents().each(function(){
      url           = jQuery(this).attr("data-url");
      objectName    = jQuery(this).attr("data-object");
      attributeName = jQuery(this).attr("data-attribute");
    });
    // Try Rails-id based if parents did not explicitly supply something
    e.parents().each(function(){
      var res;
      if (res = this.id.match(/^(\w+)_(\d+)$/i)) {
        objectName = objectName || res[1];
      }
    });
    // Load own attributes (overrides all others)
    url           = e.attr("data-url")       || url    || document.location.pathname;
    objectName    = e.attr("data-object")    || objectName;
    attributeName = e.attr("data-attribute") || attributeName;

    return {"url"     : url,
      "objectName"    : objectName,
      "attributeName" : attributeName};
  },
  
  "requestData" : function(options, value) {
    //jq14: data as JS object, not string.
    var data = "_method=put"
    data += "&"+options.objectName+'['+options.attributeName+']='+encodeURIComponent(value);
    if (window.rails_authenticity_token) {
      data += "&authenticity_token="+encodeURIComponent(window.rails_authenticity_token);
    }
    return data;
  }
}

jQuery.fn.rest_in_place = rest_in_place.main;
