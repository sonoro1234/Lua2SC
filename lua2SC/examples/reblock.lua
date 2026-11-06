local sinte = SynthDef("karp", { out=Master.busin, blockSize=1, upsample=1}, function()

    Reblock(blockSize);
    Resample(upsample);
	blockSize:poll(1,"bsiz")
    BlockSize.ir():poll(1, "block size");
    SampleRate.ir():poll(1, "sr");

    local source = Decay.ar(Impulse.ar(2), 0.1) * WhiteNoise.ar(0.2);
    local localb = LocalIn.ar(2) + {source, 0}; --// read feedback, add to source
    localb = DelayC.ar(localb, 0.5, MouseX.kr():pow(2) * 0.5); --// delay sound

    --// reverse channels to give ping pong effect, apply decay factor
    LocalOut.ar(localb:reverse() * MouseY.kr():pow(0.5):clip(0, 0.999));

    Out.ar(out, localb);
end):store(true):guiplay();

sinte:guiplay()
Scope()
FreqScope()
