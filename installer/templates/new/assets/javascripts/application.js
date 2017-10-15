import '../stylesheets/application.scss';

import $ from 'jquery';
import {Kitto} from 'kitto';
import fscreen from 'fscreen';

window.jQuery = window.$ = $;

Kitto.start();

var i = null;
$("body").mousemove(function() {
    clearTimeout(i);
    $(".fullscreen-button").addClass("active");
    i = setTimeout('$(".fullscreen-button").removeClass("active");', 1000);
})

$(".fullscreen-button").click(function() {
  var ele = document.getElementById("container");
  fscreen.requestFullscreen(ele);
})
