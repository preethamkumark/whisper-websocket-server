# Whisper WebSocket Server

A high-performance WebSocket server for real-time speech transcription using OpenAI's Whisper model via faster-whisper implementation.

## 🎯 **Overview**

This server provides a WebSocket interface to faster-whisper, designed to work like the "kaldi-gstreamer" voice recognition server. It's optimized for real-time audio transcription and is compatible with Android apps like Konele.

## ✨ **Features**

- **Real-time Transcription**: WebSocket-based streaming audio transcription
- **Memory Efficient**: Keeps audio data in memory rather than temporary files
- **Text Corrections**: Built-in regex-based text correction system
- **Android Compatible**: Works with Konele app and similar clients
- **High Performance**: Uses faster-whisper for optimized inference
- **Flexible Models**: Support for various Whisper model sizes

## 🚀 **Quick Start**

### Prerequisites
- Python 3.8+
- CUDA GPU (recommended) or CPU

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/whisper-websocket-server.git
cd whisper-websocket-server

# Install dependencies
pip install -r requirements.txt
```

### Running the Server

```bash
# Start the WebSocket server
python minimal-fw-mem.py
```

The server will start on `ws://localhost:9001` by default.

## 📋 **API Usage**

### WebSocket Connection

Connect to the WebSocket server:
```javascript
const ws = new WebSocket('ws://localhost:9001/ws?user-id=your-user-id');
```

### Audio Streaming

Send audio data as binary WebSocket messages. The server will respond with transcribed text.

## 🔧 **Configuration**

### Model Selection

Edit the model configuration in `minimal-fw-mem.py`:

```python
# Available models: tiny, base, small, medium, large-v2, large-v3
model_name = "base"  # Change this to your preferred model
```

### Text Corrections

Add custom text corrections in the `corrections` dictionary:

```python
corrections = {
    r'\bConner\b': 'Conor',
    r'\bConnor\b': 'Conor',
    # Add your custom corrections here
}
```

## 📦 **Project Structure**

```
whisper-websocket-server/
├── minimal-fw-mem.py          # Main WebSocket server
├── test_ws_client.py          # WebSocket client for testing
├── requirements.txt           # Python dependencies
├── scripts/                   # Utility scripts
└── README.md                 # This file
```

## 🧪 **Testing**

Test the WebSocket server using the included test client:

```bash
python test_ws_client.py
```

## 🔗 **Integration**

### Android (Konele)
Configure Konele app to connect to your server:
- Server URL: `ws://your-server-ip:9001/ws?user-id=android-user`
- Content-Type: `audio/wav` or `audio/flac`

### Web Applications
```javascript
const ws = new WebSocket('ws://localhost:9001/ws?user-id=web-user');

ws.onopen = () => {
    console.log('Connected to Whisper WebSocket server');
};

ws.onmessage = (event) => {
    const transcription = JSON.parse(event.data);
    console.log('Transcription:', transcription.text);
};
```

## ⚙️ **Performance Optimization**

### GPU Acceleration
For better performance, ensure CUDA is properly installed:

```bash
# Check CUDA availability
python -c "import torch; print(torch.cuda.is_available())"
```

### Model Selection Guide
- **tiny**: Fastest, lowest accuracy (~39 MB)
- **base**: Good balance (~74 MB)
- **small**: Better accuracy (~244 MB)
- **medium**: High accuracy (~769 MB)
- **large-v2/v3**: Best accuracy (~1550 MB)

## 🐛 **Troubleshooting**

### Common Issues

1. **CUDA Out of Memory**: Use a smaller model or reduce batch size
2. **Slow Performance**: Ensure GPU is being used or try a smaller model
3. **Connection Issues**: Check firewall settings and port availability

### Debug Mode
Enable debug logging by setting the environment variable:
```bash
export LOG_LEVEL=DEBUG
python minimal-fw-mem.py
```

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 **References**

- [OpenAI Whisper](https://github.com/openai/whisper)
- [faster-whisper](https://github.com/guillaumekln/faster-whisper)
- [Original Implementation](https://github.com/rpdrewes/whisper-websocket-server)
- [Konele Android App](https://github.com/Kaljurand/K6nele)

## 🏷️ **Version**

Current version: 1.0.0

## 📞 **Support**

For support and questions:
- Create an [Issue](https://github.com/yourusername/whisper-websocket-server/issues)
- Check the [Documentation](https://github.com/yourusername/whisper-websocket-server/wiki)

---

**Built with ❤️ for real-time speech recognition**