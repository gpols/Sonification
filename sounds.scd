
s.boot;

~tdata = CSVFileReader.read("/Users/polia/Documents/final_project/main/temperature_values.csv", true, true, startRow:1);
~tdata = ~tdata.flatten.collect(_.asFloat);

~dataBuff = Buffer.sendCollection(s, ~tdata.flatten.normalize,3);
~dataBuff.query;

// do not change synths and pdef yet. add busses and play all together first

(
[1, 2, 3].do{|numChannels|
"Create sample player, numChannels=%".format(numChannels).postln;
    SynthDef('hum' ++ numChannels, {|out, freq=80, rate=1, bufnum, amp=1, gate=1, pan=0, attack=0.5, release=1.0, modDepth=5, loop, trigger, start|

    var sig;
	var env;
	var humSig;
	var lowOsc;
	var startPos;

	rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);
    humSig = PlayBuf.ar(numChannels, bufnum, rate:rate, trigger:trigger, startPos:startPos, loop:loop, doneAction: 2);
    lowOsc = LFSaw.ar(freq * 0.5 + (humSig * modDepth)).clip(-0.5, 0.5);
    lowOsc = LPF.ar(lowOsc, freq * 2);
    sig = SinOsc.ar(freq + (humSig * modDepth), mul: 0.3) * lowOsc;
    sig = FreeVerb.ar(sig, mix: 0.3, room: 0.8, damp: 0.2);
    env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
    sig = sig * env * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
    }).add;
};
"Synths created!";
)


(
[1, 2, 3].do{|numChannels|
"Create sample player, numChannels=%".format(numChannels).postln;
    SynthDef('rain' ++ numChannels, { |out=0, amp=0.4, gate=1, pan=0, rate=1, loop, trigger, bufnum, start|
    var env;
    var sig;
	var rain;
	var startPos;

	rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);
    rain = PlayBuf.ar(numChannels, bufnum, rate:rate, trigger:trigger, startPos:startPos, loop:loop, doneAction: Done.freeSelf);
	env = EnvGen.kr(Env.perc(1.5, 4.0, curve: -3), gate, doneAction: Done.freeSelf);
	sig	= Mix([
        LPF.ar(WhiteNoise.ar(0.3), 4000),
        BPF.ar(WhiteNoise.ar(0.2), 1000, 0.7)
    ]) * env * amp;
	sig = Pan2.ar(sig, pan);
    Out.ar(out, sig );
    }).add;
};
"Synths created!";
)


(
[1, 2, 3].do{|numChannels|
"Create sample player, numChannels=%".format(numChannels).postln;
    SynthDef('hiss' ++ numChannels, {|out, rate=1, bufnum, amp=1, gate=1, pan, trigger=0, dur=10, loop, start, attack=0.3, sustain=1.0, release=3.0, startValue=500, endValue=800|
    var sig;
	var env;
	var startPos;
	var noise;
	var freq;
	var hissSig;

    rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);
    hissSig = PlayBuf.ar(numChannels, bufnum, rate:rate, trigger:trigger, startPos:startPos, loop:loop, doneAction: Done.freeSelf);
    noise = PinkNoise.ar(amp);
    freq = XLine.kr(startValue, endValue, dur);
    sig = RHPF.ar(noise, freq, 0.3);
    sig = RLPF.ar(sig, freq, 0.2);
    sig = sig * hissSig;
    sig = sig.tanh;
    env = EnvGen.kr(Env.asr(attack, sustain, release, curve: 'linear'), gate, doneAction: Done.freeSelf);
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
    }).add;
};
"Synths created!";
)

// check synths
SynthDescLib.global.browse;


//for testing
x = Synth(\hum1, [\out, 0, \bufnum, ~dataBuff, \start, 0, \loop, 1]);
y = Synth(\rain1, [\out, 0, \bufnum, ~dataBuff, \start, 0, \loop, 1]);
z = Synth(\hiss1, [\out, 0, \bufnum, ~dataBuff, \start, 0, \loop, 1]);


)
(

Pdef(\humSeq, Pbind(
    \instrument, \hum1,
    \bufnum, ~dataBuff,
	\trigger, 1,
	\gate, 1,
	\loop,1,
	\start, 0,
    \freq, Pseq([50, 80, 100], inf),
    \amp, Pwhite(0.3, 0.7, inf),
    \dur, Pseq([0.5, 1.0, 1.5], inf),
    \legato, Pwhite(0.5, 1.0, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;



Pdef(\humSeq, Pbind(
    \instrument, \hum2,
    \bufnum, ~dataBuff,
	\trigger, 1,
	\gate, 1,
	\loop,1,
	\start, 0,
    \freq, Pseq([50, 80, 100], inf),
    \amp, Pwhite(0.3, 0.7, inf),
    \dur, Pseq([0.5, 1.0, 1.5], inf),
    \legato, Pwhite(0.5, 1.0, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;
)

(
Pdef(\humSeq, Pbind(
    \instrument, \hum3,
    \bufnum, ~dataBuff,
	\trigger, 1,
	\gate, 1,
	\loop,1,
	\start, 0,
    \freq, Pseq([50, 80, 100], inf),
    \amp, Pwhite(0.3, 0.7, inf),
    \dur, Pseq([0.5, 1.0, 1.5], inf),
    \legato, Pwhite(0.5, 1.0, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;




Pdef(\rainSeq, Pbind(
    \instrument, \rain1,
    \bufnum, ~dataBuff,
    \amp, Pwhite(0.2, 0.5, inf),
    \dur, Pseq([1.0, 2.0, 3.0], inf),
    \loop, 1,
    \start, Pwhite(0.0, 0.5, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;



Pdef(\rainSeq, Pbind(
    \instrument, \rain2,
    \bufnum, ~dataBuff,
    \amp, Pwhite(0.2, 0.5, inf),
    \dur, Pseq([1.0, 2.0, 3.0], inf),
    \loop, 1,
    \start, Pwhite(0.0, 0.5, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;



Pdef(\rainSeq, Pbind(
    \instrument, \rain3,
    \bufnum, ~dataBuff,
    \amp, Pwhite(0.2, 0.5, inf),
    \dur, Pseq([1.0, 2.0, 3.0], inf),
    \loop, 1,
    \start, Pwhite(0.0, 0.5, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;




Pdef(\hissSeq, Pbind(
    \instrument, \hiss1,
    \bufnum, ~dataBuff,
    \rate, Pwhite(0.5, 1.5, inf),
    \amp, Pwhite(0.1, 0.3, inf),
    \dur, Pseq([2.0, 4.0, 6.0], inf),
    \loop, 1,
    \start, Pwhite(0.0, 0.5, inf),
    \startValue, Pwhite(400, 600, inf),
    \endValue, Pwhite(700, 1000, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;



Pdef(\hissSeq, Pbind(
    \instrument, \hiss2,
    \bufnum, ~dataBuff,
    \rate, Pwhite(0.5, 1.5, inf),
    \amp, Pwhite(0.1, 0.3, inf),
    \dur, Pseq([2.0, 4.0, 6.0], inf),
    \loop, 1,
    \start, Pwhite(0.0, 0.5, inf),
    \startValue, Pwhite(400, 600, inf),
    \endValue, Pwhite(700, 1000, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;



Pdef(\hissSeq, Pbind(
    \instrument, \hiss3,
    \bufnum, ~dataBuff,
    \rate, Pwhite(0.5, 1.5, inf),
    \amp, Pwhite(0.1, 0.3, inf),
    \dur, Pseq([2.0, 4.0, 6.0], inf),
    \loop, 1,
    \start, Pwhite(0.0, 0.5, inf),
    \startValue, Pwhite(400, 600, inf),
    \endValue, Pwhite(700, 1000, inf),
    \pan, Pwhite(-1.0, 1.0, inf),
)).trace.play;
)




s.meter;
s.queryAllNodes;

SynthDescLib.global.removeAt(\hum);
SynthDescLib.global.removeAt(\rain);
SynthDescLib.global.removeAt(\hiss);

s.quit;
s.boot;



