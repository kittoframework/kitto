import React from 'react';
import Widget from '../../assets/javascripts/widget';
import {updatedAt} from '../../assets/javascripts/helpers';

import './text.scss';

Widget.mount(class Text extends Widget {
  status() {
    if (!this.state.status) { return ""; }    
    
    return`status-${this.state.status}`;
  }
  
  render() {
    return (
      <div className={`${this.props.className} ${this.status()}`}>    
        <h1 className="title">{this.state.title || this.props.title}</h1>
        <h3>{this.state.text || this.props.text}</h3>
        <p className="more-info">{this.state.moreinfo || this.props.moreinfo}</p>
        <p className="updated-at">{updatedAt(this.state.updated_at)}</p>
      </div>
    );
  }
});
