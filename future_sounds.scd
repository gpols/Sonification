s.boot;
s.sampleRate;

~tdata = CSVFileReader.read("/Users/polia/Documents/final_project/main/temperature_values.csv", true, true, startRow:1);
~tdata = ~tdata.flatten.collect(_.asFloat);
~tdata.size;

~tempData = Buffer.sendCollection(s, ~tdata.flatten.normalize);
~tempData.query;
~tempData.free;



// ======================
// Buzzing/Hum sound
// ======================

(
SynthDef('hum', {|out, freq=50, rate=1, bufnum, amp=1, gate=1, pan, attack=1.0, release=1.0, sustain=3.0,
    modDepth=10, trigger=0, loop, start, mix=0.5, room=0.9, damp=0.3|

    var sig;
	var env;
	var startPos;
	var lowOsc;
	var humSig;
	var wet;
	var dry;

    rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);

    humSig = PlayBuf.ar(1, bufnum, rate:rate, trigger:trigger, startPos:startPos, loop:loop, doneAction: Done.freeSelf);

    // Saw signal for rich sound
    lowOsc = LFSaw.ar(freq * 0.5 + (humSig * modDepth));
	//Low pass filter
    lowOsc = LPF.ar(lowOsc, freq * 2);

    // Sharp sine wave on top
	// mul: output will be multiply by the value. Use to control volume
    sig = SinOsc.ar(freq + (humSig * modDepth), mul: 0.2);

    // Blend both signals
    sig = lowOsc * sig;

    // Add Reverb for depth
    sig = FreeVerb.ar(sig, mix: mix, room: room, damp: damp);

    // Envelope
    env = EnvGen.kr(Env.asr(attack, sustain, release), gate, doneAction: Done.freeSelf);
    sig = sig * env * amp;

    // Stereo Panning
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;
)

(
Ndef(\humSound).quant_(1).play;
Ndef(\humSound,
    Pbind(*[
        instrument: 'hum',
        bufnum: ~tempData,
        dur: 2,
        loop: 1,
        sustain: 2,
        freq: Pseg(Pseq([10, 80], inf), ~tempData.numFrames),
        modDepth: Pseg(Pseq([5, 30], inf), ~tempData.numFrames),
        pan: Pwhite(-0.3, 0.3),
        legato: 0.9,
    ]).trace;
);
)

Ndef(\humSound).clear;


// ======================
// Rain sound
// ======================

(
SynthDef('rain', {|out, freq=200, rate=1, bufnum, amp=0.5, gate=1, attack=0.001, release=0.05, lowFreq=200, cracklesNum=50, start=0, pan=0, trigger=1, loop=1|

    var sig, env, burst, rainSig, startPos;

    rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);

    rainSig = PlayBuf.ar(1, bufnum, rate:rate, trigger:trigger, startPos:startPos, loop:loop, doneAction: Done.freeSelf);

    burst = Dust.kr(cracklesNum);
	sig = WhiteNoise.ar(amp);
	freq = LinExp.ar(sig * 0.5 + 0.5, 0, 1, 10, 1000);

    env = EnvGen.kr(Env.perc(attack, release), burst);

	sig = LPF.ar(sig, lowFreq);
	sig = sig * env;
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);

}).add;
)


(
Ndef(\rainSound).quant_(1).play;
Ndef(\rainSound,
    Pbind(*[
        instrument: 'rain',
        bufnum: ~tempData,
        dur: 1,
        loop: 1,
		cracklesNum: Pseg([10, 200], 60, 'exp').repeat,
    ]).trace;
);
)

Ndef(\rainSound).clear;


// ======================
// Wind sound
// ======================

(
SynthDef('hiss', {|out, rate=1, bufnum, amp=1, gate=1, pan, trigger=0, dur=10, loop, start, attack=0.3, sustain=1.0, release=3.0, startValue=500, endValue=800|

	    var sig;
        var env;
        var startPos;
	    var noise;
	    var freq;
	    var hissSig;

        rate = rate * BufRateScale.kr(bufnum);
        startPos = start * BufFrames.kr(bufnum);

        hissSig = PlayBuf.ar(1, bufnum, rate:rate, trigger:trigger, startPos:startPos, loop:loop, doneAction: Done.freeSelf);

        noise = PinkNoise.ar(amp);

        freq = XLine.kr(startValue, endValue, dur);

        sig = RHPF.ar(noise, freq, 0.3);
        sig = RLPF.ar(sig, freq, 0.2);

	    sig * hissSig;

        sig = sig.tanh;

        env = EnvGen.kr(Env.asr(attack, sustain, release, curve: 'linear'), gate, doneAction: Done.freeSelf);

    // Mono to stereo.
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);

}).add;
)


(
Ndef(\hissSound).quant_(1).play;
Ndef(\hissSound,
    Pbind(*[
        instrument: 'hiss',
        bufnum: ~tempData,
        dur: 1,
        loop: 1,
		// degree: Pseq(~tempData, inf),
		// amp: Pfunc { |ev| if (ev[\degree] > 11) { 1.0 } {Rest(1)}}
    ]).trace;
);
)

Ndef(\hissSound).clear;

// ===================================================================================================




