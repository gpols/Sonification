// Boot the SuperCollider server
s.boot;

(
// Read data from a CSV file into an array
~data = CSVFileReader.read("/Users/polia/Documents/final_project/data_pred.csv", true, true, startRow: 1);

// Flatten the data and convert each element to a float
~data = ~data.flatten.collect(_.asFloat);

// Print the processed data to the console
~data.postln;
)

// ======================
// Buffer Operations
// ======================
// Store the data in a buffer
~buffer = Buffer.loadCollection(s, ~data, 3);

~buffer.free;

// ======================
// Synth Definition
// ======================
(
SynthDef(\hum, { |out = 0, bufnum, channel = 0, rate = 1, amp = 0.1, pan = 0, gate = 1 |
    var index, sig, env;

    // Create an index for reading from the buffer (moving through it over time)
    index = Phasor.ar(0, BufRateScale.kr(bufnum) * rate, 0, BufFrames.kr(bufnum));

    // Read from the specific channel in the buffer
    sig = BufRd.ar(1, bufnum, index, interpolation: 4);

    // Apply an envelope
    env = Linen.kr(gate, doneAction: Done.freeSelf);

    // Pan and output the sound
    OffsetOut.ar(out, Pan2.ar(sig, pan, env * amp));
}).add;
)

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

~reverbBus = Bus.audio(s, 2);  // Create a stereo audio bus

// Start the reverb effect
~reverbSynth = Synth(\reverb, [\in, ~reverbBus]);
)

// ======================
// Start Synths with Data Integration
// ======================

// Normalize the data for amplitude control
~ampData = ~data.linlin(~data.minItem, ~data.maxItem, 0.1, 1);
(
~humPattern = Pbind(
    \instrument, \hum,
    \bufnum, ~buffer,
    \channel, Pseq([0], inf),  // Ensure correct buffer channel usage
    \rate, Pwhite(0.5, 1.5, inf),  // Randomized rate
    \amp, Pseq(~ampData, inf),
    \dur, 0.1
).play;
)

// Start and stop the pattern player
~humPattern.start;
~humPattern.stop;

// ======================
// Data Buffer Information
// ======================
~data[224];  // Access a specific data point
~data.size;  // Check the total size of data
~buffer.numChannels;  // Number of channels in the buffer
~buffer.bufnum;  // Buffer ID
~buffer.sampleRate;  // Sample rate of the buffer
