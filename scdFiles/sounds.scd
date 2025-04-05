Server.local.options.memSize;

File.exists(Platform.userConfigDir +/+ "startup.scd")
PathName(Platform.userAppSupportDir).files;
s.queryAllNodes;

Platform.userConfigDir;
s.boot;

(
~temp = PathName(Document.current.dir);
~tempData = CSVFileReader.read((~temp +/+ "temperature_values.csv").fullPath, true, true);
~tempData = ~tempData.flatten.collect(_.asFloat);
)

(
~wind = PathName(Document.current.dir);
~windData = CSVFileReader.read((~wind +/+ "main/wind_values.csv").fullPath, true, true);
~windData = ~windData.flatten.collect(_.asFloat);
)

(
~rain = PathName(Document.current.dir);
~rainData = CSVFileReader.read((~rain +/+ "main/rain_values.csv").fullPath, true, true);
~rainData = ~rainData.flatten.collect(_.asFloat);
)


~tempBuff = Buffer.sendCollection(s, ~tempData, 3);
~tempBuff.query;
~tempBuff.plot;

~windBuff = Buffer.sendCollection(s, ~windData);
~windBuff.query;
~windBuff.plot;

~rainBuff = Buffer.sendCollection(s, ~rainData);
~rainBuff.query;
~rainBuff.plot;





(
[1, 2, 3].do { |numChannels|
    "Create sample player, numChannels=%".format(numChannels).postln;
    SynthDef('hum' ++ numChannels, { |out, freq=50, gate=1, attack= 1, release=1, rate=1, bufnum, amp=1, pan=0, modDepth=5, loop, trigger, start, room=0.8, mix=0.3, damp=0.2|

        var sig, humSig, lowOsc, startPos, env;

        rate = rate * BufRateScale.kr(bufnum);
        startPos = start * BufFrames.kr(bufnum);
        humSig = PlayBuf.ar(numChannels, bufnum, rate: rate, trigger: trigger, startPos: startPos, loop: loop);

        lowOsc = LFSaw.ar(freq * 0.5 + (humSig * modDepth)).clip(-0.5, 0.5);
        lowOsc = LPF.ar(lowOsc, freq * 2);
        sig = SinOsc.ar(freq + (humSig * modDepth), mul: 0.3) * lowOsc;
        sig = FreeVerb.ar(sig, mix: mix, room: room, damp: damp);

		env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: Done.freeSelf);
		sig = env *sig;

		sig = Splay.ar(sig, center:pan);
		// sig.postln;

        Out.ar(out, sig);
    }).add;
};
"Hum Synth created!".postln;
)



(
[1].do{|numChannels|
"Create sample player, numChannels=%".format(numChannels).postln;
    SynthDef('rain' ++ numChannels, { |out=0, amp=0.4, gate=1, pan=0, rate=1, loop, trigger, bufnum, start, highFreq=4000, lowFreq=1000, fadeIn, fadeOut|

    var env, sig, rain, startPos;

	rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);
    rain = PlayBuf.ar(1, bufnum, rate:rate, startPos:startPos, loop:loop, doneAction: Done.freeSelf);

	env = EnvGen.kr(Env.perc(1.5, 4.0, curve: -3), gate, doneAction: Done.freeSelf);
	sig	= Mix([
        LPF.ar(WhiteNoise.ar(0.3), highFreq),
        BPF.ar(WhiteNoise.ar(0.2), lowFreq, 0.7)
    ]) * env * amp;
	sig = Pan2.ar(sig, pan);
    Out.ar(out, sig );
    }).add;
};
"Rain Synths created!";
)


(
SynthDef(\metal, { |out=0, freq = 200, decay = 2, amp = 0.5, pan = 0|

    var env, sig;

	// offsets freq and scale down amp
    sig = Mix.fill(5, { |i|
        SinOsc.ar(freq * (1 + (i * 0.01)), 0, amp / 5)
    });
    sig = sig * LFTri.ar(freq * 1.5);
    env = EnvGen.kr(Env.perc(0.01, decay, amp), doneAction: Done.freeSelf);
    sig = GVerb.ar(sig, roomsize: 10, revtime: 3) * 0.3;

    Out.ar(out, Pan2.ar(sig * env, pan));
}).add;
"Metal Synth created!";
)



(
SynthDef(\fire, { |out=0, amp=0.5, pan=0, crackles=30|

    var sig, env, freq, crackle, trig;

    trig = Dust.kr(crackles);
    freq = ExpRand(400, 1200);
    env = EnvGen.kr(Env.perc(0.001, ExpRand(0.001, 0.005), ExpRand(0.03, 0.08)), trig, doneAction: Done.freeSelf);
    crackle = SinOsc.ar(freq, 0, env);
    sig = crackle * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;
"Fire Synth created!";
)


// check synths
SynthDescLib.global.browse;


// low long hum
(
~hum1 =  Pbind(
    \instrument, \hum3,
    \bufnum, ~tempBuff,
    \loop, 1,
    \freq, Pseq([18, 19, 20, 21, 22], inf),
    \amp, Pseq([0.2, 0, 0.5, 0.8, 0, 0.2, 0, 1], inf),
    \modDepth, Pbrown(0, 10, 0.5, inf),
    \legato, 10,
    \attack, 0.1,
    \release, 4,
    \pan, Pwhite(-0.5, 0.5, inf),
	);//.trace.play;
//);

// sharper, eerie
//(
~hum2 = Pbind(
    \instrument, \hum3,
    \bufnum, ~tempBuff,
    \trigger, Pwhite(0, 2, inf), // on/off
    \gate, 1,
    \loop, 1,
	\sustain, 5,
    \start, Pbrown(0, 1, 0.05, inf), // shifting start
    \freq, Pbrown(50, 70, 0.5, inf), // still low frequencies
    \legato, Pwhite(0.5, 2, inf), // short and long tones
    \pan, Pbrown(-1.0, 1.0, 0.2, inf), // 0.2 of the previous one
    \mix, Pwhite(0.5, 0.8, inf),// reverb
);//.trace.play;
//);

//s.scope;
// intense with strong reverb
//(
~hum3 = Pbind(
    \instrument, \hum3,
    \bufnum, ~tempBuff,
    \trigger, Pseq([1, 0, 1, 1, 0, 1, 0, 0], inf), // pulsing effect
    \gate, 1,
    \loop, 1,
    \start, Pseq([0, 0.5, 1, 1.5, 0.2, 0.8, 1.3], inf), // shifting start points
    \freq, Pseq([70, 75, 80, 68, 72], inf),
    \legato, Pseq([1, 2, 3, 1.5, 1], inf), // time overlap
    \pan, Pseq([-0.8, -0.4, 0, 0.4, 0.8], inf),// plays inthe order in loop
    \mix, Pwhite(0.6, 0.9, inf), // reverb
//)//.trace.play;
);

)

// heavy rain
(
~rain = Pbind(
    \instrument, \rain1,
    \bufnum, ~rainBuff,
    \amp, Pwhite(0.2, 0.4, inf),
    \dur, Pseq([2.0, 3.0, 4.0], inf),
    \loop, 1,
    \start, Pwhite(0.4, 0.8, inf),
    \highFreq, Pwhite(1500, 3000, inf),
    \lowFreq, Pwhite(300, 700, inf),
	\trigger, Pfunc { |ev| if (ev[\highFreq] > 2500) { 1 } { Rest(1) } },
    \pan, Pbrown(-0.3, 0.3, 0.02, inf),
	\fadeIn, 2,
	\fadeOut, 2,

// ).trace.play;

);
)

(

~metal = Pbind(
    \instrument, \metal,
    \bufnum, ~windBuff,
    \freq, Pwhite(200, 400, inf),
    \decay, Pwhite(1.0, 3.0, inf),
    \amp, Pwhite(0.4, 0.7, inf),
    \pan, Pwhite(-0.5, 0.5, inf),
    \dur, Pwhite(4.0, 8.0, inf),
    \trigger, Pfunc { |ev| if (ev[\freq] > 300) { 1 } { Rest(1) } }
// ).trace.play;
);
)

(
~fire = Pbind(
    \instrument, \fire,
    \degree, Pseq(~tempData, inf),
    \amp, Pwhite(0.2, 0.8, inf),
    \pan, Pwhite(-0.5, 0.5, inf),
    \dur, Pwhite(0.05, 0.2, inf),
    \crackles, Pfunc { |ev| if (ev[\degree] > 12) { 1.0 } {Rest(1)} }
// ).trace.play;
);
)



(
var clock;
clock = TempoClock.default;

Routine({
    // Start the patterns
    ~hum1.play(clock);
    ~hum2.play(clock);
    ~hum3.play(clock);
    ~fire.play(clock);

    10.wait;

    ~rain.play(clock);
    ~metal.play(clock);


    60.wait;

        ~hum1.stop;
        ~hum2.stop;
        ~hum3.stop;
        ~fire.stop;
        ~rain.stop;
        ~metal.stop;

}).play(clock);
)

SynthDescLib.global.removeAt(\fire);

s.meter;
s.queryAllNodes;

s.quit;
s.boot;

s.freeAll;


s.options.memSize;


