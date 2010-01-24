jQuery.fn.rest_in_place = function() {
  var e = this;
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
  
  function clickFunction() {
    var oldValue = e.html();
    e.html('<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' + oldValue + '"></form>')
      .find("input")[0]
        .select();
    e.unbind('click', clickFunction)
      .find("input").blur(function inputBlurHandler(){
        e.html(oldValue)
          .click(clickFunction);
      })
    e.find("form").submit(function submitHandler(){
      var value = e.find("input").val();
      e.html("saving...");
      jQuery.ajax({
        "url" : url,
        "type" : "post",
        "dataType" : "text",
        "beforeSend"  : function(xhr){ xhr.setRequestHeader("Accept", "application/json"); },
        "data" : "_method=put&"+objectName+'['+attributeName+']='+encodeURIComponent(value)+(window.rails_authenticity_token ? "&authenticity_token="+encodeURIComponent(window.rails_authenticity_token) : ''),
        "success" : function saveSuccessCallback(data, textStatus){
          jQuery.ajax({
            "url" : url,
            "beforeSend"  : function(xhr){ xhr.setRequestHeader("Accept", "application/json"); },
            "success" : function loadSuccessCallback(data){
              if (jQuery.fn.jquery < "1.4") {
                data = eval('(' + data + ')' );
              }
              e.html(data[objectName][attributeName]);
              e.click(clickFunction);
            }
          });
        }
      });
      return false;
    })
  }
  this.click(clickFunction);
  return this;
}
