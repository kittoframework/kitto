import ReactDOM from 'react-dom';
import React from 'react';

class Widget extends React.Component {
  constructor(props) {
    super(props);

    this.state = {};
    this.source = (this.props.source || this.constructor.name).toLowerCase();
    Widget.listen(this, this.source);
  }

  static events() {
    if (!this._events) {
      this._events = new EventSource('/events');

      this._events.addEventListener('error', (e) => {
        let state = e.currentTarget.readyState;

        if (state === EventSource.CONNECTING || state === EventSource.CLOSED) {

          // Restart the dashboard
          setTimeout((() => window.location.reload()), 5 * 60 * 1000)
        }
      });
    }

    return this._events;
  }

  static listen(component, source) {
    this.events().addEventListener((source.toLowerCase() || 'messages'), (event) => {
      component.setState(JSON.parse(event.data).message);
    });
  }

  static mount(component) {
    const widgets = document.querySelectorAll(`[data-widget="${component.name}"]`)

    Array.prototype.forEach.call(widgets, (el) => {
      var dataset = el.dataset;

      dataset.className = `${el.className} widget-${component.name.toLowerCase()} widget`;
      ReactDOM.render(React.createElement(component, dataset), el.parentNode);
    });
  }
}

export default Widget;
