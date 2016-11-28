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
    $('.gridster > ul').gridster({
      widget_margins: widget_margins,
      widget_base_dimensions: widget_base_dimensions
    });

    return this;
  }

  static initializeRotator() {
    let $rotator = $('.rotator');
    let $dashboards = $rotator.children();

    if (!$rotator) { return this; }

    let current_dashboard_index = 0;
    let dashboard_count = $dashboards.length;
    let interval = $rotator.data('interval') * 1000;

    let rotate = () => {
      $dashboards.hide();
      $($dashboards[current_dashboard_index]).show();

      current_dashboard_index = (current_dashboard_index + 1) % dashboard_count;
    };

    rotate();
    setInterval(rotate, interval);

    return this;
  }
}

Kitto.initializeGridster()
     .initializeRotator();
