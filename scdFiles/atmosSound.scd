

// Load file and sent to buffer
~path = PathName(Document.current.dir).parentPath +/+ "media";
~filePath = ~path +/+ "richmondPark.wav";
~atmosBuff = Buffer.read(s, ~filePath);



SynthDef(\birdsFx, { |out=0, bufnum, pan=0, amp=0.4|
    var sig, startPos, rate, dist, crushed, filtered, downsampleRate, crushTrig;

    // Reverse playback from the middle of the buffer
    rate = -1 * BufRateScale.kr(bufnum);
    startPos = BufFrames.kr(bufnum) / 2;

    sig = PlayBuf.ar(2, bufnum, rate: rate, startPos: startPos, loop: 0, doneAction: Done.freeSelf);

    // HEAVY DISTORTION
    dist = tanh(sig * 15);  // waveshaping distortion

    // Fake bitcrushing (manual downsampling)
    downsampleRate = 2000;  // lower = crunchier
    crushTrig = Impulse.ar(downsampleRate);
    crushed = Latch.ar(dist, crushTrig);  // hold signal at sample rate

    // Filter sweeps to simulate approach
    filtered = RLPF.ar(crushed, Line.kr(800, 4000, 12), 0.4);

    // Reverb
    sig = FreeVerb.ar(filtered, mix: 0.4, room: 0.7);

    // Spatialize and amp
    sig = Balance2.ar(sig[0], sig[1], pan) * amp;

    Out.ar(out, sig);
}).add;



~atmosBird = Synth(\birdsFx, [
    \bufnum, ~atmosBuff,
    \start, 0.0,
    \amp, 0.4,  // starting amp
    \pan, 0.0
]);






