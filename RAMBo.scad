// (c) 2013 Felipe C. da S. Sanches <fsanches@metamaquina.com.br>,
// Rafael H. de L. Moretti <moretti@metamaquina.com.br>
// Licensed under the terms of the GNU General Public License
// version 3 (or later).

include <Metamaquina2.h>;
use <rounded_square.scad>;

hexspacer_length = 35; //considering the height of the connectors and components
nylonspacer_length = 6;
RAMBo_pcb_thickness = 2;
M3_bolt_head = 3;
RAMBo_cover_thickness = 3;
RAMBo_thickness = nylonspacer_length + RAMBo_pcb_thickness + hexspacer_length + RAMBo_cover_thickness + M3_bolt_head;
RAMBo_border = 3.7;
RAMBo_width = 103;
RAMBo_height = 104;
epsilon = 0.05;

module PSU_connector(){
  //Power supply connector

  //Connector dimensions
  conn_thickness = 9.8;
  conn_width = 30.5;
  conn_height = 15.1;
  epsilon = 0.05;

  //Bolt slots
  bolt_diameter = 3.5;
  bolts_offset = -2.3;

  if (render_rubber)
  color(rubber_color)
  difference() {
    cube([conn_thickness, conn_width, conn_height]);

    for (i = [1 : 6]) {
      translate([conn_thickness/2,bolts_offset + 5*i,-epsilon]) {
       cylinder(conn_height+2*epsilon,r=bolt_diameter/2, $fn=20);
       }
    }
  }
}

acrylic_color = [1, 0.5, 0.5, 0.7];//red-transparent
module RAMBo_cover_curves(border=0){
  difference(){
    translate([-border,-border])
    rounded_square([RAMBo_width+2*border, RAMBo_height+2*border], corners=[3,3,3,3]);
    RAMBo_holes();
  }
  //TODO: Add logo / labels ?
}

module RAMBo_cover(){
  if (render_acrylic){
    color(acrylic_color)
    linear_extrude(height=RAMBo_cover_thickness)
    RAMBo_cover_curves();
  }
}

module RAMBo(){
  for (x=[RAMBo_border, RAMBo_width-RAMBo_border]){
    for (y=[RAMBo_border, RAMBo_height-RAMBo_border]){
      translate([x,y]){
        nylonspacer();

        translate([0,0,nylonspacer_length+RAMBo_pcb_thickness]){
          hexspacer();
          translate([0,0,hexspacer_length+RAMBo_cover_thickness]){
            //bolt head
            if (render_metal)
            color(metal_color)
            cylinder(r=3, h=M3_bolt_head, $fn=20);
          }
        }
      }
    }
  }

  translate([0,0,nylonspacer_length]){
    RAMBo_pcb();

    translate([0,0,RAMBo_pcb_thickness]){
      translate([100,60])
      PSU_connector();

      translate([0,0,hexspacer_length])
      RAMBo_cover();
    }
  }
}

module RAMBo_volume(){
//This is the space that is required for the RAMBo Electronics.
//We must make sure there's enough space so that the electronics doesn't
//take up part of the printer's max build volume.
  %cube([RAMBo_width, RAMBo_height, RAMBo_thickness]);
}

module RAMBo_wiring_holes(){
  //This is a big hole for passing all wires from one side of
  // the panel to the other side:
  translate([RAMBo_width/2, RAMBo_height/2])
  rotate(90)
  hull()
  for (i=[-1,1])
    translate([i*15,0])
    circle(r=10, $fn=20);


  //These are ziptie holes for making sure the individual wires
  // are kept in place, near their connection point in the RAMBo PCB:

  //X & Y motor cables
  translate([20,10])
  rotate(90)
  zip_tie_holes();

  //Z left and right motor cables
  translate([50,10])
  rotate(90)
  zip_tie_holes();

  //Extruder motor cable
  translate([80,10])
  rotate(90)
  zip_tie_holes();

  //Thermistor cables
  translate([95,50])
  zip_tie_holes();

  //Power Supply cables
  translate([95,85])
  zip_tie_holes();

  { //Endstop cables
    //TODO: Choose one before manufacturing:

    // Option 1: This is closer to the connector but may leave the cables exposed in the back of the machine
#    translate([10,50])
    zip_tie_holes();

    // Option 2: This is a bit far, but the cables would be less exposed in the upper portion of the pcb mount area
#    translate([80,95])
    rotate(90)
    zip_tie_holes();
  }

  //Extruder heater cable
  translate([20,95])
  rotate(90)
  zip_tie_holes();

  //HeatedBed heater cable
  translate([50,95])
  rotate(90)
  zip_tie_holes();
}

module RAMBo_holes(){
  translate([RAMBo_border, RAMBo_border])
  circle(r=m4_diameter/2, $fn=20);

  translate([RAMBo_border, RAMBo_height-RAMBo_border])
  circle(r=m4_diameter/2, $fn=20);

  translate([RAMBo_width-RAMBo_border, RAMBo_border])
  circle(r=m4_diameter/2, $fn=20);

  translate([RAMBo_width-RAMBo_border, RAMBo_height-RAMBo_border])
  circle(r=m4_diameter/2, $fn=20);
}

module RAMBo_pcb(){
  if (render_pcb){
    color(pcb_color){
      linear_extrude(height=RAMBo_pcb_thickness){
        difference(){
          square([RAMBo_width, RAMBo_height]);
          RAMBo_holes();
        }
      }
    }
  }
}

white_nylon_color = [1, 1, 0.8];
module nylonspacer(D=8, d=m4_diameter, h=nylonspacer_length){
  if (render_nylon){
    color(white_nylon_color)
    linear_extrude(height=h)
    difference(){
      circle(r=D/2, $fn=20);
      circle(r=d/2, $fn=20);
    }
  }
}

module hexspacer(D=8, d=m3_diameter, h=hexspacer_length){
  if (render_metal){
    color(metal_color)
    linear_extrude(height=h)
    difference(){
      circle(r=D/2, $fn=6);
      circle(r=d/2, $fn=20);
    }
  }
}

