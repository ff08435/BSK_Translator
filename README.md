# Burushaski to English

A Flutter mobile app that translates spoken Burushaski into English. Users record or upload audio, which is sent to a backend inference API for transcription and translation.

Burushaski is an endangered language isolate spoken in northern Pakistan (Hunza, Nagar, and surrounding regions), with no recognized linguistic relatives. This app is part of the broader **Burushaski Yaran** project, which aims to build speech translation tools for the language.

## How It Works

1. User records or uploads an audio clip of spoken Burushaski
2. The app sends the audio to a backend inference API
3. The API runs the audio through a fine-tuned Whisper model
4. The English translation is returned and displayed to the user

## About the Broader Project

Burushaski Yaran was built as a Final Year Project at Habib University. The project includes:

- A custom dataset of 511 sentences across 16 grammatical categories
- A dedicated data-elicitation PWA for audio collection
- Data augmentation (pitch shifting, speed perturbation, RIR) for training robustness
- A Whisper model fine-tuned for Burushaski speech recognition and translation
- A backend inference API serving the model
- Multiple client apps, including this one, for end users to interact with the system

The accompanying dataset paper was accepted at **CHiPSAL 2026** (co-located with LREC-COLING), and the project placed **3rd for Best Oral Presentation** at the DURS 2026 Symposium at Habib University.

## Tech Stack

- Flutter / Dart

## Getting Started

```bash
flutter pub get
flutter run
```

The app requires a running instance of the backend inference API. Update the API base URL in the app's configuration before running.

## Team

Built by Mahrukh Yousuf, Adina Mansoor, Azkaa Nasir, and Fatima Faisal, under the advisory of Tauqeer Saleem and Abdul Samad.
