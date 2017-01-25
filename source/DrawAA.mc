// DrawAA
// --------------------------------

// This is a (poorly optimised) implementation of Xiaolin Wu's line algorithm:
// https://en.wikipedia.org/wiki/Xiaolin_Wu%27s_line_algorithm
//
// Currently only a proof-of-concept, and as such, only works
// for grayscale lines on dark backgrounds
//
// drawAA = new DrawAA();
// drawAA.drawLine(dc, x0, y0, x1, y1);
// drawAA.drawPoly(dc, poly[], offsetx, offsety);

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;

class DrawAA {

      // draw AA line from (x0,y0) to (x1,y1) on bitmap (dc)
      function drawLine(bitmap, x0, y0, x1, y1) {

        var temp;

        // line direction
        var steep = ((y1-y0).toLong().abs()) > ((x1-x0).toLong().abs());

        // swap x->y co-ords if non-positive direction
        if (steep) {
            temp = x0;
            x0 = y0;
            y0 = temp;
            temp = x1;
            x1 = y1;
            y1 = temp;
        }

        // swap 0->1 co-ords to draw in the right order
        if (x0>x1) {
            temp = x0;
            x0 = x1;
            x1 = temp;
            temp = y0;
            y0 = y1;
            y1 = temp;
        }

        var dx = x1-x0;
        var dy = y1-y0;
        var gradient = (dy.toFloat() + 0.0001) / (dx.toFloat() + 0.0001);

        // draw first endpoint
        var xEnd = round(x0);
        var yEnd = y0+gradient*(xEnd-x0);
        var xGap = rfpart(x0+0.5);
        var xPixel1 = xEnd;
        var yPixel1 = ipart(yEnd);
        if (steep) {
            drawPointAA(bitmap, yPixel1,   xPixel1, rfpart(yEnd)*xGap);
            drawPointAA(bitmap, yPixel1+1, xPixel1,  fpart(yEnd)*xGap);
        } else {
            drawPointAA(bitmap, xPixel1,yPixel1, rfpart(yEnd)*xGap);
            drawPointAA(bitmap, xPixel1, yPixel1+1, fpart(yEnd)*xGap);
        }
        var intery = yEnd+gradient;

        // draw second endpoint
        xEnd = round(x1);
        yEnd = y1 + gradient * (xEnd-x1);
        xGap = fpart(x1+0.5);
        var xPixel2 = xEnd;
        var yPixel2 = ipart(yEnd);
        if (steep) {
            drawPointAA(bitmap, yPixel2,   xPixel2, rfpart(yEnd)*xGap);
            drawPointAA(bitmap, yPixel2+1, xPixel2, fpart(yEnd)*xGap);
        } else {
            drawPointAA(bitmap, xPixel2, yPixel2, rfpart(yEnd)*xGap);
            drawPointAA(bitmap, xPixel2, yPixel2+1, fpart(yEnd)*xGap);
        }

        // draw the remainder of the line
        if (steep) {
            for(var x=xPixel1+1; x<=xPixel2-1; x++){
                drawPointAA(bitmap, ipart(intery), x, rfpart(intery));
                drawPointAA(bitmap, ipart(intery)+1, x, fpart(intery));
                intery+=gradient;
            }
        } else {
            for(var x=xPixel1+1; x<=xPixel2-1; x++){
                drawPointAA(bitmap, x,ipart(intery), rfpart(intery));
                drawPointAA(bitmap, x, ipart(intery)+1, fpart(intery));
                intery+=gradient;
            }
        }
      }

      // draw AA polygon (unfilled) from an array of (points) from offset (x,y) on bitmap (dc)
      function drawPoly(dc, points, x, y) {

        for(var p=0; p < points.size()-1; p++) {
          drawLine(dc, points[p][0]+x, points[p][1] + y, points[p+1][0] + x, points[p+1][1] + y);
        }

      }


      // helper functions for drawLine
      function ipart(x) {
          return Math.floor(x).toFloat();
      }

      function round(x) {
          return ipart(x + 0.5);
      }

      function fpart(x) {
          return x - ipart(x);
      }

      function rfpart(x) {
          return 1 - fpart(x);
      }

      // draw a pixel at x,y with intensity between 0 and 1
      function drawPointAA(dc, x, y, intensity) {

        if (intensity >= 0.75) {
          dc.setColor(Gfx.COLOR_WHITE,0);
        } else if (intensity >= 0.5) {
          dc.setColor(Gfx.COLOR_LT_GRAY,0);
        } else {
          dc.setColor(Gfx.COLOR_DK_GRAY,0);
        }

        dc.drawPoint(x, y);

      }

}
