import React from 'react';
import Widget from '../../assets/javascripts/widget';

import './text.scss';

Widget.mount(class Text extends Widget {
  render() {
    return (
      <div className={this.props.className}>
        <h1 className="title">{this.props.title}</h1>
        <h3>{this.state.text || this.props.text}</h3>
        <p className="more-info">{this.props.moreinfo}</p>
      </div>
    );
  }
});
