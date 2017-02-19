import $ from 'jquery';
import Gridster from 'jquery.gridster';

window.jQuery = window.$ = $;

class Kitto {
  static start() {
    Kitto.initializeGridster().initializeRotator();
  }

  static config(config) {
    if (config) {
      $('.gridster').attr('kitto_config', JSON.stringify(config));
    } else {
      return JSON.parse($('.gridster').attr('kitto_config'));
    }
  }

  static initializeGridster() {
    window.Gridster = Gridster;

    const $gridster = $('.gridster');
    const resolution = $gridster.data('resolution');
    let config = Kitto.calculateGridsterDimensions(resolution);

    Kitto.config(config);

    $gridster.width(config.content_width);

    $('.gridster > ul').gridster({
      widget_margins: config.widget_margins,
      widget_base_dimensions: config.widget_base_dimensions,
    });

    return this;
  }

  static calculateGridsterDimensions(resolution) {
    let config = {};

    config.widget_base_dimensions = [300, 360];
    config.widget_margins = [5, 5];
    config.columns = 4;

    if (resolution == "1080") {
      config.widget_base_dimensions = [370, 340];
      config.columns = 5;
    }

    config.content_width =
      (config.widget_base_dimensions[0] +
       config.widget_margins[0] * 2) * config.columns;

    return config;
  }

  // Rotates between dashboards
  // See: https://github.com/kittoframework/kitto/wiki/Cycling-Between-Dashboards
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

let Widget = require('./widget').default;
let Helpers = require('./helpers').default;

export {Kitto, Widget, Helpers};
