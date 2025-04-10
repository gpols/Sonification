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

// Bus for volume contol
~fireBus = Bus.audio(s, 2);

~fire_env.func = {

    // route audio from bus to speakers with amp control
	SynthDef(\fireVolume, { |in=0, out=0, amp=0.3|
        var sig = In.ar(in, 2);
        Out.ar(out, sig * amp);

	}).add;

    SynthDef(\fire, { |out=0, bufnum, trigger, rate, loop, start, amp=0.5, pan=0, crackles=30|

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
        env = EnvGen.kr(Env.perc(0.001, ExpRand(0.001, 0.005), ExpRand(0.03, 0.08)), trig, doneAction: Done.freeSelf);

        // Crackle sound is a short sine wave
        crackle = SinOsc.ar(freq, 0, env);

        // add buffer signal
        sig = (fireSig * 0.4) + (crackle * amp);

        // Adapt output channels
		// Room G05:12 speakers
        case
        {sig.isArray.not} {
            "Mono to stereo".postln;
            sig = Pan2.ar(sig, pan);
        }
        {sig.size == 2} {
            "Stereo balance".postln;
            sig = Balance2.ar(sig[0], sig[1], pan);
        }
        {sig.size > 2} {
            "Spread 12 channels".postln;
            sig = Splay.ar(sig).dup(12);
        };

        // Send signal to output
        Out.ar(out, sig);

    }).add;

    "Fire Synth created!".postln;
};

~fireVolumeSynth = Synth(\fireVolume, [\in, ~fireBus, \amp, 0.0]);  // Start silent


~fire_env.makePatterns = {
	Pdef(\fires,
		Pbind(
			\instrument, \fire,
            \degree, Pseq(~tempData, inf),
            \amp, Pwhite(0.2, 0.8, inf),
            \pan, Pwhite(-0.5, 0.5, inf),
            \dur, Pwhite(0.05, 0.2, inf),
            \crackles, Pfunc { |ev| if (ev[\degree] > 12) { 1.0 } {Rest(1)} },
			\out, ~fireBus,
		)
	);
};


~fire_env.playRoutine = {
    Routine({
        var fadeTime = 180;  // seconds
        var steps = 60;      // number of steps in fade
        var waitTime = fadeTime / steps;  // time between steps
        var startAmp = 0.0;
        var endAmp = 1.0;

        // Start patterns
        Pdef(\fires).play;
		"fire started".postln;

        // Fade in the humVolume synth
        steps.do { |i|
            var ampVal = startAmp + ((endAmp - startAmp) * (i / steps));
            ~fireVolumeSynth.set(\amp, ampVal);
            waitTime.wait;
        };

        // Stop all after fade time
		Pdef(\fires).stop;
        ~fireVolumeSynth.free;

        "fire stopped.".postln;
		60.wait; // fade time
    }).play;
};

~fire_env.func.value;
~fire_env.makePatterns.value;
~fire_env.playRoutine.value;


