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

// Bus for volume control
~machBus = Bus.audio(s, 2);

// Define the SynthDefs
~mach_env.func = {

    // Volume SynthDef (route audio from machBus to speakers with amp control)
    SynthDef(\machVolume, { |in=0, out=0, amp=0.3|
        var sig = In.ar(in, 2);
        Out.ar(out, sig * amp);
    }).add;

    // Cinematic evolving machine sound with convolution
    SynthDef(\machine, { |out=0, amp=0.1, gate=1, pan=0, attack=2.0, sustain=1.0, release=4.0, irBuf=0|

        var sig, env, dry, wet, mod;

        // Simple low synth tone
        sig = LFSaw.ar(LFNoise1.kr(0.1).range(80, 200), 0, amp);

        // Envelope
        env = EnvGen.kr(Env.asr(attack, sustain, release), gate, doneAction: Done.freeSelf);
        sig = sig * env;

        sig = Convolution2.ar(sig, irBuf, 2048); // Use temperature buffer as IR

        // Stereo spatial movement
        sig = Pan2.ar(sig, SinOsc.kr(0.1).range(-0.8, 0.8));

        Out.ar(out, sig);
    }).add;

    "Machine synth added.".postln;
};

// Start volume synth silent
~machVolumeSynth = Synth(\machVolume, [\in, ~machBus, \amp, 0.0]);

// Pattern with convolution buffer
~mach_env.makePatterns = {
    Pdef(\machines,
        Pbind(
            \instrument, \machine,
            \irBuf, ~machBuff,
            \out, ~machBus,
            \dur, Pseq([8, 16, 12], inf),  // Long, evolving notes
            \amp, 0.1
        )
    );
};

// Routine to play with fade in and out
~mach_env.playRoutine = {
    Routine({
        var fadeTime = 180;  // seconds
        var steps = 60;      // number of steps in fade
        var waitTime = fadeTime / steps;
        var startAmp = 0.0;
        var endAmp = 1.0;

        Pdef(\machines).play;
        "machine sound started".postln;

        // Fade in volume
        steps.do { |i|
            var ampVal = startAmp + ((endAmp - startAmp) * (i / steps));
            ~machVolumeSynth.set(\amp, ampVal);
            waitTime.wait;
        };

        // Play full fadeTime duration
        60.wait;

        // Stop and clean up
        Pdef(\machines).stop;
        ~machVolumeSynth.free;
        "machine sound stopped.".postln;
    }).play;
};

// Run all setup and play
~mach_env.func.value;
~mach_env.makePatterns.value;
~mach_env.playRoutine.value;
