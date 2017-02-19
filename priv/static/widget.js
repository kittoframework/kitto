import ReactDOM from 'react-dom';
import React from 'react';
import Helpers from './helpers';

class Widget extends React.Component {
  constructor(props) {
    super(props);

    this.state = {};
    this.source = (this.props.source || this.constructor.name).toLowerCase();
    Widget.listen(this, this.source);
  }

  static events() {
    if (this._events) { return this._events; }

    this._events = new EventSource(`/events?topics=${this.sources().join()}`);

    this._events.addEventListener('error', (e) => {
      let state = e.currentTarget.readyState;

      if (state === EventSource.CONNECTING || state === EventSource.CLOSED) {

        // Restart the dashboard
        setTimeout((() => window.location.reload()), 5 * 60 * 1000)
      }
    });

    this.bindInternalEvents();

    return this._events;
  }

  static sources() {
    return Array.prototype.map
      .call(document.querySelectorAll('[data-source]'), (el) => el.dataset.source);
  }

  static bindInternalEvents() {
    this._events.addEventListener('_kitto', (event) => {
      let data = JSON.parse(event.data);

      switch (data.message.event) {
        case 'reload':
          if (data.message.dashboard === '*' ||
              document.location.pathname.endsWith(data.message.dashboard)) {
            document.location.reload()
          }

          break;
      }
    });
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

for (var k in Helpers) { Widget.prototype[k] = Helpers[k]; }

export default Widget;
