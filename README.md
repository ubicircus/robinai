

# Robin - AI Companion

**Robin** is an app designed for testing various LLM models. Deployable on both iOS and Android, Robin currently supports chat functionality with four models: OpenAI, Groq, Perplexity, and a custom backend.

## Features
- [x] **Chat with AI:** Interact with multiple LLM models.
- [x] **Models Available:**
  - OpenAI
  - Groq
  - Perplexity
  - Gemini
  - Custom Backend

## Roadmap

- [x] Integration of Gemini model¹
- [ ] Checking the available models at the start²
- [ ] Chat with image support³
- [ ] Work on custom system prompts⁴
- [ ] Sending and receiving audio (TTS)⁵
- [ ] Streaming communication for faster responses⁶
- [ ] Counting tokens

## Notes

1. **Integration of Gemini model:** Adding support for the Gemini AI model. Get the models, send chat messages, check image API.

2. **Checking the available models at the start:** Ensuring all models are available and working upon app launch. Use proper BLOC state at init.

3. **Chat with image support:** Allowing users to send and receive images in chat. Probably have to change the structure of the chat bloc - now only Strings are available as messages.

4. **Work on custom system prompts:** Enabling custom prompts for different system behaviors. Having the list of horizontal buttons under the chat and quickly change the system prompts. 

5. **Sending and receiving audio (TTS):** Implementing text-to-speech and speech-to-text functionalities.

6. **Streaming communication for faster responses:** Improving response times by enabling streaming communication.

## Installation

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) installed
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) for iOS

### Steps
1. **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/robin-ai-companion.git
    cd robin-ai-companion
    ```

2. **Get packages:**
    ```bash
    flutter pub get
    ```

3. **Run the app:**
    ```bash
    flutter run
    ```

## Contributing
Feel free to fork and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) License.
