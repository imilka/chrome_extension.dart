import 'dart:async';
import 'package:chrome_extension/ai.dart';

void main() async {
  print('Chrome AI API - AbortController Example');
  
  if (!chrome.languageModel.isAvailable) {
    print('LanguageModel API is not available');
    return;
  }

  await demonstrateSessionAbort();
  await demonstratePromptAbort();
  await demonstrateCloneAbort();
  await demonstrateAppendAbort();
}

/// Example 1: Aborting session creation
Future<void> demonstrateSessionAbort() async {
  print('\n=== Session Creation Abort ===');
  
  final controller = AbortController();
  
  // Simulate stopping session creation after 1 second
  Timer(Duration(seconds: 1), () {
    print('Aborting session creation...');
    controller.abort('User cancelled');
  });
  
  try {
    final session = await chrome.languageModel.create(
      LanguageModelCreateOptions(
        signal: controller.signal,
        monitor: (monitor) {
          // Monitor download progress
          print('Download in progress...');
        },
      ),
    );
    
    print('Session created successfully');
    session.destroy();
  } catch (e) {
    print('Session creation aborted: $e');
  }
}

/// Example 2: Aborting a specific prompt
Future<void> demonstratePromptAbort() async {
  print('\n=== Prompt Abort ===');
  
  final session = await chrome.languageModel.create();
  final controller = AbortController();
  
  // Listen for abort events
  controller.signal.onAbort(() {
    print('Prompt was aborted!');
  });
  
  // Simulate stopping the prompt after 2 seconds
  Timer(Duration(seconds: 2), () {
    print('Aborting prompt...');
    controller.abort('Taking too long');
  });
  
  try {
    final response = await session.prompt(
      'Write a very long detailed essay about the history of computing',
      LanguageModelPromptOptions(
        signal: controller.signal,
      ),
    );
    
    print('Response: $response');
  } catch (e) {
    print('Prompt aborted: $e');
  } finally {
    session.destroy();
  }
}

/// Example 3: Aborting session cloning
Future<void> demonstrateCloneAbort() async {
  print('\n=== Clone Abort ===');
  
  final originalSession = await chrome.languageModel.create(
    LanguageModelCreateOptions(
      initialPrompts: [
        Message(role: 'system', content: 'You are a helpful assistant'),
      ],
    ),
  );
  
  final controller = AbortController();
  
  // Abort cloning immediately
  Timer(Duration(milliseconds: 100), () {
    print('Aborting clone operation...');
    controller.abort();
  });
  
  try {
    final clonedSession = await originalSession.clone(
      LanguageModelCloneOptions(
        signal: controller.signal,
      ),
    );
    
    print('Session cloned successfully');
    clonedSession.destroy();
  } catch (e) {
    print('Clone operation aborted: $e');
  } finally {
    originalSession.destroy();
  }
}

/// Example 4: Aborting append operation
Future<void> demonstrateAppendAbort() async {
  print('\n=== Append Abort ===');
  
  final session = await chrome.languageModel.create();
  final controller = AbortController();
  
  // Abort the append operation
  Timer(Duration(milliseconds: 500), () {
    print('Aborting append...');
    controller.abort();
  });
  
  try {
    await session.append(
      [
        Message(role: 'user', content: 'Hello'),
        Message(role: 'assistant', content: 'Hi there!'),
        Message(role: 'user', content: 'How are you?'),
      ],
      controller.signal,
    );
    
    print('Messages appended successfully');
  } catch (e) {
    print('Append operation aborted: $e');
  } finally {
    session.destroy();
  }
}

/// Example 5: Multiple operations with shared controller
Future<void> demonstrateSharedAbort() async {
  print('\n=== Shared Abort Controller ===');
  
  final controller = AbortController();
  
  // Simulate user clicking a "Stop All" button after 3 seconds
  Timer(Duration(seconds: 3), () {
    print('User clicked Stop All - aborting everything...');
    controller.abort('Stop all operations');
  });
  
  // Start multiple operations that can all be cancelled with one controller
  final futures = <Future>[];
  
  // Session creation
  futures.add(
    chrome.languageModel.create(
      LanguageModelCreateOptions(signal: controller.signal),
    ).then((session) {
      print('Session 1 created');
      return session;
    }).catchError((e) {
      print('Session 1 creation aborted: $e');
      return null;
    }),
  );
  
  // Another session creation
  futures.add(
    chrome.languageModel.create(
      LanguageModelCreateOptions(signal: controller.signal),
    ).then((session) {
      print('Session 2 created');
      return session;
    }).catchError((e) {
      print('Session 2 creation aborted: $e');
      return null;
    }),
  );
  
  // Wait for all operations to complete or be aborted
  final results = await Future.wait(futures);
  
  // Clean up any successful sessions
  for (final result in results) {
    if (result != null && result is LanguageModelSession) {
      result.destroy();
    }
  }
}

/// Example 6: Proper cleanup with AbortController
Future<void> demonstrateProperCleanup() async {
  print('\n=== Proper Cleanup Example ===');
  
  LanguageModelSession? session;
  final controller = AbortController();
  
  try {
    // Create session with abort capability
    session = await chrome.languageModel.create(
      LanguageModelCreateOptions(
        signal: controller.signal,
        temperature: 0.7,
      ),
    );
    
    print('Starting long-running prompt...');
    
    // Start a long-running prompt
    final promptFuture = session.prompt(
      'Write a 10,000-word comprehensive guide about artificial intelligence',
      LanguageModelPromptOptions(
        signal: controller.signal,
      ),
    );
    
    // Simulate user wanting to stop after 1 second
    Timer(Duration(seconds: 1), () {
      print('User wants to stop - aborting...');
      controller.abort('User requested stop');
    });
    
    final response = await promptFuture;
    print('Response: ${response.substring(0, 100)}...');
    
  } catch (e) {
    print('Operation aborted or failed: $e');
  } finally {
    // Always clean up the session, even if aborted
    session?.destroy();
    print('Session cleaned up');
  }
}

/// Example 7: Checking abort status
Future<void> demonstrateAbortStatus() async {
  print('\n=== Abort Status Check ===');
  
  final controller = AbortController();
  final signal = controller.signal;
  
  print('Signal aborted: ${signal.aborted}'); // false
  
  controller.abort('Manual abort for demonstration');
  
  print('Signal aborted: ${signal.aborted}'); // true
  print('Abort reason: ${signal.reason}'); // "Manual abort for demonstration"
  
  // Trying to use an already aborted signal
  try {
    await chrome.languageModel.create(
      LanguageModelCreateOptions(signal: signal),
    );
  } catch (e) {
    print('Expected error with pre-aborted signal: $e');
  }
} 