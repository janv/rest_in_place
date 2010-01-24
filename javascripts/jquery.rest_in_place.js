function RestInPlaceEditor(e) {
  this.element = jQuery(e);
  this.initOptions();
  
  this.element.bind('click', {editor: this}, this.clickHandler);
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
  },
  
  loadSuccessCallback : function(data) {
    //jq14: data as JS object, not string.
    if (jQuery.fn.jquery < "1.4") data = eval('(' + data + ')' );
    this.element.html(data[this.objectName][this.attributeName]);
    this.element.click(this.clickHandler);    
  },
  
  ajax : function(options) {
    options.url = this.url;
    options.beforeSend = function(xhr){ xhr.setRequestHeader("Accept", "application/json"); };
    return jQuery.ajax(options);
  },
  
  clickHandler : function(event) {
    var editor = event.data.editor;
    editor.oldValue = editor.element.html();
    
    editor.element.html('<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' + editor.oldValue + '"></form>')
    editor.element.find("input")[0].select();
    editor.element.unbind('click', editor.clickHandler)
    editor.element.find("input").bind('blur',  {editor: editor}, editor.inputBlurHandler);
    editor.element.find("form").bind('submit', {editor: editor}, editor.submitHandler)
  },

  inputBlurHandler : function(event) {
    var editor   = event.data.editor;
    editor.element
      .html(editor.oldValue)
      .bind('click', {editor: editor}, editor.clickHandler);
  },
  
  submitHandler : function(event) {
    var editor = event.data.editor;
    editor.ajax({
      "type"       : "post",
      "dataType"   : "text",
      "data"       : editor.requestData(),
      "success"    : function(){
        editor.ajax({
          "success" : function(data){ editor.loadSuccessCallback(data) }
        });
      }
    });
    editor.element.html("saving...");
    return false;
  }
}


jQuery.fn.rest_in_place = function() {
  this.data('restInPlaceEditor', new RestInPlaceEditor(this));
  return this;
}