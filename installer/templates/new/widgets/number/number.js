import React from 'react';
import Widget from '../../assets/javascripts/widget';
import {updatedAt,
        append,
        prepend,
        shortenedNumber} from '../../assets/javascripts/helpers';

import './number.scss';

Widget.mount(class Number extends Widget {
  constructor(props) {
    super(props);

    this.state = { value: 0 };
    this.lastValue = 0;
  }
  componentWillUpdate(_props, lastState) {
    this.lastValue = this.state.value;
  }
  decorateValue(value) {
    return append(prepend(shortenedNumber(this.state.value), this.props.prefix),
                  this.props.suffix);
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
  render() {
    return (
      <div className={this.props.className}>
        <h1 className="title">{this.props.title}</h1>
        <h2 className="value"> {this.decorateValue(this.state.value)}</h2>
        <p className="more-info">{this.props.moreinfo}</p>
        <p className="change-rate">
          {this.arrow()}<span>{this.difference()}</span>
        </p>
        <p className="updated-at">{updatedAt(this.state.updated_at)}</p>
      </div>
    );
  }
});
