// This javascript code implements the drawing interface for the space/time
// drawing.

var use_lorentz;                // Use relativistic instead of Newtonian geometry.
var scene;                      // A collection of all drawable aobjects.
var velocity_ui;                // The current observer's velocity UI.
var time_ui;                    // The current observer's time UI.
var dot_size = 5.0;             // hmm.  magic number.  5 pixel radius.
var z_height = 0.2;
var spacetime_canvas;
var anim_canvas;
var fade_in;                    // Controls fade-in of event on anim canvas.
var icon_list = {};
var icon_left;
var icon_right;
var menu_hover_allowed = true;

// This function is called after the page has loaded.
$(document).ready( function() {
  var colors = new Array( "black", "aqua", "blue", "fuchsia", "gray",
                          "green", "lime", "maroon", "navy", "olive", "purple",
                          "red", "silver", "teal", "white",  "yellow"
                        );
  var text = $('#color_list').html();
  for(var i=0; i < colors.length; i++) {
    text += ("<option value=\""+colors[i]+"\">" + colors[i] + "</option>\n");
  }
  $('#color_list').html(text);
  $('#color_list').prop("value", "black");
  var text = $('#icon_list').html();
  for(var i in icon_list) {
    text += ("<option value=\""+i+"\">" + i + "</option>\n");
  }
  $('#icon_list').html(text);
  $('#icon_list').prop("value", "person");
  properties.add("#color_list", "color");
  properties.add("#icon_list", "icon_name");
  properties.add("#item_name", "name");
  // properties.add("#icon_width", "icon_width");
  properties.add("#clock_check", "clock");
  properties.add("#center_check", "center");
  window.addEventListener('resize', windowResize, false);
  $(window).keydown(handleKeyPress);
  $(".toolbox input").click(function(event) { pickTool(event.target.id); });
  $(".action").click(function(event) { clickAction(event.target.id); });
  $(".player").click(function(event) { clickAction("do_lesson", '',
                                                   event.target.id); });
  $(".menu").hover(function(event) { hover_in(event,">ul"); },
                   function(event) { hover_out(event, ">ul"); });
  $(".menu ul").hover(function(event) { hover_in(event, ">ul"); },
                      function(event) { hover_out(event, ">ul"); });
  $(".menu a").hover(function(event) { hover_in(event, ""); },
                     function(event) { hover_out(event, ""); });
  $(".menu input").hover(function(event) { hover_in(event, ""); },
                         function(event) { hover_out(event, ""); });
  $(".menu ul a").click(menuClicked);

  spacetime_canvas = $("#spacetime_canvas");
  anim_canvas = $("#anim_canvas");
  spacetime_canvas.mousedown(mouse_down_spacetime);
  spacetime_canvas.mousemove(mouse_move_spacetime);
  anim_canvas.mousedown(mouse_down_anim);
  anim_canvas.mousemove(mouse_move_anim);
  $(window).mouseup(mouse_up);

  setup_hotkeys();
  $("#lorentz_check").prop('checked', true);
  $("#lorentz_check").change(lorentzChange);
  $("#view_subtitles").change(subtitleChange);
  velocity_ui = new pairSlider("velocity", setVelocity);
  velocity_ui.range(-0.999, 0.999, true);
  velocity_ui.digits = 3;
  time_ui = new pairSlider("time", setTime);
  time_ui.range(-10, 10);
  $("#dismiss_popup").click(function() { $("#initial_popup").hide(); });
  initialize_document();
  initialize_animation();
  redraw_scene();
});

function initialize_document() {
  var m = window.location.hash.match(/#file=(.*)/);
  var m2 = window.location.hash.match(/#([^\?]+)(\?pause=true)?/);
  if( m ) {
    console.log("Trying to reload an existing file: " + m[1]);
    start_load(m[1]);
  }  else if( m2 ) {
    console.log("Trying to run lesson: " + m2[1] + ", " + m2[2]);
    action_table.newdoc();
    action_table.do_lesson(m2[1], m2[2]);
  } else {
    action_table.newdoc();
  }
}

/******************************************************************************/
function Scene(range) {
  this.velocity = 0.0;
  this.gamma =  1.0;
  this.drawables =  create("list");
  this.scale = 0.1;
  this.center_x = 0.0;
  this.center_t = 4.0;
  this.time = 0.0;
  if( range ) {
    this.center_x = (range.min_x + range.max_x)/2.0;
    this.center_t = (range.min_t + range.max_t)/2.0;
    this.scale = 2.0 / Math.max( range.max_x - range.min_x,
                                 range.max_t - range.min_t);
  }

  // Scale parameters for tick marks.
  this.dt = 0.1;                // major tick marks.
  this.dt2 = 0.2;               // minor tick marks.
  this.min_x = -1.0;
  this.max_x =  1.0;
  this.min_t = -1.0;
  this.max_t =  1.0;
  this.digits = 2;              // how many digits in axis tick labels.

  this.add = function(item) {
    this.drawables.add(item);
    z_height += 0.05;           // pick position in anim canvas.
    if( z_height > 0.8 ) {
      z_height = 0.2;
    }
  }

  this.remove = function(item) {
    this.drawables.remove(item);
  }

  // Pick nice scale for tick marks on axis.
  this.set_range = function(min, max, grid_size) {
    var scale = Math.log(grid_size)/Math.log(10);
    this.dt2 = Math.pow( 10, Math.floor(scale));
    this.dt =  this.dt2 * 10;
    if( grid_size/this.dt2 < 1.5 ) { // Adjust grid size to look nice.
      this.dt = this.dt/2;
      this.dt2 = this.dt2*1;
    } else if( grid_size/this.dt2 > 6.5 ) {
      this.dt = this.dt*2;
      this.dt2 = this.dt2*5;
    } else if( grid_size/this.dt2 > 2.5 ) {
      this.dt = this.dt*1;
      this.dt2 = this.dt2*5;
    } else if( grid_size/this.dt2 > 2.0 ) {
      this.dt = this.dt*1;
      this.dt2 = this.dt2*2;
    }
    this.digits = Math.ceil( -Math.log(this.dt)/Math.log(10));
    if( this.digits < 0 ) {
      this.digits = 0;
    }
    this.min_x = Math.floor(min.x/this.dt)*this.dt; // round min down.
    this.max_x = Math.ceil(max.x/this.dt)*this.dt;  // round max up.
    this.min_t = Math.floor(min.t/this.dt)*this.dt;
    this.max_t = Math.ceil(max.t/this.dt)*this.dt;
  }

  this.update =  function() {
    console.log("Update scene. v = " + scene.velocity);
    for(var item=this.drawables.head; item; item = item.next_ns) {
      item.update();
    }
  }
}
register("scene", "new Scene(arg1)"); // Register as a json serializable object.

function set_new_scene(s) {
  console.log("Here is the new scene:");
  console.log(s);
  if( !s || s.type != "scene" ) s = create("scene", s);
  scene = s;
  selected_item = null;
  $("#lorentz_check").prop('checked', true);
  setVelocity(scene.velocity);
  setTime(scene.time);
  $('#color_list').prop("value", "black");
  $('#icon_list').prop("value", "person");
  $('#item_name').prop("value", "P1");
  $("#clock_check").prop("checked", false);
  $("#center_check").prop("checked", false);
  undo_stack.clear();
  updateTransform();
}

action_table.zoom_in =  function() {
  scene.scale *= 1.20;
  if( scene.scale > 100 ) {
    scene.scale = 100;
  }
  updateTransform();
};

action_table.zoom_out =  function() {
  scene.scale /= 1.20;
  if( scene.scale < 0.01 ) {
    scene.scale = 0.01;
  }
  updateTransform();
};

action_table.reset_view =  function() {
  scene.scale = 0.1;
  scene.center_x = 0.0;
  scene.center_t = 4.0;
  updateTransform();
};

function redraw_scene() {
  if( ! scene )  {
    return;
  }
  var ccon =  spacetime_canvas[0].getContext("2d");
  var acon = anim_canvas[0].getContext("2d");

  ccon.clearRect(0,0, spacetime_canvas.width(), spacetime_canvas.height());
  acon.clearRect(0,0, anim_canvas.width(), anim_canvas.height());

  // The time bar.
  var w = {x:0.0, t: scene.time};
  var s = w2s(w);
  ccon.beginPath();
  ccon.lineWidth = 3;
  ccon.strokeStyle = "#a8a";
  ccon.moveTo( 0, s.y);
  ccon.lineTo( spacetime_canvas.width(), s.y);
  ccon.stroke();

  // Axis grids.
  ccon.beginPath();
  ccon.lineWidth = 1;
  ccon.strokeStyle = "#888";
  acon.beginPath();
  acon.lineWidth = 1;
  acon.strokeStyle = "#888";
  for(w.t = scene.min_t; w.t <= scene.max_t; w.t += scene.dt2) {
    var s = w2s(w);
    ccon.moveTo( 0, s.y);
    ccon.lineTo( spacetime_canvas.width(), s.y);
  }
  for(w.x = scene.min_x; w.x <= scene.max_x; w.x += scene.dt2) {
    var s = w2s(w);
    ccon.moveTo( s.x, 0);
    ccon.lineTo( s.x, spacetime_canvas.height());

    acon.moveTo( s.x, 0);
    acon.lineTo( s.x, anim_canvas.height());
  }
  ccon.stroke();
  acon.stroke();

  // Text on axis grid.
  ccon.beginPath();
  ccon.lineWidth = 1;
  ccon.strokeStyle = "#888";
  acon.beginPath();
  acon.lineWidth = 1;
  acon.strokeStyle = "#888";
  for(w.t = scene.min_t; w.t <= scene.max_t; w.t += scene.dt) {
    var s = w2s(w);
    var text = w.t.toFixed(scene.digits);
    ccon.fillText(text, 2, s.y-2);
  }
  for(w.x = scene.min_x; w.x <= scene.max_x; w.x += scene.dt) {
    var s = w2s(w);
    var text = w.x.toFixed(scene.digits);
    acon.fillText(text, s.x+2, anim_canvas.height() * 0.95);
  }
  ccon.stroke();
  acon.stroke();

  // Selected item.
  if( selected_item ) {
    ccon.beginPath();
    ccon.lineWidth = 3;
    ccon.strokeStyle = "#ff8";
    acon.beginPath();
    acon.lineWidth = 3;
    acon.strokeStyle = "#ff8";
    selected_item.draw(ccon, acon);
    ccon.stroke();
    acon.stroke();
  }

  // All items.
  for(var item=scene.drawables.head; item; item = item.next_ns) {
    ccon.beginPath();
    ccon.lineWidth = 1;
    ccon.strokeStyle = item.color;
    acon.beginPath();
    acon.lineWidth = 1;
    acon.strokeStyle = item.color;
    item.draw(ccon, acon);
    ccon.stroke();
    acon.stroke();
  }
}

/******************************************************************************/
/******************************************************************************/

function hover_in(event, type) {
  if( recording && menu_hover_allowed ) {
    var id = event.target.id || event.target.parentElement.id;
    var element = "#" + id + type;
    if( $(element) && $(element).offset() ) {
      recording.add( create("hover_in", element));
    }
  }
}
function hover_out(event, type) {
  if( recording && menu_hover_allowed ) {
    var id = event.target.id || event.target.parentElement.id;
    if( id ) {
      recording.add( create("hover_out", "#" + id + type));
    } else {
      recording.add( create("hover_out_all", "#menu"));
    }
  }
}
function HoverIn(element) {
  this.element = element;
  this.play = function() {
    $(this.element).addClass("fake_hover");
  }
  this.compute_position = function() {
    var a = $(this.element);
    if( a && a.offset() ) {
      var left = a.offset().left;
      var top = a.offset().top;
      if( left == 0 && top == 0 ) { // currently invisible, use parents intsead.
        left = a.parents().offset().left;
        top = a.parents().offset().top;
      }
      return { x: left + 0.5*a.width(),
               y: top  + 0.5*a.height() };
    } else {
      console.log("POSITION: Hover in 0,0. element = " + this.element);
      return { x: 0, y: 0};
    }
  }
}
function HoverOut(element, all) {
  this.element = element;
  this.all = all;
  this.play = function() {
    if( this.all ) {
      $(".fake_hover").removeClass("fake_hover");
    } else {
      $(this.element).removeClass("fake_hover");
    }
  }
}
register("hover_in", "new HoverIn(arg1)");
register("hover_out", "new HoverOut(arg1)");
register("hover_out_all", "new HoverOut(arg1, true)");

function menuClicked(event) {
  var parent = $(event.target).parents(".menu");
  // Make the menu go away.
  parent.removeClass("allowHover");
  window.setTimeout(function() { parent.addClass("allowHover"); }, 250);
  if( recording ) {
    var id = event.target.id || event.target.parentElement.id;
    recording.add( create("hover_out_all", "#" + id));
  }
}

function AddItem(item) {
  this.item = item;

  this.run = function() {
    scene.add(this.item);
    this.item.update();
    redraw_scene();
  }
  this.undo = function() {
    if( this.item == selected_item ) {
      select_item(null);
    }
    scene.remove(this.item);
    redraw_scene();
  }
}
register("add", "new AddItem(arg1)");

function DeleteSelected(item) {
  this.item = item;

  this.run = function() {
    if( this.item == selected_item ) {
      select_item(null);
    }
    scene.remove(this.item);
    redraw_scene();
  }
  this.undo = function() {
    scene.add(this.item);
    this.item.update();
    select_item(this.item);
    redraw_scene();
  }
}
register("del", "new DeleteSelected(arg1)");

action_table.del =  function() {
  if( selected_item != null ) {
    undo_stack.add(create("del", selected_item));
  }
};

function MoveItem(item, dt, dx, z) {
  if( z < 0 ) z = 0;
  if( z > 1 ) z = 1;
  this.item = item;
  this.old_z = item.z;
  this.dt = dt;
  this.dx = dx;
  this.z = z;

  this.run = function() {
    this.item.move(this.dt, this.dx);
    if( this.z != null ) {
      item.z = this.z;
    }
    this.item.update();
    redraw_scene();
  }
  this.undo = function() {
    this.item.move(-this.dt, -this.dx);
    if( this.z != null ) {
      this.item.z = this.old_z;
    }
    this.item.update();
    redraw_scene();
  }
  this.absorb = function(other) {
    if( this.type == other.type && this.item == other.item) {
      this.old_z = other.old_z;
      this.dt += other.dt;
      this.dx += other.dx;
      return true;
    }
    return false;
  }
}
register("move", "new MoveItem(arg1,arg2, arg3, arg4)");

function MoveScene(dt, dx) {
  this.dt = dt;
  this.dx = dx;

  this.run = function() {
    scene.center_t -= this.dt;
    scene.center_x -= this.dx;
    updateTransform();
    redraw_scene();
  }
  this.undo = function() {
    scene.center_t += this.dt;
    scene.center_x += this.dx;
    updateTransform();
    redraw_scene();
  }
  this.absorb = function(other) {
    if( this.type == other.type && this.item == other.item) {
      this.dt += other.dt;
      this.dx += other.dx;
      return true;
    }
    return false;
  }
}
register("move_scene", "new MoveScene(arg1,arg2)");

function clickAction(id, key, file) {
  if( recording ) {
    recording.add(create("click", "#"+id, key));
  }
  if( action_table[id] ) {
    action_table[id](file);
  }
}

/******************************************************************************/
/******************************************************************************/
var action_hotkeys = {};
var tool_hotkeys = {};
function setup_hotkeys() {
  action_hotkeys['N'] = "newdoc";
  action_hotkeys['S'] = "save";
  action_hotkeys['O'] = "load";
  action_hotkeys['R'] = "reload";

  action_hotkeys['Z'] = "undo";
  action_hotkeys['U'] = "redo";
  // action_hotkeys['X'] = "cut";
  // action_hotkeys['C'] = "copy";
  // action_hotkeys['V'] = "paste";

  action_hotkeys['J'] = "zoom_in";
  action_hotkeys['K'] = "zoom_out";
  // action_hotkeys['F'] = "fit_view";
  action_hotkeys['L'] = "reset_view";

  tool_hotkeys['S'] = "pick";
  tool_hotkeys['E'] = "event";
  tool_hotkeys['I'] = "instant";
  tool_hotkeys['L'] = "location";
  tool_hotkeys['C'] = "cone";
  tool_hotkeys['P'] = "path";

  for( var k in action_hotkeys ) {
    var id = "#" + action_hotkeys[k];
    $(id).text( $(id).text() + "  (Ctrl-"+k+")" );
  }
  for( var k in tool_hotkeys ) {
    var id = "#" + tool_hotkeys[k];
    $(id).prop("title", $(id).prop("title") + "  (key: "+k+")" );
  }
}

function handleKeyPress(event) { // Note: use onkeydown to catch delete key.
  if( event.target.type == "text" ) {
    // Don't do shortcut keys on text input.
    return;
  }
  var key = String.fromCharCode(event.keyCode);
  if( action_hotkeys[key] && event.ctrlKey ) {
    clickAction(action_hotkeys[key], "Ctrl-"+key);
    event.preventDefault();
    return;
  }
  if( tool_hotkeys[key] && !event.ctrlKey ) {
    pickTool(tool_hotkeys[key], key);
    event.preventDefault();
    return;
  }
  if( event.keyCode == 46 ) {   // Delete key.
    action_table.del();
  }

  if( recording ) {
    check_recording_keys(event, key);
  }
}

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
var current_tool = "pick";
function pickTool(new_tool, key) {
  if( recording ) {
    recording.add(create("click", "#"+new_tool, key));
  }
  undo_stack.add( create("tool", new_tool));
}
function PickTool(tool) {
  this.old_tool = current_tool;
  this.new_tool = tool;

  function pick(tool, old) {
    $(".selected").removeClass("selected");
    current_tool = tool;
    $("#"+tool).addClass("selected");
  }
  this.run = function() {
    pick(this.new_tool, this.old_tool);
  }
  this.undo = function() {
    pick(this.old_tool, this.new_tool);
  }
}
register("tool", "new PickTool(arg1)");

/******************************************************************************/
console.log("Define function.");
function ChangeProperty(item, name, value) {
  this.item = item;
  this.name = name;
  this.new_value = value;
  this.old_value = item[name];

  this.run = function() {
    console.log("Change " + this.item +  ", " + this.name + ", " + this.new_value);
    this.item[this.name] = this.new_value;
    this.item.update();
    if( (this.name == "center") && (this.new_value)) {
      scene.center = this.item;
    } else {
      scene.center = 0;
    }
    if( this.item == selected_item ) properties.pull(this.item);
    redraw_scene();
  }

  this.undo = function() {
    console.log("Undo Change " + this.item +  ", " + this.name);
    this.item[this.name] = this.old_value;
    this.item.update();
    if( (this.name == "center") && (this.old_value)) {
      scene.center = this.item;
    } else {
      scene.center = 0;
    }
    if( this.item == selected_item ) properties.pull(this.item);
    redraw_scene();
  }
}
register("change", "new ChangeProperty(arg1, arg2, arg3)");

/******************************************************************************/
// Check the UI for the current selected property.
function OneProperty(element, name) {
  this.element = element;
  this.name = name;
  var pn = "value";            // Checkbox uses "checked", others use "value".
  if( element.indexOf("check") > 0 ) {
    pn = "checked";
  }
  this.apply = function(item) {
    var el = $(this.element);
    item[name] = el.prop(pn);
  }
  this.pull = function(item) {
    var value = item[name];
    var el = $(this.element);
    el.prop(pn, value);
  }
  var el = $(element);
  el.change(function(event) { change_property(event, element, name, pn); });
}

function ChangePropertyUI(element, pn, value) {
  this.element = element;
  this.pn = pn;
  this.value = value;
  this.play = function() {
    var el = $(this.element);
    el.prop(this.pn, this.value);
  }
  this.compute_position = function() {
    var a = $(this.element);
    return { x: a.offset().left + 0.5*a.width(),
             y: a.offset().top  + 0.5*a.height() };
  }
}
register("change_prop", "new ChangePropertyUI(arg1, arg2, arg3)");

function change_property(event, element, name, pn) {
  console.log("change_property: " + element + ", " + name + ", " + pn);
  var el = $(element);
  var value = el.prop(pn);
  if ((name == "center") && (scene.center) && value) {
    undo_stack.add(create("change", scene.center, name, false));
  }
  if (selected_item != null) {
    undo_stack.add(create("change", selected_item, name, value));
  }
  if( recording ) {
    recording.add( create("change_prop", element, pn, value));
  }
}

var properties = {
  list: [],
  add: function(element, name) {
    this.list.push( new OneProperty(element, name));
  },
  apply: function(item) {
    for(var i=0; i< this.list.length; i++) {
      this.list[i].apply(item);
    }
  },
  pull: function(item) {
    for(var i=0; i< this.list.length; i++) {
      this.list[i].pull(item);
    }
  }
}

function increment_name() {
  var name = $('#item_name').prop("value");
  if( ! name ) return;          // Leave blank if no name.
  var re = /(.*[^\d])(\d+)/;
  var match = re.exec(name);
  if( match ) {
    var n = 1 + parseInt(match[2]);
    name = match[1] + n;
  } else {
    name = name + "1";
  }
  $('#item_name').prop("value", name);
}

/******************************************************************************/
/******************************************************************************/
// This is called whenever the window is resized.  We use it to recompute
// the size of the canvas, and then redraw.
function windowResize(event) {
  var future = document.getElementsByClassName("future");
  var show_future = $('#show_future');
  var flag = "none";
  if( show_future && show_future.is(':checked') ) {
    flag = "";
    $("#recorder").show();
    $("#recorder2").show();
  } else {
    $("#recorder").hide();
    $("#recorder2").hide();
  }
  for(var i=0; i < future.length; i++) {
    future[i].style.display = flag;
  }
  if( spacetime_canvas[0].getContext && anim_canvas[0].getContext ) {
    $(".broken_canvas").hide();
    fixCanvas( spacetime_canvas);
    fixCanvas( anim_canvas);
    updateTransform();
  } else {
    console.log("ERROR: There was no context for the canvas elements.");
  }
}

function fixCanvas(c) {
  // Adjusting the size seems to only work when growing the canvas. So
  // first shrink it, then let it grow to the desired size.
  c.width( 10 );
  c.height( 10 );

  c.show();
  // subtract 4 for border?
  c.width( c.parent().width() - 4);
  c.height( c.parent().height() - 4);
  c.attr("width", c.width());
  c.attr("height", c.height());
}

// This runs whenever the "use lorentz" checkbox changes..
function lorentzChange(event) {
  if( recording ) {
    recording.add(create("click", "#lorentz_check"));
  }
  undo_stack.add( create("lorentz", $("#lorentz_check").prop('checked')));
}

function CheckLorentz(value) {
  this.value = value;

  this.run = function() {
    $("#lorentz_check").prop('checked', this.value);
    setVelocity(scene.velocity);
  }
  this.undo = function() {
    $("#lorentz_check").prop('checked', ! this.value);
    setVelocity(scene.velocity);
  }
}
register("lorentz", "new CheckLorentz(arg1)");

/******************************************************************************/
/******************************************************************************/
// This pairs off a slider and text input so they keep the same number.
// When the number changes,
function pairSlider(name, setter) {
  this.name = name;
  var slider = "#" + name + "_slider";
  var text = "#" + name + "_text";
  var value = NaN;
  this.digits = 3;
  var pair = this;              // So the event handlers can see 'this'
  var min=0;
  var max=1;
  var smin = 0;
  var smax = 100;

  // Set the range. If hard=true, don't adjust the range to look pretty.
  this.range = function(pmin,pmax, hard) {
    min = pmin;
    max = pmax;
    var scale = ( Math.log(max-min)/Math.log(10) );
    var dt = Math.pow(10,Math.floor(scale));
    var dt2 = dt* 0.01;
    min = Math.floor(min/dt2) * dt2;
    max = Math.ceil(max/dt2) * dt2;
    smin = min/dt2;
    smax = max/dt2;
    $(slider).prop("min", smin);
    $(slider).prop("max", smax);
    if( hard ) {
      min = pmin;             // Adjusted min and max.
      max = pmax;
    }
    this.min = min;
    this.max = max;
    // console.log(text + " min="+min+", max="+max+", dt="+dt+", dt2="+dt2);
  }

  $(slider).click(function(event) {
    if( recording ) {
      recording.add(create("click", slider));
    }
  });

  $(text).click(function(event) {
    if( recording ) {
      recording.add(create("click", text));
    }
  });

  // This runs whenever the slider bar changes.
  $(slider).on("input change", function(event) {
    var svalue = 1.0 * $(slider).prop('value'); // convert string to integer.
    var val = min + (svalue-smin)/(smax-smin)*(max-min);
    pair.update(val, true);
  });

  // This runs whenever a key is pressed in the text input.  We
  // are only interested in the return key -- which will change the value.
  $(text).keydown( function(event) {
    var evt = event || window.event;
    // "e" is the standard behavior (FF, Chrome, Safari, Opera),
    // while "window.event" (or "event") is IE's behavior
    if( evt.keyCode === 13 ) {
      // console.log("Pressed enter on " + text);
      var val = parseFloat($(text).prop('value'));
      if( isNaN(val) ) {
        val = (min+max)/2.0;
      }
      pair.update(val);
      // If the text entered was garbage, we correct it.
      $(text).prop('value', value.toFixed(pair.digits));
    }
  });

  // This checks to see if the value has changed -- if not, it updates
  // the ui, and calls the setter.
  this.update = function(v, from_slider) {
    v = Math.max(min, Math.min(max, v));
    if( (value != NaN)
        && Math.abs(value - v) < 1e-6
        && use_lorentz == $("#lorentz_check").prop('checked') ) {
      return value;             // No real change.
    }
    var adjuster = create("adjust_" + name, from_slider, value, v);
    undo_stack.add(adjuster);
    return v;
  }

  this.set = function(v) {      // Called by undo_stack via adjuster.
    if( isNaN(v) ) {
      v = 0.0;
    }
    value = v;
    var svalue = ((v - min)*(smax-smin)/(max-min)) + smin;
    $(slider).prop('value', svalue);
    $(text).prop('value', v.toFixed(this.digits));
    setter(v);
  }
}

function Adjuster(target, from_slider, old_value, new_value) {
  this.old_value = old_value;
  this.new_value = new_value;
  this.target_ns = target;
  this.from_slider = from_slider;

  this.absorb = function(other) {
    if( this.type == other.type && this.target_ns == other.target_ns
        && this.from_slider && other.from_slider) {
      this.old_value = other.old_value;
      return true;
    }
    return false;
  }

  this.run = function() {
    this.target_ns.set(this.new_value);
  }
  this.undo = function() {
    this.target_ns.set(this.old_value);
  }

  this.compute_position = function() {
    var a = $("#"+this.target_ns.name+"_slider");
    var percent = ((this.new_value-this.target_ns.min)
                   /(this.target_ns.max-this.target_ns.min));
    return { x: a.offset().left + percent*a.width(),
             y: a.offset().top  + 0.5*a.height() };
  }

}
register("adjust_velocity", "new Adjuster(velocity_ui, arg1, arg2, arg3)");
register("adjust_time", "new Adjuster(time_ui, arg1, arg2, arg3)");

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

function setTime(t) {
  t = time_ui.update(t);
  scene.time = t;
  redraw_scene();
}

function initialize_animation() {
  var speed =  1.0;
  var timer_id = false;
  var delta_t = 15;

  $("#pause_animation").hide();
  $("#play_animation").show();
  $("#animation_speed").change(function() {
    var el = $("#animation_speed");
    var value = el.prop("value");
    speed = value;
  });

  function do_animate() {
    var new_time = scene.time + 0.1 * speed*delta_t*0.001;
    setTime(new_time);
  }

  action_table.pause_animation = function() {
    if( timer_id ) {
      clearInterval(timer_id);
      timer_id = false;
    }
    $("#pause_animation").hide();
    $("#play_animation").show();
  }
  action_table.play_animation = function() {
    if( speed == 0.0 ) {
      speed = 1.0;
    }
    if( ! timer_id ) {
      timer_id = setInterval(do_animate, delta_t);
    }
    $("#pause_animation").show();
    $("#play_animation").hide();
  }
};

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

// Whenever the value changes, we recompute gamma, update the UI, and
// then redraw the scene.
function setVelocity(v) {
  // XXX find center's current x and t.
  use_lorentz = $("#lorentz_check").prop('checked');
  v = velocity_ui.update(v);        // XXX TODO: this should not be called twice.
  scene.velocity = v;
  scene.gamma = Math.sqrt( 1.0/(1-v*v));
  if( use_lorentz ) {
    $('#gamma_text').html("<math><mrow><mi> &gamma; </mi><mo>=</mo><mn>"
                           + scene.gamma.toFixed(3) + "</mn></mrow></math>");
  } else {
    $('#gamma_text').html("<math><mrow><mi> &gamma; </mi><mo>=</mo><mn>"
                          + "1.000" + "</mn></mrow></math>");
  }
  // XXX translate by change to center's current x and t.
  scene.update();
  redraw_scene();
}

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

// A Transform converts coordinates from different reference frames.
function Transform() {
  this.velocity = scene.velocity;
  this.gamma = scene.gamma;
}
register("transform", "new Transform()");

Transform.prototype.toCurrent = function(pt) {
  // First, convert pt from this.velocity reference frame to v=0 frame.
  if( use_lorentz ) {
    var x0 = this.gamma*(pt.x + this.velocity*pt.t);
    var t0 = this.gamma*(pt.t + this.velocity*pt.x);
  } else {
    var x0 = pt.x + this.velocity*pt.t;
    var t0 = pt.t;
  }
  // Second, convert from v=0 frame to  current velocity reference frame.
  if( use_lorentz ) {
    var x = scene.gamma*(x0 - scene.velocity*t0);
    var t = scene.gamma*(t0 - scene.velocity*x0);
  } else {
    var x = x0 - scene.velocity*t0;
    var t = t0;
  }
  return { x: x, t: t};
}
Transform.prototype.toScreen = function(pt) {
  // Convert to current world view, and then to screen coordinates.
  return w2s( this.toCurrent(pt) );
}

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

// Converting from (x,t), or world coordinates to screen coordinates is done
// by two linear transformations.
var screenx;
var screeny;
function Linear(m, b) {
  this.m = m;
  this.b = b;
  this.min = 0;
  this.max = 1.0;
}

Linear.prototype.map = function(x) {
  return this.m*x + this.b;
}

Linear.prototype.inv = function(x) {
  return (x-this.b)/this.m;
}

// This computes the transformation from world coordinates to screen coordinates.
// The transform must be updated whenever the screen changes size.
function updateTransform() {
  console.log("Update transform. v = " + scene.velocity);
  // TODO: translate line by 0.5 to remove the blur.
  // world to screen x and y.
  // Two conditions:
  // x=center_x -> screen_x=width/2,
  // x=center_x + 1 -> screen_x = width/2+scale*width/2
  // Linear equation:
  //   screen_x = (width/2 + scale * width/2 * (x - center_x)
  //            = (width/2 - scale * width/2 * center_x ) + scale * width/2 * (x )
  screenx = new Linear(scene.scale*spacetime_canvas.width()/2.0,
                       spacetime_canvas.width()/2
                           - scene.scale*spacetime_canvas.width()/2*scene.center_x);
  screenx.min = 0.0;
  screenx.max = spacetime_canvas.width();
  // Two conditions:
  // t=center_t -> screen_y=height/2,
  // t=center_t + 1 -> screen_y = height/2+scale*width/2
  // (Note: same m for x and y prevents afine transformation
  // Linear equation:
  //   screen_y = (height/2 - scale * width/2 * (t - center_t)
  //            = (height/2 + scale * width/2 * center_t ) + scale * width/2 * (x )
  screeny = new Linear(-scene.scale*spacetime_canvas.width()/2.0,
                       spacetime_canvas.height()/2.0
                           + scene.scale*spacetime_canvas.width()/2*scene.center_t);

  fade_in = Math.abs(screeny.m * 1.0);
  screeny.min = spacetime_canvas.height();
  screeny.max = 0.0;
  var min = s2w({x:0, y: spacetime_canvas.height()});
  var max = s2w({x:spacetime_canvas.width(), y: 0});
  var grid_size = $("#pick").height() / screenx.m;
  time_ui.range( min.t, max.t);
  scene.set_range(min, max, grid_size);
  scene.update();
  redraw_scene();
}

function w2s(world) {           // World to Spacetime canvas transformation.
  return { x: screenx.map(world.x), y: screeny.map(world.t)};
}

function s2w(screen) {           // Spacetime canvas to World transformation.
  return { x: screenx.inv(screen.x), t: screeny.inv(screen.y) };
}

function event2world(event, canvas) {
  if( canvas == "s" ) {
    var rect = spacetime_canvas.offset();
    // Note: I'm not sure why mouse position is off by a few pixels.
    var pt = s2w( { x:  event.clientX - Math.ceil(rect.left) - 1,
                    y:  event.clientY - Math.ceil(rect.top) - 1} );
    pt.z = null;
    return pt;
  } else {
    var rect = anim_canvas.offset();
    var pt =  s2w( { x:  event.clientX - Math.ceil(rect.left) - 1,
                     y:  event.clientY - Math.ceil(rect.top) - 1} )
    var z = (event.clientY - Math.ceil(rect.top) - 1)/anim_canvas.innerHeight();
    return { x: pt.x, t: scene.time, z: z };
  }
}

/******************************************************************************/
/******************************************************************************/
var mouse_down_origin = null;   // Where the last registered mouse_down event came from.
var mouse_tools = {};
function mouse_down_spacetime(event) {
  mouse_down_origin = "s";
  var pt = event2world(event, mouse_down_origin);
  if( recording ) {
    recording.add( create( "s_down", pt));
  }
  mouse_tools[current_tool].mouse_down(event, pt, "s");
}

function mouse_move_spacetime(event) {
  var pt = event2world(event, "s");
  if( recording ) {
    recording.add( create( "s_move", pt));
  }
  if( mouse_down_origin == "s" ) { // Drag: mouse move after mouse down.
    mouse_tools[current_tool].mouse_move(event, pt, "s");
  }
}

function mouse_down_anim(event) {
  mouse_down_origin = "a";
  var pt = event2world(event, "a");
  if( recording ) {
    recording.add( create( "a_down", pt));
  }
  mouse_tools[current_tool].mouse_down(event, pt, "a");
}

function mouse_move_anim(event) {
  var pt = event2world(event, "a");
  if( recording ) {
    recording.add( create( "a_move", pt));
  }
  if( mouse_down_origin == "a" ) { // handle drag.
    mouse_tools[current_tool].mouse_move(event, pt, "a");
  }
}

function mouse_up(event) {      // Over any element/window.
  if( mouse_down_origin ) {
    var pt = event2world(event, mouse_down_origin);
    if( recording ) {
      recording.add( create( mouse_down_origin + "_up", pt));
    }
    mouse_tools[current_tool].mouse_up(event, pt);
  }
  mouse_down_origin = null;
}

function SelectTool() {
  this.prev_pt = null;
  this.mouse_down = function(event, pt, source) {
    this.prev_pt = pt;
    var cutoff = dot_size * 1.2 /screenx.m; // 20% padding on hits.
    var min_d = Infinity;
    var closest = null;
    for(var item=scene.drawables.head; item; item = item.next_ns) {
      var d = item.distance(pt, source);
      if( d < min_d ) {
        closest = item;
        min_d = d;
      }
    }
    if( min_d < cutoff ) {
      undo_stack.add(create("select", closest));
    } else {
      undo_stack.add(create("select", null));
    }
  }

  this.mouse_move = function(event, pt, source) {
    var dt = pt.t - this.prev_pt.t;
    var dx = pt.x - this.prev_pt.x;
    if( selected_item ) {
      undo_stack.add(create("move", selected_item, dt, dx, pt.z));
    } else {
      undo_stack.add(create("move_scene", dt, dx));
      pt.t -= dt;
      pt.x -= dx;
    }
    this.prev_pt = pt;
  }

  this.mouse_up = function(event, pt) {
    this.prev_pt = null;
  }
}

function SelectItem(item) {
  this.item = item;
  this.old = selected_item;

  this.run = function() {
    select_item(this.item);
  }
  this.undo = function() {
    select_item(this.old);
  }
}
register("select", "new SelectItem(arg1)");

function MouseTool(item) {
  this.object = null;
  this.prev_pt = null;

  this.mouse_down = function(event, pt, source) {
    this.prev_pt = pt;
    this.object = create(item, pt);
    if( source == "a" ) {
      this.object.z = pt.z;
    }
    undo_stack.add(create("add", this.object));
    increment_name();
  }

  this.mouse_move = function(event, pt, source) {
    var dt = pt.t - this.prev_pt.t;
    var dx = pt.x - this.prev_pt.x;
    if( this.object ) {
      this.object.move( dt, dx);
      if( source == "a" ) {
        this.object.z = pt.z;
      }
      this.object.update();
      redraw_scene();
    }
    this.prev_pt = pt;
  }

  this.mouse_up = function(event, pt) {
    this.pt = pt;
    this.object = null;
  }
}

mouse_tools["pick"] = new SelectTool();
mouse_tools["event"] = new MouseTool("event");
mouse_tools["instant"] = new MouseTool("instant");
mouse_tools["location"] = new MouseTool("location");
mouse_tools["cone"] = new MouseTool("cone");
mouse_tools["path"] = new MouseTool("path");

mouse_tools["path"].mouse_move = function(event, pt, source) {
  if( this.object && ( pt.t - this.prev_pt.t > 0.005 ) ) {
    var dt = pt.t - this.prev_pt.t;
    if( pt.x < this.prev_pt.x - dt*0.99 ) {
      pt.x = this.prev_pt.x - dt*0.99;
    }
    if( pt.x > this.prev_pt.x + dt*0.99 ) {
      pt.x = this.prev_pt.x + dt*0.99;
    }
    this.object.add(pt);
    this.object.update();
    redraw_scene();
    this.prev_pt = pt;
  }
}

/******************************************************************************/
/******************************************************************************/
var selected_item = null;
function select_item(item) {
  if( item ) {
    properties.pull(item);
  }
  selected_item = item;
  redraw_scene();
}

/******************************************************************************/
/******************************************************************************/
function DrawThing(coords) {
  properties.apply(this);
  this.z = z_height;
  this.transform = create("transform");
  this.coords = coords;
  this.data_ns = null;

  this.move = function(dt, dx) {
    this.coords.t += dt;
    this.coords.x += dx;
  };
  this.update = function() {
    if(this.data_ns) this.data_ns.update();
  }
  this.draw = function(ccon, acon) {
    if(this.data_ns) this.data_ns.draw(ccon, acon);
  }
  this.distance = function(pt, source) {
    if(this.data_ns) return this.data_ns.distance(pt, source);
  }
  this.text = function(t) {
    if( this.clock ) {
      return this.name + ": " + t.toFixed(3);
    } else {
      return this.name;
    }
  }
}

function Event(coords) {
  DrawThing.call(this, coords);
  this.update = function() {
    console.log("Update event. v = " + scene.velocity);
    this.pt_ns = this.transform.toCurrent(this.coords);
    this.pts_ns = w2s(this.pt_ns);
  }
  this.draw = function(ccon, acon) {
    ccon.arc( this.pts_ns.x, this.pts_ns.y, dot_size, 0.0, 2.0*Math.PI, false);
    ccon.fillText(this.name, this.pts_ns.x + dot_size, this.pts_ns.y - dot_size);
    var radius = 2*dot_size - Math.abs(this.pt_ns.t - scene.time)*fade_in;
    if( radius > 0 ) {
      if( radius > dot_size ) {
        radius = dot_size;
      }
      var y = this.z * anim_canvas.innerHeight();
      acon.arc( this.pts_ns.x, y, radius, 0.0, 2.0*Math.PI, false);
      acon.fillText(this.name, this.pts_ns.x + dot_size, y - dot_size);
    }
  }
  this.distance = function(pt, source) {
    var dx = this.pt_ns.x - pt.x;
    var dt = this.pt_ns.t - pt.t;
    if( source == "s" ) {
      return Math.sqrt( dx*dx + dt*dt);
    } else {
      var dz = this.z - pt.z;
      dz *= anim_canvas.innerHeight() / screenx.m;
      return Math.sqrt( dx*dx + dt*dt + dz*dz);
    }
  }
}
register("event", "new Event(arg1)");

function InstantData(item) {
  this.update_spacetime = function() {
    var width = spacetime_canvas.width();
    var height = spacetime_canvas.height();
    // item.transform.toScreen(item.coords);
    this.pt = item.transform.toCurrent(item.coords);
    this.sp = w2s(this.pt);
    this.delta = item.transform.toCurrent({ x: 1, t: 0});
    var dsx = screenx.m * this.delta.x;
    var dsy = screeny.m * this.delta.t;
    // as parametric curve, line is
    // point(r) = {x: s.x + r*dsx, y: s.y + r*dsy}
    // can solve for y:
    //  r = (x-s.x)/dsx ->  y = s.y + (x-s.x)*dsy/dsx
    // or solve x;   x = s.x + (y-s.y)*dsx/dsy
    this.sp1 = { x: 0,     y: this.sp.y + (0    -this.sp.x)*dsy/dsx};
    this.sp2 = { x: width, y: this.sp.y + (width-this.sp.x)*dsy/dsx};
  }
  this.update_anim = function() {
    var width = anim_canvas.width();
    this.y = item.z * anim_canvas.height();
    // If the line is close to horizontal, we flash it on the screen
    // at the right time.  This is when the projected line width is more
    // than 3 screen widths.
    if( Math.abs(this.delta.t) < Math.abs(dot_size * this.delta.x) / (3*width) ) {
      this.flash = true;
      this.t = this.pt.t + ( 0.5*width - this.pt.x ) *this.delta.t/this.delta.x;
    } else {
      // Otherwise, the line intersects the current time as a dot.
      // We need to compute the width of the dot.
      this.flash = false;
      var r = ( 1 + (this.delta.x*this.delta.x)/(this.delta.t*this.delta.t) );
      this.L = dot_size * Math.sqrt(r);
    }
  }

  this.update = function() {
    this.update_spacetime();
    this.update_anim();
  }

  this.draw = function(ccon, acon) {
    ccon.moveTo(this.sp1.x, this.sp1.y);
    ccon.lineTo(this.sp2.x, this.sp2.y);
    ccon.fillText(item.name, this.sp.x + dot_size, this.sp.y - dot_size);

    if( this.flash ) {
      this.radius = 2*dot_size - Math.abs(this.t - scene.time) * fade_in;
      if( this.radius > 0 ) {
        if( this.radius > dot_size ) {
          this.radius = dot_size;
        }
        acon.lineWidth = this.radius;
        acon.moveTo(0, this.y);
        acon.lineTo(anim_canvas.width(), this.y);
        acon.fillText(item.name, this.sp.x + dot_size, this.y - dot_size);
      }
    } else {
      var x = this.pt.x + (scene.time - this.pt.t) * this.delta.x/this.delta.t;
      this.center = w2s( { x: x, t: scene.time});
      this.center.y = this.y;
      acon.rect( this.center.x-this.L/2, this.center.y-dot_size/4,
                 this.L, dot_size/2);
      var text_x = this.sp.x;
      if( text_x < this.center.x - this.L/2 ) text_x = this.center.x - this.L/2;
      if( text_x > this.center.x + this.L/2 ) text_x = this.center.x + this.L/2;
      acon.fillText(item.name, text_x + dot_size, this.y - dot_size);
    }
  }

  this.distance = function(pt, source) {
    if( source == "s") {
      // return abs(dot( pt - this.pt, perp(delta))).
      return Math.abs((pt.x - this.pt.x)*this.delta.t
          - (pt.t - this.pt.t)*this.delta.x);
    } else {
      if( this.flash ) {
        if( this.radius > 0 ) {
          var dz = item.z - pt.z;
          dz *= anim_canvas.innerHeight() / screenx.m;
          return Math.abs(dz);
        }
      } else {                  // XXX fix.  mixing screen and world coordinates.
        if (( pt.x >= this.center.x-this.L/2 && pt.x <=  this.center.x-this.L/2)
            && ( pt.y >= this.y-dot_size/4 && pt.y <=  this.y-dot_size/4)) {
          return 0;
        }
      }
    }
    return Infinity;
  }
}

function Instant(coords) {
  DrawThing.call(this, coords);
  this.data_ns = new InstantData(this);
}
register("instant",  "new Instant(arg1)");

function ConeData(item) {
  this.neg = icon_left;
  this.pos = icon_right;

  this.update = function() {
    this.pt = item.transform.toCurrent(item.coords);
    this.pts = w2s(this.pt);
    this.y = item.z * anim_canvas.height();
  }

  this.draw = function(ccon, acon) {
    if( this.pts.y >= 0 ) {
      ccon.moveTo( this.pts.x - this.pts.y, 0);
      ccon.lineTo( this.pts.x, this.pts.y);
      ccon.lineTo( this.pts.x + this.pts.y, 0);
      ccon.fillText(item.name, this.pts.x + dot_size, this.pts.y + 3*dot_size);
    }

    var dt = scene.time - this.pt.t;
    var pt1 = w2s({x: this.pt.x - dt, t: this.pt.t} );
    var pt2 = w2s({x: this.pt.x + dt, t: this.pt.t} );
    if( pt2.x - pt1.x  > -dot_size ) {
      this.neg.draw(acon, pt1.x, this.y, 1.0, item.name, false, null);
      this.pos.draw(acon, pt2.x, this.y, 1.0, item.name, false, null);
    }
  }
  this.distance = function(pt, source) {
    var dx = pt.x - this.pt.x;
    if( source == "s") {
      var dt = pt.t - this.pt.t;
      return Math.abs(  Math.abs(dx) - dt);
    } else {
      var dt = scene.time - this.pt.t;
      if( dt > 0 ) {
        var dz = pt.z - item.z;
        dz *= anim_canvas.innerHeight() / screenx.m;
        return this.pos.distance( Math.abs(dx) - dt, dz, 1.0);
      }
    }
    return Infinity;
  }
}

function Cone(coords) {
  DrawThing.call(this, coords);
  this.data_ns = new ConeData(this);
}
register("cone",  "new Cone(arg1)");

function LocationData(item) {
  this.update_spacetime = function() {
    var width = spacetime_canvas.width();
    var height = spacetime_canvas.height();
    this.pt = item.transform.toCurrent(item.coords);
    this.sp = w2s(this.pt);
    this.delta = item.transform.toCurrent({ x:0, t:1});
    var dsx = screenx.m * this.delta.x;
    var dsy = screeny.m * this.delta.t;
    // as parametric curve, line is
    // point(r) = {x: s.x + r*dsx, y: s.y + r*dsy}
    // can solve for y:
    //  r = (x-s.x)/dsx ->  y = s.y + (x-s.x)*dsy/dsx
    // or solve x;   x = s.x + (y-s.y)*dsx/dsy
    this.sp1 = { x: this.sp.x + (     0-this.sp.y)*dsx/dsy, y: 0};
    this.sp2 = { x: this.sp.x + (height-this.sp.y)*dsx/dsy, y: height};
  }

  this.update_anim = function() {
    var width = anim_canvas.width();
    this.icon = icon_list[item.icon_name];
    this.y = item.z * anim_canvas.height();
    var r = ( 1 - (this.delta.x*this.delta.x)/(this.delta.t*this.delta.t) );
    this.width = Math.sqrt(r);
  }

  this.update = function() {
    this.update_spacetime();
    this.update_anim();
  }

  this.draw = function(ccon, acon) {
    ccon.moveTo(this.sp1.x, this.sp1.y);
    ccon.lineTo(this.sp2.x, this.sp2.y);
    ccon.fillText(item.name, this.sp.x + dot_size, this.sp.y - dot_size);

    this.x = this.pt.x + (scene.time - this.pt.t) * this.delta.x/this.delta.t;
    this.center = w2s( { x: this.x, t: scene.time});
    var dt = scene.time - this.pt.t;
    var dx = this.pt.x - this.x;
    var dclock = Math.sqrt( dt*dt - dx*dx);
    if( dt < 0 ) {
      dclock = -dclock;
    }
    this.center.y = this.y;
    this.icon.draw( acon, this.center.x, this.center.y, this.width, item.text(dclock));
  }

  this.distance = function(pt, source) {
    if( source == "s") {
      // return abs(dot( pt - this.pt, perp(delta))).
      return Math.abs((pt.x - this.pt.x)*this.delta.t
          - (pt.t - this.pt.t)*this.delta.x);
    } else {
      var dx = pt.x - this.x;
      var dz = pt.z - item.z;
      dz *= anim_canvas.innerHeight() / screenx.m;
      return this.icon.distance( dx, dz, this.width);
    }
  }
}

function Location(coords) {
  DrawThing.call(this, coords);
  this.data_ns = new LocationData(this);
}
register("location", "new Location(arg1)");

function PathData(item) {
  this.index = 0;
  this.update = function() {
    this.y = item.z * anim_canvas.height();
    this.icon = icon_list[item.icon_name];
    this.pts = new Array(item.pts.length);
    this.s = new Array(item.pts.length);
    this.t = new Array(item.pts.length);
    for(var i = 0; i < item.pts.length; i++) {
      this.pts[i] = item.transform.toCurrent(item.pts[i]);
      this.s[i] = w2s(this.pts[i]);
      if( i == 0 ) {
        this.t[i] = 0.0;
      } else {
        if( scene.time > this.pts[i-1].t && scene.time < this.pts[i].t ) {
          this.index = i-1;
        }
        var dt = this.pts[i].t - this.pts[i-1].t;
        var dx = this.pts[i].x - this.pts[i-1].x;
        this.t[i] = this.t[i-1] + Math.sqrt(dt*dt + dx*dx);
      }
    }
  }

  this.find_index = function() {
    if( (this.index < 0) || (this.index > this.pts.length-1) ) {
      this.index = 0;
    }
    while( (this.index > 0) && (scene.time < this.pts[this.index].t) ) {
      this.index--;
    }
    while( (this.index < this.pts.length-2)
        && (scene.time > this.pts[this.index+1].t) ) {
      this.index++;
    }
  }

  this.draw = function(ccon, acon) {
    if( this.s.length < 2 ) {
      return;
    }
    for(var i=0; i < this.s.length; i++) {
      if( i == 0 ) {
        ccon.fillText(item.name, this.s[i].x + dot_size, this.s[i].y - dot_size);
        ccon.moveTo(this.s[i].x, this.s[i].y);
      } else {
        ccon.lineTo(this.s[i].x, this.s[i].y);
      }
    }
    this.find_index();
    var i = this.index;
    var b = 0.01;               // buffer.
    if( (scene.time < this.pts[i].t-b) || (scene.time > this.pts[i+1].t+b) ) {
      return;
    }
    var dt = this.pts[i+1].t - this.pts[i].t;
    var dx = this.pts[i+1].x - this.pts[i].x;
    this.x =  this.pts[i].x + (scene.time - this.pts[i].t) * dx/dt;
    var pt = w2s( {x: this.x, t: scene.time} );
    var w2 = 1 - (dx*dx)/(dt*dt);
    if( w2 < 0.0025 ) w2 = 0.025;
    this.width = Math.sqrt(w2);
    if( isNaN(this.width) ) {
      console.log("XXX Problem at "+i+", dx="+dx+", dt="+dt);
    }
    var dclock = Math.sqrt(dt*dt - dx*dx) * (scene.time - this.pts[i].t)/dt;
    this.icon.draw( acon, pt.x, this.y, this.width, item.text(this.t[i]-dclock));
  }

  this.distance = function(pt, source) {
    if( this.s.length < 2 ) {
      return Infinity;
    }
    if( source == "s") {
      var dist = Infinity;
      for(var i=0; i < this.s.length-1; i++) {
        var lx = pt.x - this.pts[i].x; // l = vector from p[i] to pt.
        var lt = pt.t - this.pts[i].t;
        // v = vector from p[i] to i+1.
        var vx = this.pts[i+1].x - this.pts[i].x;
        var vt = this.pts[i+1].t - this.pts[i].t;
        // v2 = ||v||^2.
        var v2 = vx*vx + vt*vt;
        var s = lx*vx + lt*vt;  // s = dot(l, v)
        var d2 = 0;             // distance off the end of segment i. * ||v||
        if( s < 0 ) {
          d2 = -s;
        } else if( s > v2) {
          d2 = s - v2;
        }
        var d1 = lx*vt - lt*vx;  // s = dot(l, perp(v))
        var d = (d1*d1 + d2*d2)/v2;
        if( d < dist ) dist = d;
      }
      if( dist < Infinity ) return Math.sqrt(dist);
      return Infinity;
    } else {
      var i = this.index;
      if( (scene.time < this.pts[i].t) || (scene.time > this.pts[i+1].t) ) {
        return Infinity;
      }
      var dx = pt.x - this.x;
      var dz = pt.z - item.z;
      dz *= anim_canvas.innerHeight() / screenx.m;
      return this.icon.distance( dx, dz, this.width);
    }
  }
}

function Path(coords) {
  DrawThing.call(this, coords);
  this.pts = new Array(1);
  this.pts[0] = coords;
  this.data_ns = new PathData(this);

  this.move = function(dt, dx) {
    for(var i = 0; i < this.pts.length; i++) {
      this.pts[i].t += dt;
      this.pts[i].x += dx;
    }
  };
  this.add = function(pt)  {
    this.pts.push(pt);
  }
}
register("path",  "new Path(arg1)");

/******************************************************************************/
/******************************************************************************/
icon_list["spot"] = {
  draw: function(acon, x, y, width, name) {
    acon.moveTo(x + dot_size, y);
    acon.arc( x, y, dot_size, 0.0, 2.0*Math.PI, false);
    acon.fillText(name, x + dot_size, y - dot_size);
  },
  distance: function( dx, dz, width) {
    return Math.sqrt( dx*dx + dz*dz);
  }
}
icon_list["train"] = {
  w: 12*dot_size,
  h: 4*dot_size,
  r: dot_size,
  draw: function(acon, x, y, width, name) {
    acon.moveTo(x, y);
    acon.rect( x, y, this.w*width, this.h);
    acon.moveTo(x, y+this.h);
    acon.bezierCurveTo(x,              y+this.h+this.r,
                       x+this.r*width, y+this.h+this.r,
                       x+this.r*width, y+this.h);
    acon.moveTo(x+this.w*width, y+this.h);
    acon.bezierCurveTo(x+this.w*width,              y+this.h+this.r,
                       x+this.w*width-this.r*width, y+this.h+this.r,
                       x+this.w*width-this.r*width, y+this.h);
    // Firefox does not support ellipses, use bezier curve.
    // acon.ellipse(x+this.r*width, y+this.h, this.r*width, this.r,
    //              0.0, 0, Math.PI, false);
    // acon.ellipse(x+this.w*width-this.r*width, y+this.h, this.r*width, this.r,
    //              0.0, 0, Math.PI, false);
    acon.fillText(name, x + dot_size, y - dot_size);
  },
  distance: function( dx, dz, width) {
    dx *= screenx.m;
    dz *= screenx.m;
    if( (0 < dx) && (dx < this.w*width)  && (0 < dz) && (dz < this.h)) {
      return 0;
    }
    return Infinity;
  },
}

icon_list["barn"] = {
  w: 12*dot_size,
  h: 6*dot_size,
  peak: 2*dot_size,
  draw: function(acon, x, y, width, name) {
    acon.moveTo(x, y);
    acon.lineTo(x+this.w*width/2.0, y - this.peak);
    acon.lineTo(x+this.w*width, y);
    acon.rect( x, y, this.w*width, this.h);
    acon.fillText(name, x + dot_size, y - dot_size - this.peak);
  },
  distance: function( dx, dz, width) {
    dx *= screenx.m;
    dz *= screenx.m;
    if( (0 < dx) && (dx < this.w*width)  && (0 < dz) && (dz < this.h)) {
      return 0;
    }
    return Infinity;
  }
}

icon_list["person"] = {
  r: dot_size/2.0,
  draw: function(acon, x, y, width, name) {
    acon.moveTo(x+ this.r*width, y-this.r);
    // Firefox does not support ellipses, use bezier curve.
    // acon.ellipse(x, y-this.r, this.r*width, this.r, // head
    //              0.0, 0, 2*Math.PI, false);
    acon.bezierCurveTo(x + this.r*width, y-this.r*2,
                       x - this.r*width, y-this.r*2,
                       x - this.r*width, y-this.r);
    acon.bezierCurveTo(x - this.r*width, y,
                       x + this.r*width, y,
                       x + this.r*width, y-this.r);

    acon.moveTo(x - 2*this.r*width, y + 4*this.r); // arms
    acon.lineTo(x                 , y           );
    acon.lineTo(x + 2*this.r*width, y + 4*this.r);

    acon.moveTo(x                 , y           ); // body
    acon.lineTo(x                 , y + 4*this.r);

    acon.moveTo(x - 2*this.r*width, y + 8*this.r); // legs
    acon.lineTo(x                 , y + 4*this.r);
    acon.lineTo(x + 2*this.r*width, y + 8*this.r);

    acon.fillText(name, x, y - dot_size - this.r);
  },
  distance: function( dx, dz, width) {
    dx *= screenx.m;
    dz *= screenx.m;
    if( (Math.abs(dx) < this.r*width)
        && (-2*this.r < dz) && (dz < 8*this.r)) {
      return 0;
    }
    return Infinity;
  }
}

function LightIcon(direction) {
  this.draw = function(acon, x, y, width, name) {
    acon.moveTo(x + dot_size*direction, y + dot_size);
    acon.lineTo(x, y);
    acon.lineTo(x + dot_size*direction, y - dot_size);
    if( direction < 0 ) {
      acon.fillText(name, x + 0.5*dot_size, y - 0.5*dot_size);
    } else {
      var metrics = acon.measureText(name);
      acon.fillText(name, x -metrics.width- 0.5*dot_size, y - 0.5*dot_size);
    }
  }
  this.distance = function( dx, dz, width) {
    return Math.sqrt( dx*dx + dz*dz);
  }
}

icon_left = new LightIcon(1);
icon_right = new LightIcon(-1);

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

function UndoStack() {
  var head = null;
  var tail = null;
  var count = 0;
  var max_count = 100;

  this.debug = function() {
    return { head:head, tail:tail, count:count};
  }

  this.clear = function() {
    head = null;
    tail = null;
    count = 0;
  }

  this.add = function(action) {
    action.run();
    if( recording ) {
      recording.add(action);
    }
    // minor changes can absorb previous action.
    if( head != null && action.absorb && action.absorb(head.action) ) {
      head.action = action;
      head.time = +new Date();
      return;
    }
    var node = {
      next: null,
      prev: head,
      action: action,
      time: +new Date()
    };
    if( head == null ) {
      tail = node;
    } else {
      head.next = node;
    }
    head = node;
    count++;
    while( count > max_count) { // clean up a little.
      tail = tail.next;
      tail.prev = null;
      count--;
    }
    return node;
  }

  this.redo = function() {
    if( head == null || head.next == null ) {
      console.log("Undo stack full.");
      return;
    }
    head = head.next;
    if( recording ) {
      recording.add(head.action);
    }
    count++;
    head.action.run();
  }

  this.undo = function() {
    if( head == null ) {
      console.log("Undo stack empty.");
      return;
    }
    if( recording ) {
      recording.add(create("revert", head.action));
    }
    head.action.undo();
    head = head.prev;
    count--;
  }

  this.unto_until = function(timestamp) {
    while( head != null && head.time >= timestamp) {
      undo();
    }
  }
}
var undo_stack = new UndoStack();

action_table.undo =  function() {
  undo_stack.undo();
};
action_table.redo =  function() {
  undo_stack.redo();
};

function Revert(action) {
  this.action = action;
  this.run = function() { action.undo() };
  this.undo = function() { action.run() };
}
register("revert", "new Revert(arg1)");

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

action_table.free_form = function() {
  $('.playback').hide();
  $('.recording').hide();
  windowResize();
  if( playback ) {
    playback.stop_and_delete();
  }
  window.location.hash = "";
}

action_table.do_lesson = function(file, start_paused) {
  if( recording ) {
    console.log("I AM STILL RECORDING!");
    recording.abort();
  }
  $('.playback').show();
  $('.recording').hide();
  if( start_paused ) {
    $("#initial_popup").show();
  } else {
    $("#initial_popup").hide();
  }
  windowResize();
  if( start_paused ) {
    window.location.hash = "#" + file + start_paused;
  } else {
    window.location.hash = "#" + file;
  }
  jQuery.ajax({
    url: "lessons/"+ file + '.rec',
    dataType: 'html',
    success: function(data) {
      if( playback ) {
        playback.stop_and_delete();
      }
      playback = new Playback(file, data, start_paused);
     },
    fail: function(jqXHR, textStatus, errorThrown) {
      console.log("Could not load "+file+": "+errorThrown);
    }
  });
}

var recording = false;
var playback = false;

function Playback(name, data_json, start_paused) {
  this.name = name;
  if( $("#view_subtitles").prop('checked') ) {
    window.open("lessons/" + name + ".html", "subtitles");
  }
  clean_serialize();
  this.full_data = my_parse(data_json);
  clean_serialize();
  this.pager = this.full_data.pager;
  if( ! this.pager ) this.pager = create("pager",name); // For old recordings.
  this.pager.filename = name;
  this.pager.advance_to(0);
  this.pager.display();
  set_new_scene(this.full_data.range);
  $(".fake_pointer").html('<img src="images/mouse.svg">');
  var data = this.full_data.data; // Just the array of events.
  find_next_pos();
  var audio = $('#audio');
  if( start_paused ) {
    audio.removeAttr('autoplay');
  } else {
    audio.attr('autoplay', 'autoplay');
  }
  audio.bind("play", play_actions);
  audio.bind("pause", pause_actions);
  audio.bind("ended", ended_actions);
  audio.bind("timeupdate", play_time_update);
  audio.bind("seeked", play_time_update);
  var debug_sounds = "";       // Modified by test server.

  var sound_file =  debug_sounds + "lessons/"+name;
  $("#audio_mp3").attr("src", sound_file + ".mp3");
  $("#audio_ogg").attr("src", sound_file + ".ogg");
  audio.get(0).load();

  var start_time = +new Date(); // miliseconds.
  var current_time = 0;         // seconds.
  var total_time = this.full_data.duration; // seconds.
  audio.prop("duration", total_time);
  var index = 0;                // last index played.
  var timer_id = 0;
  var prev_pos_index = 0;
  var next_pos_index = 0;
  var prev_t = -0.1;
  var next_t = 0;
  var prev_pos = data[0].event.compute_position();
  var next_pos = prev_pos;

  function play_actions() {
    pause_actions();
    $(".fake_pointer").show();
    $("#initial_popup").hide();
    start_time = (+new Date())  - current_time*1000; // miliseconds.
    timer_id = setInterval(playback_animate, 50);
  }

  function pause_actions() {
    if( timer_id ) {
      clearInterval(timer_id);
      timer_id = 0;
    }
  }

  function ended_actions() {
    pause_actions();
    $(".fake_pointer").hide();
  }


  action_table.debug_page = function() {
    console.log("@@@ debug page time = " + (1000*current_time));
  }

  this.stop = function() {
    pause_actions();
    $(".fake_pointer").hide();
    $("#initial_popup").hide();
  }

  this.stop_and_delete = function() {
    this.stop();
    var audio = $('#audio');
    audio.attr('src',  "");
    audio.unbind("play", play_actions);
    audio.unbind("pause", pause_actions);
    audio.unbind("ended", ended_actions);
    audio.unbind("timeupdate", play_time_update);
    audio.unbind("seeked", play_time_update);
    $(".fake_pointer").hide();
    $("#initial_popup").hide();
    playback = false;
  }

  // This is called by the audio playback.  I use it to adjust
  // the start time -- this is important if we seek forward or backward.
  function play_time_update(event) {
    var new_time = $("#audio").prop("currentTime"); // seconds.
    totalTime = total_time;
    if( new_time > total_time ) new_time = total_time;
    if( new_time < current_time ) {
      rewind(new_time);
    }
    current_time = new_time;    // seconds.
    start_time = (+new Date())  - current_time*1000; // miliseconds.
  }

  function rewind(t) {
    if( index < data.length && data[index].t <= t ) {
      // didn't go far enough back to have to undo anything.
      return;
    }
    clean_serialize();
    playback.full_data = my_parse(data_json);
    clean_serialize();
    set_new_scene(playback.full_data.range);
    index = 0;                // last index played.
    prev_pos_index = 0;
    next_pos_index = 0;
    prev_t = -0.1;
    next_t = 0;
    prev_pos = data[0].event.compute_position();
    next_pos = prev_pos;
    current_time = t;
  }

  // Called at regular intervals by a timer.
  function playback_animate() {
    var t = (+new Date()) - start_time; // miliseconds since start.
    playback.pager.advance_to(t);
    // console.log("Playback until "+ (t/1000.0).toFixed(1));
    while( index < data.length-1 && data[index+1].t <= t ) {
      index++;
      var e = data[index];
      if( e.event.play ) {
        e.event.play(t);
      }
      if( e.event.undo ) {
        undo_stack.add(e.event);
      }
      if( e.npos+index != next_pos_index ) {
        prev_pos = next_pos;
        prev_pos_index = next_pos_index;
        prev_t = next_t;
        next_pos_index = e.npos+index;
        next_t = data[next_pos_index].t;
        next_pos = data[next_pos_index].event.compute_position();

        // console.log("pos in "+prev_pos_index +") x:"+prev_pos.x.toFixed(1)
        //     +", y: "+prev_pos.y.toFixed(1)
        //         + ", t:" + (prev_t/1000.0).toFixed(1)
        //             + " -- next "+next_pos_index +") x:"+next_pos.x.toFixed(1)
        //                 +", y: "+next_pos.y.toFixed(1)
        //                     + ", t:" + (next_t/1000.0).toFixed(1)
        //                         + ", type:" + data[next_pos_index].event.type
        //            );
      }
    }
    if( index < data.length-1 ) {
      var alpha = (t - prev_t)/(next_t - prev_t);
      if( isNaN(alpha) ) {
        alpha = 0.0;
      }
      var x = prev_pos.x*(1-alpha) + next_pos.x*alpha;
      var y = prev_pos.y*(1-alpha) + next_pos.y*alpha;
      $(".fake_pointer").offset({top:y, left:x});
    }
  }

  function find_next_pos() {
    // Not all events can compute their positions, so a recording item's npos
    // points to the next item that has a position.  Then, for playback, we
    // just linearly interpolate between the previous point, and npos.
    // Only the last item has npos pointing to self.
    var next_position = data.length-1;
    for( var i= data.length-1; i >= 0; i-- ) {
      data[i].npos = next_position-i;
      if( data[i].event.compute_position ) {
        next_position = i;
      }
    }
  }

  // if( zzz_trace_all_audio ) {
   //   audio.bind("load", function(f) {
   //     console.log("Event load: "+f);
   //   });
   //   audio.bind("abort", function(f) {
   //     console.log("Event abort: "+f);
   //   });
   //   audio.bind("canplay", function(f) {
   //     console.log("Event canplay: "+f);
   //   });
   //   audio.bind("emptied", function(f) {
   //     console.log("Event emptied: "+f);
   //   });
    // audio.bind("ended", function(f) {
    //   console.log("Event ended: "+f);
    // });
   //   audio.bind("error", function(f) {
   //     console.log("Event error: "+f);
   //   });
   //   audio.bind("loadeddata", function(f) {
   //     console.log("Event loadeddata: "+f);
   //   });
   //   audio.bind("loadstart", function(f) {
   //     console.log("Event loadstart: "+f);
   //   });
   //  audio.bind("pause", function(f) {
   //    zzpause = f;
   //    console.log("Event pause: "+f);
   //  });
   // audio.bind("play", function(f) {
   //   console.log("Event play: "+f);
   // });
   // audio.bind("playing", function(f) {
   //   console.log("Event playing: "+f);
   // });
   // audio.bind("progress", function(f) {
   //   console.log("Event progress: "+f);
   // });
   // audio.bind("ratechange", function(f) {
   //   console.log("Event ratechange: "+f);
   // });
   // audio.bind("seeked", function(f) {
   //   console.log("Event seeked: "+f);
   // });
   // audio.bind("seeking", function(f) {
   //   console.log("Event seeking: "+f);
   // });
   // audio.bind("stalled", function(f) {
   //   console.log("Event stalled: "+f);
   // });
   //   audio.bind("suspend", function(f) {
   //     console.log("Event suspend: "+f);
   //   });
   //   audio.bind("timeupdate", function(f) {
   //     zztime = f;
   //     console.log("Event timeupdate: "+f);
   //   });
   //   audio.bind("volumechange", function(f) {
   //     console.log("Event volumechange: "+f);
   //   });
   //   audio.bind("waiting", function(f) {
   //     console.log("Event waiting: "+f);
   //   });
  // }
}

function PlaybackEdge(endpt) {
  this.endpt = endpt;
  this.play = function() {
    if( playback && this.endpt == "stop" ) {
      playback.stop();
    }
  }
  this.compute_position = function() {
    var a = $("#audio");
    return { x: a.offset().left + 0.5*a.width(),
             y: a.offset().top  + 0.5*a.height() };
  }
}
register("playback", "new PlaybackEdge(arg1)");

function Click(id, key) {
  this.id = id;
  this.key = key;
  this.play = function() {
    $(".fake_hover").removeClass("fake_hover"); // Close all menus.
    $(".fake_pointer").html('<img src="images/click.svg">');
    window.setTimeout(function() {
      $(".fake_pointer").html('<img src="images/mouse.svg">');
    }, 500);
  }
  this.compute_position = function() {
    var a = $(this.id);
    return { x: a.offset().left + 0.5*a.width(),
             y: a.offset().top  + 0.5*a.height() };
  }
}
register("click", "new Click(arg1, arg2)");

function MouseMove(pt) {
  this.pt = pt;

  this.maybe_skip = function(other) {
    if( this.type == other.type && this.event == other.event) {
      return true;
    }
    return false;
  }

  this.play = function() {
    if( this.type.match("up")) {
      $(".fake_pointer").html('<img src="images/mouse.svg">');
    }
    if( this.type.match("down")) {
      $(".fake_pointer").html('<img src="images/click.svg">');
    }
  }

  this.compute_position = function() {
    var s = w2s(this.pt);
    if( this.type[0] == "s" ) {
      var a = spacetime_canvas;
      return { x: (a.offset().left*1.0) + s.x,
               y: (a.offset().top *1.0) + s.y };
    } else {
      var a = anim_canvas;
      var x = a.offset().left*1.0;
      var y = a.offset().top*1.0;
      var h = a.height();
      return { x: x + s.x, y: y + this.pt.z * h };
    }
  }
}
register("s_move", "new MouseMove(arg1)");
register("s_up",   "new MouseMove(arg1)");
register("s_down", "new MouseMove(arg1)");
register("s_drag", "new MouseMove(arg1)");
register("a_move", "new MouseMove(arg1)");
register("a_up",   "new MouseMove(arg1)");
register("a_down", "new MouseMove(arg1)");
register("a_drag", "new MouseMove(arg1)");

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

function subtitleChange() {
  if( $("#view_subtitles").prop('checked') ) {
    var filename = "lessons/help.html";
    var page = "";
    if( recording ) {
      recording.pager.display();
    }
    if( playback ) {
      playback.pager.display();
    }
  }
}

function PageTurner(name) {
  this.time_stamps = [0];
  this.filename = name;
  this.number = 0;

  this.add_time = function(t) {
    this.number = this.find_index(t);
    this.time_stamps.splice(this.number, 0, t);
    this.display();
  }

  this.advance_to = function(t) {
    var n = this.find_index(t);
    var display_needed = (n != this.number);
    this.number = n;
    if( display_needed ) {
      this.display();
    }
  }

  this.display = function() {
    var name = "lessons/"+this.filename + ".html";
    if( this.number > 0 ) {
      name = name + "#page"+this.number;
    }
    $("#debug_audio").html("page "+this.number + ", hover:"+menu_hover_allowed);
    if( $("#view_subtitles").prop('checked') ) {
      window.open(name, "subtitles");
    }
  }

  this.find_index = function(t) { // Find n so that t[n] < t < t[n+1].
    var n = this.number;
    if( n < 0 ) n = 0;
    if( n >= this.time_stamps.length ) n = this.time_stamps.length-1;
    if( this.time_stamps.length == 0 ) {
      n = 0;
    } else {
      while( n+1 < this.time_stamps.length &&
          this.time_stamps[n+1] < t ) {
        n++;
      }
      while( n > 0 && this.time_stamps[n] > t ) {
        n--;
      }
    }
    return n;
  }
}
register("pager", "new PageTurner(arg1)");

action_table.dump_scene = function() {
  console.log("Current scene. v = " + scene.velocity);
  console.log(scene);
  var found = false;
  for(var item = scene.drawables.head; item; item = item.next_ns) {
    if (scene.center == item) {
      found = true;
      if (item.center) {
        console.log("CENTER: " + item.name + " " + item.type + ", " + item.center);
      } else {
        console.log("CENTER DOESN't KNOW IT: " + item.name + " " + item.type + ", " + item.center);
      }
    } else {
      if (item.center) {
        console.log("THINKS IT's CENTER: " + item.name + " " + item.type + ", " + item.center);
      } else {
        console.log(" " + item.name + " " + item.type + ", " + item.center);
      }
    }
  }
  if (scene.center && !found) {
    console.log("MISSING CENTER: " + scene.center.name + " " + scene.center.type + ", " + scene.center.center);
  }
}

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
