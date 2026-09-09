fork{
    0.1.wait;
    t = t ? TempoClock.default;
    p = p ? ProxySpace.new;
    p.push;
    0.1.wait;
    p.clock = t;
    0.1.wait;
    ProxySynthDef.sampleAccurate = true;
    0.1.wait;
    p.know = true;
    p.quant = 4;
    0.1.wait;
    p.fadeTime = 4;
    0.1.wait;
    p.reshaping = \elastic;
    p.pop;
};
    "********** ProxySpace p ***********\n".postString;