

// Load file and sent to buffer
~path = PathName(Document.current.dir).parentPath +/+ "media";
~filePath = ~path +/+ "richmondPark.wav";
~atmosBuff = Buffer.read(s, ~filePath);


(
SynthDef(\birds, {|out=0, bufnum, pan=0, loop=0, rate=1, start=0|

    var sig;
	var startPos;

	// Calculate buffer playback rate and start position
    rate = rate * BufRateScale.kr(bufnum);
    startPos = start * BufFrames.kr(bufnum);
    sig = PlayBuf.ar(2, bufnum, rate:rate, startPos:startPos, loop:loop, doneAction: Done.freeSelf);

	        // Compile-time channel adaptation
        case
        {sig.isArray.not} {
            "Mono to stereo".postln;
            sig = Pan2.ar(sig, pan);
        }
        {sig.size == 2} {
            "Stereo balance".postln;
            sig = Balance2.ar(sig[0], sig[1], pan);
        }
        {sig.size > 2} {
            "Spread 12 channels".postln;
            sig = Splay.ar(sig).dup(12);
        };

    Out.ar(out, sig);
}).add;

 "Birds Synth created!".postln;
)

// Play it
// Start halfway through the file
// x = Synth(\birds, [\bufnum, ~atmosBuff, \start, 0.5]);

// Start at 25% and pan left
// y = Synth(\birds, [\bufnum, ~atmosBuff, \start, 0.25, \pan, -0.7]);

z = Synth(\birds, [\bufnum, ~atmosBuff, \start, 0.8, \rate, -1]);



