// Create environment
~mach_env = ();

// Load data first
~mach_env.init = { |self|
    ~mach = PathName(Document.current.dir);
    ~machData = CSVFileReader.read((~mach +/+ "temperature_values.csv").fullPath, true, true);
    ~machData = ~machData.flatten.collect(_.asFloat);
	 // Send to buffer
    ~machBuff = Buffer.sendCollection(s, ~machData);

    "Machine Environment initialized!".postln;
};

// Run this first
~mach_env.init.value;

// Bus for volume contol
~machBus = Bus.audio(s, 2);

// Define the SynthDefs
~mach_env.func = {

    // Volume SynthDef (route audio from machBus to speakers with amp control)
    SynthDef(\machVolume, { |in=0, out=0, amp=0.3|
        var sig = In.ar(in, 2);
        Out.ar(out, sig * amp);
    }).add;

    // Main machine synth
    SynthDef(\machine, { |out, amp=0.1, gate=1, pan=0, attack=0.01, sustain=1.0, release=1.5,
        freq=200, resFreq=1000, decay=2.0, loop=1|

        var sig, env, noise;

        noise = WhiteNoise.ar(amp);

        sig = Ringz.ar(noise, resFreq, decay);

        sig = Resonz.ar(sig, freq, 0.2) + sig;
        sig = sig * SinOsc.kr(1.2).range(0.8, 1.2);
        sig = sig * 0.5;
        env = EnvGen.kr(Env.asr(attack, sustain, release), gate, doneAction: Done.freeSelf);
        sig = sig * env;

        // Stereo output handling
        sig = Pan2.ar(sig, pan);

        Out.ar(out, sig);
    }).add;

    "Machine synth added.".postln;
};



~machVolumeSynth = Synth(\fireVolume, [\in, ~machBus, \amp, 0.0]);  // Start silent


~mach_env.makePatterns = {
	Pdef(\machines,
		Pbind(
			\instrument, \machine,
            \bufnum, ~machBuff,
			\out, ~machBus,
		)
	);
};


~mach_env.playRoutine = {
    Routine({
        var fadeTime = 180;  // seconds
        var steps = 60;      // number of steps in fade
        var waitTime = fadeTime / steps;  // time between steps
        var startAmp = 0.0;
        var endAmp = 1.0;

        // Start patterns
        Pdef(\machines).play;
		"machine sound started".postln;

        // Fade in the humVolume synth
        steps.do { |i|
            var ampVal = startAmp + ((endAmp - startAmp) * (i / steps));
            ~machVolumeSynth.set(\amp, ampVal);
            waitTime.wait;
        };

        // Stop all after fade time
		Pdef(\machines).stop;
        ~machVolumeSynth.free;

        "machine sound stopped.".postln;
		60.wait; // fade time
    }).play;
};

~mach_env.func.value;
~mach_env.makePatterns.value;
~mach_env.playRoutine.value;




 