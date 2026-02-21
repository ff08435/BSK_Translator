from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from transformers import WhisperProcessor, WhisperForConditionalGeneration
from pydub import AudioSegment
import torch
import numpy as np
import io
import os

app = FastAPI()

# Allow Flutter app to call this
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
BASE_MODEL = "openai/whisper-small"
# This path goes up one level from 'Backend' then into your model folder
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "..", "whisper_burushaski_final")

print(f"Loading model from: {MODEL_PATH}...")
try:
    processor = WhisperProcessor.from_pretrained(BASE_MODEL)
    model = WhisperForConditionalGeneration.from_pretrained(MODEL_PATH)
    model.eval()
    print("Model loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")

@app.post("/translate-audio")
async def transcribe(file: UploadFile = File(...)):
    contents = await file.read()
    
    # 1. Load audio using pydub (handles m4a, aac, wav, mp3 etc. via FFmpeg)
    audio_segment = AudioSegment.from_file(io.BytesIO(contents))
    
    # 2. Convert to 16kHz mono (required by Whisper)
    audio_segment = audio_segment.set_frame_rate(16000).set_channels(1)
    
    # 3. Convert to numpy array
    samples = np.array(audio_segment.get_array_of_samples()).astype(np.float32)
    
    # 4. Normalize to -1.0 to 1.0 (pydub samples are typically 16-bit integers)
    samples = samples / 32768.0
    
    # 5. Process with Whisper
    inputs = processor(samples, sampling_rate=16000, return_tensors="pt")
    
    with torch.no_grad():
        # Set language to "en" for translation tasks
        # If your Burushaski model outputs English, use task="translate"
        predicted_ids = model.generate(
            inputs["input_features"],
            forced_decoder_ids=processor.get_decoder_prompt_ids(language="en", task="translate")
        )
    
    transcription = processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]
    return {"text": transcription}

@app.get("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
