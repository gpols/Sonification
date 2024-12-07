from libraries import *

def exponential(a, k, t):
    """
    Generate an exponential signal.
    
    Parameters:
    a (float): Initial amplitude of the signal.
    k (float): Growth rate of the exponential function.
    t (float): Time variable.
    
    Returns:
    float: The value of the exponential signal at time t.
    """
    return a * math.exp(k * t)

def apply_reverb(sound_data, decay=1.5, delay=0.2, fs=44100):
   """
   Apply a simple reverb effect to the sound data.
   
   Parameters:
   sound_data (numpy.ndarray): Array containing the sound wave.
   decay (float, optional): Decay factor for the reverb. Default is 0.5.
   delay (float, optional): Delay time for the reverb in seconds. Default is 0.02.
   fs (int, optional): Sampling frequency in Hz. Default is 44100.
   
   Returns:
   numpy.ndarray: Array containing the sound wave with reverb applied.
   """
   delay_samples = int(fs * delay)
   reverb_data = np.zeros_like(sound_data)
   
   for i in range(delay_samples, len(sound_data)):
      reverb_data[i] = sound_data[i] + decay * sound_data[i - delay_samples]
   
   # Normalize the reverb data
   reverb_data = reverb_data / np.max(np.abs(reverb_data))
   return reverb_data
