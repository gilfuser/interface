{
    PdefnAllGui.new(Pdefn.all.size);
    q.pxMixer = ProxyMixer(p, 16); // espaço para 16 proxies
    // q.pxMixer.parent.alwaysOnTop_(true);
    q.ndefMixer = NdefMixer(s);
    // if you have JITLibExtensions installed, try ProxyMeter to see the proxy levels:
    if ( \ProxyMeter.asClass.notNil ) {
        ProxyMeter.addMixer(q.pxMixer);
        ProxyMeter.addMixer(q.ndefMixer)
    };
    if (\SCNvim.asClass.notNil) {
        // Server.program = (Platform.resourceDir +/+ "scsynth.exe").quote;
        \SCNvim.asClass.updateStatusLine(1, \SCNvim.asClass.port);
    } { Document.open( Platform.userHomeDir ++ "/SuperCollider/_0_main-controls.scd") };

    s.makeWindow;
    s.meter(2,10);
    s.scope(2);
}.defer(1);