/* [General] */
// Create slats between contacts (requires hi-res printer!)
contact_slats = false;

/* [Alignment Peg Dimensions] */

// Alignment peg diameter
peg_dia = 1.8;

// Vertical offset of top pegs
top_peg_vert_offset = 28.6;

// Horizontal offset of top pegs
top_peg_horiz_offset = 8.1;

// Vertical offset of middle pegs
mid_peg_vert_offset = 13.8;

// Horizontal offset of middle pegs
mid_peg_horiz_offset = 3;

/* [Thickness Adjustment] */

// Front-half depth (label-side)
label_depth = 0.8;

// How much should the PCB be raised from the bottom of the well?
pcb_standoff_height = 2.3;

/* [Standoff Dimensions] */
// Vertical offset for board standoffs
standoff_vert_offset = 20.5;

// Board standoff size
standoff = [2.5,2.9,pcb_standoff_height];

/* [Hidden] */
$fn = 10;

// Cartridge depth (including front-half)
card_depth = 3.6;

// Size of well for PCB
ds_card_center = [30.3,32.6,3];

// Depth of plastic behind PCB
behind_pcb_depth = card_depth - label_depth - ds_card_center[2];

// assume a cuboid DS card in a vacuum...
// Overall dimensions of the cards, used for other calculations
ds_card_cube = [32.75,34.85,card_depth];
card_center_offset = [
    (ds_card_cube[0] - ds_card_center[0])/2,
    (ds_card_cube[1] - ds_card_center[1])/2,
    1 // sorry for magic...
];

// Polygon defining the side profile of a DS cartridge
ds_card_side_profile = [
    [0,0],
    [32,0],
    [34.85,card_depth - label_depth],
    [34.85,card_depth],
    [32,card_depth],
    [32,card_depth - label_depth],
    [0,card_depth - label_depth]
];

// Game Card contact dimensions
ds_card_pins = 17; // number of contacts
pin_width = 1.5; // width of an individual contact
pin_spacing = 26.6/ds_card_pins;

// Module using the side-profile polygon
// to create a solid DS Card (with lip for top half)
module ds_card_primitive() {
    translate([32.75,34.85,0])
    rotate([90,0,-90])
    linear_extrude(32.75)
    polygon(ds_card_side_profile);
}

// Module defining the plastic between contacts
// NOTE: does not print correctly on Ender 3 at highest res
// not a priority as this plastic is not required
module ds_card_pins_module() {
    translate([0,0,behind_pcb_depth])
    difference() {
        cube([29.8,12.1,1.3]);
        translate([1.6,0,0])
        if (contact_slats) {
            for (i = [0 : ds_card_pins-1]) {
                translate([i*pin_spacing,0,0])
                cube([1.5,10.5,1.3]);
            }
        } else {
            cube([
                ds_card_pins*pin_spacing,
                10.5,
                pcb_standoff_height
            ]);
        }
    }
}

// Shorthand module for the PCB alignment peg
// just a cylinder w/ fixed vars
module alignment_peg() {
    cylinder(h=ds_card_cube[2],d=peg_dia);
}

// assembly
// puts everything together
module ds_card_assembly() {
    difference() {
        ds_card_primitive();
        translate(card_center_offset)
            cube(ds_card_center);

        // Cutout for cartridge pins
        // TODO make less magic-numbery
        translate([3.5,0,0])
            cube([26.6,10.5,2.4]);
        
        // side cut "A"
        // long groove down left side of cartridge
        translate([31.9,0,0])
            cube([
                1,
                ds_card_cube[1],
                1
            ]);
        // side cut "B"
        // first cut on right side, near contacts
        translate([0,0,0])
            cube([
                2,
                5.9,
                2
            ]);
        // side cut "C"
        // second cut on right side, above "B"
        translate([0,12.3,0])
            cube([
                2,
                3.9,
                2
            ]);
        
    }
    // compensation for side cuts
    translate([0,0,2]) 
        cube([2,16.2,0.5]);
    translate([2,12.3,card_center_offset[2]])
        cube([1,3.9,1]);
    
    translate([1.9,0,1])
    ds_card_pins_module();
    
    // top alignment pegs
    translate([
        top_peg_horiz_offset,
        top_peg_vert_offset,
        0
    ]) alignment_peg();
    translate([
        ds_card_cube[0]-top_peg_horiz_offset,
        top_peg_vert_offset,
        0
    ]) alignment_peg();
    
    // middle alignment pegs
    translate([
        mid_peg_horiz_offset,
        mid_peg_vert_offset,
        0
    ]) alignment_peg();
    translate([
        ds_card_cube[0]-mid_peg_horiz_offset,
        mid_peg_vert_offset,
        0
    ]) alignment_peg();
    
    // board standoffs
    translate([
        1,
        standoff_vert_offset,
        0
    ]) cube(standoff);
    translate([
        ds_card_cube[0]-(standoff[0]+1),
        standoff_vert_offset,
        0
    ]) cube(standoff);
}

// render
// clean up stray edges
intersection() {
    ds_card_primitive();
    ds_card_assembly();
}

// front of card, for funnies
translate([
    ds_card_cube[0] + 5,
    0,
    0
])

// card "lid"
difference() {
    union() {
        cube([ds_card_cube[0],ds_card_cube[1],3.75-ds_card_cube[2]]);
        translate([0,2.85,0]) {
            difference() {
                cube([ds_card_cube[0],ds_card_cube[1]-2.85,3.75-2.8]);
                translate([
                    card_center_offset[0],
                    card_center_offset[1]-2.85,
                    0
                ])
                    cube(ds_card_center);
            }
        }
    }
    translate([
        card_center_offset[0]+2,
        card_center_offset[1]+2,
        0
    ])
        cube([
            ds_card_center[0]-4,
            ds_card_center[1]-4,
            ds_card_center[2]
        ]);
}
