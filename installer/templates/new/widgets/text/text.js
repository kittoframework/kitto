import React from 'react';
import Widget from '../../assets/javascripts/widget';

import './text.scss';

Widget.mount(class Text extends Widget {
  render() {
    return (
      <div className={this.state.classname || this.props.className}>
        <h1 className="title">{this.state.title || this.props.title}</h1>
        <h3>{this.state.text || this.props.text}</h3>
        <p className="more-info">{this.state.moreinfo || this.props.moreinfo}</p>
      </div>
    );
  }
});
