/*
 * Widget to display comment style information (avatar, user name, and text)
 * in your dashboards.
 *
 * Usage:
 *
 * Broadcast data in the following format from jobs:
 *
 *   %{
 *     avatar: "http://placehold.it/50x50",
 *     name: "John Smith",
 *     quote: "Dang! Kitto is super awesome!"
 *   }
 *
 * To display in a dashboard:
 *
 *   <div data-widget="Comments"
 *        data-source="blog_comments"
 *        data-title="Blog"
 *        data-moreinfo="mycoolblog.com"></div>
**/

import React from 'react';
import Widget from '../../assets/javascripts/widget';

import './comments.scss';

const placeholder = "http://placehold.it/50x50";

Widget.mount(class Comments extends Widget {
  render() {
    return (
      <div className={this.props.className}>
        <h1 className="title">{this.props.title}</h1>
        <div className="comment-container">
          <h3>
            <img src={this.state.avatar || placeholder} />
            <span className="name">{this.state.name}</span>
          </h3>
          <p className="comment">{this.state.quote}</p>
        </div>
        <p className="more-info">{this.props.moreinfo}</p>
      </div>
    );
  }
});
