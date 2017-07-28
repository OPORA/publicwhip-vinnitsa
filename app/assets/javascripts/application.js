// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
// require_tree .
//-Fix bug back return js code
$(window).on("popstate", function(e) {
    history.back();
});
//----
$('button.btn.glyphicon').click(function () {
    if($(this).hasClass('glyphicon-chevron-down'))
    {
        $(this).removeClass('btn glyphicon glyphicon-chevron-down');
        $(this).addClass('btn glyphicon glyphicon-chevron-up');
    }
    else {
        $(this).removeClass('btn glyphicon glyphicon-chevron-up');
        $(this).addClass('btn glyphicon glyphicon-chevron-down');
    }
});
/*!
 * IE10 viewport hack for Surface/desktop Windows 8 bug
 * Copyright 2014-2015 Twitter, Inc.
 * Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
 */

// See the Getting Started docs for more information:
// http://getbootstrap.com/getting-started/#support-ie10-width

(function () {
    'use strict';

    if (navigator.userAgent.match(/IEMobile\/10\.0/)) {
        var msViewportStyle = document.createElement('style')
        msViewportStyle.appendChild(
            document.createTextNode(
                '@-ms-viewport{width:auto!important}'
            )
        )
        document.querySelector('head').appendChild(msViewportStyle)
    }

})();


function CreateRadialBar( wrapper ) {

    var border = wrapper.dataset.trackWidth;
    var strokeSpacing = wrapper.dataset.strokeSpacing;
    var start = 0;
    var end = parseFloat(wrapper.dataset.percentage);
    var radius = 100;
    var endAngle = Math.PI * 2;
    var formatText = d3.format('.0%');
    var boxSize = radius * 2;
    var count = end;
    var progress = start;
    var step = end < start ? -0.01 : 0.01;
    var colours = {
        fill: '#' + wrapper.dataset.fillColour,
        track: '#' + wrapper.dataset.trackColour,
        text: '#' + wrapper.dataset.textColour,
        stroke: '#' + wrapper.dataset.strokeColour,
    };


    //Define the circle
    var circle = d3.svg.arc()
        .startAngle(0)
        .innerRadius(radius)
        .outerRadius(radius - border);

    //setup SVG wrapper
    var svg = d3.select(wrapper)
        .append('svg')
        .attr('width', boxSize)
        .attr('height', boxSize);

    // ADD Group container
    var g = svg.append('g')
        .attr('transform', 'translate(' + boxSize / 2 + ',' + boxSize / 2 + ')');

    //Setup track
    var track = g.append('g').attr('class', 'radial-progress');
    track.append('path')
        .attr('class', 'radial-progress__background')
        .attr('fill', colours.track)
        .attr('stroke', colours.stroke)
        .attr('stroke-width', strokeSpacing + 'px')
        .attr('d', circle.endAngle(endAngle));

    //Add colour fill
    var value = track.append('path')
        .attr('class', 'radial-progress__value')
        .attr('fill', colours.fill)
        .attr('stroke', colours.stroke)
        .attr('stroke-width', strokeSpacing + 'px');

    //Add text value
    var numberText = track.append('text')
        .attr('class', 'radial-progress__text')
        .attr('fill', colours.text)
        .attr('text-anchor', 'middle')
        .attr('dy', '.5rem');

    function update(progress) {
        //update position of endAngle
        value.attr('d', circle.endAngle(endAngle * progress));
        //update text value
        numberText.text(formatText(progress));
    }

    (function iterate() {
        //call update to begin animation
        update(progress);
        if (count > 0) {
            //reduce count till it reaches 0
            count--;
            //increase progress
            progress += step;
            //Control the speed of the fill
            setTimeout(iterate, 10);
        }
    })();
}
