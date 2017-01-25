using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Application as App;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Timer as Timer;

enum {
  SCREEN_SHAPE_CIRC = 0x000001,
  SCREEN_SHAPE_SEMICIRC = 0x000002,
  SCREEN_SHAPE_RECT = 0x000003
}

class BasicView extends Ui.WatchFace {

    // globals
    var debug = false;
    var timer1;
    var timer_timeout = 80;
    var timer_steps = timer_timeout;
    var angle = 0;
    var isAwake = false;
    var drawAA = null;

    // sensors / status
    var battery = 0;
    var bluetooth = true;

    // time
    var hour = null;
    var minute = null;
    var day = null;
    var day_of_week = null;
    var month_str = null;
    var month = null;

    // layout
    var vert_layout = false;
    var canvas_h = 0;
    var canvas_w = 0;
    var canvas_shape = 0;
    var canvas_rect = false;
    var canvas_circ = false;
    var canvas_semicirc = false;
    var canvas_tall = false;
    var canvas_r240 = false;

    // settings
    var set_leading_zero = false;

    // fonts

    // bitmaps
    var b_gauge = null;
    var b_gauge_over = null;

    // animation settings
    var poly_min;
    var poly_hour;
    var centerpoint;

    function initialize() {
     Ui.WatchFace.initialize();
    }


    function onLayout(dc) {

      drawAA = new DrawAA();

      // w,h of canvas
      canvas_w = dc.getWidth();
      canvas_h = dc.getHeight();

      // check the orientation
      if ( canvas_h > (canvas_w*1.2) ) {
        vert_layout = true;
      } else {
        vert_layout = false;
      }

      // let's grab the canvas shape
      var deviceSettings = Sys.getDeviceSettings();
      canvas_shape = deviceSettings.screenShape;

      if (debug) {
        Sys.println(Lang.format("canvas_shape: $1$", [canvas_shape]));
      }

      // find out the type of screen on the device
      canvas_tall = (vert_layout && canvas_shape == SCREEN_SHAPE_RECT) ? true : false;
      canvas_rect = (canvas_shape == SCREEN_SHAPE_RECT && !vert_layout) ? true : false;
      canvas_circ = (canvas_shape == SCREEN_SHAPE_CIRC) ? true : false;
      canvas_semicirc = (canvas_shape == SCREEN_SHAPE_SEMICIRC) ? true : false;
      canvas_r240 =  (canvas_w == 240 && canvas_w == 240) ? true : false;

      // set offsets based on screen type
      // positioning for different screen layouts
      if (canvas_tall) {
      }
      if (canvas_rect) {
      }
      if (canvas_circ) {
        if (canvas_r240) {
        } else {
        }
      }
      if (canvas_semicirc) {
      }


      // w,h of canvas
      var dw = dc.getWidth();
      var dh = dc.getHeight();

      // define the polygon points for the minute and hour hands
      poly_min = [[dw/2,dh/2], [(dw/2)-10,(dh/2)-20], [(dw/2),5], [(dw/2)+10,(dh/2)-20], [dw/2,dh/2] ];
      poly_hour = [[dw/2,dh/2], [(dw/2)-10,(dh/2)-20], [(dw/2),35], [(dw/2)+10,(dh/2)-20], [dw/2,dh/2] ];

      // centerpoint is the middle of the canvas
      centerpoint = [dw/2,dh/2];

    }



    // helper function to rotate point[x,y] around origin[x,y] by (angle)
    function rotatePoint(origin, point, angle) {

      var radians = angle * Math.PI / 180.0;
      var cos = Math.cos(radians);
      var sin = Math.sin(radians);
      var dX = point[0] - origin[0];
      var dY = point[1] - origin[1];

      return [ cos * dX - sin * dY + origin[0], sin * dX + cos * dY + origin[1]];

    }


    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }


    //! Update the view
    function onUpdate(dc) {


      // grab time objects
      var clockTime = Sys.getClockTime();
      var date = Time.Gregorian.info(Time.now(),0);

      // define time, day, month variables
      hour = clockTime.hour;
      minute = clockTime.min;
      day = date.day;
      month = date.month;
      day_of_week = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).day_of_week;
      month_str = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).month;

      // grab battery
      var stats = Sys.getSystemStats();
      var batteryRaw = stats.battery;
      battery = batteryRaw > batteryRaw.toNumber() ? (batteryRaw + 1).toNumber() : batteryRaw.toNumber();

      // do we have bluetooth?
      var deviceSettings = Sys.getDeviceSettings();
      bluetooth = deviceSettings.phoneConnected;

      // 12-hour support
      if (hour > 12 || hour == 0) {
          if (!deviceSettings.is24Hour)
              {
              if (hour == 0)
                  {
                  hour = 12;
                  }
              else
                  {
                  hour = hour - 12;
                  }
              }
      }

      // add padding to units if required
      if( minute < 10 ) {
          minute = "0" + minute;
      }

      if( hour < 10 && set_leading_zero) {
          hour = "0" + hour;
      }

      if( day < 10 ) {
          day = "0" + day;
      }

      if( month < 10 ) {
          month = "0" + month;
      }


      // clear the screen
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
      dc.clear();


      var offsetx = 0;
      var offsety = 0;

      var poly_min_rot = [];
      var poly_hour_rot = [];

      var temp_point = [];

      // rotate the poly_hour[] and poly_min[] hands around the centerpoint[x,y] by (angle)
      for (var u=0; u<poly_hour.size(); u++) {

        temp_point = rotatePoint(centerpoint,poly_hour[u],angle);
        poly_hour_rot.add(temp_point);

        temp_point = rotatePoint(centerpoint,poly_min[u],angle*2);
        poly_min_rot.add(temp_point);

      }

      // draw both the hour and minute hands
      drawAA.drawPoly(dc, poly_min_rot, offsetx, offsety);
      drawAA.drawPoly(dc, poly_hour_rot, offsetx, offsety);


    }





    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    // this is our animation loop callback
    function callback1() {

      // redraw the screen
      Ui.requestUpdate();

      // increment the angle
      angle = angle + 0.5;

      // timer not greater than 500ms? then let's start the timer again
      if (timer_steps < 500) {
        timer1 = new Timer.Timer();
        timer1.start(method(:callback1), timer_steps, false );
      } else {
        // timer exists? stop it
        if (timer1) {
          timer1.stop();
        }
      }


    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {

      // let's start our animation loop
      isAwake = true;

      timer1 = new Timer.Timer();
      timer1.start(method(:callback1), timer_steps, false );

    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {

      isAwake = false;

      // redraw the screen
      Ui.requestUpdate();

      // bye bye timer
      if (timer1) {
        timer1.stop();
      }

      timer_steps = timer_timeout;


    }

}
