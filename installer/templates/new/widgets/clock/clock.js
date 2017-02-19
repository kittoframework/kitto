import React from 'react';
import {Widget} from 'kitto';

import './clock.scss';

class Clock extends Widget {
  constructor(props) {
    super(props);
    this.state = Clock.dateTime()
    setInterval(this.update.bind(this), 500);
  }
  update() { this.setState(Clock.dateTime()); }
  render() {
    return (
      <div className={this.props.className}>
        <h1 className="date">{this.state.date}</h1>
        <h2 className="time">{this.state.time}</h2>
      </div>
    );
  }
  static formatTime(i) { return i < 10 ? "0" + i : i; }
  static dateTime() {
    var today = new Date(),
        h = today.getHours(),
        m = today.getMinutes(),
        s = today.getSeconds(),
        m = Clock.formatTime(m),
        s = Clock.formatTime(s);

    return {
      time: (h + ":" + m + ":" + s),
      date: today.toDateString(),
    }
  }
};

Widget.mount(Clock);
export default Clock;
