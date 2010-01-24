function RestInPlaceEditor(e) {
  this.element = jQuery(e);
  this.initOptions();
  
  var editor = this;
  
  function clickHandler() {
    var oldValue = editor.element.html();
    editor.element.html('<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' + oldValue + '"></form>')
    editor.element.find("input")[0].select();
    editor.element.unbind('click', clickHandler)
    editor.element.find("input").blur(function inputBlurHandler(){
      editor.element.html(oldValue).click(clickHandler);
    })
    editor.element.find("form").submit(function submitHandler(){
      jQuery.ajax({
        "url"        : editor.url,
        "type"       : "post",
        "dataType"   : "text",
        "beforeSend" : function(xhr){ xhr.setRequestHeader("Accept", "application/json"); },
        "data"       : editor.requestData(),
        "success"    : function saveSuccessCallback(data, textStatus){
          jQuery.ajax({
            "url"        : editor.url,
            "beforeSend" : function(xhr){ xhr.setRequestHeader("Accept", "application/json"); },
            "success"    : function loadSuccessCallback(data){
              //jq14: data as JS object, not string.
              if (jQuery.fn.jquery < "1.4") data = eval('(' + data + ')' );
              editor.element.html(data[editor.objectName][editor.attributeName]);
              editor.element.click(clickHandler);
            }
          });
        }
      });
      editor.element.html("saving...");
      return false;
    })
  }
  editor.element.click(clickHandler);
  
}

RestInPlaceEditor.prototype = {
  initOptions : function() {
    // Try parent supplied info
    var self = this;
    self.element.parents().each(function(){
      self.url           = jQuery(this).attr("data-url");
      self.objectName    = jQuery(this).attr("data-object");
      self.attributeName = jQuery(this).attr("data-attribute");
    });
    // Try Rails-id based if parents did not explicitly supply something
    self.element.parents().each(function(){
      var res;
      if (res = this.id.match(/^(\w+)_(\d+)$/i)) {
        self.objectName = self.objectName || res[1];
      }
    });
    // Load own attributes (overrides all others)
    self.url           = self.element.attr("data-url")       || self.url    || document.location.pathname;
    self.objectName    = self.element.attr("data-object")    || self.objectName;
    self.attributeName = self.element.attr("data-attribute") || self.attributeName;
  },
  
  requestData : function(value) {
    //jq14: data as JS object, not string.
    var data = "_method=put"
    data += "&"+this.objectName+'['+this.attributeName+']='+encodeURIComponent(this.element.find("input").val());
    if (window.rails_authenticity_token) {
      data += "&authenticity_token="+encodeURIComponent(window.rails_authenticity_token);
    }
    return data;
  }
  
}


jQuery.fn.rest_in_place = function() {
  this.data('restInPlaceEditor', new RestInPlaceEditor(this));
  return this;
}