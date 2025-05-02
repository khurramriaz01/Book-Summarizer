import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = 'AIzaSyCzAnBNCSJHu1dLPI8_wqsMreKjicCYadM';
  
  try {
    print('Testing available models...');
    
    // Test different model names
    final models = [
      'gemini-1.5-flash',
    ];
    
    for (final modelName in models) {
      try {
        print('\nTesting model: $modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );
        
        // Try a simple generation to test if the model works
        final prompt = 'Say "Hello" if you can receive this message.';
        final response = await model.generateContent([Content.text(prompt)]);
        print('Response: ${response.text}');
        print('Model $modelName is available');
      } catch (e) {
        print('Model $modelName error: $e');
      }
      print('--------------------');
    }
  } catch (e) {
    print('Error in test: $e');
  }
} 