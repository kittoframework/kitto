import React from 'react';
import {Widget} from 'kitto';

import './number.scss';

class Number extends Widget {
  constructor(props) {
    super(props);

    this.state = { value: 0 };
    this.lastValue = 0;
  }
  componentWillUpdate(_props, lastState) {
    this.lastValue = this.state.value;
  }
  decorateValue(value) {
    let number = this.shortenedNumber(this.state.value);

    return this.append(this.prepend(number, this.props.prefix), this.props.suffix);
  }
  arrow() {
    if (this.state.value > this.lastValue) {
      return (<i className="fa fa-arrow-up"></i>);
    } else {
      return (<i className="fa fa-arrow-down"></i>);
    }
  }
  difference() {
    if (this.lastValue && this.lastValue !== 0) {
      let normalized = (this.state.value - this.lastValue) / this.lastValue * 100;
      return `${Math.abs(Math.round(normalized))}%`
    } else {
      return '';
    }
  }
  changeRate() {
    if (this.props.changerate == "off") { return; }

    return (
      <p className="change-rate">
        {this.arrow()}<span>{this.difference()}</span>
      </p>
    );
  }
  render() {
    return (
      <div className={this.props.className}>
        <h1 className="title">{this.props.title}</h1>
        <h2 className="value"> {this.decorateValue(this.state.value)}</h2>
        <p className="more-info">{this.props.moreinfo}</p>
        {this.changeRate()}
        <p className="updated-at">{this.updatedAt(this.state.updated_at)}</p>
      </div>
    );
  }
};

Widget.mount(Number);
export default Number;
