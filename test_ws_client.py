import asyncio
import websockets
import base64

# Path to a short audio file for testing (must exist)
AUDIO_FILE = "test.wav"
WS_URL = "ws://localhost:8000/ws"  # Adjust if your server uses a different path/port

async def test_whisper_ws():
    async with websockets.connect(WS_URL) as ws:
        # Read audio file and send as binary
        with open(AUDIO_FILE, "rb") as f:
            audio_bytes = f.read()
        await ws.send(audio_bytes)
        # Wait for response
        response = await ws.recv()
        print("Transcription result:", response)

if __name__ == "__main__":
    asyncio.run(test_whisper_ws())
