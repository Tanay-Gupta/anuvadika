import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:vosk_flutter/vosk_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isModelLoadingLeft = false;
  bool isModelLoadingRight = false;

  bool isRecordingLeft = false;

  bool isRecordingRight = false;

  String selectedLanguage = 'English';

  String oppositeLanguage = 'French';

  List<String> transcriptions = []; // List to store all transcriptions

  final ScrollController _scrollController = ScrollController();

  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();

  SpeechService? _speechService;

  Recognizer? _recognizer;

  String accumulatedText = ""; // To accumulate speech input

  @override
  void initState() {
    super.initState();
  }

  void _toggleRecordingLeft() async {
    setState(() {
      isRecordingLeft = !isRecordingLeft;
      isModelLoadingLeft = isRecordingLeft?true:false;

      if (isRecordingLeft) {
        isRecordingRight = false; // Stop right mic if left is started

        accumulatedText = ""; // Reset accumulated text

        _startRecognition(selectedLanguage);
      } else {
        _stopRecognition();
      }
    });
  }

  void _toggleRecordingRight() async {
    setState(() {
      isRecordingRight = !isRecordingRight;
      isModelLoadingRight =isRecordingRight? true:false;

      if (isRecordingRight) {
        isRecordingLeft = false; // Stop left mic if right is started

        accumulatedText = ""; // Reset accumulated text

        _startRecognition(oppositeLanguage);
      } else {
        _stopRecognitionRight();
      }
    });
  }

  Future<void> _startRecognition(String language) async {
    try {
      _recognizer = await _vosk.createRecognizer(
          model: await _loadModel(language), sampleRate: 16000);

      setState(() {
        isModelLoadingLeft = false;
        isModelLoadingRight = false;
      });

      if (_speechService == null) {
        _speechService = await _vosk.initSpeechService(_recognizer!);

        _speechService!.start();

        // Listen for results

        _speechService!.onResult().listen((event) {
          Map<String, dynamic> jsonResponse = json.decode(event);

          String convertedText = jsonResponse['text'].toString().trim();

          if (convertedText.isNotEmpty) {
            // Accumulate text while the microphone is on

            setState(() {
              accumulatedText += " $convertedText"; // Append new text
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        transcriptions.add("Error: ${e.toString()}");
      });
    }
  }

  Future<void> _stopRecognition() async {
    if (_speechService != null) {
      await _speechService!.stop();

      await _speechService!.dispose();

      _speechService = null;

      // Add accumulated text to the transcriptions list when mic stops

      if (accumulatedText.isNotEmpty) {
        accumulatedText='$selectedLanguage: $accumulatedText';
        setState(() {
          transcriptions.add(accumulatedText.trim()); // Add final text

          accumulatedText = ""; // Reset after adding

          _scrollToBottom(); // Auto-scroll to the latest message
        });
      }
    }

    if (_recognizer != null) {
      await _recognizer!.dispose();

      _recognizer = null;
    }
  }
Future<void> _stopRecognitionRight() async {
    if (_speechService != null) {
      await _speechService!.stop();

      await _speechService!.dispose();

      _speechService = null;

      // Add accumulated text to the transcriptions list when mic stops

      if (accumulatedText.isNotEmpty) {
        accumulatedText='$oppositeLanguage: $accumulatedText';
        setState(() {
          transcriptions.add(accumulatedText.trim()); // Add final text

          accumulatedText = ""; // Reset after adding

          _scrollToBottom(); // Auto-scroll to the latest message
        });
      }
    }

    if (_recognizer != null) {
      await _recognizer!.dispose();

      _recognizer = null;
    }
  }
  Future<Model> _loadModel(String language) async {
    String modelPath;

    if (language == 'English') {
      modelPath = 'assets/models/vosk-model-small-en-in-0.4.zip';
    } else if (language == 'French') {
      modelPath = 'assets/models/vosk-model-small-fr-0.22.zip';
    } else if (language == 'Hindi') {
      modelPath = 'assets/models/vosk-model-small-hi-0.22.zip';
    } else if (language == 'Japanese') {
      modelPath = 'assets/models/vosk-model-small-ja-0.22.zip';
    } else {
      modelPath =
          'assets/models/vosk-model-small-en-in-0.4.zip'; // Default to English
    }

    final loadedModelPath = await ModelLoader().loadFromAssets(modelPath);

    return await _vosk.createModel(loadedModelPath);
  }

  void _swapLanguages() {
    setState(() {
      final temp = selectedLanguage;

      selectedLanguage = oppositeLanguage;

      oppositeLanguage = temp;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Row(
          children: [
            SizedBox(width: 30),
            Icon(Icons.chat_bubble, color: Colors.white),
            SizedBox(width: 5),
            Flexible(
              child: Text(
                'Conversation',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 50),
            Icon(Icons.translate, color: Colors.white),
            SizedBox(width: 5),
            Flexible(
              child: Text(
                'Translation',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Chat background color

                  borderRadius: BorderRadius.circular(15),

                  border: Border.all(color: Colors.redAccent),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: transcriptions
                        .map((text) => _buildChatBubble(text))
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLanguageButton(selectedLanguage, true),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, size: 45),
                    onPressed: _swapLanguages,
                  ),
                  _buildLanguageButton(oppositeLanguage, false),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //----------------- Left Mic -----------------
                  GestureDetector(
                    onTap: isRecordingRight == false
                        ? _toggleRecordingLeft
                        : () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            isRecordingRight ? Colors.grey : Colors.redAccent,
                        child: isModelLoadingLeft
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isRecordingLeft ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 35,
                              ),
                      ),
                    ),
                  ),

                  //----------------- Right Mic -----------------
                  GestureDetector(
                    onTap: isRecordingLeft == false
                        ? _toggleRecordingRight
                        : () {},
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child:  CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            isRecordingLeft ? Colors.grey : Colors.redAccent,
                        child:isModelLoadingRight
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                          isRecordingRight ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text) {
    return Container(
      width: double.infinity, // Fixed width for chat bubbles

      padding: const EdgeInsets.all(10), // Padding inside the bubble

      margin: const EdgeInsets.symmetric(vertical: 4), // Space between bubbles

      decoration: BoxDecoration(
        color: Colors.blue[100], // Background color for the chat bubble

        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),

      child: SelectableText(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        toolbarOptions: const ToolbarOptions(copy: true),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildLanguageButton(String language, bool isLeft) {
    return GestureDetector(
      onTap: () => _showLanguageSelection(context, isLeft),
      child: Container(
        width: 120,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          language,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLanguageSelection(BuildContext context, bool isLeft) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: ['English', 'French', 'Hindi', 'Japanese']
                .map((language) => ListTile(
                      title: Text(language),
                      onTap: () {
                        setState(() {
                          if (isLeft) {
                            selectedLanguage = language;
                          } else {
                            oppositeLanguage = language;
                          }
                        });

                        Navigator.pop(context); // Close the modal
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
