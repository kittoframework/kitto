import React from 'react';
import Widget from '../../assets/javascripts/widget';
import {updatedAt} from '../../assets/javascripts/helpers';

import './text.scss';

Widget.mount(class Text extends Widget {
  render() {
    let status = "";
    if (this.state.widgetStatus) {
      status = this.state.widgetStatus;
    }
    return (
      <div className={`${this.props.className} ${status}`}>    
        <h1 className="title">{this.state.title || this.props.title}</h1>
        <h3>{this.state.text || this.props.text}</h3>
        <p className="more-info">{this.state.moreinfo || this.props.moreinfo}</p>
        <p className="updated-at">{updatedAt(this.state.updated_at)}</p>
      </div>
    );
  }
});