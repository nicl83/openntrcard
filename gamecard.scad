// Alignment peg diameter
peg_dia = 1.8;

// Board standoff size
standoff = [3.5,2.9,2.3];

// Size of well for PCB
ds_card_center = [30.3,32.6,3];

/* [Hidden] */
$fn = 10;

// assume a cuboid DS card in a vacuum...
ds_card_cube = [32.75,34.85,3.6];
card_center_offset = [
    (ds_card_cube[0] - ds_card_center[0])/2,
    (ds_card_cube[1] - ds_card_center[1])/2,
    1 // sorry for magic...
];

ds_card_pins = 17;
pin_width = 1.5;
pin_spacing = 26.6/ds_card_pins;

ds_card_side_profile = [
    [0,0],
    [32,0],
    [34.85,2.8],
    [34.85,3.6],
    [32,3.6],
    [32,2.8],
    [0,2.8]
]; // Polygon points
module ds_card_primitive() {
    translate([32.75,34.85,0])
    rotate([90,0,-90])
    linear_extrude(32.75)
    polygon(ds_card_side_profile);
}

module ds_card_pins_module() {
    difference() {
        cube([29.8,12.1,1.3]);
        translate([1.6,0,0])
        for (i = [0 : ds_card_pins-1]) {
            translate([i*pin_spacing,0,0])
            cube([1.5,10.5,1.3]);
        }
    }
}

module alignment_peg() {
    cylinder(h=ds_card_cube[2],d=peg_dia);
}

// assembly
module ds_card_assembly() {
    difference() {
        ds_card_primitive();
        translate(card_center_offset)
            cube(ds_card_center);
        translate([3.5,0,0])
            cube([26.6,10.5,2.4]);
        translate([31.9,0,0]) // side cut A
            cube([
                1,
                ds_card_cube[1],
                1
            ]);
        translate([0,0,0]) // side cut B
            cube([
                2,
                5.9,
                2
            ]);
        translate([0,12.3,0]) // side cut C
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
    
    // alignment pegs
    translate([8.1,28.6,0]) alignment_peg();
    translate([ds_card_cube[0]-8.1,28.6,0]) alignment_peg();
    
    translate([3,13.8,0]) alignment_peg();   
    translate([ds_card_cube[0]-3,13.8,0]) alignment_peg();
    
    // board standoffs
    translate([0,20.5,0]) cube(standoff);
    translate([ds_card_cube[0]-standoff[0],20.5,0]) cube(standoff);
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
