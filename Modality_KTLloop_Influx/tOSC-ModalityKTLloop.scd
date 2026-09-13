q = q ? ();
// ************ check if anything is coming, and note the sending address ************
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
		(msg[0] != '/n_off') &&
		(msg[0] != '/n_on') &&
		(msg[0] != '/play2')
	) {
		"time: % sender: %\nmessage: %\n".postf(time, addr, msg);
} }; thisProcess.addOSCRecvFunc(f);
);

thisProcess.removeOSCRecvFunc(f);   // ******************** stop posting ****************************

(
k = MKtl(\tosca, "touchosc-my");
//MKtl(\tosca).rebuild(\tosca, "touchosc-my");
k.device.updateSrcAddr("192.168.43.1", 48829);  // ALWAYS CHECK WHEN OPEN TOSC LAYOUT!!!!!!!!!
k.device.updateDstAddr("192.168.43.1", 9000);
// k.gui;
k.trace(false);

q.mkGroup = k.elementGroup;
q.pxChange = q.mkGroup.elAt(\orbs, \bt, \change);
q.chooseFX = q.mkGroup.elAt(\orbs, \bt, \fx );
q.toggleFX = q.mkGroup.elAt(\orbs, \bt, \tg);
q.sliders = q.mkGroup.elAt(\orbs, \sl);
q.numbers = q.mkGroup.elAt(\orbs, \num);

q.sliders.name

// make initial shorter names
q.pxChange.do {|el, i| k.addNamed("change%".format(i).asSymbol, el ) };
q.chooseFX.do { |el, i| k.addNamed("chooseFX%".format(i).asSymbol, el ) };
q.toggleFX.do { |el, i| k.addNamed("toggleFX%".format(i).asSymbol, el ) };
q.numbers.do { |el, i| k.addNamed("num%".format(i).asSymbol, el ) };
q.sliders.do {|el, i| k.addNamed("slider%".format(i).asSymbol, el ) }; // those will change

// inital setups ______________________________________________________

q.pxChain = q.fx.orb1;
q.px = q.pxChain.proxy;

q.elNames = {
	Array.fill( q.pxChain.slotNames.size, { |i|
		var name = q.pxChain.slotNames[i * 10 + 10];
		q.fx.fxLib.at(name).argNames.drop(1).collect { |j|
			j;
		}.addFirst(name.asString.toUpper.asSymbol)
	} )
}; /* [ [ HOLE, dtime, damp, size, diff, fb ], [ DROPTAPE, modspeed, ... */

q.numParams = {
	q.elNames.collect{ |params, i| params.size }
}; /*[ 6, 5, 4, 5, 6, 4 ]*/


q.ctrlVals = {
	Array.fill( q.px.getKeysValues.size, {|i|
		q.px.getKeysValues[i][1]
	})
}; /* [ 0, 0.667, 0.05, 0.5, 0.14, 0.5, 0, 4, ... */

q.colors = [/*'blue', 'yellow', */'purple', /*'gray', */'orange', /*'green', 'pink', */'red' ];

q.sliderColors = {
	q.elNames.collect{ |params,i|
		q.colors[i % q.colors.size]!params.size;
	}.flat
}; /* [ purple, purple, purple, purple, purple, purple, gray, gray, ... */

q.lastFX = 0;
q.lastOrbFX = [1, 2, 3];

q.resetLastFX = {
	q.lastIndice = q.lastOrbFX[q.lastFX];
	q.chooseLast = Array.fill(q.chooseFX.size, { |i| q.chooseFX.elAt(i).name } );
	k.setValueAt( q.chooseLast.removeAt(q.lastIndice), 1); // pick last
	k.setValueAt( q.chooseLast, 0); // reset the others
};

q.resetLastFX;

q.lastCtrlKeys = {
	Array.fill( q.elNames[q.lastIndice].size, { |i| q.elNames[q.lastIndice][i] } )
};
q.lastCtrlKeys;
q.ctrlParamPairs = ();
);


(
q.changeToscPx = { |q, lastFX|

	// set on starting or on changing proxys: // _______________________
	q.elNames;
	q.numParams;
	q.lastOffset = 0;

	q.offset = Array.fill( q.numParams.size, { |i|
		var sum = q.lastOffset;
		q.lastOffset = q.lastOffset + q.numParams[i];
		sum
	}); /* [ 0, 6, 11, 15, 20, 26 ] */

	q.resetLastFX;

	q.lastDryWetVal = { q.px.controlKeys[q.offset[q.lastIndice]] };

	k.addNamed( q.lastDryWetVal, q.sliders.elAt(0) );

	q.dryWet = Array.fill( q.pxChain.slotsInUse.size, 0); /* [ 0, 0, 0, 0, 0, 0 ] */

	//__________________________________________________________________

	(
		q.toggleFX.do { |onOff, i|
			var ctlKey;

			if ( q.offset[i].notNil )
			{
				ctlKey = q.px.controlKeys[q.offset[i]];

				if ( q.ctrlVals[ q.offset[i] ] != 0,
					{ k.setValueAt( onOff.name, 1 ) },
					{ k.setValueAt( onOff.name, 0 ) }
				);
				q.tosca.sendMsg( "/orbs/tg%/position/y".format( i ),
					10 + ( 1040 / q.numParams.size * i ).floor
				);
				q.tosca.sendMsg( "/orbs/tg%/size/h".format( i ),
					( 1040 / q.numParams.size - 10 ).floor
				);
				q.tosca.sendMsg( "/orbs/tg%/color".format(i), q.colors[i % q.colors.size] );
			}
			{ q.tosca.sendMsg( "/orbs/tg%/visible".format(i), 0) };

			onOff.action = {
				if ( onOff.value == 1.0 )
				{

					q.px.set( ctlKey, q.dryWet[i] );
					q.ctrlVals;
					if ( k.elAt(ctlKey).notNil )
					{ k.setValueAt( k.elAt(ctlKey).name, q.dryWet[i] ) };
				}
				{

					q.ctrlVals;
					q.dryWet[i] = q.px.get( ctlKey );
					q.px.set( ctlKey, 0 );
					if ( k.elAt(ctlKey).notNil )
					{ k.setValueAt( k.elAt(ctlKey).name, 0 ) };
				};
			};
		};
	);
	(
		q.mapElementsToParamsFrom = { |q, elemgroup, offset, numParams|

			elemgroup.do { |sl, i|
				var paramKey, paramVal, spec;

				paramKey = q.px.controlKeys[i + offset];
				paramVal = q.ctrlVals[i + offset];

				if ( paramKey.notNil )
				{
					spec = q.px.getSpec(paramKey);

					k.setValueAt( sl.name, spec.unmap(paramVal) );
					q.tosca.sendMsg( "/orbs/num%".format(i + 1), q.ctrlVals[i + offset].round(0.001) );
					q.tosca.sendMsg( "/orbs/label%".format(i + 1), q.elNames.flat[i + offset] );
					q.tosca.sendMsg( "/orbs/fader%/color".format(i), q.sliderColors[i + offset] );

					if ( i > 0 )
					{
						// for KTLloop: recorded controler setting process param:
						if (i < q.numParams[i])
						{
							k.addNamed( q.px.controlKeys[i + offset], sl ); // bind ctrlKeys with sliders
							q.ctrlParamPairs.put(sl.name, q.px.controlKeys[i + offset]) // use in KTLloop
						};

						q.tosca.sendMsg( "/orbs/fader%/position/x".format( i ),
							600 + ( 1350 / (numParams - 1) * ( i - 1 ) ).floor
						);
						q.tosca.sendMsg( "/orbs/label%/position/x".format( i + 1 ),
							600 + ( 1350 / (numParams - 1) * ( i - 1 ) + (
								1350 / (numParams - 1) - 90 * 0.5 - 90 ) ).floor
						);

						q.tosca.sendMsg( "/orbs/num%/position/x".format( i + 1 ),
							600 + ( 1350 / (numParams - 1) * ( i - 1 ) + (
								1350 / (numParams - 1) - 90 * 0.5 - 90 ) ).floor
						);
						q.tosca.sendMsg( "/orbs/fader%/size/w".format( i ),
							( 1350 / (numParams - 1) - 90 ).floor
						);
					};

					// spec = spec ?? { editGui.paramGui.specs[paramKey] };
					k.setValueAt( sl.name, spec.unmap(paramVal) );
					q.tosca.sendMsg( "/orbs/num%".format(i+1), paramVal.round(0.001));

					sl.action = { |el|
						q.px.softSet(paramKey,
							paramKey.asSpec.map(el.value),
							within: 0.04,
							lastVal: spec.map(el.prevValue));
						q.tosca.sendMsg(
							"/orbs/num%".format(i+1), paramKey.asSpec.map(el.value).round(0.001) );
					};
				};

				if ( i < numParams )
				{
					q.tosca.sendMsg( "/orbs/fader%/visible".format(i), 1 );
					q.tosca.sendMsg( "/orbs/label%/visible".format(i+1), 1 );
					q.tosca.sendMsg( "/orbs/num%/visible".format(i+1), 1 );
				}
				{
					q.tosca.sendMsg( "/orbs/fader%/visible".format(i), 0);
					q.tosca.sendMsg( "/orbs/label%/visible".format(i + 1), 0);
					q.tosca.sendMsg( "/orbs/num%/visible".format(i + 1), 0);
				};
			};
		};
	);

	q.mapElementsToParamsFrom( q.sliders, q.offset[q.lastIndice], q.numParams[q.lastIndice] );

	(
		q.chooseFX.do { |btn, i|
			var offset, toggleFX;

			if ( q.numParams[i].notNil )
			{
				offset = q.offset[i];
				// ctlKey = q.px.controlKeys[q.offset[i]];
				q.tosca.sendMsg( "/orbs/fx%/visible".format(i), 1 );
				q.tosca.sendMsg( "/orbs/label%/visible".format(i + 7), 1 );
				q.tosca.sendMsg( "/orbs/label%".format(i + 7), q.elNames[i][0] );
				q.tosca.sendMsg( "/orbs/fx%/color".format(i), q.colors[i % q.colors.size] );
				q.tosca.sendMsg( "/orbs/fx%/position/y".format( i ),
					10 + ( 1040 / q.numParams.size * i ).floor );
				q.tosca.sendMsg( "/orbs/label%/position/y".format( i + 7 ),
					10 + ( 1040 / q.numParams.size * i + (
						1040 / q.numParams.size - 10 * 0.5 - 23) ).floor );
				q.tosca.sendMsg( "/orbs/fx%/size/h".format( i ),
					( 1040 / q.numParams.size - 10 ).floor );
			}
			{
				q.tosca.sendMsg( "/orbs/fx%/visible".format(i), 0 );
				q.tosca.sendMsg( "/orbs/label%/visible".format(i + 7), 0 );
			};

			btn.action = { |el|
				// q.tosca.sendMsg( "/orbs/fx%".format(q.lastOrbFX[q.lastFX]), 0 );
				// remove
				k.namedDict.removeAt( q.lastDryWetVal );

				q.lastOrbFX[q.lastFX] = i;
				q.lastCtrlKeys;
				q.lastOffset = 0;
				q.resetLastFX;
				q.lastDryWetVal;
				k.addNamed( q.lastDryWetVal, q.sliders.elAt(0) );

				q.ctrlVals;
				q.mapElementsToParamsFrom( q.sliders, offset, q.numParams[i] );
				// q.lastDryWetVal = q.px.controlKeys[offset];
			}
		};
	);

};

q.changeToscPx;

q.pxChange.elAt(0).action_( { |el|
	if(el.value==1,
		{
			k.namedDict.removeAt( q.lastDryWetVal );
			q.ctrlVals;
			q.pxChain = q.fx.orb1;
			q.px = q.pxChain.proxy;
			q.lastFX = 0;
			q.changeToscPx;
		}
	)
} );
q.pxChange.elAt(1).action_( { |el|
	if(el.value==1,
		{
			k.namedDict.removeAt( q.lastDryWetVal );
			q.ctrlVals;
			q.pxChain = q.fx.orb2;
			q.px = q.pxChain.proxy;
			q.lastFX = 1;
			q.changeToscPx;
		}
	)
} );
q.pxChange.elAt(2).action_( { |el|
	if(el.value==1,
		{
			k.namedDict.removeAt( q.lastDryWetVal );
			q.ctrlVals;
			q.pxChain = q.fx.orb3;
			q.px = q.pxChain.proxy;
			q.lastFX = 2;
			q.changeToscPx;
		}


	)
} );

);
/*
q.fx.orb1.proxy.getKeysValues;
Ndef(\orb1).getKeysValues[0]
q.fx.orb1.proxy.controlKeys
k.namedDict.keys
q.fx.orb1.proxy.getSpec(\wet10)
q.fxGui.editGui.paramGui.specs[\amp]
q.fxGui.editGui.paramGui.specs[\amp].warp
q.fxGui.editGui.editKeys[8]
q.fx.orb1.slotNames.size
q.fx.orb1.slotNames[10]
Ndef(\orb1).controlKeys
Ndef(\orb1).controlKeysValues
q.fx.orb1.slotsDo{|name, i| name.postln; i.postln}
q.fx.orb1.slotValuesDo{|name, i| name.postln; i.postln}
q.fx.orb1.slotSize
q.fx.orb1.slotNames.size
q.fx.orb1.slotNames.at(10)
k.elAt('slider1')
k.elAt('onOff8')
q.fx.orb1.slotsInUse.size
q.fx.orb1.slotsInUse[10];
q.fx.orb1.proxy.set(\wet10, 0);
q.fx.orb1.proxy.get(\wet10)
q.fx.orb1.remove(\wah)
q.fx.orb1.add(\wah)
*/
