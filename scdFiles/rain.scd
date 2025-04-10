// Create environment for rain
~rain_env = ();

// Load rain data from CSV and prepare buffer
~rain_env.init = { |self|
    ~rain = PathName(Document.current.dir);

    // Read and flatten rain (temperature) data
    ~rainData = CSVFileReader.read((~rain +/+ "rain_values.csv").fullPath, true, true);
    ~rainData = ~rainData.flatten.collect(_.asFloat);

    // Send to buffer
    ~rainBuff = Buffer.sendCollection(s, ~rainData);

    "Rain Environment initialized!".postln;
};

~rainBuff.postln;
// Load the rain data
~rain_env.init.value;

// Plot the rain data visually
// ~rainData.plot;


// Bus for volume contol
~rainBus = Bus.audio(s, 2);

// SynthDef creation function
~rain_env.func = {

	// route audio from bus to speakers with amp control
	SynthDef(\rainVolume, { |in=0, out=0, amp=0.3|
        var sig = In.ar(in, 2);
        Out.ar(out, sig * amp);

	}).add;

    // SynthDef: rain
    SynthDef(\rain, { |out=0, amp=0.4, gate=1, pan=0, rate=1, loop, trigger, bufnum, start, highFreq=4000, lowFreq=1000, fadeIn, fadeOut|

        var env, sig, rainSig, startPos;

        // Calculate buffer playback rate and start position
        rate = rate * BufRateScale.kr(bufnum);
        startPos = start * BufFrames.kr(bufnum);

        // Play the rain buffer
        rainSig = PlayBuf.ar(1, bufnum, rate:rate, startPos:startPos, loop:loop, doneAction: Done.freeSelf);

        // Envelope to fade in and out
        env = EnvGen.kr(Env.perc(1.5, 4.0, curve: -3), gate, doneAction: Done.freeSelf);

        // Mix LPF and BPF noise, modulated by env, amp and buffer signal
        sig = Mix([
            LPF.ar(WhiteNoise.ar(0.3), highFreq),
            BPF.ar(WhiteNoise.ar(0.2), lowFreq, 0.7)]) * env * amp * rainSig;

        // Compile-time channel adaptation
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

        // Output signal
        Out.ar(out, sig);

    }).add;

    "Rain Synth created!".postln;
};


// Pattern generation function for rain playback
~rain_env.makePbinds = {
	Pdef(\rains,
		Pbind(
            \instrument, \rain,
            \bufnum, ~rainBuff,
            \amp, Pwhite(0.2, 0.4, inf),
            \dur, Pseq([2.0, 3.0, 4.0], inf),
            \loop, 1,
            \start, Pwhite(0.4, 0.8, inf),
            \highFreq, Pwhite(1500, 3000, inf),
            \lowFreq, Pwhite(300, 700, inf),
            // only play if highFreq is above threshold
			\trigger, Pfunc { |ev| if (ev[\highFreq] > 2500) { 1 } { Rest(1) } },
            \pan, Pbrown(-0.3, 0.3, 0.02, inf),
            \fadeIn, 2,
            \fadeOut, 2,
			\out, ~rainBus,
	));
};


~rainVolumeSynth = Synth(\rainVolume, [\in, ~rainBus, \amp, 0.0]);

~rain_env.playRoutine = {
    Routine({
        var fadeTime = 180;  // seconds
        var steps = 60;      // number of steps in fade
        var waitTime = fadeTime / steps;  // time between steps
        var startAmp = 0.0;
        var endAmp = 1.0;

        // Start patterns
        Pdef(\rains).play;
		"Rain started".postln;

        // Fade in the humVolume synth
        steps.do { |i|
            var ampVal = startAmp + ((endAmp - startAmp) * (i / steps));
            ~rainVolumeSynth.set(\amp, ampVal);
            waitTime.wait;
        };

        // Stop all after fade time
		Pdef(\rains).stop;
        ~rainVolumeSynth.free;

        "Rain stopped.".postln;
		60.wait; // fade time
    }).play;
};

// Run SynthDefs and Patterns
~rain_env.func.value;
~rain_env.makePbinds.value;
~rain_env.playRoutine.value;

// SynthDescLib.global.browse;
