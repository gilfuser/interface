{
    p = p ? ProxySpace.new;
    // PdefnAllGui.new(Pdefn.all.size);:
    q.pxMixer = ProxyMixer(p, 12); // espaço para 16 proxies
    // q.pxMixer.parent.alwaysOnTop_(true);
    q.ndefMixer = NdefMixer(s);
    s.makeWindow;
    s.meter(2,s.options.numOutputBusChannels);
    s.scope(2);
    // if you have JITLibExtensions installed, try ProxyMeter to see the proxy levels:
    if ( \ProxyMeter.asClass.notNil ) {
        ProxyMeter.addMixer(q.pxMixer);
        ProxyMeter.addMixer(q.ndefMixer)
    };
    if (\SCNvim.asClass.notNil) {
        // Server.program = (Platform.resourceDir +/+ "scsynth.exe").quote;
        \SCNvim.asClass.updateStatusLine(1, \SCNvim.asClass.port);
    }; //{ Document.open( Platform.userHomeDir +/+"SuperCollider"+/+"_0_main-controls.scd") }; //TODO: implementar try
}.defer(1);
