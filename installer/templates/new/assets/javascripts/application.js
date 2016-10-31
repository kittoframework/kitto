import '../stylesheets/application.scss';

import $ from 'jquery';
import Gridster from 'jquery.gridster';

window.jQuery = window.$ = $;
window.Gridster = Gridster;

class Kitto {
  static initializeGridster() {
    const $gridster = $('.gridster');
    const resolution = $gridster.data('resolution');

    var widget_base_dimensions = [300, 360],
        widget_margins = [5, 5],
        columns = 4,
        content_width;

    if (resolution == "1080") {
      widget_base_dimensions = [370, 340];
      columns = 5;
    }

    $gridster.data('widget_base_dimensions', widget_base_dimensions);
    $gridster.data('columns', columns);

    content_width = (widget_base_dimensions[0] + widget_margins[0] * 2) * columns;

    $gridster.width(content_width);
    $('.gridster ul:first').gridster({
      widget_margins: widget_margins,
      widget_base_dimensions: widget_base_dimensions
    });

    return this;
  }
}

Kitto.initializeGridster();
