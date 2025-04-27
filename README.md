# Future Sounds
**Sonification of Climate Projection Data**  
Author: Poliana Groth

## Introduction

Future Sounds is an experimental data art project that transforms long-term climate projections into immersive, symbolic soundscapes using SuperCollider and Python.  
Python is used for data analysis and preprocessing, and SuperCollider for sound synthesis.  
The final audio composition is optimized for 12-speaker surround sound but can be listened to in stereo as well.

## Requirements

- Python 3.9 or newer
- [SuperCollider (tested with version 3.13.0)](https://supercollider.github.io/download)
- [uv (Python package manager)](https://github.com/astral-sh/uv)

## Installation and Setup

### 1. Clone the Project

```bash
git clone https://github.com/gpols/Sonification.git
cd Sonification
```

### 2. Install `uv`

- **macOS**:
```bash
brew install astral-sh/uv/uv
```

- **Windows**:
  - Download the latest `uv.exe` from: https://github.com/astral-sh/uv/releases/latest
  - Extract and add its folder to your system PATH
  - Restart your terminal

### 3. Create a Virtual Environment

```bash
uv venv
```

### 4. Activate the Environment

- **macOS/Linux**:
```bash
source .venv/bin/activate
```

- **Windows (PowerShell)**:
```bash
.venv\Scripts\Activate.ps1
```

### 5. Install Dependencies

```bash
uv pip install -r pyproject.toml
```

## Running the Project

1. Open SuperCollider and load the scripts from the `scd_files/` folder.
2. Run individual sound scripts or the full composition script.
```
