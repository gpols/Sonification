// Always set before boot
Server.local.options.outDevice_("ASIO : Dante Virtual Soundcard (x64)");
Server.local.options.numOutputBusChannels = 12;
Server.local.options.sampleRate = 48000;

s.boot;

Document.current.dir();

"hum.scd".loadRelative();
"rain.scd".loadRelative();
"wind.scd".loadRelative();
"eletronic.scd".loadRelative();

// s.record(numChannels: 12);


// eletronic  introduce after 3 min
// hum and rain is the only ones to start from beggining
// fire introduce after 1.5 minutes


// THINGS TO FIX

// All sounds more volume
// different values to each channel
//


