// HUMMING SOUND
// Low frequency signal reading from the temperature values
// Use temperature data to modulate parameters of the sound

// Create environment
~hum_env = ();

// Load data first
~hum_env.init = { |self|

    // Get path to current document directory
    ~hum = PathName(Document.current.dir +/+ ".." +/+ "data_exp");

    // Read temperature values from CSV and convert to flat float array
    ~humData = CSVFileReader.read((~hum +/+ "temperature_values.csv").fullPath, true, true, startRow:1);
    ~humData = ~humData.flatten.collect(_.asFloat);

    // print first 10 values
    "Loaded temperature values (first 10):".postln;
    ~humData[..10].postln;

    // Send data to buffer
    ~humBuff = Buffer.sendCollection(s, ~humData);

    // buffer confirmation
    "Buffer initialized with number of frames:".postln;
    ~humBuff.numFrames.postln;

    "Temperature Environment initialized!".postln;
};

// Initiate environment before everthing
~hum_env.init.value;

// plot graph
~humData.plot;

// Create sound synth inside a function
~hum_env.func = {
    SynthDef(\hum, {
        |out, freq=40, gate=1, attack=2, release=6, rate=1, bufnum, amp=1, pan=0, modDepth=2, loop=1, trigger=1, start=0.0, room=0.9, mix=0.4, damp=0.3|

        var sig, humSig, startPos, env, lfo, sig1, sig2;

        // Calculate playback rate and start position in buffer
        rate = rate * BufRateScale.kr(bufnum);
        startPos = start * BufFrames.kr(bufnum);

        // Play buffer
        humSig = PlayBuf.ar(1, bufnum, rate: rate, trigger: trigger, startPos: startPos, loop: loop);

        // A second order low pass filter with cutoff frequency in HZ
        humSig = LPF.ar(humSig, 1.5);

        // Very slow sine LFO to add depth movement (for vibration effect)
        lfo = SinOsc.kr(0.1).range(-1, 1);

        // Extra signals for texture
        sig1 = SinOsc.ar(freq + (humSig * modDepth) + lfo * 0.5);
        sig2 = SinOsc.ar(freq * 0.5 + (humSig * (modDepth * 0.2))) * 0.3;

        sig = Mix([sig1, sig2]);

        // Filter again (deep tone)
        sig = LPF.ar(sig, 150);

        // Reverb
        sig = FreeVerb.ar(sig, mix: mix, room: room, damp: damp);

        // Envelope
        env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: Done.freeSelf);
        sig = env * sig;

        // output set up to 12 speakers
        // sig = PanAz.ar(12, sig, pan, level: amp);

        // Stereo output
        sig = Pan2.ar(sig, pan);

        Out.ar(out, sig);
    }).add;

    "Hum Synth created!".postln;
};

// check if synth was created
// SynthDescLib.global.browse;

// slow and smooth changes in modulation
// creates vibrational hum
~hum_env.makePatterns = {
    Pdef(\hum,
        Pbind(
            \instrument, \hum,
            \bufnum, ~humBuff,
            \legato, 5,
            \room, Pseq([0.8, 0.3, 1.0], inf),
            \pan, Pwhite(-0.7, 0.7, inf),
            \modDepth, Pseq([5.0, 3.0, 1.0], inf),
            \amp, 0.5
        )
    );
};

// creates function and pbind
~hum_env.func.value;
~hum_env.makePatterns.value;

// plays for 5 minutes then stop
Routine({

    Pdef(\hum).play;
    "Hum signal started".postln;

    300.wait;  // wait for 5 minutes

    Pdef(\hum).stop;

    20.wait; // some synths may have finished their envelope release
    s.freeAll; // free server
    "Hum signal stopped".postln;

}).play;

