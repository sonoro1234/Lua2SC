local sinte = SynthDef("hardsync", {out = Master.busin , upsample=1}, function()
    local cutoff = 18000;

    Resample(upsample);
	SampleRate.ir():poll(1, "sr");
    local sig = SyncSaw.ar(MouseY.kr(1, 1000, 2), MouseX.kr(100, 4000, 2));

    --// crude anti-alisaing filter
    sig = LPF.ar(sig, cutoff);
    sig = LPF.ar(sig, cutoff);
    Out.ar(out, (sig * 0.05):dup());
end):store(true):guiplay();

sinte:guiplay()
Scope()
FreqScope()