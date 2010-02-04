function RestInPlaceEditor(e) {
  this.element = jQuery(e);
  this.initOptions();
  this.bindForm();
  
  this.element.bind('click', {editor: this}, this.clickHandler);
}

RestInPlaceEditor.prototype = {
  // Public Interface Functions //////////////////////////////////////////////
  
  activate : function() {
    this.oldValue = this.element.html();    
    this.element.unbind('click', this.clickHandler)
    this.activateForm();
  },
  
  abort : function() {
    this.element
      .html(this.oldValue)
      .bind('click', {editor: this}, this.clickHandler);
  },
  
  update : function() {
    var editor = this;
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
  },
  
  activateForm : function() {
    alert("The form was not properly initialized. activateForm is unbound");
  },
  
  // Helper Functions ////////////////////////////////////////////////////////
  
  initOptions : function() {
    // Try parent supplied info
    var self = this;
    self.element.parents().each(function(){
      self.url           = self.url           || jQuery(this).attr("data-url");
      self.formType      = self.formType      || jQuery(this).attr("data-formtype");
      self.objectName    = self.objectName    || jQuery(this).attr("data-object");
      self.attributeName = self.attributeName || jQuery(this).attr("data-attribute");
    });
    // Try Rails-id based if parents did not explicitly supply something
    self.element.parents().each(function(){
      var res;
      if (res = this.id.match(/^(\w+)_(\d+)$/i)) {
        self.objectName = self.objectName || res[1];
      }
    });
    // Load own attributes (overrides all others)
    self.url           = self.element.attr("data-url")       || self.url      || document.location.pathname;
    self.formType      = self.element.attr("data-formtype")  || self.formtype || "input";
    self.objectName    = self.element.attr("data-object")    || self.objectName;
    self.attributeName = self.element.attr("data-attribute") || self.attributeName;
  },
  
  bindForm : function() {
    this.activateForm = RestInPlaceEditor.forms[this.formType].activateForm;
    this.getValue     = RestInPlaceEditor.forms[this.formType].getValue;
  },
  
  getValue : function() {
    alert("The form was not properly initialized. getValue is unbound");    
  },
  
  /* Generate the data sent in the POST request */
  requestData : function() {
    //jq14: data as JS object, not string.
    var data = "_method=put";
    data += "&"+this.objectName+'['+this.attributeName+']='+encodeURIComponent(this.getValue());
    if (window.rails_authenticity_token) {
      data += "&authenticity_token="+encodeURIComponent(window.rails_authenticity_token);
    }
    return data;
  },
  
  ajax : function(options) {
    options.url = this.url;
    options.beforeSend = function(xhr){ xhr.setRequestHeader("Accept", "application/json"); };
    return jQuery.ajax(options);
  },

  // Handlers ////////////////////////////////////////////////////////////////
  
  loadSuccessCallback : function(data) {
    //jq14: data as JS object, not string.
    if (jQuery.fn.jquery < "1.4") data = eval('(' + data + ')' );
    this.element.html(data[this.objectName][this.attributeName]);
    this.element.bind('click', {editor: this}, this.clickHandler);    
  },
  
  clickHandler : function(event) {
    event.data.editor.activate();
  }
}


RestInPlaceEditor.forms = {
  "input" : {
    /* is bound to the editor and called to replace the element's content with a form for editing data */
    activateForm : function() {
      this.element.html('<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' + this.oldValue + '"></form>');
      this.element.find('input')[0].select();
      this.element.find("form")
        .bind('submit', {editor: this}, RestInPlaceEditor.forms.input.submitHandler);
      this.element.find("input")
        .bind('blur',   {editor: this}, RestInPlaceEditor.forms.input.inputBlurHandler);
    },
    
    getValue :  function() {
      return this.element.find("input").val();
    },

    inputBlurHandler : function(event) {
      event.data.editor.abort();
    },

    submitHandler : function(event) {
      event.data.editor.update();
      return false;
    }
  },

  "textarea" : {
    /* is bound to the editor and called to replace the element's content with a form for editing data */
    activateForm : function() {
      this.element.html('<form action="javascript:void(0)" style="display:inline;"><textarea>' + this.oldValue + '</textarea></form>');
      this.element.find('textarea')[0].select();
      this.element.find("textarea")
        .bind('blur', {editor: this}, RestInPlaceEditor.forms.textarea.blurHandler);
    },
    
    getValue :  function() {
      return this.element.find("textarea").val();
    },

    blurHandler : function(event) {
      event.data.editor.update();
    }

  }
}

jQuery.fn.rest_in_place = function() {
  this.each(function(){
    jQuery(this).data('restInPlaceEditor', new RestInPlaceEditor(this));
  })
  return this;
}