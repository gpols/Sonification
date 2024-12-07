from libraries import *

def tremolo(a, f, t, m, c):
    """
    Apply a tremolo effect to an audio signal.
    Parameters:
    a (float): Amplitude of the audio signal.
    f (float): Frequency of the tremolo effect.
    t (float): Time variable.
    m (float): Modulation depth of the tremolo effect.
    c (float): Phase offset of the tremolo effect.
    Returns:
    float: The amplitude-modulated audio signal.
    """

    return a * (1 + m * math.sin(2 * math.pi * f * t + c))


def square_wave(a, f, t, m, c):
    """
    Generate a square wave signal.
    
    Parameters:
    a (float): Amplitude of the wave.
    f (float): Frequency of the wave in Hz.
    t (numpy.ndarray): Time array.
    m (float): Modulation depth.
    c (float): Phase shift.
    
    Returns:
    numpy.ndarray: The generated square wave signal.
    """
    return a * (1 + m * np.sign(np.sin(2 * np.pi * f * t + c)))



