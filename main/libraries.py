#When run from your IPython profile, or using the %run -i PMCLibs.py command within your notebook, this file will load the necessary modules for PMC labs and define a few helper functions for working with audio files.

#import helpful stuff:
from __future__ import division, print_function, absolute_import
import xarray as xr
import pandas as pd
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import math
import scipy.constants as const
import scipy
from scipy.signal import resample, fftconvolve
from scipy.signal import fftconvolve
from scipy.io import wavfile
import seaborn as sns
from IPython.core.display import HTML
import soundfile as sf
#Is this helpful?
from numpy import sin, pi, arange, array
from scipy.signal import resample
import struct
import warnings
## Py 3
import sys
try:
    from StringIO import StringIO
except ImportError:
    from io import StringIO
import base64

try:
    from IPython.display import Audio
    def wavPlayer(data, rate):
        display(Audio(data, rate=rate))
except ImportError:
    pass

def play(data, rate=44100) :
    """ Creates an HTML audio player to play an array of samples stored in data.
        
        Data should be an array of sample values
        Each sample expected to be floats in the range -1 to 1
        Rate is expressed in Hz, default is 44100
        """
    tmp1 = 2**15 * data
    tmp  = tmp1.astype(np.int16)
    wavPlayer(tmp, rate)

def wavReadMono(filename):
    """ Reads a .wav file into a single array of samples.
        
        Sample data will be floats in the range -1 to 1
        """
    [rate, samps] = wavfile.read(filename)
    if (np.size(np.shape(samps)) == 1) :
        s = samps.astype(np.double)/2**15
    else:
        modsamps = samps[:,0].astype(np.double)/(2**15)
        for i in range(1, samps.shape[1]) :
            modsamps = modsamps + (samps[:,i].astype(np.double))/(2**15)
        modsamps = modsamps / samps.shape[1]
        s = modsamps
    
    return s;

def wavReadMulti(filename):
    """ Reads a .wav file into a multidimensional array.
        
        If called as data = wavReadMulti then
        data[:,i] will be an array storing samples for channel i
        Sample data will be floats in the range -1 to 1
        
        """
    [rate, samps] = wavfile.read(filename)
    if (np.size(np.shape(samps)) == 1) :
        s = samps.astype(np.double)/2**15
    else :
        modsamps = np.ndarray(shape=shape(samps),dtype=np.double)
        for i in range(0, samps.shape[1]) :
            modsamps[:,i] = (samps[:,i].astype(np.double))/(2**15)
        s = modsamps
    return s;

def wavWrite(filename, data, rate=44100):
    """ Writes data to a .WAV file """
    wavfile.write(filename, rate, (2**15*data).astype(np.int16))
