

// create invironment
~temp_env = ();

// Load data first
~temp_env.init = { |self|

    ~temp = PathName(Document.current.dir);
    ~tempData = CSVFileReader.read((~temp +/+ "temperature_values.csv").fullPath, true, true);
    ~tempData = ~tempData.flatten.collect(_.asFloat);
    ~tempBuff = Buffer.sendCollection(s, ~tempData);
    " Temperature Environment initialized!".postln;
};

// Call data load
~temp_env.init.value;
~tempData.plot;


// Create synths as functions
~temp_env.func = {
	SynthDef(\hum, { |out, freq=50, gate=1, attack=1, release=1, rate=1, bufnum, amp=1, pan=0, modDepth=5, loop, trigger, start, room=0.8, mix=0.3, damp=0.2|

		var sig;
		var humSig;
		var lowOsc;
		var startPos;
		var env;
		rate = rate * BufRateScale.kr(bufnum);
        startPos = start * BufFrames.kr(bufnum);
        humSig = PlayBuf.ar(1, bufnum, rate: rate, trigger: trigger, startPos: startPos, loop: loop);
        lowOsc = LFSaw.ar(freq * 0.5 + (humSig * modDepth)).clip(-0.5, 0.5);
        lowOsc = LPF.ar(lowOsc, freq * 2);
        sig = SinOsc.ar(freq + (humSig * modDepth), mul: 0.3) * lowOsc;
        sig = FreeVerb.ar(sig, mix: mix, room: room, damp: damp);
        env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: Done.freeSelf);
        sig = env * sig;
        sig = Splay.ar(sig, center: pan);
        Out.ar(out, sig);
        }).add;
	"Hum Synth created!".postln;

    // Create Fire Synth
    SynthDef(\fire, { |out=0, amp=0.5, pan=0, crackles=30|
        var sig;
		var env;
		var freq;
		var crackle;
		var trig;

        trig = Dust.kr(crackles);
        freq = ExpRand(400, 1200);
        env = EnvGen.kr(Env.perc(0.001, ExpRand(0.001, 0.005), ExpRand(0.03, 0.08)), trig, doneAction: Done.freeSelf);
        crackle = SinOsc.ar(freq, 0, env);
        sig = crackle * amp;
        sig = Pan2.ar(sig, pan);
        Out.ar(out, sig);
    }).add;

    "Fire Synth created!".postln;
};


// Function to create Pbinds
~temp_env.makePbinds = {
    [
        Pbind(
            \instrument, \hum,
            \bufnum, ~tempBuff,
            \loop, 1,
            \freq, Pseq([18, 19, 20, 21, 22], inf),
            \amp, Pseq([0.2, 0, 0.5, 0.8, 0, 0.2, 0, 1], inf),
            \modDepth, Pbrown(0, 10, 0.5, inf),
            \legato, 10,
            \attack, 0.1,
            \release, 4,
            \pan, Pwhite(-0.5, 0.5, inf),
        ).play,

        Pbind(
            \instrument, \hum,
            \bufnum, ~tempBuff,
            \trigger, Pwhite(0, 2, inf),
            \gate, 1,
            \loop, 1,
            \sustain, 5,
            \start, Pbrown(0, 1, 0.05, inf),
            \freq, Pbrown(50, 70, 0.5, inf),
            \legato, Pwhite(0.5, 2, inf),
            \pan, Pbrown(-1.0, 1.0, 0.2, inf),
            \mix, Pwhite(0.5, 0.8, inf),
        ).play,

        Pbind(
            \instrument, \hum,
            \bufnum, ~tempBuff,
            \trigger, Pseq([1, 0, 1, 1, 0, 1, 0, 0], inf),
            \gate, 1,
            \loop, 1,
            \start, Pseq([0, 0.5, 1, 1.5, 0.2, 0.8, 1.3], inf),
            \freq, Pseq([70, 75, 80, 68, 72], inf),
            \legato, Pseq([1, 2, 3, 1.5, 1], inf),
            \pan, Pseq([-0.8, -0.4, 0, 0.4, 0.8], inf),
            \mix, Pwhite(0.6, 0.9, inf),
        ).play,

		Pbind(
            \instrument, \fire,
            \bufnum, ~tempBuff,
            \amp, Pwhite(0.2, 0.8, inf),
            \pan, Pwhite(-0.5, 0.5, inf),
            \dur, Pwhite(0.05, 0.2, inf),
		).play,
    ];
};

// Run functions
~temp_env.func.value;
~temp_env.makePbinds.value;

// Check Synths
// SynthDescLib.global.browse;
