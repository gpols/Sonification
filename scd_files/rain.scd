
// RAIN/WIND SOUND
//

// Create environment for rain
~rain_env = ();

// Load rain data from CSV and prepare buffer
~rain_env.init = { |self|

    ~rain = PathName(Document.current.dir +/+ ".." +/+ "data_exp");
    ~rainData = CSVFileReader.read((~rain +/+ "rain_values.csv").fullPath, true, true);
    ~rainData = ~rainData.flatten.collect(_.asFloat);

    "Rain Environment initialized!".postln;
};

// Load the rain data
~rain_env.init.value;

// Plot the rain data visually
// ~rainData.plot;


// SynthDef creation function
~rain_env.func = {
    SynthDef(\rain, { |out=0, amp=0.4, gate=1, pan=0, rate=1, loop, trigger, start, highFreq=4000, lowFreq=1000, fadeIn, fadeOut|

        var env, sig;

        // Envelope to fade in and out
        env = EnvGen.kr(Env.perc(2.0, 4.0, curve: -3), gate, doneAction: Done.freeSelf);

        // Mix LPF and BPF noise, modulated by env, amp and buffer signal
        sig = Mix([
            LPF.ar(PinkNoise.ar(0.8), highFreq),
            BPF.ar(WhiteNoise.ar(0.6), lowFreq, 0.7)]) * env * amp;

        sig = FreeVerb.ar(sig, mix: 0.3, room: 0.7, damp: 0.5);

		// output set up to 12 speakers (G05 Room)
		// sig = PanAz.ar(12, sig, pan, level: amp);

	    // mono to stereo
	    sig = Pan2.ar(sig, pan);


    }).add;

    "Rain Synth created!".postln;
};


// Pattern generation function for rain playback
~rain_env.makePbinds = {
	    var rainValues = ~rainData.copy;
	Pdef(\rains,
		Pbind(
            \instrument, \rain,
            \dur, Pseq([2.0, 3.0, 4.0], inf),
            \loop, 1,
			\trigger, 1,
            \fadeIn, 1,
            \fadeOut, 2,
			\pan, Pseg(Pwhite(-1.0, 1.0, inf), Pwhite(4.0, 12.0, inf)),

			\amp, Pseq(rainValues.collect { |val|

                    var ampValues = if (val > 0.5) { 1.0 } { 0.0 };

                    if (ampValues > 0.0) {
                        ampValues  // Play sound
                    } {
                        Rest()  // Silent
                    }
                }, inf)
	));
};

// creates function and pbind
~rain_env.func.value;
~rain_env.makePatterns.value;

// plays for 5 minutes then stop
Routine({

	Pdef(\rains).play;
        "Rain started".postln;

        300.wait;  // wait for 5 minutes

        Pdef(\rains).stop;
        "Rain stopped".postln;

}).play;


