from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from transformers import WhisperProcessor, WhisperForConditionalGeneration
from pydub import AudioSegment
import torch
import numpy as np
import io

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load from HF repo instead of local path
MODEL_ID = "Fatima983/whisper-burushaski"

print(f"Loading model from HF: {MODEL_ID}...")
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using device: {device}")

processor = WhisperProcessor.from_pretrained("openai/whisper-large-v2")
model = WhisperForConditionalGeneration.from_pretrained(MODEL_ID)
model.to(device)
model.eval()
print("Model loaded successfully!")

@app.post("/translate-audio")
async def transcribe(file: UploadFile = File(...)):
    contents = await file.read()
    
    audio_segment = AudioSegment.from_file(io.BytesIO(contents))
    audio_segment = audio_segment.set_frame_rate(16000).set_channels(1)
    
    samples = np.array(audio_segment.get_array_of_samples()).astype(np.float32)
    samples = samples / 32768.0
    
    inputs = processor(samples, sampling_rate=16000, return_tensors="pt")
    inputs = {k: v.to(device) for k, v in inputs.items()}
    
    with torch.no_grad():
        predicted_ids = model.generate(
            inputs["input_features"],
            forced_decoder_ids=processor.get_decoder_prompt_ids(
                language="en", task="translate"
            )
        )
    
    transcription = processor.batch_decode(
        predicted_ids, skip_special_tokens=True
    )[0]
    return {"text": transcription}

@app.get("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860)
