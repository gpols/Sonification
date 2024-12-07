# Takes an array and adsr values, and returns the processed array. 
# Simple ADSR - Values cannot be 0.
# @Param1 : NUMPY ARRAY
# @Param1 : Relative Attack time (between 0 to 1)
# @Param2 : Relative Decay time (between 0 to 1)
# @Param3 : Relative Sustain time (between 0 to 1)
# @Param4 : Relative Release time (between 0 to 1)
# @Param5 : Relative sustain level time (between 0 to 1)
def envelope(array,a,d,s,r,sustain_level):

    numSamples = len(array)
    attack_length = round(a*numSamples)
    decay_length = round(d*numSamples)
    sustain_length = round(s*numSamples)
    release_length = round(r*numSamples)

    attack = np.linspace(0,1,attack_length)
    decay = np.linspace(1,sustain_level,decay_length)
    sustain = np.full((sustain_length,), sustain_level)
    release = np.linspace(sustain_level,0,release_length)

    envelope = np.concatenate((attack,decay,sustain,release))
    print(s*numSamples)

    if a+d+s+r < 1:
        rem = 1 - (a+d+s+r)
        rem_length = int(rem*numSamples)
        silence = np.full( (rem_length), 0)
        envelope = np.concatenate((envelope,  silence))

    # Ensure the envelope length matches the array length
    envelope = np.resize(envelope, numSamples)
    
    return np.multiply(array, envelope)