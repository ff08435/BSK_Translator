from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from transformers import WhisperProcessor, WhisperForConditionalGeneration
import torch
import numpy as np
import io
import soundfile as sf

app = FastAPI()

# Allow Flutter app to call this
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
BASE_MODEL = "openai/whisper-small"
MODEL_PATH = "../whisper_burushaski_final"  # <-- change this

print("Loading model...")
processor = WhisperProcessor.from_pretrained(BASE_MODEL)
model = WhisperForConditionalGeneration.from_pretrained(MODEL_PATH)
model.eval()
print("Model loaded!")

@app.post("/translate-audio")
async def transcribe(file: UploadFile = File(...)):
    contents = await file.read()
    
    # Read audio bytes
    audio_data, sample_rate = sf.read(io.BytesIO(contents))
    
    # Convert to mono if stereo
    if len(audio_data.shape) > 1:
        audio_data = audio_data.mean(axis=1)
    
    # Resample to 16kHz if needed (Whisper requires 16kHz)
    if sample_rate != 16000:
        import librosa
        audio_data = librosa.resample(audio_data, orig_sr=sample_rate, target_sr=16000)
    
    # Process
    inputs = processor(
        audio_data.astype(np.float32),
        sampling_rate=16000,
        return_tensors="pt"
    )
    
    with torch.no_grad():
        predicted_ids = model.generate(
            inputs["input_features"],
            forced_decoder_ids=processor.get_decoder_prompt_ids(language="en", task="translate")
            # Use task="transcribe" if your model transcribes (same language)
            # Use task="translate" if it translates to English
        )
    
    transcription = processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]
    return {"text": transcription}

@app.get("/health")
def health():
    return {"status": "ok"}