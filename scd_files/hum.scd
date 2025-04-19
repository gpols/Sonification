
// HUMBLING SOUND
// Low frequency signal reading from the temperature values

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

// Initiate environment before everthing
~hum_env.init.value;

// plot graph
// ~humData.plot;

// Create sound synth inside a function
~hum_env.func = {

    SynthDef(\hum, { |out, freq=50, gate=1, attack=1, release=1, rate=1, bufnum, amp=1, pan=0, modDepth=5, loop, trigger, start, room=0.8, mix=0.3, damp=0.2|

    var sig, humSig, lowOsc, startPos, env;

	// Calculates playback rate and start position within the buffer
    rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);
    humSig = PlayBuf.ar(1, bufnum, rate: rate, trigger: trigger, startPos: startPos, loop: loop);

	// low-frequency sawtooth wave oscillator
	// base frequency of the saw oscillator is half the freq value
    lowOsc = LFSaw.ar(freq * 0.5 + (humSig * modDepth));

	// low-pass filter with double cutoff freq
    lowOsc = LPF.ar(lowOsc, freq * 2);

	// add the low freq to the main osc
    sig = SinOsc.ar(freq + (humSig * modDepth)) * lowOsc;

	// random resonant low pass filter
	sig = RLPF.ar(sig, LFNoise1.kr(0.005).range(100, 400), 0.3);

	// add reverb
    sig = FreeVerb.ar(sig, mix: mix, room: room, damp: damp);

    // apply envelope
    env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: Done.freeSelf);

	// add to the signal
    sig = env * sig;

    // output set up to 12 speakers (G05 Room)
		// sig = PanAz.ar(12, sig, pan, level: amp);

	// mono to stereo
	sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);

}).add;

    "Hum Synth created!".postln;
};

// freq slowly changes over time
// room, pan, modDepth change continuously
// bufnum ensures Synth reads from the temperature buffer

~hum_env.makePatterns = {
    Pdef(\hum,
        Pbind(
            \instrument, \hum,
            \bufnum, ~humBuff,
            \freq, Pseg([20, 25, 31, 40, 50, 63, 80], [50, 50, 50, 50, 50, 50], \exp),
            \legato, 10,
            \room, Pseq([0.8, 0.3, 1.0], inf),
            \pan, Pwhite(-0.7, 0.7, inf),
            \modDepth, Pseq([5.0, 3.0, 1.0], inf),
            \amp, 0.8
        )
    );
};

// creates function and pbind
~hum_env.func.value;
~hum_env.makePatterns.value;

// plays for 5 minutes then stop
Routine({

	Pdef(\hum).play;
        "Hum started".postln;

        300.wait;  // wait for 5 minutes

        Pdef(\hum).stop;
        "Hum stopped".postln;

}).play;






