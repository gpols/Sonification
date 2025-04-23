// Always set before boot

// Room G05 setup
// Server.local.options.outDevice_("ASIO : Dante Virtual Soundcard (x64)");
// Server.local.options.numOutputBusChannels = 12;
// Server.local.options.sampleRate = 48000;

// Start the timer
// ~startTime = SystemClock.seconds;

PathName(Document.current.dir +/+ ".." +/+ "scd_files");

(
"hum.scd".loadRelative();
"hiss.scd".loadRelative();
"fire.scd".loadRelative();
"eletronic.scd".loadRelative();
"All scripts loaded. Playback started.".postln;
)
// ~endTime = SystemClock.seconds;
// ("Total play duration: " ++ (~endTime - ~startTime).round(0.01) ++ " seconds").postln;

// s.record(numChannels: 12);


