import React from 'react';
import {Widget} from 'kitto';

import './image.scss';

const placeholder = '/assets/images/placeholder.png';

class Image extends Widget {
  image() {
    return {
      backgroundImage: `url(${this.state.image || placeholder})`
    };
  }
  render() {
    return (
      <div style={this.image()} className={this.props.className}></div>
    );
  }
};

Widget.mount(Image);
export default Image;
