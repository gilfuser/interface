q = q ? ();
//{
//~mktl.resetActions;
//~mktl.free;
// *************** check if anything is coming, and note the sending address ************************
(
f = { |msg, time, addr|
	if( (msg[0] != '/status.reply') &&
		(msg[0] != '/localhostInLevels') &&
		(msg[0] != '/localhostOutLevels') &&
		(msg[0] != '/n_end') &&
		(msg[0] != '/n_go') &&
		(msg[0] != '/done') &&
		(msg[0] != '/synced') &&
		(msg[0] != '/n_move') &&
		(msg[0] != '/play2')
	) {
		"time: % sender: %\nmessage: %\n".postf(time, addr, msg);
	}
};
thisProcess.addOSCRecvFunc(f);
);

thisProcess.removeOSCRecvFunc(f);   // ******************** stop posting ***************************

~mktl = MKtl(\tosca, "touchosc-my");
//MKtl(\tosca).rebuild(\tosca, "touchosc-my");
~mktl.device.updateSrcAddr("192.168.0.9", 39079);  // ALWAYS CHANGE MKtl WHEN OPEN Tosc Skmecs LAYOUT!!!!!!!!!
~mktl.device.updateDstAddr("192.168.0.9", 9000);
~mktl.gui;
s.sync;

////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// ORB 0 /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

~mktl.setValueAt('fxr1_bt_tg_1', 0);

(
// make shorter names
8.collect{ | i|
	~mktl.addNamed( "multi%".format(i+1).asSymbol, ~mktl.elAt(\fxr1, \bt, \mtg, (8-(i+1)) ));
	~mktl.addNamed( "toggle%".format(i+1).asSymbol, ~mktl.elAt(\fxr1, \bt, \tg, i ) );
};
6.collect{ | i|
	~mktl.addNamed( "num%".format(i+1).asSymbol, ~mktl.elAt(\fxr1, \num, i ));
	~mktl.addNamed( "fader%".format(i+1).asSymbol, ~mktl.elAt( \fxr1, \sl, i ) );
};
);
~mktl.trace(true);
// add actions through MFunc
(
~toggleBts = ~mktl.elAt(\fxr1, \bt, \tg);
~toggleBts.do { |el| el.action = MFunc.new };
);

// toggle FX slots on/off
(
~toggleBts.do { |bt, i|
	bt.action.add (\onOff, { |bt|
		if (bt.value == 1)
		{ Ndef(\orb1).set("wet%".format(i*10+10).asSymbol, 1 ) }
		{ Ndef(\orb1).set("wet%".format(i*10+10).asSymbol, 0 ) };
	});
};
);


// assign elements from a specific control on,
// so one can jump to all controls from an effect
//************************************************************************************************************************
(
q.mapElToParams0 = { | q, elGroup, editGui, indexOffset = 0, numLabel |
	elGroup.do { |el, i|
		el.action.add(\indexOffset, { |el|
			var proxy, paramKey, spec;
			proxy = editGui.proxy;
			paramKey = editGui.editKeys[i + indexOffset];
			if (paramKey.notNil) {
				spec = proxy.getSpec(paramKey);
				spec = spec ?? { editGui.paramGui.specs[paramKey] };
				if ( numLabel.notNil) { ~tosca.sendMsg("fxr1/num1", rrand(0.0,1.0).postln) };
				//if ( numLabel.notNil) { numLabel.value_(spec.map(el.value).round(0.001)) }; // why numbers are still between 0 and 1?
				proxy.softSet(paramKey,
					spec.map(el.value),
					within: 0.04,
					lastVal: spec.map(el.prevValue));
			};
		})
	};
};
);

~visFBbuts0 = ~mktl.elAt(\fxr1, \bt, \mtg );
~visFBbuts0.do { |el| el.action = MFunc.new};

~faders0 = ~mktl.elAt(\fxr1, \sl );
~faders0.do { |el| el.action = MFunc.new};


/*
// get some info:

q.fx.orb1.slotNames.size
q.fx.orb1.slotNames[10]
Ndef(\orb1).controlKeys
Ndef(\orb1).getKeysValues
Ndef(\orb1).controlKeysValues
q.fx.orb1.slotsDo{|name, i| name.postln; i.postln}
q.fx.orb1.slotValuesDo{|name, i| name.postln; i.postln}
q.fx.orb1.slotSize
q.fx.orb1.slotNames.size
q.fx.orb1.slotNames.pop
q.fx.orb1.slotNames.at(10)
*/

// ~test = q.fx.orb1.slotNames.asArray

// index position summing all parameters
~elNames0 = Array.fill(q.fx.orb1.slotNames.size, { |i|
	var name = q.fx.orb1.slotNames[i*10+10];
	q.fx.fxLib.at(name).argNames.drop(1).collect { |j|
		j;
	}.addFirst(name)
} );

~elParams0 = Array.fill(q.fx.orb1.slotNames.size, { |i|
	var name = q.fx.orb1.slotNames[i*10+10];
	q.fx.fxLib.at(name).argNames.drop(1).collect { |j|
		j;
	}.addFirst("wet%".format(i*10+10).asSymbol)
} );

// offset index to be controlled.
(
~elParams0.size.do { |i|
	~mktl.elAt( "multi%".format(i+1).asSymbol ).action.add(\indexOffset, { |el|
		q.mapElToParams0(
			~mktl.elAt(\fxr1, \sl),
			q.pChainGuis[0].editGui,
			~elIndex0[i],
			~mktl.elAt(\fxr1, \num, i+1)
		);
	});
};
);

//***************************************************************************************

(

~specs0 = Ndef(\orb1).controlKeys;

~paramNames0 = ~elNames0.flat;

~colors0 = ~elParams0.collect{ |params,i|
	var colors = ['blue', 'yellow', 'purple', 'gray', 'orange', 'green', 'pink', 'red' ];
	colors[i]!params.size;
}.flat;


(
~faderVals0 = ~elParams0.deepCollect(2){ |vals,i|
	Ndef(\orb0).get(vals)
}
);

);

// make it the six visible
~faders0.do { |el, i| el.value = ~faderVals0[0][i] };

~params0 = ~elNames0.collect{ |params, i|
	params.size
};  // numbers of parameters in each of the 8 FX

~fxIndex = 0;

~faders0.do {|el, i|
	el.action.add(\toFaderVals, {
		~faderVals0[ ~fxIndex ][i] = ( el.value).round(0.001);
	})
};

(
~visFBbuts0.reverse.do{ |el, i|

	el.action.add(\updateFxInd, {~fxIndex = i });

	el.action.add(\colors, {
		if ( el.value == 1)
		{
			6.do  { |j|
				~tosca.sendMsg("/fxr1/fader%/color".format(j+1), ~colors0[~elParams0[i] + j /*% ~colors0.size*/ ] );
				~tosca.sendMsg("/fxr1/label%/color".format(j+1), ~colors0[~elParams0[i] + j /*% ~colors0.size*/ ] );
				~tosca.sendMsg("/fxr1/num%/color".format(j+1), ~colors0[~elParams0[i] + j /*% ~colors0.size*/ ] );
			}
		}
	});
	el.action.add(\updateSpecs, { |el|
		if (el.value == 1)
		{
			6.do { |el, j|
				~mktl.elAt(\orb0, \num, j).deviceSpec_(~specs0[ ~elParams0[i] + j /*% ~specs0.size*/ ] )
			};
		}
	});
	el.action.add(\updateNames, { |el|
		if (el.value == 1)
		{
			6.do { |k|
				~tosca.sendMsg("/o0/label%".format(k+1), ~paramNames0[ ~elParams0[i] + k % 29 ]/*.postln*/ )
			}
		}
	});


	// this is not working as it should________________________________________________________________

	/*el.action.add(\toFaderVals, {
	if (el.value == 0)
	{
	~faders0.do { |el, j|
	~faderVals0[ i * 6 + j ] = ( el.value).round(0.001);
	}
	}
	});*/
	el.action.add(\fromFaderVals, { |el|
		if (el.value == 1)
		{
			~faders0.collect { |fader, m|
				fader.value = ~faderVals0[i][m]
			}
		}
	});

//__________________________________________________________________________________________________

}
);

//~visFBbuts0.do{ |el| el.action.remove(\toFaderVals)}

//~visFBbuts0.do { |el| el.action.remove(\numbers)}




////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// ORB 1 /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
(
// make shorter names
8.collect{ | i|
	~mktl.addNamed( "multi1%".format(i+1).asSymbol, ~mktl.elAt(\orb1, \bt, \mtg, (8-(i+1)) ));
	~mktl.addNamed( "toggle1%".format(i+1).asSymbol, ~mktl.elAt(\orb1, \bt, \tg, i ) );
};
6.collect{ | i|
	~mktl.addNamed( "num1%".format(i+1).asSymbol, ~mktl.elAt(\orb1, \num, i ));
	~mktl.addNamed( "fader1%".format(i+1).asSymbol, ~mktl.elAt( \orb1, \sl, i ) );
};
);
//~mktl.namedDict.keys;

~toggleBts1 = ~mktl.elAt(\orb1, \bt, \tg);
~toggleBts1.do { |el| el.action = MFunc.new };

// toggle FX on/off
(
~toggleBts1.do { |bt, i|
	bt.action.add (\onOff, { |bt|
		if (bt.value > 0, {q.fx.orb1.add(q.fx.orb1.slotNames["%0".format(i+1).asInteger])},
			{q.fx.orb1.remove(q.fx.orb1.slotNames["%0".format(i+1).asInteger]); }
		);
	});
};
);

// assign elements from a specific control on,
// so one can jump to all controls from an effect
//************************************************************************************************************************

(
q.mapElToParams1 = { | q, elGroup, editGui, indexOffset = 0, numLabel |
	elGroup.do { |el, i|
		el.action.add(\indexOffset, { |el|
			var proxy, paramKey, spec;
			proxy = editGui.proxy;
			paramKey = editGui.editKeys[i + indexOffset];
			if (paramKey.notNil) {
				spec = proxy.getSpec(paramKey);
				spec = spec ?? { editGui.paramGui.specs[paramKey] };
				numLabel = ~mktl.elAt(\orb1, \num, i);
				//if ( numLabel.notNil) { ~tosca.sendMsg("fxr1/num%".format(i+1), paramKey.asSpec.map(el.value).round(0.001)) };
				if ( numLabel.notNil) { ~mktl.elAt("fxr1/num%".format(i+1)).value_(paramKey.asSpec.map(el.value).round(0.001)) };
				proxy.softSet(paramKey,
					spec.map(el.value),
					within: 0.04,
					lastVal: spec.map(el.prevValue));
			};
		})
	};
};
);

~visFBbuts1 = ~mktl.elAt(\orb1, \bt, \mtg );
~visFBbuts1.do { |el| el.action = MFunc.new};

~faders1 = ~mktl.elAt(\orb1, \sl );
~faders1.do { |el| el.action = MFunc.new};

~elIndex1 = #[ 0, 2, 7, 13, 16,21,23,26];  // index position summing all parameters


// offset index to be controlled.
(
8.do { |i|
	~mktl.elAt( "multi1%".format(i+1).asSymbol ).action.add(\indexOffset, { |el|
		q.mapElToParams1(
			~mktl.elAt(\orb1, \sl),
			q.pChainGuis[1].editGui,
			~elIndex[i]/*,
			~mktl.elAt(\orb1, \num, i)*/
		);
	});
};
);
//*************************************************************************************************


(

~specs1 = [
	['wet10', 'inAmp'],
	['wet20', 'choose', 'sfreq', 'res', 'peak'],
	['wet30', 'lofreq', 'width'],
	['wet40', 'rate', 'depth', 'ring', 'gain'],
	['wet50', 'freq'],
	['wet60', 'dtime', 'damp', 'size', 'diff', 'fb'],
	['wet70', 'lnfreq', 'rqn'],
	['wet80', 'pRatio', 'pDisp']
].flat;

~paramNames1 = [
	['SOUND_IN', 'inAmp'],
	['FILTER', 'choose', 'sfreq', 'res', 'peak'],
	['STROBE', 'lofreq', 'width'],
	['WAH', 'rate', 'depth', 'ring', 'gain'],
	['RING_MOD', 'freq'],
	['HOLE', 'dtime', 'damp', 'size', 'diff', 'fb'],
	['LPF_NOISE', 'lnfreq', 'rqn'],
	['PITCH', 'pRatio', 'pDisp']
].flat;

~colors1 = ['blue'!2, 'red'!5, 'gray'!3, 'green'!5, 'orange'!2, 'pink'!6, 'purple'!3, 'yellow'!3 ].flat;

);

~faderVals1 = [
	[Ndef(\orb1).get(\wet10), Ndef(\orb1).get(\inAmp)],
	[Ndef(\orb1).get(\wet20), Ndef(\orb1).get(\choose), Ndef(\orb1).get(\sfreq), Ndef(\orb1).get(\res), Ndef(\orb1).get(\peak)],
	[Ndef(\orb1).get(\wet30), Ndef(\orb1).get(\lofreq), Ndef(\orb1).get(\width)],
	[Ndef(\orb1).get(\wet40), Ndef(\orb1).get(\rate), Ndef(\orb1).get(\depth), Ndef(\orb1).get(\ring), Ndef(\orb1).get(\gain)],
	[Ndef(\orb1).get(\wet50), Ndef(\orb1).get(\freq)],
	[Ndef(\orb1).get(\wet60), Ndef(\orb1).get(\dtime), Ndef(\orb1).get(\damp), Ndef(\orb1).get(\size), Ndef(\orb1).get(\diff), Ndef(\orb1).get(\fb)],
	[Ndef(\orb1).get(\wet70), Ndef(\orb1).get(\lnfreq), Ndef(\orb1).get(\rqn)],
	[Ndef(\orb1).get(\wet80), Ndef(\orb1).get(\pRatio), Ndef(\orb1).get(\pDisp)],
	Ndef(\orb1).get(\wet10)
].flat;

~faders1.do { |el, i| el.value = ~faderVals1[i] };

~absIndex1 = 0;

~faders1.do { |el, i|
	/* el.action.add( \valToNumbers, {
	~mktl.elAt(\orb1, \num, i).value = (el.value).round(0.001)
	});*/
	el.action.add( \valsToFaderVals, {
		~faderVals1[ ~absIndex1 + i % 29] = (el.value).round(0.001);

	})
};

(
~visFBbuts1.reverse.do{ |el, i|
	el.action.add(\updateAbsIndex, { ~absIndex1 = ~elIndex1[i] });
	el.action.add(\colors, {
		if ( el.value == 1)
		{
			6.do  { |j|
				~tosca.sendMsg("/fxr1/fader%/color".format(j+1), ~colors1[~elIndex1[i] + j % 29 ] );
				~tosca.sendMsg("/fxr1/label%/color".format(j+1), ~colors1[~elIndex1[i] + j % 29 ] );
				~tosca.sendMsg("/fxr1/num%/color".format(j+1), ~colors1[~elIndex1[i] + j % 29 ] );
			}
		}

	});
	el.action.add(\updateNumbSpecs, { |el|
		if (el.value == 1)
		{
			6.do { |j|
				~mktl.elAt(\orb1, \num, j).deviceSpec_(~specs1[ ~elIndex1[i] + j % 29 ] )
			};
		}
	});
	el.action.add(\updateNames, { |el|
		if (el.value == 1)
		{
			6.do { |k|
				~tosca.sendMsg("/fxr1/label%".format(k+1), ~paramNames1[ ~elIndex1[i] + k % 29 ]/*.postln*/ )
			}
		}
	});
	el.action.add(\fromFaderVals, { |el|
		if (el.value == 0)
		{
			6.do { |m|
				~mktl.elAt(\orb1, \sl, m).value_( ~faderVals1[ ~elIndex1[i] + m % 29] )
			}
		}
	});
}
);
