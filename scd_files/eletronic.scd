
// ELETRIC SIGNAL SOUND
// Eletric beeping sound with reverb
// Use values of temperature data as condition

// Create environment
~eletric_env = ();


// TouchDesigner connection IP and Port
~td = NetAddr("10.100.56.216", 8000);
// test connection
// ~td.sendMsg("/test", 1.0);

// Load data first
~eletric_env.init = { |self|

    // Get path to current document directory
    ~eletric = PathName(Document.current.dir +/+ ".." +/+ "data_exp");
    ~eletricData = CSVFileReader.read((~eletric +/+ "temperature_values.csv").fullPath, true, true);
    ~eletricData = ~eletricData.flatten.collect(_.asFloat);

    "Eletric Environment initialized!".postln;
};

// Initiate environment data before everthing
~eletric_env.init.value;

// create sound synth inside a function
~eletric_env.func = {

	SynthDef(\eletric, { |out=0, trigger, rate, loop, start, amp=1.0, pan=0|
		var freq, sig;

		// Triggers a new frequency from the list Dseq every 2 seconds(0.5)
	    freq = Demand.kr(Impulse.kr(0.5), 0, Dseq([300, 420, 280, 550], inf));

		// oscilator signal shaped by envelope
	    sig = SinOsc.ar(freq) * EnvGen.kr(Env.perc(0.01, 1), doneAction: Done.freeSelf) * amp;

		// frequency shifting with slow random modulation
	    sig = FreqShift.ar(sig, LFNoise1.kr(0.2).range(-200, 200));

		// feedback delay
	    sig = CombC.ar(sig, 0.3, 0.2, 2);

        // output set up to 12 speakers (G05 Room)
		// sig = PanAz.ar(12, sig, pan, level: amp);

		// mono to stereo
	    sig = Pan2.ar(sig, pan);

        // Send signal to output
        Out.ar(out, sig);
}).add;
};


// copy data array to be safe
// the data will be mapped to play only above certain treshold
// Pbar runs both Pbind in parallel. One produces sound and the other sends data to TouchDesigner

~eletric_env.makePatterns = {
    var tempValues = ~eletricData.copy;

    Pdef(\eletrics,
        Ppar([
            Pbind(
                \instrument, \eletric,
                \rate, 1.0,
                \loop, 1,
                \start, 0,
                \dur, 0.2,
				\pan, Pseg(Pwhite(-1.0, 1.0, inf), Pwhite(4.0, 12.0, inf)),
				// values above 0.6 means summer months in the dataset
                \amp, Pseq(tempValues.collect { |val|
                    if (val > 0.6) { 0.5 } { Rest() }
                }, inf)
            ),
            Pbind(
                \dur, 0.2,
                \type, \rest, // does not play any sound
                \dummy, Pseq(tempValues, inf),  // just to keep the same timing
				// silent otherwise
                \doSend, Pfunc { |ev|
                    var ampValues = if (ev[\dummy] > 0.6) { 0.5 } { 0.0 };

					//send the OSC message instantly with each event
                    AppClock.sched(0.0, {
                        ~td.sendMsg("/eletricAmp", ampValues);
                        nil;
                    });
                    Rest();
                }
            );
        ])
    );
};


// creates function and pbind
~eletric_env.func.value;
~eletric_env.makePatterns.value;

// plays for 5 minutes then stop
Routine({

	Pdef(\eletrics).play;
        "Eletric Signal started".postln;

        300.wait;  // wait for 5 minutes

        Pdef(\eletrics).stop;
	    10.wait;// some synths may have finished their envelope release
	    s.freeAll; // free server
        "Eletric Signal stopped".postln;

}).play;





