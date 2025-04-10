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

// Bus for volume contol
~humBus = Bus.audio(s, 2);

// Create SynthDefs inside a function
~hum_env.func = {

	// route audio from bus to speakers with amp control
    SynthDef(\humVolume, { |in=0, out=0, amp=0.3|
        var sig = In.ar(in, 2);
        Out.ar(out, sig * amp);

	}).add;

    // HUM SYNTHDEF
    SynthDef(\hum, { |out, freq=50, gate=1, attack=1, release=1, rate=1, bufnum, amp=1, pan=0, modDepth=5, loop, trigger, start, room=0.8, mix=0.3, damp=0.2|
        var sig, humSig, lowOsc, startPos, env;

        // Calculate playback rate and start position in buffer
        rate = rate * BufRateScale.kr(bufnum);
        startPos = start * BufFrames.kr(bufnum);

        // Play buffer
        humSig = PlayBuf.ar(1, bufnum, rate: rate, trigger: trigger, startPos: startPos, loop: loop);

        // Modulate a low-frequency saw wave with buffer data
        lowOsc = LFSaw.ar(freq * 0.5 + (humSig * modDepth)).clip(-0.5, 0.5);
        lowOsc = LPF.ar(lowOsc, freq * 2);

        // Multiply sine wave by modulated saw wave
        sig = SinOsc.ar(freq + (humSig * modDepth), mul: 0.3) * lowOsc;

        // Add reverb
        sig = FreeVerb.ar(sig, mix: mix, room: room, damp: damp);

        // Apply amplitude envelope
        env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: Done.freeSelf);
        sig = env * sig;

        // Adapt output channels
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

    "Hum Synth created!".postln;
};


// Function to create multiple Pbinds (patterns)
~hum_env.makePatterns = {
    Pdef(\hum1,
        Pbind(
            \instrument, \hum,
            \bufnum, ~humBuff,
            \freq, Pseq([20, 22, 19, 21], inf),
            \amp, 0.1,
			\legato, 10,
			\room,Pseq([0.8, 0.3, 1.0], inf),
			\release, 5,
            \pan, Pwhite(-0.7, 0.7, inf),
			\out, ~humBus,
        )
    );

    Pdef(\hum2,
        Pbind(
            \instrument, \hum,
            \bufnum, ~humBuff,
			\trigger, Pseq([1, 0, 1], inf),
			\start, Pseq([0.2, 0.6, 1.0], inf),
            \freq, Pseq([90, 95, 100], inf),
            \amp, 0.1,
            \attack, 5,
            \release, 1,
            \legato, 6,
			\mix, Pseq([0.8, 0.3, 1.0], inf),
            \pan, Pwhite(-0.5, 0.5, inf),
			\out, ~humBus,
        )
    );
};

~humVolumeSynth = Synth(\humVolume, [\in, ~humBus, \amp, 0.0]);  // Start silent

~hum_env.playRoutine = {
    Routine({
        var fadeTime = 180;  // seconds
        var steps = 60;      // number of steps in fade
        var waitTime = fadeTime / steps;  // time between steps
        var startAmp = 0.0;
        var endAmp = 1.0;

        // Start patterns
        Pdef(\hum1).play;
		"hum1 started".postln;

		60.wait;

        Pdef(\hum2).play;
        "hum2 started".postln;

        // Fade in the humVolume synth
        steps.do { |i|
            var ampVal = startAmp + ((endAmp - startAmp) * (i / steps));
            ~humVolumeSynth.set(\amp, ampVal);
            waitTime.wait;
        };

        // Stop all after fade time
        [\hum1, \hum2].do { |key| Pdef(key).stop; };
        ~humVolumeSynth.free;
        "Hums stopped.".postln;
		60.wait; // fade time
    }).play;
};


~hum_env.func.value;
~hum_env.makePatterns.value;
~hum_env.playRoutine.value;


// SynthDescLib.global.browse;
