// Change parameter in Ndefs with effects. One for each orbit from Tidal.
// I'm using four orbits here, so there are four Ndefs.
// This is a litle bit long because there are X steps involved:
// 1: start the server with enougth output channels.
// the output from the orbits and the effect Ndefs should't output to the
// physical output becou
// In practice this should be in separated files to a better organization.

(
OSCdef(\oscFromTidal, { |msg|
	MFdef(\theHub).value(msg);
}, '/dirt/play').permanent_(true)
);

MFdef(\theHub).add(\post, {|msg| msg.postln});
MFdef(\theHub).enable(\post);
MFdef(\theHub).disable(\post);

q.orbz = Ndef(\orb0);
q.vstorb = 0;

// q.allOrbs = [q.fx.orb0.proxy, q.fx.orb1.proxy, q.fx.orb2.proxy, q.fx.orb3.proxy];
(
MFdef(\theHub).add(\setOrb,
	{ |msg|
		var orbz;
		if ( ( msg.indexOf( \orbit ).notNil ) and: ( orbz != q.orbz ) ) {
			// "index of orbit: % \n".postf(msg.indexOf( \orbit ));
			// "orbit should be... % \n".postf(msg.at( msg.indexOf( \orbit ).asInteger + 1));
			q.orbz = Ndef( "orb%".format( msg.at( msg.indexOf( \orbit ).asInteger + 1 ) ).asSymbol );
			orbz = q.orbz;
			// q.orbz.postln;
		};
	}
)
);
(
MFdef(\theHub).add(\setVst,
	{ |msg|
		var vstorbz;
		if ( ( msg.indexOf( \orbit ).notNil ) and: ( vstorbz != q.vstorb ) ) {
			// "orbit should be... % \n".postf(msg.at( msg.indexOf( \orbit ).asInteger + 1));
			q.vstorb = msg.at( msg.indexOf( \orbit ).asInteger + 1 );
			vstorbz = q.vstorb;
		};
	}
);
);

(
MFdef(\theHub).add( \tidalSetOrbs,
// \drywet,
	{ |msg|
		msg.collect { |key, i|
			switch ( key )
			{ \wet10 } { q.orbz.set( key, msg[i+1] ) }
            { \wet20 } { q.orbz.set( key, msg[i+1] ) }
            { \wet30 } { q.orbz.set( key, msg[i+1] ) }
            { \wet40 } { q.orbz.set( key, msg[i+1] ) }
			// { \wet50 } { q.orbz.set( key, msg[i+1] ) }
			// { \wet60 } { q.orbz.set( key, msg[i+1] ) }
			// { \wet70 } { q.orbz.set( key, msg[i+1] ) }
			// { \wet80 } { q.orbz.set( key, msg[i+1] ) }

			/* pitch -*/
			// { \pideg } { q.orbz.set( key, msg[i+1] ) }
			// { \pdisp } { q.orbz.set( key, msg[i+1] ) }
			// { \tdisp } { q.orbz.set( key, msg[i+1] ) }
			// { \slide } { q.orbz.set( key, msg[i+1] ) }

			/* tape, */
			{ \trate } { q.orbz.set( key, msg[i+1] ) }
			{ \tphase } { q.orbz.set( key, msg[i+1] ) }
			{ \tdepth } { q.orbz.set( key, msg[i+1] ) }
			{ \toffset } { q.orbz.set( key, msg[i+1] ) }

			/* comp, */
			// { \ctrl } { q.orbz.set( key, msg[i+1] ) }
			// { \thresh } { q.orbz.set( key, msg[i+1] ) }
			// { \slopea } { q.orbz.set( key, msg[i+1] ) }
			// { \clamp } { q.orbz.set( key, msg[i+1] ) }
			// { \relax } { q.orbz.set( key, msg[i+1] ) }

			/* wah, */
			{ \wrate } { q.orbz.set( key, msg[i+1] ) }
			{ \depth } { q.orbz.set( key, msg[i+1] ) }
			{ \sinsaw } { q.orbz.set( key, msg[i+1] ) }
			{ \jfreq } { q.orbz.set( key, msg[i+1] ) }
			{ \jdepth } { q.orbz.set( key, msg[i+1] ) }

			/* lfo,*/
			// { \sisap} { q.orbz.set( key, msg[i+1] ) }
			// { \lrate} { q.orbz.set( key, msg[i+1] ) }
			// { \iphase } { q.orbz.set( key, msg[i+1] ) }
			// { \lwidth } { q.orbz.set( key, msg[i+1] ) }
			// { \midfreq } { q.orbz.set( key, msg[i+1] ) }
			// { \hifreq } { q.orbz.set( key, msg[i+1] ) }

			/* ampFin */
			// { \postAmp } { q.orbz.set( key, msg[i+1] ) }

			{ \cps } { q.orbz.set( key, msg[i+1] ) }
			{ \delta } { q.orbz.set( key, msg[i+1] );
				q.deltas.setPairs( q.vstorb, msg[i+1].asFloat )
			}

			/* ---------------- vst stuff --------------------- */

			/* reverb */
			// { \vwet } { ~vwet.setPairs( q.vstorb.asInteger, msg[i+1].asFloat ) }
			// { \vdry } { ~vdry.setPairs( q.vstorb.asInteger, msg[i+1].asFloat ) }
			// { \vdelay } { ~vdelay.setPairs(q.vstorb.asInteger, msg[i+1].asFloat ) }
			// { \vsize } { ~vsize.setPairs( q.vstorb.asInteger, msg[i+1].asFloat ) }
			// { \vlocut } { ~vlocut.setPairs(q.vstorb.asInteger, msg[i+1].asFloat ) }
			// { \vhicut } { ~vhicut.setPairs( q.vstorb.asInteger, msg[i+1].asFloat ) }

			/* acid */
            { \acut } { ~acid.set( \Cutoff, msg[i+1] ) }
			{ \ares } { ~acid.set( \Resonance, msg[i+1] ) }
			{ \amod } { ~acid.set( \Envmod, msg[i+1] ) }
			{ \adec } { ~acid.set( \Decay, msg[i+1] ) }
			// { \accd } { ~acid.set( \Accent, msg[i+1].asFloat ) }
			{ \aacc } { ~acid.set( \Accent, msg[i+1] ) }
			;
		}
	})
);
