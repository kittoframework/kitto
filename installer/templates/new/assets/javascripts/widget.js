import ReactDOM from 'react-dom';
import React from 'react';

class Widget extends React.Component {
  constructor(props) {
    super(props);

    this.state = {};
    this.source = (this.props.source || this.constructor.name).toLowerCase();
    this.listen(this.source);
  }
  listen(source) {
    this.events = new EventSource('/events');
    this.events.addEventListener((source.toLowerCase() || 'messages'), function(event) {
      this.setState(JSON.parse(event.data).message);
    }.bind(this));
  }
  static mount(component) {
    const widgets = document.querySelectorAll(`[data-widget="${component.name}"]`)

    Array.prototype.forEach.call(widgets, function(el) {
      var dataset = el.dataset;

      dataset.className = `${el.className} widget-${component.name.toLowerCase()} widget`;
      ReactDOM.render(React.createElement(component, dataset), el.parentNode);
    });
  }
}

export default Widget;
