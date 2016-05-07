import '../stylesheets/application.scss';

import $ from 'jquery';
import Gridster from 'jquery.gridster';

window.jQuery = window.$ = $;
window.Gridster = Gridster;

class App {
  static initializeGridster() {
    const widgetBaseDimensions = [300, 360],
          widgetMargins = [5, 5],
          columns = 4;

    const contentWidth = (widgetBaseDimensions[0] + widgetMargins[0] * 2) * columns;

    $('gridster').width(contentWidth);
    $('.gridster ul:first').gridster({
      widget_margins: [5, 5],
      widget_base_dimensions: [300, 360]
    });

    return this;
  }
  static initializeWidgets() {
    return;
  }
}

$(function() {
  App.initializeGridster()
     .initializeWidgets()
});
