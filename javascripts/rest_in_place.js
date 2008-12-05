rest_in_place = function(element, url, objectName, attributeName){
	var e = element;
	
	function clickFunction(){
		var oldValue = e.innerHTML;
		function submitFunction(){
			var value = Form.Element.getValue(e.select('input')[0]);
			e.innerHTML = "saving...";
			new Ajax.Request(url,{
				method: 'put',
				parameters: objectName+'['+attributeName+']='+encodeURIComponent(value)+(window.rails_authenticity_token ? "&authenticity_token="+window.rails_authenticity_token : ''),
				onSuccess: function(transport){
					new Ajax.Request(url, {
						method: 'get',
						requestHeaders: { "Accept" : "application/javascript"},
						onSuccess : function(xhr){
							var data = xhr.responseText.evalJSON();
							e.innerHTML = data[objectName][attributeName];
							Event.observe(e,'click', clickFunction);
						}
					});
				}
			});
			return false;
		}
		e.innerHTML = '<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' + oldValue + '"></form>';
		Form.Element.select(e.select('input')[0]);
		Event.stopObserving(e, 'click', clickFunction);
		Event.observe(e.select('input')[0], 'blur', function(){
			e.innerHTML = oldValue;
			Event.observe(e, 'click', clickFunction);
		});
		Event.observe(e.select('form')[0], 'submit', submitFunction)
	}
	
	Event.observe(e,'click', clickFunction)
}

Event.observe(window, 'load',function() {
	$$(".rest_in_place").each(function(e){
		var url; var obj; var attrib;
		Element.ancestors(e).each(function(a){
			url    = url    || Element.readAttribute(a, 'url');
			obj    = obj    || Element.readAttribute(a, 'object');
			attrib = attrib || Element.readAttribute(a, 'attribute');
		});
		Element.ancestors(e).each(function(a){
			if (res = a.id.match(/^(\w+)_(\d+)$/i)) {
				obj = obj || res[1];
			}
		});
		url    = Element.readAttribute(e, 'url')       || url    || document.location.pathname;
		obj    = Element.readAttribute(e, 'object')    || obj;
		attrib = Element.readAttribute(e, 'attribute') || attrib;
		rest_in_place(e, url, obj, attrib);
	});
});