fork{
    0.1.wait;
    p = ProxySpace.push;
    0.1.wait;
    p.know = true;
    t = t ? TempoClock.default;
    p.clock = t;
    0.1.wait;
    ProxySynthDef.sampleAccurate = true;
    0.1.wait;
    p.quant = 1;
    0.1.wait;
    p.fadeTime = 16;
    0.1.wait;
    p.reshaping = \elastic;
};
    "********** make ProxySpace p ***********\n".postString;