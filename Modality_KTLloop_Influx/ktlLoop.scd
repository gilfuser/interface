
{
	// This document depends on and is linked to touchOSC-Modality.scd

	(
		// make a KtlLoop for them
		// KTLloop ////////////////
		~loopOrb1 = KtlLoop(\orb1);
		~loopOrb1.object = Ndef('orb1'); //KTLloop
		~loopOrb2 = KtlLoop(\orb2);
		~loopOrb2.object = Ndef('orb2'); //KTLloop
		~loopOrb3 = KtlLoop(\orb3);
		~loopOrb3.object = Ndef('orb3'); //KTLloop
		[~loopOrb1, ~loopOrb2, ~loopOrb3].collect( { |i| i.looped = true; i.rescaled = true } );

		KtlLoopGui(~loopOrb1, 10, bounds: 330@180);
		KtlLoopGui(~loopOrb2, 10, bounds: 330@180);
		KtlLoopGui(~loopOrb3, 10, bounds: 330@180);
		// the object to control

		q.theLoop = ~loopOrb1;

		// which control params to record
		q.paramsToRecord = {
			q.theLoop.paramsToRecord_(
				q.sliders.elAt( ( 1..(q.numParams[q.lastIndice] - 1) )).collect(_.name) )
		};
		q.paramsToRecord;


		// which recorded controller params to use for setting which process params:

		q.theLoop.ktlMap_( q.ctrlParamPairs );

	);

	(
		// connect the MKtl and the KtlLoop:
		~rec = { |el|
			// "rec: ".post;
			var event = (\type: \set).put(el.name, el.value);
			q.theLoop.recordEvent( event );
			event.postln;
		};
		q.sliders.elAt( ( 1..(q.numParams[q.lastIndice] - 1) ) ).do { |sl i|
			sl.removeAction(~rec)
		};

		~sliders.elAt(1).removeAction(~rec)
	)


	// for testing everything so far:
// start recording by code:
q.theLoop.startRec;
// now move sliders ... then
~loop.stopRec;

// -> should get a recorded list info post:
// KtlLoop('kel') stopRec; // recorded list[2] with 145 events.

~loopOrb1.list; // a long list
~loopOrb1.list.size; // and its size

// should replay the movements that were recorded:
~loopOrb1.play;


	(
		// make small element groups and so, having lots of ktlloops
		~elLoopa1 = MKtlElementGroup(\loop1, k, k.elAt(\say, \sl, [0, 1]));
		// connect them: use action of the group of all sliders  to record
		~elLoopa1.action = { |el|
			var event = (\type: \set).put(el.name, el.value);
			~loop1.recordEvent( event );
		};
	);

	// {

				q.tosca.sendMsg( "/orbs/toggle18/visible", 0 );
				q.tosca.sendMsg( "/orbs/label16/visible", 0 );

		q.hasRecorded = false;
		q.isPlaying = false;

	k.elAt(\recPlay0).action = { |el|
		if ( el.value == 1 and: q.hasRecorded == false and: q.isPlaying == false )
		{
			q.tosca.sendMsg( "/orbs/toggle1/color", "red" );
			q.tosca.sendMsg( "/orbs/label15/color", "yellow" );
			q.theLoop.startRec;
			q.hasRecorded = true;

		};
		if ( el.value == 0 and: q.hasRecorded == true and: q.isPlaying== false )
		{
			q.tosca.sendMsg( "/orbs/toggle1/color", "green" );
			q.tosca.sendMsg( "/orbs/label15", ">>>>>" );
			q.tosca.sendMsg( "/orbs/label15/color", "red" );
			q.tosca.sendMsg( "/orbs/push1/visible", 1 );
			q.tosca.sendMsg( "/orbs/label16/visible", 1 );
			q.theLoop.stopRec;
			q.theLoop.play;
			q.isPlaying = true;

		};
	};

	k.elAt(\recPlay1).action = { |el|
		if ( q.hasRecorded == true and: q.isPlaying == true )
		{
			q.tosca.sendMsg( "/orbs/toggle1/color", "gray" );
			q.tosca.sendMsg( "/orbs/push1/color", "gray" );
			q.tosca.sendMsg( "/orbs/label15/color", "red" );
			q.tosca.sendMsg( "/orbs/label15", "REC" );
			q.tosca.sendMsg( "/orbs/label16", "[ STOP ]" );
			q.theLoop.stop;
			q.isPlaying = false;
			// q.hasRecorded = false;

		};
		if ( q.hasRecorded == true and: q.isPlaying == false )
		{
			q.tosca.sendMsg( "/orbs/label16", "[ PLAY ]" );
			q.tosca.sendMsg( "/orbs/label16/color", "red" );
			q.tosca.sendMsg( "/orbs/push1/color", "green" );
			q.theLoop.play;
			q.isPlaying = true;

		};
	};

	// };

}.fork;

(
	w = Window("KtlLoop.help", Rect(0,500, 400, 550)).front;
	w.view.addFlowLayout;
	Slider2D(w, Rect(0,0,190,190))
	.action_({ |sl|

		// put params into an event,
		var event = (lx: sl.x, ly: sl.y);
		// store it,
		k.recordEvent(event.put(\type, \set));
		// and set the object from it
		k.setuObj(event);
	});
	Slider2D(w, Rect(0,0,190,190))
	.action_({ |sl|
		var event = (rx: sl.x, ry: sl.y);
		k.recordEvent(event.put(\type, \set));
		k.setuObj(event);
	});

	// make an eventloopgui for KtlLoop
	KtlLoopGui(~loop1, parent: w, bounds: 330@180);

	w.view.decorator.nextLine.shift(0, 10);

	// and an NdefGui for the Ndef
	NdefGui(Ndef(\form), 6, w);
)

0.2.wait;

// LOOP A - SUS and REL ///////////////////////////////////////////////////////////////////

~loop1a2 = KtlLoop(\loopa2);
~loop1a2.object = Ndef(\aset);
~ela2 = k.elAt(\p0, \k, [2, 3]);
~loop1a2.paramsToRecord_( ~ela2.collect(_.name));
~loop1a2.ktlMap_( ( p0_k_2: \sus, p0_k_3: \rel ) );
~loop1a2.looped = true;
~elLoopa2 = MKtlElementGroup(\loopa2, k, ~ela2);

~elLoopa2.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1a2.recordEvent( event ) };


k.elAt(\pca05).action = { |el|
	if ( (el.value == 1)) { "Rec A: Sustain + Release".postln; ~loop1a2.startRec; };
	if ( (el.value == 0) ) { "Play A: Sustain + Release ".postln; ~loop1a2.stopRec; ~loop1a2.play }
};
0.2.wait;

/////////////////////////////// Skip Stretch ///////////////////////////////////////

// LOOP A - DIST, FOLD and SLIDE ///////////////////////////////////////////////////

~loop1a3 = KtlLoop(\loopa3);
~loop1a3.object = Ndef(\asay);
~loop1a3.paramsToRecord_( [k.elAt(\k05), k.elAt(\k06), k.elAt(\k07) ].collect(_.name) );
~loop1a3.ktlMap_( ( p0_k_5: \dist, p0_k_6: \fold, p0_k_7: \slide ) );
~loop1a3.looped = true;
~loop1a3.rescaled = true;
~elLoopa3 = MKtlElementGroup(\loopa3, k, k.elAt(\p0, \k, [5, 6, 7]));

~elLoopa3.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1a3.recordEvent( event ) };


k.elAt(\pca06).action = { |el|
	if ( (el.value == 1)) { "Rec A: Dist + Fold + Slide".postln; ~loop1a3.startRec; };
	if ( (el.value == 0) ) { "Play A: Dist + Fold + Slide ".postln; ~loop1a3.stopRec; ~loop1a3.play }
};
0.2.wait;

///////////////////////////////////// B ///////////////////////////////////////////////

// LOOP B - ATK and DEC ///////////////////////////////////////////////////////////////

~loop1b1 = KtlLoop(\loopb1);
~loop1b1.object = Ndef(\bset);  // COOL! You can change the object anytime!
~loop1b1.paramsToRecord_( [k.elAt(\k10), k.elAt(\k11) ].collect(_.name) );
~loop1b1.ktlMap_( ( p1_k_0: \atk, p1_k_1: \dec ) );
~loop1b1.looped = true;
~loop1b1.rescaled = true;
~elLoopb1 = MKtlElementGroup(\loopb1, k, k.elAt(\p1, \k, [0, 1]));

~elLoopb1.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1b1.recordEvent( event ) };


k.elAt(\pca14).action = { |el|
	if ( (el.value == 1)) { "REC B: Attack + Decay".postln; ~loop1b1.startRec; };
	if ( (el.value == 0) ) { "PLAY B: Attack + Decay".postln; ~loop1b1.stopRec; ~loop1b1.play }
};
0.2.wait;

// LOOP B - SUS, REL ///////////////////////////////////////////////////////////////

~loop1b2 = KtlLoop(\loopb2);
~loop1b2.object = Ndef(\bset);
~loop1b2.paramsToRecord_( [k.elAt(\k12), k.elAt(\k13) ].collect(_.name) );
~loop1b2.ktlMap_( ( p1_k_2: \sus, p1_k_3: \rel ) );
~loop1b2.looped = true;
~loop1b2.rescaled = true;
~elloopb2 = MKtlElementGroup(\loopb2, k, k.elAt(\p1, \k, [2, 3]));

~elloopb2.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1b2.recordEvent( event ) };


k.elAt(\pca15).action = { |el|
	if ( (el.value == 1)) { "REC B: Sustain + Release".postln; ~loop1b2.startRec; };
	if ( (el.value == 0) ) { "PLAY B: Sustain + Release".postln; ~loop1b2.stopRec; ~loop1b2.play }
};

// LOOP B - DIST, FOLD and SLIDE ///////////////////////////////////////////////////////////////

~loop1b3 = KtlLoop(\loopb3);
~loop1b3els = k.elAt(\p1, \k, [5, 6, 7]);
~loop1b3.object = Ndef(\bsay);  // COOL! You can change the object anytime!
~loop1b3.paramsToRecord_( ~loop1b3els.collect(_.name) );
~loop1b3.ktlMap_( ( p1_k_5: \dist, p1_k_6: \fold, p1_k_7: \slide ) );  // and the parameters to!
~loop1b3.looped = true;
~loop1b3.rescaled = true;
~elloopb3 = MKtlElementGroup(\loopb3, k, ~loop1b3els);
~elloopb3.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1b3.recordEvent( event ) };


k.elAt(\pca16).action = { |el|
	if ( (el.value == 1)) { "REC B: Dist + Fold + Slide".postln; ~loop1b3.startRec; };
	if ( (el.value == 0) ) { "PLAY B: Dist + Fold + Slide".postln; ~loop1b3.stopRec; ~loop1b3.play }
};

//////////////////////////////////// C /////////////////////////////////////////////////////

// LOOP C - ATTACK and DECAY ///////////////////////////////////////////////////////////////

~loop1c1 = KtlLoop(\loopc1);
~loop1c1.object = Ndef(\cset);
~loop1c1.paramsToRecord_( [k.elAt(\k20), k.elAt(\k21) ].collect(_.name) );
~loop1c1.ktlMap_( ( p2_k_0: \atk, p2_k_1: \dec ) );
~loop1c1.looped = true;
~loop1c1.rescaled = true;
~elLoopc1 = MKtlElementGroup(\loopc1, k, k.elAt(\p2, \k, [0, 1]));

~elLoopc1.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1c1.recordEvent(event) };


k.elAt(\pca24).action = { |el|
	if ( (el.value == 1)) { "REC C: Attack + Decay".postln; ~loop1c1.startRec; };
	if ( (el.value == 0) ) { "PLAY C: Attack + Decay".postln; ~loop1c1.stopRec; ~loop1c1.play }
};

// LOOP C - SUS, REL ///////////////////////////////////////////////////////////////

~loop1c2 = KtlLoop(\loopc2);
~loop1c2.object = Ndef(\cset);
~loop1c2.paramsToRecord_( [k.elAt(\k22), k.elAt(\k23) ].collect(_.name) );
~loop1c2.ktlMap_( ( p2_k_2: \sus, p2_k_3: \rel ) );
~loop1c2.looped = true;
~loop1c2.rescaled = true;
~elloopc2 = MKtlElementGroup(\loopc2, k, k.elAt(\p2, \k, [2, 3]));

~elloopc2.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1c2.recordEvent( event ) };


k.elAt(\pca25).action = { |el|
	if ( (el.value == 1)) { "REC C: Sustain + Release".postln; ~loop1c2.startRec; };
	if ( (el.value == 0) ) { "PLAY C: Sustain + Release".postln; ~loop1c2.stopRec; ~loop1c2.play }
};

// LOOP C - DIST, FOLD and Slide ///////////////////////////////////////////////////////////////

~loop1c3 = KtlLoop(\loopc3);
~loop1c3.object = Ndef(\csay);
~loop1c3.paramsToRecord_( [k.elAt(\k25), k.elAt(\k26), k.elAt(\k27) ].collect(_.name) );
~loop1c3.ktlMap_( ( p2_k_5: \dist, p2_k_6: \fold ) );
~loop1c3.looped = true;
~loop1c3.rescaled = true;
~elloopc3 = MKtlElementGroup(\loopc3, k, k.elAt(\p2, \k, [5, 6, 7]));

~elloopc3.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1c3.recordEvent( event ) };


k.elAt(\pca26).action = { |el|
	if ( (el.value == 1)) { "REC C: Distortion + Fold + Slide".postln; ~loop1c3.startRec; };
	if ( (el.value == 0) ) { "PLAY C: Distortion + Fold + Slide".postln; ~loop1c3.stopRec; ~loop1c3.play }
};


//////////////////////////////////////// D ////////////////////////////////////////////////

// LOOP D - ATK and DEC ///////////////////////////////////////////////////////////////

~loop1d1 = KtlLoop(\loopd1);
~loop1d1.object = Ndef(\dset);  // COOL! You can change the object anytime!
~loop1d1.paramsToRecord_( [k.elAt(\k30), k.elAt(\k31) ].collect(_.name) );
~loop1d1.ktlMap_( ( p3_k_0: \atk, p3_k_1: \dec ) );
~loop1d1.looped = true;
~loop1d1.rescaled = true;
~elloopd1 = MKtlElementGroup(\loopd1, k, k.elAt(\p3, \k, [0, 1]));

~elloopd1.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1d1.recordEvent( event ) };


k.elAt(\pca34).action = { |el|
	if ( (el.value == 1)) { "REC D: Attack + Decay".postln; ~loop1d1.startRec; };
	if ( (el.value == 0) ) { "PLAY D: Attack + Decay".postln; ~loop1d1.stopRec; ~loop1d1.play }
};

// LOOP D - SUS, REL ///////////////////////////////////////////////////////////////

~loop1d2 = KtlLoop(\loopd2);
~loop1d2.object = Ndef(\dset);
~loop1d2.paramsToRecord_( [k.elAt(\k32), k.elAt(\k33) ].collect(_.name) );
~loop1d2.ktlMap_( ( p3_k_2: \sus, p3_k_3: \rel ) );
~loop1d2.looped = true;
~loop1d2.rescaled = true;
~elloopd2 = MKtlElementGroup(\loopd2, k, k.elAt(\p3, \k, [2, 3]));

~elloopd2.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1d2.recordEvent( event ) };


k.elAt(\pca35).action = { |el|
	if ( (el.value == 1)) { "REC D: Sustain + Release".postln; ~loop1d2.startRec; };
	if ( (el.value == 0) ) { "PLAY D: Sustain + Release".postln; ~loop1d2.stopRec; ~loop1d2.play }
};

0.2.wait;

// LOOP D - DIST, FOLD and SLIDE ///////////////////////////////////////////////////////////////

~loop1d3 = KtlLoop(\loopd3);
~loop1d3.object = Ndef(\dsay);
~elloopd3 = k.elAt(\p0, \k, [5, 6, 7]);
~loop1d3.paramsToRecord_( ~elloopd3.collect(_.name) );
~loop1d3.ktlMap_( ( p3_k_5: \dist, p3_k_6: \fold, p3_k_7: \slide ) );
~loop1d3.looped = true;
~loop1d3.rescaled = true;
~elloopd3 = MKtlElementGroup(\loopd3, k, ~elloopd3 );
~elloopd3.action = { |el|
	var event = (\type: \set).put(el.name, el.value);
	~loop1d3.recordEvent( event ) };


k.elAt(\pca36).action = { |el|
	if ( (el.value == 1)) { "loopd3 Gravando! ".postln; ~loop1d3.startRec; };
	if ( (el.value == 0) ) { "loopd3 Tocando! ".postln; ~loop1d3.stopRec; ~loop1d3.play }
};

0.2.wait;

// PLUCK INFLUX ///////////////////////////////////////////////////////////////

/*
~inphAddMul = Influx([\x, \y], [\a, \b, \c, \d, \e, \f]/*, (x: 0.5, y: 0.1)*/);
~iogui = InfluxWGui(~inphAddMul).moveTo(411, Window.screenBounds.height );

~inphLoop = KtlLoop(\inph, { |ev|
if (ev.type == \set) {
// filter just the params we are interested in
ev = ev.select{ |val, key| ~inphLoop.paramsToRecord.includes(key) };
// rescale if rescale is on
ev = ~inphLoop.rescaleEvent(ev);
// map to the objects out specs
ev = ev.collect{ |val, key| ~inphLoop.object.getSpec(key).map(val) };
// debug info?
//	ev.round(0.001).postln;
// then set the object to the new values!
~inphLoop.object.set(*ev.asKeyValuePairs);
};
});
// which params to record (might be more coming from the source)
~inphLoop.paramsToRecord_([\x, \y]);
// which in params go to which out params
~inphLoop.ktlMap_((x: \x, y: \y));
// which object gets set to the out param values
// here, the Influx a
~inphLoop.object = ~inphAddMul;

0.1.wait;

KtlLoopGui(~inphLoop, bounds: 320@180).moveTo(5, 320);

{(
~win = Window("Influx(\x) control", Rect(5, 540, 320, 210)).front;
~win.addFlowLayout;

~comp1 = CompositeView(~win, ~win.bounds.width_(120));
~comp1.addFlowLayout;
StaticText(~comp1, Rect(0, 0, 110, 20))
.align_(\center).string_("Change  weights:");
[
"set to diagonal", { ~inphAddMul.setwPre(\diagL); },
"disentangle", { ~inphAddMul.disentangle(0.3); },
"entangle", { ~inphAddMul.entangle(0.3); },
"RANDOM", { ~inphAddMul.rand(1.0); }
].pairsDo { |label, action|
Button(~comp1, Rect(0, 0, 110, 20)).states_([[label]]).action_(action);
};

// w.view.decorator.nextLine.shift(0, 5);
StaticText(~comp1, Rect(0, 0, 110, 20)).align_(\center).string_("Attach to:");

/*[\add, \maxdev].collect { |name, i|
Button(~comp1, Rect(0, 0, 110, 20))
.states_([[name, Color.black], [name, Color.black, Color.green]])
.action_({ |btn|
[ { "remove ".post; ~inphAddMul.removeMapped(name.postcs);  },
{ "attach ".post; ~inphAddMul.attachMapped( Pdef(\pluk).postcs, paramNames: , specs:)  }
][btn.value].value;
});
};*/
~comp2 = CompositeView(~win, ~win.bounds.width_(180));
~comp2.addFlowLayout;

StaticText(~comp2, Rect(200, 0, 160, 20)).align_(\center).string_("Change inputs:");

~sl2d1 = Slider2D(~comp2,
Rect(200, 30, 170, 170)).x_(0.5).y_(0.5).background_( Color.new255(200, 100, 0) ).action_( { |sl|
// recording into KtlLoop here
~inphLoop.recordEvent((type: \set, x: sl.x, y: sl.y));
// and this is the normal set function
// bipolar mapping here done by hand
~inphAddMul.set(\x, sl.x * 2 - 1, \y, sl.y * 2 - 1);
});

SkipJack({ ~sl2d1.setXY(*[~inphAddMul.inValDict[\x], ~inphAddMul.inValDict[\y]] + 1 / 2)  },
0.05, { ~win.isClosed }, 'sl2d');
);}.defer(1);

//	~pset = PdefPresetGui( ~plukPres, 22);
try{~plukPres.loadSettings};
~inphAddMul.attachMapped( Pdef(\pluk));
*/



/*	~loop1Inph = KtlLoop(\loopinph);
~loop1Inph.object = Pdef(\pluk);
~elinph = k.elAt(\p0, \k, [5, 6, 7]); // test
~loop1Inph.paramsToRecord_( ~elinph.collect(_.name) );
~loop1Inph.ktlMap_( ( p3_k_5: \dist, p3_k_6: \fold, p3_k_7: \slide ) );
~loop1Inph.looped = true;
~loop1Inph.rescaled = true;
~loop1Inph = MKtlElementGroup(\loopd3, k, ~elinph );
~loop1Inph.action = { |el|
var event = (\type: \set).put(el.name, el.value);
~loop1Inph.recordEvent( event ) };


k.elAt(\pcb10).action = { |el|
if ( (el.value == 1)) { "loopd3 Gravando! ".postln; ~loop1Inph.startRec; };
if ( (el.value == 0) ) { "loopd3 Tocando! ".postln; ~loop1Inph.stopRec; ~loop1Inph.play }
};*/

}.fork;

// try recording:
/*
~loop1.startRec;
// now move sliders ... then
~loop1.stopRec;

// -> should get a recorded list info post:
// KtlLoop('kel') stopRec; // recorded list[2] with 145 events.

~loop1.list;
~loop1.list.size;

s.latency = 0.2;

// try playback:
~loop1.play;

// rescaling - all recorded controller values
// can be scaled, shifted, and inverted.

~loop1.rescaled = false;

~loop1.rescaled = true;
// decrease range toward center
~loop1.scaler = 0.75;
~loop1.scaler = 0.25;
// shift up or down
~loop1.shift = 0.1;
~loop1.shift = -0.1;

// invert range
~loop1.invert;
~loop1.up;
~loop1.flipInv;

// dont rescale amp?
~loop1.dontRescale(\sl_4);
~loop1.doRescale(\sl_4);

~loop1.postKtlInfo;
*/
