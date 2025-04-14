// Create environment
~hum_env = ();

// Load data first
~hum_env.init = { |self|

    // Get path to current document directory
    ~hum = PathName(Document.current.dir);

    // Read temperature values from CSV and convert to flat float array
    ~humData = CSVFileReader.read((~hum +/+ "temperature_values.csv").fullPath, true, true);
    ~humData = ~humData.flatten.collect(_.asFloat);

    // Send data to buffer
    ~humBuff = Buffer.sendCollection(s, ~humData);

    "Temperature Environment initialized!".postln;
};

// Initiate temperature data before everthing
~hum_env.init.value;
// ~tempData.plot;

// Create SynthDefs inside a function
~hum_env.func = {

    SynthDef(\hum, { |out, freq=50, gate=1, attack=1, release=1, rate=1, bufnum, amp=1, pan=0, modDepth=5, loop, trigger, start, room=0.8, mix=0.3, damp=0.2|
    var sig, humSig, lowOsc, startPos, env;

    rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);
    humSig = PlayBuf.ar(1, bufnum, rate: rate, trigger: trigger, startPos: startPos, loop: loop);

    lowOsc = LFSaw.ar(freq * 0.5 + (humSig * modDepth)).clip(-0.5, 0.5);
    lowOsc = LPF.ar(lowOsc, freq * 2);

    sig = SinOsc.ar(freq + (humSig * modDepth)) * lowOsc;

    sig = FreeVerb.ar(sig, mix: mix, room: room, damp: damp);
    env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: Done.freeSelf);
    sig = env * sig;

    sig = PanAz.ar(12, sig, pan, level: amp);

    Out.ar(out, sig);
}).add;

    "Hum Synth created!".postln;
};


// Function to create multiple Pbinds (patterns)
~hum_env.makePatterns = {
    Pdef(\hum,
        Pbind(
            \instrument, \hum,
            \bufnum, ~humBuff,
            \freq, Pseg([20, 25, 31, 40, 50], [50, 50, 50, 50, 50, 50], \exp),
            \amp, 1.0,
            \legato, Pseq([10, 0.5, 6], inf),
            \room, Pseq([1.0, 0.2, 0.9], inf),
            \release, 2,
			\pan, Pseg(Pwhite(-1.0, 1.0, inf), Pwhite(4.0, 12.0, inf)),
            \modDepth, Pseq([15, 2, 10], inf),
        )
    );
};


~hum_env.playRoutine = {
    Routine({
        Pdef(\hum).play;
        "hum started".postln;
    }).play;
};



~hum_env.func.value;
~hum_env.makePatterns.value;
~hum_env.playRoutine.value;
