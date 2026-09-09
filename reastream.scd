if (VSTPlugin.pluginKeys.indexOfEqual( 'ReaStream (ReaPlugs Edition)' ).notNil)
{
    fork{
        Ndef(\reastream, \vst -> {
            // var sig = WhiteNoise.ar(0.1) ! 2;
            VSTPlugin.ar(Ndef(\orb00).ar, 2, id: \rea1);
            VSTPlugin.ar(Ndef(\orb01).ar, 2, id: \rea2);
            VSTPlugin.ar(Ndef(\orb02).ar, 2, id: \rea3);
            VSTPlugin.ar(Ndef(\orb03).ar, 2, id: \rea4);
            VSTPlugin.ar(Ndef(\orb04).ar, 2, id: \rea5);
            VSTPlugin.ar(Ndef(\orb05).ar, 2, id: \rea6);
            VSTPlugin.ar(Ndef(\orb06).ar, 2, id: \rea7);
            VSTPlugin.ar(Ndef(\orb07).ar, 2, id: \rea8);
        });//.play;
        0.1.wait;
        ~rea = VSTPluginNodeProxyController.collect(Ndef(\reastream));
        ~rea.rea1.open("ReaStream (ReaPlugs Edition)", editor: true);
        ~rea.rea2.open("ReaStream (ReaPlugs Edition)", editor: true);
        ~rea.rea3.open("ReaStream (ReaPlugs Edition)", editor: true);
        ~rea.rea4.open("ReaStream (ReaPlugs Edition)", editor: true);
        ~rea.rea5.open("ReaStream (ReaPlugs Edition)", editor: true);
        ~rea.rea6.open("ReaStream (ReaPlugs Edition)", editor: true);
        ~rea.rea7.open("ReaStream (ReaPlugs Edition)", editor: true);
        ~rea.rea8.open("ReaStream (ReaPlugs Edition)", editor: true);
        0.2.wait;
/*~rea.rea1.editor;
~rea.rea1.gui;
~rea.rea2.editor;
~rea.rea3.editor;
~rea.rea4.editor;
~rea.rea5.editor;
~rea.rea6.editor;
~rea.rea7.editor;
~rea.rea8.editor;*/
        ~rea.rea1.readProgram(Platform.userHomeDir+/+"SuperCollider"+/+"vst"+/+"reastream_orb00.fxp");
        ~rea.rea2.readProgram(Platform.userHomeDir+/+"SuperCollider"+/+"vst"+/+"reastream_orb01.fxp");
        ~rea.rea3.readProgram(Platform.userHomeDir+/+"SuperCollider"+/+"vst"+/+"reastream_orb02.fxp");
        ~rea.rea4.readProgram(Platform.userHomeDir+/+"SuperCollider"+/+"vst"+/+"reastream_orb03.fxp");
        ~rea.rea5.readProgram(Platform.userHomeDir+/+"SuperCollider"+/+"vst"+/+"reastream_orb04.fxp");
        ~rea.rea6.readProgram(Platform.userHomeDir+/+"SuperCollider"+/+"vst"+/+"reastream_orb05.fxp");
        ~rea.rea7.readProgram(Platform.userHomeDir+/+"SuperCollider"+/+"vst"+/+"reastream_orb06.fxp");
        ~rea.rea8.readProgram(Platform.userHomeDir+/+"SuperCollider"+/+"vst"+/+"reastream_orb07.fxp");
    };
};