from libraries import *


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

# Dynamic tempo effect
# librosa.effects.time_stretch(y, *, rate, **kwargs)
# Stretch factor. If rate > 1, then the signal is sped up. If rate < 1, then the signal is slowed down.
# need set implicit rate parameter , because the definition of function has additional parameter, then parameter rate
def time_stretch(signal, rate=1.0):

    
    if rate <= 0:
        raise ParameterError("rate must be a positive number")

    return lr.effects.time_stretch(signal, rate=rate)


# Scratch sound effect
# librosa.effects.pitch_shift(y, *, sr, n_steps, bins_per_octave=12, res_type='soxr_hq', scale=False, **kwargs)
# Resample type. By default, ‘soxr_hq’ is used. (high quality)
# A step is equal to a semitone if bins_per_octave is set to 12.

def pitch_shift_signal(signal, sampling_rate, n_steps, bins_per_octave=12, res_type='soxr_hq', scale=False):

    return lr.effects.pitch_shift(signal, sr=sampling_rate, n_steps=n_steps, 
                                  bins_per_octave=bins_per_octave, res_type=res_type, scale=scale)


# Define the IIR filter coefficients
b = [0.1]  # Numerator coefficients
a = [1, -0.9]  # Denominator coefficients

# Apply IIR filter as reverb effect
def apply_reverb(signal, b, a):
    return lfilter(b, a, signal)

def apply_fadeout(audio, sr, duration=3.0):
    # convert to audio indices (samples)
    length = int(duration * sr)
    end = audio.shape[0]
    start = end - length

    # compute fade out curve
    # linear fade
    fade_curve = np.linspace(1.0, 0.0, length)

    # apply the curve
    audio[start:end] = audio[start:end] * fade_curve

    
def apply_fadein(audio, sr, duration=3.0):
    # convert to audio indices (samples)
    length = int(duration * sr)

    # compute fade in curve
    # linear fade
    fade_curve = np.linspace(0.0, 1.0, length)

    # apply the curve
    audio[:length] = audio[:length] * fade_curve

def lowpass_filter(signal, cutoff_freq, sampling_rate, order=5):
    nyquist = 0.5 * sampling_rate
    normal_cutoff = cutoff_freq / nyquist
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    filtered_signal = filtfilt(b, a, signal)
    return filtered_signal

def highpass_filter(signal, cutoff_freq, sampling_rate, order=5):
    nyquist = 0.5 * sampling_rate
    normal_cutoff = cutoff_freq / nyquist
    b, a = butter(order, normal_cutoff, btype='high', analog=False)
    filtered_signal = filtfilt(b, a, signal)
    return filtered_signal
