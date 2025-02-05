fork{
    0.1.wait;
    t = t ? TempoClock.default;
    p = p ? ProxySpace;
    p.push;
    0.1.wait;
    p.clock = t;
    0.1.wait;
    ProxySynthDef.sampleAccurate = true;
    0.1.wait;
    p.quant = 4;
    0.1.wait;
    p.fadeTime = 4;
    0.1.wait;
    p.reshaping = \elastic;
};
    "********** make ProxySpace p ***********\n".postString;