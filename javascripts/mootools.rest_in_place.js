var RestInPlace = new Class({

  Binds: ['onClick', 'onSubmit'], // uses Bind Mutator (http://www.clientcide.com/code-releases/classbinds-for-mootols-is-back/)

  initialize: function(element) {
    this.element = $(element);
    this.elements = [this.element].extend(this.element.getParents()); // element with parents
    this.element.addEvent('click', this.onClick);
  },

  onClick: function() {
    this.element.removeEvent('click', this.onClick)
    var value = this.element.get('text');

    var form = new Element('form', { styles: { display: 'inline' } });
    var input = new Element('input', {
      type: 'text',
      value: value,
      events: {
        blur: function() {
          this.element.set('html', value);
          this.element.addEvent('click', this.onClick);
        }.bind(this)
      }
    });
    this.element.empty().grab(form.grab(input));
    input.focus()
    form.addEvent('submit', this.onSubmit);
  },

  onSubmit: function(e) {
    e.preventDefault();
    var value = this.element.getElement('input').get('value');
    this.element.set('html', 'saving...')

    var object = this.getOption('object') || this.getObjectFromId();
    var attribute = this.getOption('attribute');
    var url = this.getOption('url') || document.location.pathname;
    new Request.HTML({
      url: url,
      method: 'put',
      onSuccess: function() {
        new Request.JSON({
          url: url,
          method: 'get',
          onSuccess: function(json) {
            this.element.set('html', json[object][attribute]);
            this.element.addEvent('click', this.onClick);
          }.bind(this)
        }).setHeader('Accept', 'application/javascript').send();
      }.bind(this)
    }).send(object + '[' + attribute +']=' + encodeURIComponent(value) + (window.rails_authenticity_token ? "&authenticity_token="+encodeURIComponent(window.rails_authenticity_token) : ''));
  },

  getOption: function(name) {
    for( var i = 0; i < this.elements.length; i++ ) if( property = this.elements[i].getProperty(name) ) return property;
  },

  getObjectFromId: function() {
    var parents = this.element.getParents();
    for( var i = 0; i < parents.length; i++ ) if(match = parents[i].id.match(/^(\w+)_(\d+)$/i)) return match[1];
  }

});

window.addEvent('domready', function() {
  $$('.rest_in_place').each(function(field) { new RestInPlace(field); });
});