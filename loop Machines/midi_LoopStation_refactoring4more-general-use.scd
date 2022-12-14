var click_out = 2;
var win = Window("Super MIDI Looper", Rect(100, 200, 800, 200)).front;
var layout = win.addFlowLayout((0@0), (0@0));
var container = ();
var size = (40@40);
var font = Font("Synchro LET", 18);
var metronome = ();
var durations = [2,4,8,16];
var reload_func = {
	var tempo = t.tempo.reciprocal;
	~numloops.do{ |i|
		var slot = floor(i/(~numloops/4));
		// loop[i].free;
		~loop[i] = " "; // = loop.alloc(s, s.sampleRate * durations[slot] * tempo);
	};
};
var player = nil!8;
~numloops = 8;
~loop = nil!~numloops;
~player_button = (nil!(~numloops/4))!4;
~recorder_button = (nil!(~numloops/4))!4;
// Window
win.view.background_(Color.white);


// Controls
StaticText(win, (800@10));

StaticText(win, (100@30))
.font_(font)
.string_(" Tempo:");

NumberBox(win, (100@30))
.align_(\right)
.font_(font)
.step_(0.01)
.scroll_step_(0.1)
.clipLo_(40)
.clipHi_(400)
.value_(t.tempo * 60)
.action_{ |v| t.tempo = (v.value / 60).postln};

StaticText(win, (40@10));
Button(win, (120@30))
.font_(font)
.states_([["Reload", Color.red, Color.white]])
.action_{ reload_func.value };
StaticText(win, (40@10));


StaticText(win, (100@30))
.font_(font)
.align_(\center)
.string_(" Click:");

metronome.button = Button(win, (100@30)).states_([
	["OFF", Color.white, Color.black],
	["ON", Color.white, Color.red(0.75)],
])
.font_(font)
.action_{ |v|
	if ( v.value.booleanValue )
	{ metronome.player_instance = metronome.player.play(quant:4) }
	{ metronome.player_instance.stop }
};

metronome.display = 4.collect{
	StaticText(win, (15@10));
	UserView(win, (30@30)).background_(Color.red(0.25))
};
StaticText(win, (15@10));
StaticText(win, (800@10));
layout.nextLine;

4.do{ |i| StaticText(win, (200@30)).align_(\center).font_(font).string_(durations[i]) };

// Loopers
4.do{ |i|
	var font = Font("Synchro LET", 14);
	var bsize = 43;
	container[i] = ();
	container[i].view = CompositeView(win, (200@400));
	container[i].view.background_([Color.black, Color.white, Color.black, Color.white][i]);
	container[i].layout = container[i].view.addFlowLayout((5@5),(5@5));
	(~numloops/4).do{ |j|
		var folder, name;
		~current_loop = (i * (~numloops/4) ) + j;
		// REC
		~recorder_button[i][j] = Button(container[i].view, (bsize@bsize))
		.font_(font)
		.states_([
			["REC", Color.red, Color.white],
			["-", Color.white, Color.red]
		])

		.action_({ |e, v|
	var name = ( "l" ++ durations[i].asString ++ "_" ++ (j + 1) ).asString.split(separator: $.)[0].asString;
	var folder;
			"will record loop: % \n".postf(name);
			~add_notes = ""; // clear it
			~loop[~current_loop] = "";

			Tdef(\loop_recorder, {
				var test = "";

				durations[i].do { |j|
					1.wait;
					if ( test == ~add_notes )
					{ ~loop[~current_loop] = ~loop[~current_loop] + "_";
						~tidalSocket.sendMsg('/ctrl', "loop", ~loop[~current_loop] );
					}
					{
						if ( ~notes.isEmpty )
						{ ~loop[~current_loop] = ~loop[~current_loop] + "~";
							~tidalSocket.sendMsg('/ctrl', "loop", ~loop[~current_loop] );
						}
						{ ~loop[~current_loop] = ~loop[~current_loop] + ~notes;
							~tidalSocket.sendMsg('/ctrl', "loop", ~loop[~current_loop] );
							test = ~add_notes;
						}
					};

					"recording % > %\n".postf(name, ~loop[~current_loop]);
				};
			}).play(quant:4);

			unixCmd( "cd ~/CAMPO/loops; mkdir -p % \n".format(folder) );

			AppClock.sched(
				(t.tempo.reciprocal * durations[i])
				+ ((t.nextBar - t.beats) * t.beatDur),
				{ v.value_(0);
					Tdef(\loop_recorder).stop;

					//copy loop name to clipboard
					unixCmd( "echo -n % | xclip -selection clipboard \n".format(name) );
				}
			);
		});

		// TODO:
		// 1 - map buttons in Modality
		//     pads in cc mode
		//     they could blink!
		// 2 - Count before recording.
		//     Maybe offset in time to occur a litle bit before
		//     Outside this Tdef? post the count-down as in metronome.display_player
		//     Maybe create a warning window with colours and big numbers
		//
		// For the Future:
		// 1 - More control in the gui
		//     durations, countdown


		// PLAY

		~player_button[i][j] = Button(container[i].view, (bsize@bsize))
		.font_(font)
		.states_([
			["PLAY", Color.green(0.5), Color.white],
			["STOP", Color.black, Color.green(0.5)]
		])
		.action_{ |v|
			if (v.value.booleanValue)
			{
				("play/copy loop: %").postf(~loop[~current_loop]);
				//copy loop content to clipboard
				unixCmd( "echo -n % | xclip -selection clipboard".format(~loop[~current_loop]) );
				Tdef(\player, {
					1.do{
						~tidalSocket.sendMsg('/ctrl', "loop", ~loop[~current_loop] );
						durations[i].wait;
					}
				}
				).play(quant:4);
			}
			{
				("stopping loop: %").postf(name);
				~tidalSocket.sendMsg('/ctrl', "loop", "[]" );
				Tdef(\player).stop;
			}
		};

	};
};

// Players
metronome.player = Pbind(
	\instrument, \click,
	\freq, Pseq([1000, Pn(500,3)], inf),
	\amp, 0.2
);

metronome.display_player = Pbind(
	\type, \setProperties,
	\args, #[\background],
	\receiver, Pstutter(2, Pseq(metronome.display, inf)),
	\background, Pseq([Color.green(0.75), Color.red(0.25)], inf),
	\dur, Pseq([9,1]/10, inf),
).play(quant:4);

win.onClose_{
	metronome.display_player.stop;
	metronome.player_instance.stop;
};

s = Server.default;
s.waitForBoot {

	reload_func.value;

	SynthDef(\click, { |freq amp|
		var env = EnvGen.ar(Env.perc(0.001,0.05), levelScale:amp, doneAction:2);
		var snd = SinOsc.ar(freq, 0.5pi);
		snd = snd * env;
		OffsetOut.ar(click_out, snd!2);
	}).add;

};