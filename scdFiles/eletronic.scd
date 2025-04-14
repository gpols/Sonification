
// Create environment
~eletric_env = ();
// TouchDesigner IP and Port
~td = NetAddr("169.254.79.245", 8000);
~td.sendMsg("/test", 1.0);

// Load data first
~eletric_env.init = { |self|

    // Get path to current document directory
    ~eletric = PathName(Document.current.dir);
    ~eletricData = CSVFileReader.read((~eletric +/+ "temperature_values.csv").fullPath, true, true);
    ~eletricData = ~eletricData.flatten.collect(_.asFloat);

    "Eletric Environment initialized!".postln;
};

// Initiate temperature data before everthing
~eletric_env.init.value;

~eletric_env.func = {

	SynthDef(\eletric, { |out=0, bufnum, trigger, rate, loop, start, amp=1.0, pan=0|
		var freq, sig;

	    freq = Demand.kr(Impulse.kr(0.5), 0, Dseq([300, 420, 280, 550], inf));
	    sig = SinOsc.ar(freq) * EnvGen.kr(Env.perc(0.01, 1), doneAction: Done.freeSelf) * amp;
	    sig = FreqShift.ar(sig, LFNoise1.kr(0.2).range(-200, 200));
	    sig = CombC.ar(sig, 0.3, 0.2, 2);

		sig = PanAz.ar(12, sig, pan, level: amp);

        // Send signal to output
        Out.ar(out, sig);
}).add;
};


// Embeds several event streams so that they form a single output stream with all their events in temporal order. When one stream ends, the other streams are further embedded until all have ended.

~eletric_env.makePatterns = {
    var temps = ~eletricData.copy;

    Pdef(\eletrics,
        Ppar([
            Pbind(
                \instrument, \eletric,
                \rate, 1.0,
                \loop, 1,
                \start, 0,
                \dur, 0.2,
				\pan, Pseg(Pwhite(-1.0, 1.0, inf), Pwhite(4.0, 12.0, inf)),
                \amp, Pseq(temps.collect { |val|
                    if (val > 16) { 0.5 } { Rest() }
                }, inf)
            ),
            Pbind(
                \dur, 0.2,
                \type, \rest,
                \dummy, Pseq(temps, inf),  // just to keep the same timing
                \doSend, Pfunc { |ev|
                    var ampVal = if (ev[\dummy] > 16) { 0.5 } { 0.0 };
                    AppClock.sched(0.0, {
                        ~td.sendMsg("/eletricAmp", ampVal);
                        nil;
                    });
                    Rest();
                }
            )
        ])
    );
};

~eletric_env.playRoutine = {
    Routine({
        Pdef(\eletrics).play;
		"Eletric started".postln;
    }).play;
};



~eletric_env.func.value;
~eletric_env.makePatterns.value;
~eletric_env.playRoutine.value;
~eletric_env.makeGui.value;






