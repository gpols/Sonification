#When run from your IPython profile, or using the %run -i PMCLibs.py command within your notebook, this file will load the necessary modules for PMC labs and define a few helper functions for working with audio files.

#import helpful stuff:
from __future__ import division, print_function, absolute_import
import scipy.constants as const
import scipy
from scipy.signal import butter, filtfilt, resample, lfilter

import pandas as pd
import seaborn as sns

import numpy as np
from numpy import sin, pi, arange, array

import librosa as lr
from librosa import ParameterError
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import math

from scipy.io import wavfile
from IPython.core.display import HTML
import IPython.display as ipd
import sounddevice as sd


