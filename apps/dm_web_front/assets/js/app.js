// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/updates", Socket)
liveSocket.connect()

var popOverSettings = {
    trigger: 'hover',
    placement: 'auto',
    container: 'body',
    html: true,
    selector: '[data-toggle="popover"]', //Sepcify the selector here
    content: function () {
        return $('#popover-content').html();
    }
}

$('body').popover(popOverSettings);

$("#line_filter").on("keyup", function () {
    var value = $(this).val().toLowerCase();
    $("#lines tr").filter(function () {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
});