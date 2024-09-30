 
import 'package:flutter/material.dart';

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'package:flutter_tts/flutter_tts.dart';

 

class TranslatorPage extends StatefulWidget {

  @override

  _TranslatorPageState createState() => _TranslatorPageState();

}

 

class _TranslatorPageState extends State<TranslatorPage> {

  final TextEditingController _textController = TextEditingController();

  String _translatedText = '';

  late OnDeviceTranslator _onDeviceTranslator;

  late FlutterTts _flutterTts; // Initialize FlutterTTS

  TranslateLanguage _sourceLanguage = TranslateLanguage.english;

  TranslateLanguage _targetLanguage =

      TranslateLanguage.french; // Default to French for demonstration

 

  @override

  void initState() {

    super.initState();

    _flutterTts = FlutterTts(); // Instantiate TTS

    _initializeTranslator();

  }

 

  // Initialize the translator based on selected source and target languages

  void _initializeTranslator() {

    _onDeviceTranslator = OnDeviceTranslator(

      sourceLanguage: _sourceLanguage,

      targetLanguage: _targetLanguage,

    );

  }

 

  // Check and download TTS language packs if needed

  Future<void> _downloadTTSLanguages() async {

    String targetLanguageCode = _getLanguageCode(_targetLanguage);

 

    await _checkAndDownloadTTS(targetLanguageCode);

  }

 

  // Method to check and download TTS language pack for a specific language

  Future<void> _checkAndDownloadTTS(String languageCode) async {

    bool isLanguageAvailable =

        await _flutterTts.isLanguageAvailable(languageCode);

    if (!isLanguageAvailable) {

      // Download the language pack in the background if not already available

      print("Downloading TTS language pack for $languageCode");

      await _flutterTts.setLanguage(languageCode);

    } else {

      print("TTS language pack for $languageCode is already available.");

    }

  }

 

  // Translate text and trigger TTS speech output

  Future<void> _translateText() async {

    if (_textController.text.isEmpty) return;

    try {

      // Download TTS pack for the target language

      await _downloadTTSLanguages();

 

      // Perform translation

      final String translatedText =

          await _onDeviceTranslator.translateText(_textController.text);

      setState(() {

        _translatedText = translatedText;

      });

 

      // Speak the translated text after translation is done

      await _speakTranslatedText();

    } catch (e) {

      setState(() {

        _translatedText = 'Translation error: $e';

      });

    }

  }

 

  // Function to trigger Text-to-Speech for the translated text

  Future<void> _speakTranslatedText() async {

    if (_translatedText.isNotEmpty) {

      // Set TTS language to the target language before speaking

      String targetLanguageCode = _getLanguageCode(_targetLanguage);

      await _flutterTts.setLanguage(targetLanguageCode);

      await _flutterTts.speak(_translatedText);

    }

  }

 

  // Helper method to map TranslateLanguage to language codes for TTS

  String _getLanguageCode(TranslateLanguage language) {

    switch (language) {

      case TranslateLanguage.english:

        return 'en-US'; // English US

      case TranslateLanguage.hindi:

        return 'hi-IN'; // Hindi

      case TranslateLanguage.french:

        return 'fr-FR'; // French

      case TranslateLanguage.japanese:

        return 'ja-JP'; // Japanese

      case TranslateLanguage.spanish:

        return 'es-ES'; // Spanish (Spain)

      case TranslateLanguage.german:

        return 'de-DE'; // German

      case TranslateLanguage.bengali:

        return 'bn-IN'; // Bengali

      default:

        return 'en-US'; // Default to English

    }

  }

 

  // Language mapping for dropdowns

  final Map<String, TranslateLanguage> _languages = {

    'English': TranslateLanguage.english,

    'Hindi': TranslateLanguage.hindi,

    'French': TranslateLanguage.french,

    'Japanese': TranslateLanguage.japanese,

    'Spanish': TranslateLanguage.spanish,

    'German': TranslateLanguage.german,

    'Bengali': TranslateLanguage.bengali, // Bengali added

  };

 

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Translator'),

        backgroundColor: Colors.red, // AppBar color

      ),

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(16.0),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // Dropdown for Source Language

              DropdownButton<TranslateLanguage>(

                value: _sourceLanguage,

                onChanged: (TranslateLanguage? newValue) {

                  setState(() {

                    _sourceLanguage = newValue!;

                    _initializeTranslator();

                  });

                },

                items: _languages.entries.map((entry) {

                  return DropdownMenuItem<TranslateLanguage>(

                    value: entry.value,

                    child: Text(entry.key),

                  );

                }).toList(),

              ),

              // Dropdown for Target Language

              DropdownButton<TranslateLanguage>(

                value: _targetLanguage,

                onChanged: (TranslateLanguage? newValue) {

                  setState(() {

                    _targetLanguage = newValue!;

                    _initializeTranslator();

                  });

                },

                items: _languages.entries.map((entry) {

                  return DropdownMenuItem<TranslateLanguage>(

                    value: entry.value,

                    child: Text(entry.key),

                  );

                }).toList(),

              ),

              // TextField for Input

              TextField(

                controller: _textController,

                decoration: InputDecoration(

                  labelText: 'Enter text to translate',

                  border: OutlineInputBorder(),

                  filled: true,

                  fillColor: Colors.red[50], // Light red background for input

                ),

              ),

              const SizedBox(height: 20),

              ElevatedButton(

                onPressed: _translateText,

                style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.red), // Red button color

                child: const Text('Translate'),

              ),

              const SizedBox(height: 20),

              const Text(

                'Translated Text:',

                style: TextStyle(fontWeight: FontWeight.bold),

              ),

              const SizedBox(height: 10),

              Text(_translatedText),

              const SizedBox(height: 20),

              if (_translatedText.isNotEmpty)

                IconButton(

                  icon: Icon(Icons.volume_up),

                  color: Colors.red,

                  iconSize: 36.0,

                  onPressed:

                      _speakTranslatedText, // Play TTS when icon is tapped

                ),

            ],

          ),

        ),

      ),

    );

  }

 

  @override

  void dispose() {

    _textController.dispose();

    _flutterTts.stop(); // Stop TTS when widget is disposed

    super.dispose();

  }

}

 


 