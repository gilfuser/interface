// COLECOES:
// escalas;
q.printScl.fork
// arrays for degrees
q.printDeg.fork;
// patterns for degree
q.printPdeg.fork;
// Pdefn for degrees
q.printPndeg.fork;
// CHORDS Patterns
q.printChor.fork;
// DURATIONS ARAYYS
q.printDur.fork;
// DURATIONS PDEFN
q.printPndur.fork;
// LEGATO ARRAYS
q.printLeg.fork;
// LEGATO PDEFN
q.printPnleg.fork;
// ATTACK ARAYYS
q.printAtt.fork;
// ATTACK PDEFN
q.printPnatt.fork;

// SynthDefs
q.printSdefs;
q.printSParams; // SynthDefs e seus parâmetros

//FXFuncs
q.printFxFuncs;

// ProxyChain
q.printPxChain;

// LinkClock
***** Acess control click through Ndef(click).kr *****
l.tempo

// Samples!
q.printPlayers
b
b.family.keys
b.tr808.keys
b.rs8[0].play

//Swing it!
q.prinSwing

// SuperDirt Stuff
SuperDirt.postTidalParameters([\default, \supercomparator])
~dirt.postSampleInfo

// MFunc
q.mod

    TODO: q.printOrbs (mostra as orbs existentes, PxChains com nomes e args)