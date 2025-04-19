// Always set before boot
// Server.local.options.outDevice_("ASIO : Dante Virtual Soundcard (x64)");
// Server.local.options.numOutputBusChannels = 12;
// Server.local.options.sampleRate = 48000;



Document.current.dir();

(
"hum.scd".loadRelative();
// "rain.scd".loadRelative();
// "wind.scd".loadRelative();
"eletronic.scd".loadRelative();
)
// s.record(numChannels: 12);

// THINGS TO FIX

// All sounds more volume DONE


