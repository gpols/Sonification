// CRACKLING SOUND
// Burning wood sound
// Use data to add variation to the base tone
// Control the frequency of crackes

// Create environment
~fire_env = ();

// Load data first
~fire_env.init = { |self|

    // Get path to document directory
    ~fire = PathName(Document.current.dir +/+ ".." +/+ "data_exp");
    ~fireData = CSVFileReader.read((~fire +/+ "wind_values.csv").fullPath, true, true);
    ~fireData = ~fireData.flatten.collect(_.asFloat);

	 // print first 10 values
    "Loaded wind values (first 10):".postln;
    ~fireData[..10].postln;

    // Send data to buffer
    ~fireBuff = Buffer.sendCollection(s, ~fireData);

	 // buffer confirmation
    "Buffer initialized with number of frames:".postln;
    ~fireBuff.numFrames.postln;

    "Fire Environment initialized!".postln;
};

// Initiate temperature data before everthing
~fire_env.init.value;
~fireData.plot;

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

        // output set up to 12 speakers
		// sig = PanAz.ar(12, sig, pan, level: amp);

		// Stereo output
        sig = Pan2.ar(sig, pan);

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
			\crackles, Pseq(~fireData, inf), // higher values, more crackling
			\pan, Pseg(Pwhite(-1.0, 1.0, inf), Pwhite(4.0, 12.0, inf)),
		);
	);
};


// creates function and pbind
~fire_env.func.value;
~fire_env.makePatterns.value;

// plays for 5 minutes then stop
Routine({

	Pdef(\fires).play;
        "Fire signal started".postln;

        300.wait;  // wait for 5 minutes

        Pdef(\fires).stop;
	    20.wait;// some synths may have finished their envelope release
	    s.freeAll; // free server
        "Fire signal stopped".postln;

}).play;




