import numpy as np
import struct
from scipy.signal import convolve

def apply_reverb(sample_data, reverb_data, frame_rate=44100.0, gain_dry=1, gain_wet=1, output_gain=0.05):
    """
    Apply a reverb effect to the given sample data using the provided reverb impulse data.

    Parameters:
    sample_data (bytes): The raw audio data of the sample.
    reverb_data (bytes): The raw audio data of the reverb impulse.
    frame_rate (float): The sample rate (frames per second).
    gain_dry (float): Gain for the dry signal (original sample).
    gain_wet (float): Gain for the wet signal (reverb).
    output_gain (float): Output gain for the final mix.

    Returns:
    np.ndarray: The processed audio data with the reverb effect applied.
    """

    # Unpack the sample frames into a numpy array and normalize
    num_samples_sample = len(sample_data) // 2  # Assuming 16-bit samples
    sample = struct.unpack('{n}h'.format(n=num_samples_sample), sample_data)
    sample = np.array([sample[0::2], sample[1::2]], dtype=np.float64)  # Separate channels
    sample[0] /= np.max(np.abs(sample[0]), axis=0)  # Normalize left channel
    sample[1] /= np.max(np.abs(sample[1]), axis=0)  # Normalize right channel

    # Unpack the reverb frames into a numpy array and normalize
    num_samples_reverb = len(reverb_data) // 2  # Assuming 16-bit samples
    reverb = struct.unpack('{n}h'.format(n=num_samples_reverb), reverb_data)
    reverb = np.array([reverb[0::2], reverb[1::2]], dtype=np.float64)  # Separate channels
    reverb[0] /= np.max(np.abs(reverb[0]), axis=0)  # Normalize left channel
    reverb[1] /= np.max(np.abs(reverb[1]), axis=0)  # Normalize right channel

    # Initialize the output array for the reverb effect
    reverb_out = np.zeros([2, np.shape(sample)[1] + np.shape(reverb)[1] - 1], dtype=np.float64)
    # Convolve the left channel of the sample with the left channel of the reverb
    reverb_out[0] = output_gain * (convolve(sample[0] * gain_dry, reverb[0] * gain_wet, method='fft'))
    # Convolve the right channel of the sample with the right channel of the reverb
    reverb_out[1] = output_gain * (convolve(sample[1] * gain_dry, reverb[1] * gain_wet, method='fft'))

    # Convert the floating-point reverb output to 16-bit integers
    reverb_integer = np.zeros((reverb_out.shape), dtype=np.int16)
    reverb_integer[0] = (reverb_out[0] * int(np.iinfo(np.int16).max)).astype(np.int16)
    reverb_integer[1] = (reverb_out[1] * int(np.iinfo(np.int16).max)).astype(np.int16)

    # Interleave the left and right channels for the final output
    reverb_to_render = np.empty((reverb_integer[0].size + reverb_integer[1].size), dtype=np.int16)
    reverb_to_render[0::2] = reverb_integer[0]
    reverb_to_render[1::2] = reverb_integer[1]

    return reverb_to_render

# Example usage:
# sample_data = ...  # Load your sample data here
# reverb_data = ...  # Load your reverb impulse data here
# processed_data = apply_reverb(sample_data, reverb_data)