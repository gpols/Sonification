// Boot the SuperCollider server
s.boot;

(
~data = CSVFileReader.read("/Users/polia/Documents/final_project/data_pred.csv", true, true, startRow: 1);
~data = ~data.flatten.collect(_.asFloat);
~data.postln;
)

// checking
// if the duration 1 second per value data
~totalDuration = (~data.size * 1) / 60;
~data.size

// ======================
// Reverb Effect
// ======================
(
SynthDef(\reverb, {
    var sig, wet, dec = \dec.kr(1);
    sig = In.ar(\in.ir(0), 2);  // Input from bus
    wet = DelayN.ar(sig, 0.1, \predel.kr(0.02));
    wet = Mix.fill(6, {
        CombC.ar(wet, 0.1, LFNoise1.kr(0.02!2).exprange(0.02,0.1), dec);
    });
    6.do {
        wet = AllpassC.ar(wet, 0.02, LFNoise1.kr(0.02!2).exprange(0.01,0.02), dec);
    };
    sig = sig.blend(wet, \mix.kr(0.3)) * \amp.kr(0.5);
    Out.ar(\out.ir(0), sig);
}).add;

~reverbBus = Bus.audio(s, 2);
// Start the reverb effect
~reverbSynth = Synth(\reverb, [\in, ~reverbBus]);
)

// ======================
// Synth Definitions
// ======================
(
SynthDef(\hum, { |out = 0, freq = 50, amp = 0.1, pan = 0, gate = 1, verbmix = 0.3 |
    var audio, env, dry, wet;

    audio = Blip.ar(freq, amp);  // Sound generator
    env = Linen.kr(gate, doneAction: Done.freeSelf);

    dry = Pan2.ar(audio * env, pan);   // Dry signal (goes to speakers)
    wet = dry * verbmix;               // Wet signal (sent to reverb)

    Out.ar(out, dry);              // Direct output (dry signal)
    Out.ar(~reverbBus, wet);   // Send to reverb bus (wet signal)
}).add;
)

(
SynthDef(\crackle, { |out = 0, pan = 0, gate = 1|
    var sig, freq, amp, pan, env, burst;

    // Random burst-like crackle events
    burst = Dust.kr(5); // Controls how often crackles occur

    // Generate random frequency & amplitude for each burst
    freq = TRand.kr(200, 3000, burst); // Fire crackles have a higher freq range
    amp = TRand.kr(0.3, 1.0, burst); // Randomized amplitude for dynamics
    pan = TRand.kr(-1.0, 1.0, burst);

    // Generate a short burst of noise for the crackle sound
    sig = WhiteNoise.ar(amp);
    sig = BPF.ar(sig, freq, 0.2); // Band-pass filtering for sharpness

    // Apply envelope (short percussive burst)
    env = EnvGen.kr(Env.perc(0.001, TRand.kr(0.01, 0.05, burst)), burst, doneAction: Done.freeSelf);

    sig = Pan2.ar(sig * env, pan);

    Out.ar(out, sig);
}).add;
)




// ======================
// Play sounds as pattern
// ======================

(
~humSound = Pbind(
    \instrument, \hum,
	\degree, Pseq(~data, inf),
    \freq, Pwhite(50, 80, inf), // Harmonic frequencies
	\amp, Pseq(~data.linlin(0, 1, 0.05, 0.1), inf),
    \dur, 1.0,        // One second per value
    \verbmix, 1.0
).trace.play;
)

~humSound.start;
~humSound.stop;
~humSound.free;

(
~crackleSound = Pbind(
    \instrument, \crackle,
    \dur, 1.0
).trace.play;
)

~crackleSound.start;
~crackleSound.stop;
~crackleSound.free;



