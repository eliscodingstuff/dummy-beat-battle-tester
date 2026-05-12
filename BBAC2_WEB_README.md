# BBAC2 Web - Sample Generator Usage

## Setup Instructions

### 1. Install Python Dependencies
```bash
pip install websockets watchdog
```

### 2. Start AutoLocSamples Server
```bash
cd BeatBattleAntiCheat
python autoLocSamples.py
```

You should see:
```
AutoLocSamples server starting on ws://localhost:8765
Monitoring downloads folder: C:\Users\YourName\Downloads
Server ready. Waiting for connections...
```

### 3. Start Web Server
Since browsers block local file access, you need to run a local web server:

**Option A: Python HTTP Server**
```bash
# In the parent BeatBattleAntiCheat folder (where index.html is)
python -m http.server 8000
```

**Option B: VS Code Live Server**
- Install "Live Server" extension
- Right-click index.html → "Open with Live Server"

### 4. Open Webpage
Navigate to: `http://localhost:8000`

## Usage Flow

1. **Sign In / Login**
   - Create account or login
   - Set sample destination folder

2. **User Screen**
   - Click "Generate Samples"

3. **Game Screen**
   - 5 random samples are displayed
   - Click any sample button to preview/play it
   - Click "Download ZIP" to:
     - Create a ZIP file with the 5 samples
     - Download it to your Downloads folder
     - AutoLocSamples automatically extracts it to your sample destination

4. **AutoLocSamples Process**
   - Watches Downloads folder for the ZIP
   - Waits up to 10 seconds
   - Extracts to: `YourSampleDestination/BBAC_Samples_TIMESTAMP/`
   - Sends status updates to webpage

## Features Implemented

✅ Random sample selection (5 from 15 available 808s)
✅ Sample preview (click button to play)
✅ ZIP creation in browser
✅ Automatic download
✅ WebSocket connection to native app
✅ Auto-extraction to configured folder
✅ Status messages and error handling
✅ 10-second timeout if file doesn't appear

## Troubleshooting

**"Could not connect to AutoLocSamples"**
- Make sure `python autoLocSamples.py` is running
- Check that port 8765 is not blocked

**"Not enough samples available"**
- Check that `sampleDatabase/manifest.json` exists
- Verify wav files are in `sampleDatabase/` folder

**Samples don't play**
- Make sure web server is running (not opening as `file://`)
- Check browser console for CORS errors

## File Structure
```
BeatBattleAntiCheat/
├── index.html
├── app.js
├── style.css
├── sampleDatabase/
│   ├── manifest.json
│   ├── Assault808.wav
│   ├── beneath808.wav
│   └── ... (15 total 808 samples)
└── BeatBattleAntiCheat/
    └── autoLocSamples.py
```
