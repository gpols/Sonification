// Boot the SuperCollider server
s.boot;

(
~data = CSVFileReader.read("/Users/polia/Documents/final_project/data_pred.csv", true, true, startRow: 1);
~data = ~data.flatten.collect(_.asFloat);
~data.postln;
)

~buffer = Buffer.loadCollection(s, ~data, 3);
~buffer.free;
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
SynthDef(\hum, { |out = 0, bufnum, freq = 50, amp = 0.1, pan = 0, gate = 1, verbmix = 0.3 |
    var audio, env, dry, wet;

    audio = Blip.ar(freq, amp);  // Sound generator
    env = Linen.kr(gate, doneAction: Done.freeSelf);

    dry = Pan2.ar(audio * env, pan);   // Dry signal (goes to speakers)
    wet = dry * verbmix;               // Wet signal (sent to reverb)

    Out.ar(out, dry);              // Direct output (dry signal)
    Out.ar(~reverbBus, wet);   // Send to reverb bus (wet signal)
}).add;
)


SynthDef(\synth2, { |out = 1, bufnum|
    var sig;
    sig = SinOsc.ar(400, 0, 0.2);  // Fixed FM synthesis
    Out.ar(out, sig);
}).add;

SynthDef(\synth3, { |out = 2, bufnum|
    var sig;
    sig = GrainBuf.ar(3, Impulse.kr(10), 0.1, bufnum, 1, 0, 2);  // Use 3-channel buffer
    Out.ar(out, sig);
}).add;
)

// ======================
// Play a Pattern using the data
// ======================
(
~testPlayer = Pbind(
    \instrument, \hum,
    \freq, 50,  // Map data to usable frequency range
    \amp, Pseq(~data, inf),  // Scale amplitude
    \verbmix, 0.5,
    \dur, 0.1
).trace.play;
)


// Start and stop the pattern player
~testPlayer.start;
~testPlayer.stop;
~testPlayer.free;
