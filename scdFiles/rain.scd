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


// SynthDef creation function
~rain_env.func = {
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
            LPF.ar(WhiteNoise.ar(0.8), highFreq),
            BPF.ar(WhiteNoise.ar(0.6), lowFreq, 0.7)]) * env * amp * rainSig;

        sig = PanAz.ar(12, sig, pan, level: amp);

        // Output signal
        Out.ar(out, sig);

    }).add;

    "Rain Synth created!".postln;
};


// Pattern generation function for rain playback
~rain_env.makePbinds = {
	    var temps = ~rainData.copy;
	Pdef(\rains,
		Pbind(
            \instrument, \rain,
            \bufnum, ~rainBuff,
            \dur, Pseq([2.0, 3.0, 4.0], inf),
            \loop, 1,
			\trigger, 1,
            \fadeIn, 2,
            \fadeOut, 2,
			\pan, Pseg(Pwhite(-1.0, 1.0, inf), Pwhite(4.0, 12.0, inf)),
			\amp, Pseq(temps.collect { |val|
                    var ampVal;
                    ampVal = if (val > 0.1) { 1.0 } { 0.0 };

                    if (ampVal > 0.0) {
                        ampVal  // Play sound
                    } {
                        Rest()  // Silent step
                    }
                }, inf)
	));
};

~rain_env.playRoutine = {
    Routine({
        Pdef(\rains).play;
        "Rain started".postln;

    }).play;
};

// Run SynthDefs and Patterns
~rain_env.func.value;
~rain_env.makePbinds.value;
~rain_env.playRoutine.value;

