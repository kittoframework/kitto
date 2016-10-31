import React from 'react';
import Widget from '../../assets/javascripts/widget';
import {updatedAt,truncate} from '../../assets/javascripts/helpers';

import './list.scss';

class ListItem extends React.Component {
  render() {
    return (
      <li>
        <span className="label">
          {truncate(this.props.label, this.props.labelLength || 80)}
        </span>
        <span className="value">
          {truncate(this.props.value, this.props.valueLength)}
        </span>
      </li>
    );
  }
}

export class List extends Widget {
  renderItems(items) {
    return items.map((item, i) => {
      return <ListItem key={i}
                       label={item.label}
                       value={item.value}
                       labelLength={+this.props.labelLength}
                       valueLength={+this.props.valueLength}/>;
    });
  }
  renderList(items) {
    return this.props.unordered ? <ul>{items}</ul> : <ol>{items}</ol>;
  }
  render() {
    return (
      <div className={this.props.className}>
        <h1 className="title">{this.props.title}</h1>
        <h3>{this.props.text}</h3>
        <ul>
          {this.renderList(this.renderItems(this.state.items || []))}
        </ul>
        <p className="more-info">{this.props.moreinfo}</p>
        <p className="updated-at">{updatedAt(this.state.updated_at)}</p>
      </div>
    );
  }
};

Widget.mount(List);
