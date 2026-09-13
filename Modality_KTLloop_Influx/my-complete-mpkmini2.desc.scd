/*
* todo:
* test on osx
m.free;
MKtl.find(\midi);
m = MKtl(\mpk2, "akai-mpkmini2");
m.gui;
m.explore;
MIDIExplorer.verbose = true;
MIDIExplorer.verbose = false; // turn it off again
m.explore(false);
m.createDescriptionFile;
MKtl(\x, "*mpk*2").gui;
m.trace;
m.trace(false);
*/
"my customized description version, with all the programs mapped, according to my own edit in MPK MiniMKII editor".postln;
(
deviceName: "MPKmini2",
protocol: 'midi',
deviceType: 'midiKeyboard',
elementTypes: [\knob, \kney, \pad, \bend],
status: (
	linux: "tested and working",
	osx: "tested desc only, looks ok, no gui info yet. 2016-03-17, adc",
	win: "tested and working"),

idInfo: "MPKmini2",

deviceInfo: (
	vendorURI: 'http://www.akaipro.com/product/mpk-mini-mkii',
	manualURI: 'http://6be54c364949b623a3c0-4409a68c214f3a9eeca8d0265e9266c0.r0.cf2.rackcdn.com/988/documents/MPK%20mini%20-%20User%20Guide%20-%20v1.0.pdf',
	features: [\pianoKey, \pad, \knob, \bender],
	notes:
	"Uses only ```Program 1```.\n"
	"To use the other programs use first: [MPK MiniMKII editor](http://www.akaipro.com/product/mpk-mini-mkii#downloads)\n"
	"avoiding more mapping overlaping as occours in the defaults.\n"
	"Accidental ```Prog-Change``` activation on the device needs to be reverted by ```Bank A/B```.\n",
	longName: "AKAI MPKmini mk2"
),

elementsDesc: (
	elements:[

		///////////// PROGRAM 1 /////////////
		(
			key: \p0,
			shared: (page: 0),
			elements:
			[

				// ------ pad BANK A (0..7), BANK B (8..15) note on-off -------------
				(
					key: \pad,
					shared: ( type: \pad, midiChan: 0, spec: \midiVel, groupType: \noteOnOff ),
					elements: ( 0..15 ).collect{ |i|
						(
							midiNum: i,
							key: (i+1).asSymbol,
							style:( row: (i div:4), column: 2 + (i % 4))
						)
					}
				),

				// ------ pad BANK A (0..7), BANK B (8..15) CC -------------
				(
					key: \bt,
					shared: ( midiChan: 0, midiMsgType: \cc, type: \button, spec: \but, ioType: \inout ),
					elements: ( 0..15 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i,
							style:( row: 4.5 + (i div:4), column: 2 + (i % 4))
						)
					}
				),

				// ------ knob -------------
				(
					key: \kn,
					shared: ( type: \knob, midiChan: 4, spec: \midiCC, midiMsgType: \cc ),
					elements: ( 0..7 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i, style:( row: i div:4, column: 6 + (i % 4) ),
						)
					}
				),

				//////// piano key //////////
				(
					key: \pkey,
					shared: ( midiChan: 4, type: \pianoKey, groupType: \noteOnOff, spec: \midiVel ),
					elements:
					(0..120).collect { |i|
						var pos = Piano.pos( i % 48, 0);
						(
							key: i.asSymbol,
							midiNum: i,
							style: (
								row: ( i div: 48 * 1.5 ) + (pos.y * 0.6),
								column: 10 + (pos.x * 0.65 % 25),
								color: pos.color,
								width: 0.9,
								height: 0.75,
							)
						)
					}
				),
				// ------- bend ------------
				( key: \bUp,
					midiChan: 4, \midiNum: 30, midiMsgType: \cc, type: \slider, spec: \midiCC, style: (row: 0, column:0.5, width: 0.84, height: 1.75 )
				),
				( key: \bX,
					midiChan: 4, midiMsgType: \bend, type: \xfader, spec: \midiBend, style: (row: 1.66, column:0, width: 1.9 )
				),
				( key: \bDn,
					midiChan: 4, \midiNum: 31, midiMsgType: \cc, type: \slider, spec: \midiCC, style: (row: 2.5, column:0.5, width: 0.84, height: 1.75 )
				),
			]
		),

		///////////// PROGRAM 2 /////////////
		(
			key: \p1,
			shared: (page: 1),
			elements:
			[

				// ------ pad BANK A (0..7), BANK B (8..15) note on-off -------------
				(
					key: \pad,
					shared: ( type: \pad, midiChan: 1, spec: \midiVel, groupType: \noteOnOff ),
					elements: ( 0..15 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i,
							style:( row: (i div:4), column: 2 + (i % 4) )
						)
					}
				),

				// ------ pad BANK A (0..7), BANK B (8..15) CC -------------
				(
					key: \bt,
					shared: ( type: \pad, midiChan: 1, spec: \but, midiMsgType: \cc, ioType: \inout ),
					elements: ( 0..15 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i,
							style:( row: 4.5 + (i div:4), column: 2 + (i % 4))
						)
					}
				),


				// ------ knob -------------
				(
					key: \kn,
					shared: ( type: \knob, midiChan: 5, spec: \but, midiMsgType: \cc ),
					elements: ( 0..7 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i, style:( row: i div:4, column: 6 + (i % 4) ),
						)
					}
				),

				//////// piano key //////////
				(
					key: \pkey,
					shared: ( midiChan: 5, type: \pianoKey, groupType: \noteOnOff, spec: \midiVel ),
					elements:
					(0..120).collect { |i|
						var pos = Piano.pos( i % 25, 0);
						(
							key: i.asSymbol,
							midiNum: i,
							style: (
								row: ( i div: 25 * 1.5 ) + (pos.y * 0.6),
								column: 10 + (pos.x * 0.65 % 25),
								color: pos.color,
								width: 0.9,
								height: 0.75,
							)
						)
					}
				),
				// ------- bend ------------
				( key: \bUp,
					midiChan: 5, \midiNum: 30, midiMsgType: \cc, type: \slider, spec: \midiCC, style: (row: 0, column:0.5, width: 0.84, height: 1.75 )
				),
				( key: \bX,
					midiChan: 5, midiMsgType: \bend, type: \xfader, spec: \midiBend, style: (row: 1.66, column:0, width: 1.9 )
				),
				( key: \bDn,
					midiChan: 5, \midiNum: 31, midiMsgType: \cc, type: \slider, spec: \midiCC, style: (row: 2.5, column:0.5, width: 0.84, height: 1.75 )
				),
			]
		),

		///////////// PROGRAM 3 /////////////
		(
			key: \p2,
			shared: (page: 2),
			elements:
			[

				// ------ pad BANK A (0..7), BANK B (8..15) note on-off -------------
				(
					key: \pad,
					shared: ( type: \pad, midiChan: 2, spec: \midiVel, groupType: \noteOnOff ),
					elements: ( 0..15 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i, style:( row: (i div:4), column: 2 + (i % 4) )
						)
					}
				),

				// ------ pad BANK A (0..7), BANK B (8..15) CC -------------
				(
					key: \bt,
					shared: ( type: \pad, midiChan: 2, spec: \but, midiMsgType: \cc, ioType: \inout ),
					elements: ( 0..15 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i,
							style:( row: 4.5 + (i div:4), column: 2 + (i % 4))
						)
					}
				),

				// ------ knob -------------
				(
					key: \kn,
					shared: ( type: \knob, midiChan: 6, spec: \midiCC, midiMsgType: \cc ),
					elements: ( 0..7 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i, style:( row: i div:4, column: 6 + (i % 4) )
						)
					}
				),

				//////// piano key //////////
				(
					key: \pkey,
					shared: ( midiChan: 6, type: \pianoKey, groupType: \noteOnOff, spec: \midiVel ),
					elements:
					(0..120).collect { |i|
						var pos = Piano.pos( i % 25, 0);
						(
							key: i.asSymbol,
							midiNum: i,
							style: (
								row: ( i div: 25 * 1.5 ) + (pos.y * 0.6),
								column: 10 + (pos.x * 0.65 % 25),
								color: pos.color,
								width: 0.9,
								height: 0.75,
							)
						)
					}
				),
				// ------- bend ------------
				( key: \bUp,
					midiChan: 6, \midiNum: 30, midiMsgType: \cc, type: \slider, spec: \midiCC, style: (row: 0, column:0.5, width: 0.84, height: 1.75 )
				),
				( key: \bDn,
					midiChan: 6, \midiNum: 31, midiMsgType: \cc, type: \slider, spec: \midiCC, style: (row: 2.5, column:0.5, width: 0.84, height: 1.75 )
				),
				( key: \bX,
					midiChan: 6, midiMsgType: \bend, type: \xfader, spec: \midiBend, style: (row: 1.66, column:0, width: 1.9 )
				),
			]
		),

		///////////// PROGRAM 4 /////////////
		(
			key: \p3,
			shared: (page: 3),
			elements:
			[

				// ------ pad BANK A (0..7), BANK B (8..15) note on-off -------------
				(
					key: \pad,
					shared: ( type: \pad, midiChan: 3, spec: \midiVel, groupType: \noteOnOff ),
					elements: ( 0..15 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i, style:( row: (i div:4), column: 2 + (i % 4) )
						)
					}
				),

				// ------ pad BANK A (0..7), BANK B (8..15) CC -------------
				(
					key: \bt,
					shared: ( type: \pad, midiChan: 3, spec: \but, midiMsgType: \cc, ioType: \inout ),
					elements: ( 0..15 ).collect{ |i|
						(
							key: (i+1).asSymbol,
							midiNum: i,
							style:( row: 4.5 + (i div:4), column: 2 + (i % 4))
						)
					}
				),

				// ------ knob -------------
				(
					key: \kn,
					shared: ( type: \knob, midiChan: 7, spec: \midiCC, midiMsgType: \cc ),
					elements: ( 0..7 ).collect{ |i|
						(
							key: i.asSymbol,
							midiNum: i, style:( row: i div:4, column: 6 + (i % 4) )
						)
					}
				),

				//////// piano key //////////
				(
					key: \pkey,
					shared: ( midiChan: 7, type: \pianoKey, groupType: \noteOnOff, spec: \midiVel ),
					elements:
					(0..120).collect { |i|
						var pos = Piano.pos( i % 25, 0);
						(
							key: i.asSymbol,
							midiNum: i,
							style: (
								row: ( i div: 25 * 1.5 ) + (pos.y * 0.6),
								column: 10 + (pos.x * 0.65 % 25),
								color: pos.color,
								width: 0.9,
								height: 0.75,
							)
						)
					}
				),
				// ------- bend ------------
				( key: \bUp,
					midiChan: 7, \midiNum: 30, midiMsgType: \cc, type: \slider, spec: \midiCC, style: (row: 0, column:0.5, width: 0.84, height: 1.75 )
				),
				( key: \bDn,
					midiChan: 7, \midiNum: 31, midiMsgType: \cc, type: \slider, spec: \midiCC, style: (row: 2.5, column:0.5, width: 0.84, height: 1.75 )
				),
				( key: \bX,
					midiChan: 7, midiMsgType: \bend, type: \xfader, spec: \midiBend, style: (row: 1.66, column:0, width: 1.9 )
				),
			]
		),
	]

)
);

// TODO:
// make a version for the standard mapping for general use and make a PR in Modality GitHub
// midiMsgType: \program,
/*(
~descInput = (
idInfo: ~idInfo, // still around from above
protocol: \midi,
elementsDesc: (
elements: [
(
key: 'prog',
type: 'knob',
midiMsgType: \program, // program does not need \midiNum
midiChan: 0,
spec: \midiProgram,
ioType: \in
)
]
)
)
);*/
