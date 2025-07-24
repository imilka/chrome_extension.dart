import 'dart:async';
import 'package:chrome_extension/ai.dart';

void main() async {
  print('Chrome AI API Example');
  
  // Check if the LanguageModel API is available
  if (!chrome.languageModel.isAvailable) {
    print('LanguageModel API is not available');
    return;
  }

  try {
    await demonstrateBasicUsage();
    await demonstrateAdvancedUsage();
    await demonstrateStreamingUsage();
    await demonstrateAbortUsage();
  } catch (e) {
    print('Error: $e');
  }
}

/// AbortController usage example
Future<void> demonstrateAbortUsage() async {
  print('\n=== AbortController Usage ===');
  
  final controller = AbortController();
  
  // Setup abort after 2 seconds
  Timer(Duration(seconds: 2), () {
    print('Aborting operation...');
    controller.abort('User requested cancellation');
  });
  
  try {
    final session = await chrome.languageModel.create(
      LanguageModelCreateOptions(
        signal: controller.signal,
      ),
    );
    
    final response = await session.prompt(
      'Write a very long essay about the future of artificial intelligence',
      LanguageModelPromptOptions(
        signal: controller.signal,
      ),
    );
    
    print('Response: $response');
    session.destroy();
  } catch (e) {
    print('Operation was aborted: $e');
  }
}

/// Basic usage: Check availability, get params, create session, and prompt
Future<void> demonstrateBasicUsage() async {
  print('\n=== Basic Usage ===');
  
  // Check if the language model is available
  final availability = await chrome.languageModel.availability();
  print('Model availability: $availability');
  
  if (availability == 'unavailable') {
    print('Language model is not available on this device');
    return;
  }
  
  // Get model parameters
  final params = await chrome.languageModel.params();
  if (params != null) {
    print('Model parameters:');
    print('  Default temperature: ${params.defaultTemperature}');
    print('  Max temperature: ${params.maxTemperature}');
    print('  Default topK: ${params.defaultTopK}');
    print('  Max topK: ${params.maxTopK}');
  }
  
  // Create a simple session
  final session = await chrome.languageModel.create();
  
  // Send a basic prompt
  final response = await session.prompt('Write a short poem about programming');
  print('\nResponse: $response');
  
  // Clean up
  session.destroy();
}

/// Advanced usage: Custom options, initial prompts, and session management
Future<void> demonstrateAdvancedUsage() async {
  print('\n=== Advanced Usage ===');
  
  // Create a session with custom options
  final session = await chrome.languageModel.create(
    LanguageModelCreateOptions(
      initialPrompts: [
        Message(
          role: 'system',
          content: 'You are a helpful coding assistant specialized in Dart.',
        ),
        Message(
          role: 'user',
          content: 'What is a Future in Dart?',
        ),
        Message(
          role: 'assistant',
          content: 'A Future in Dart represents a potential value or error that will be available at some time in the future.',
        ),
      ],
      temperature: 0.7,
      topK: 5,
      expectedInputs: [
        ExpectedInput(type: 'text', languages: ['en']),
      ],
      expectedOutputs: [
        ExpectedOutput(type: 'text', languages: ['en']),
      ],
    ),
  );
  
  print('Session created with custom options');
  print('Input usage: ${session.inputUsage}/${session.inputQuota}');
  
  // Continue the conversation
  final response = await session.prompt(
    'How do you handle errors with Futures?',
  );
  print('\nCoding Assistant Response: $response');
  
  // Clone the session for parallel conversations
  final clonedSession = await session.clone();
  final clonedResponse = await clonedSession.prompt(
    'What is async/await in Dart?',
  );
  print('\nCloned Session Response: $clonedResponse');
  
  // Clean up
  session.destroy();
  clonedSession.destroy();
}

/// Streaming usage: Get responses as they are generated
Future<void> demonstrateStreamingUsage() async {
  print('\n=== Streaming Usage ===');
  
  final session = await chrome.languageModel.create(
    LanguageModelCreateOptions(
      temperature: 0.9, // Higher temperature for more creative output
    ),
  );
  
  print('Streaming response:');
  
  // Send a prompt and stream the response
  final stream = session.promptStreaming(
    'Write a detailed explanation of how machine learning works, including key concepts.',
  );
  
  await for (final chunk in stream) {
    // Print each chunk as it arrives
    print(chunk);
  }
  
  session.destroy();
}

/// Example of handling multimodal content (requires appropriate setup)
Future<void> demonstrateMultimodalUsage() async {
  print('\n=== Multimodal Usage (Conceptual) ===');
  
  // This is a conceptual example - actual image/audio handling would require
  // proper file handling and browser APIs
  
  try {
    final session = await chrome.languageModel.create(
      LanguageModelCreateOptions(
        expectedInputs: [
          ExpectedInput(type: 'text'),
          ExpectedInput(type: 'image'),
        ],
      ),
    );
    
    // Example of multimodal message structure
    final messages = [
      Message(
        role: 'user',
        content: [
          {'type': 'text', 'value': 'What do you see in this image?'},
          // {'type': 'image', 'value': imageBlob}, // Would be actual image data
        ],
      ),
    ];
    
    print('Multimodal session created (example structure only)');
    session.destroy();
  } catch (e) {
    print('Multimodal example failed (expected): $e');
  }
}

/// Example of using tools with the language model
Future<void> demonstrateToolUsage() async {
  print('\n=== Tool Usage (Conceptual) ===');
  
  // This demonstrates the tool structure - actual execution would require
  // proper function implementations
  
  try {
    final session = await chrome.languageModel.create(
      LanguageModelCreateOptions(
        tools: [
          Tool(
            name: 'getCurrentTime',
            description: 'Get the current time and date',
            inputSchema: {
              'type': 'object',
              'properties': {},
            },
            execute: () {
              return DateTime.now().toString();
            },
          ),
          Tool(
            name: 'calculateMath',
            description: 'Perform mathematical calculations',
            inputSchema: {
              'type': 'object',
              'properties': {
                'expression': {
                  'type': 'string',
                  'description': 'Mathematical expression to evaluate',
                },
              },
              'required': ['expression'],
            },
            execute: (args) {
              // Simplified math evaluation (real implementation would be more robust)
              final expression = args['expression'] as String;
              return 'Result of $expression'; // Placeholder
            },
          ),
        ],
      ),
    );
    
    final response = await session.prompt(
      'What time is it and what is 2 + 2?',
    );
    
    print('Tool-enabled response: $response');
    session.destroy();
  } catch (e) {
    print('Tool usage example failed (expected): $e');
  }
}

/// Example of error handling and edge cases
Future<void> demonstrateErrorHandling() async {
  print('\n=== Error Handling ===');
  
  try {
    // Try to create a session with invalid parameters
    await chrome.languageModel.create(
      LanguageModelCreateOptions(
        temperature: -1.0, // Invalid temperature
      ),
    );
  } catch (e) {
    print('Caught expected error for invalid temperature: $e');
  }
  
  try {
    // Test with a destroyed session
    final session = await chrome.languageModel.create();
    session.destroy();
    
    // This should fail
    await session.prompt('This should fail');
  } catch (e) {
    print('Caught expected error for destroyed session: $e');
  }
  
  // Test quota monitoring
  final session = await chrome.languageModel.create();
  
  // Listen for quota overflow events
  session.onQuotaOverflow.listen((_) {
    print('Quota overflow detected!');
  });
  
  // Monitor input usage
  final usage = await session.measureInputUsage('Test prompt');
  print('Input usage for test prompt: $usage tokens');
  
  session.destroy();
} 