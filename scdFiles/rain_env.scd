// create invironment
~rain_env = ();

// Load data first
~rain_env.init = { |self|
    ~rain = PathName(Document.current.dir);
    ~rainData = CSVFileReader.read((~rain +/+ "temperature_values.csv").fullPath, true, true);
    ~rainData = ~rainData.flatten.collect(_.asFloat);
    ~rainBuff = Buffer.sendCollection(s, ~rainData);
    " Rain Environment initialized!".postln;
};

~rain_env.init.value;
~rainData.plot;

~rain_env.func = {
    SynthDef(\rain, { |out=0, amp=0.4, gate=1, pan=0, rate=1, loop, trigger, bufnum, start, highFreq=4000, lowFreq=1000, fadeIn, fadeOut|

    var env;
	var sig;
	var rain;
	var startPos;

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
	"Rain Synth created!".postln;
    };


~rain_env.makePbinds = {
	[
	Pbind(
    \instrument, \rain,
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
        ).play;
    ];
};



// Run functions
~rain_env.func.value;
~rain_env.makePbinds.value;


SynthDescLib.global.browse;