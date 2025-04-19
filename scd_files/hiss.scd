
// Hiss SOUND
// Rain and wind sound with a shimmer
// Use values of rain data as condition

// Create environment for rain
~hiss_env = ();

// Load rain data from CSV
~hiss_env.init = { |self|

    ~hiss = PathName(Document.current.dir +/+ ".." +/+ "data_exp");
    ~hissData = CSVFileReader.read((~hiss +/+ "rain_values.csv").fullPath, true, true);
    ~hissData = ~hissData.flatten.collect(_.asFloat);

    "Rain Environment initialized!".postln;
};

// Load the rain data first
~hiss_env.init.value;

// Plot the rain data visually
// ~hissData.plot;


// SynthDef creation function

~hiss_env.func = {
    SynthDef(\hiss, { |out=0, amp=0.4, gate=1, pan=0, highFreq=4000, lowFreq=1000|

        var env, sig, noise1, noise2, ringMod;

        // Envelope with slower attack that last longer
        env = EnvGen.kr(Env.perc(3.0, 6.0, curve: -4), gate, doneAction: Done.freeSelf);

        // Mix of Pink and White
        noise1 = LPF.ar(PinkNoise.ar(0.6), highFreq);
        noise2 = BPF.ar(WhiteNoise.ar(0.4), lowFreq, 0.5);

        // Add ring modulation to create shimmer sound
        ringMod = noise2 * SinOsc.ar(100 + LFNoise1.kr(0.2).range(0, 10));

        // Mix them all
        sig = Mix([noise1, noise2, ringMod]) * env * amp;

        // Resonat low pass filter
        sig = RLPF.ar(sig, LFNoise1.kr(0.2).range(800, 5000), 0.3);

        //reverb
        sig = FreeVerb.ar(sig, mix: 0.6, room: 0.9, damp: 0.7);

		// output set up to 12 speakers (G05 Room)
		// sig = PanAz.ar(12, sig, pan, level: amp);

        // Pan and out
        sig = Pan2.ar(sig, pan);
        Out.ar(out, sig);

    }).add;

    "Hiss Synth created!".postln;
};


~hiss_env.makePatterns = {
    var rainValues = ~hissData.copy;

    Pdef(\hiss,
            Pbind(
                \instrument, \hiss,
                \rate, 1.0,
                \loop, 1,
                \start, 0,
                \dur, 0.2,
				\pan, Pseg(Pwhite(-1.0, 1.0, inf), Pwhite(4.0, 12.0, inf)),
				// values above 0.7 are the highest periods of rain
                \amp, Pseq(rainValues.collect { |val|
                    if (val > 0.7) { 0.5 } { Rest() }
                }, inf)
            ),

    );
};


// creates function and pbind
~hiss_env.func.value;
~hiss_env.makePatterns.value;

// plays for 5 minutes then stop
Routine({

	Pdef(\hiss).play;
        "Hiss started".postln;

        300.wait;  // wait for 5 minutes

        Pdef(\hiss).stop;
        "Hiss stopped".postln;

}).play;


