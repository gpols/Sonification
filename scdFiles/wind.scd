// Create environment
~fire_env = ();

// Load data first
~fire_env.init = { |self|

    // Get path to current document directory
    ~fire = PathName(Document.current.dir);
    ~fireData = CSVFileReader.read((~fire +/+ "wind_values.csv").fullPath, true, true);
    ~fireData = ~fireData.flatten.collect(_.asFloat);

    // Send data to buffer
    ~fireBuff = Buffer.sendCollection(s, ~fireData);

    "Fire Environment initialized!".postln;
};

// Initiate temperature data before everthing
~fire_env.init.value;
// ~fireData.plot;

~fire_env.func = {

    SynthDef(\fire, { |out=0, bufnum, trigger, rate, loop, start, amp=0.5, pan=0, crackles=1|

        var sig, env, freq, crackle, trig, startPos, fireSig;

        // Calculate playback rate and start position in buffer
        rate = rate * BufRateScale.kr(bufnum);
        startPos = start * BufFrames.kr(bufnum);

        // Play buffer
        fireSig = PlayBuf.ar(1, bufnum, rate: rate, trigger: trigger, startPos: startPos, loop: loop);

        // Random trigger events simulating crackles
        trig = Dust.kr(crackles);
        freq = ExpRand(400, 1200);

        // Envelope for each crackle
		// Low values to create clip sound
        env = EnvGen.kr(Env.perc(0.001, ExpRand(0.001, 0.005), ExpRand(0.08, 0.15)), trig, doneAction: Done.freeSelf);

        // Crackle sound is a short sine wave
        crackle = SinOsc.ar(freq, 0, env);

        // add buffer signal
        sig = (fireSig * 0.8) + (crackle * amp);

		sig = PanAz.ar(12, sig, pan, level: amp);

        // Send signal to output
        Out.ar(out, sig);

    }).add;

    "Fire Synth created!".postln;
};



~fire_env.makePatterns = {
	Pdef(\fires,
		Pbind(
			\instrument, \fire,
            \bufnum, ~fireBuff,
            \amp, Pwhite(0.8, 1.5, inf),
            \dur, Pwhite(0.05, 0.2, inf),
			\crackles, Pseq(~fireData, inf),
			\pan, Pseg(Pwhite(-1.0, 1.0, inf), Pwhite(4.0, 12.0, inf)),
		);
	);
};


~fire_env.playRoutine = {
    Routine({
        Pdef(\fires).play;
		"fire started".postln;

    }).play;
};

~fire_env.func.value;
~fire_env.makePatterns.value;
~fire_env.playRoutine.value;


