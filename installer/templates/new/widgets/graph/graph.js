import ReactDOM from 'react-dom';
import React from 'react';
import 'd3';
import 'rickshaw';
import {Kitto, Widget} from 'kitto';

import './graph.scss';

class Graph extends Widget {
  static get defaultProps() {
    return { graphType: 'area' };
  }

  componentDidMount() {
    this.$node = $(ReactDOM.findDOMNode(this));
    this.current = 0;
    this.renderGraph();
  }
  renderGraph() {
    let container = this.$node.parent();
    let $gridster = $('.gridster');
    let config = Kitto.config();
    let widget_base_dimensions = config.widget_base_dimensions;
    let width = (widget_base_dimensions[0] *
                 container.data('sizex')) + 5 * 2 * (container.data('sizex') - 1);
    let height = (widget_base_dimensions[1] * container.data('sizey'));

    this.graph = new Rickshaw.Graph({
      element: this.$node[0],
      width: width,
      height: height,
      renderer: this.props.graphType,
      series: [{color: '#fff', data: [{ x: 0, y: 0 }]}]
    });

    new Rickshaw.Graph.Axis.Time({ graph: this.graph });
    new Rickshaw.Graph.Axis.Y({ graph: this.graph,
                                tickFormat: Rickshaw.Fixtures.Number.formatKMBT });
    this.graph.render();
  }
  componentWillUpdate(_props, state) {
    this.graph.series[0].data = state.points;
    this.current = state.points[state.points.length -1].y;
    this.graph.render();
  }
  currentValue() {
    return this.prettyNumber(this.prepend(this.current));
  }
  render() {
    return (
      <div className={this.props.className}>
        <h1 className="title">{this.props.title}</h1>
        <h2 className="value">{this.currentValue()}</h2>
        <p className="more-info">{this.props.moreinfo}</p>
      </div>
    );
  }
};

Widget.mount(Graph);
export default Graph;
