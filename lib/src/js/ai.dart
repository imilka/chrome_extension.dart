// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unnecessary_import
// ignore_for_file: unintended_html_in_doc_comment

library;

import 'dart:js_interop';
import 'chrome.dart';

export 'chrome.dart';

// AbortController and AbortSignal bindings
@JS('AbortController')
extension type JSAbortController._(JSObject _) implements JSObject {
  external factory JSAbortController();
  
  /// The AbortSignal associated with this controller
  external JSAbortSignal get signal;
  
  /// Abort the operation
  external void abort([JSAny? reason]);
}

extension type JSAbortSignal._(JSObject _) implements JSObject {
  /// Whether the signal has been aborted
  external bool get aborted;
  
  /// The reason for aborting (if any)
  external JSAny? get reason;
  
  /// Add an event listener for the abort event
  external void addEventListener(String type, JSFunction listener);
  
  /// Remove an event listener
  external void removeEventListener(String type, JSFunction listener);
}

// Global LanguageModel API
@JS('LanguageModel')
external JSLanguageModel? get languageModelNullable;

JSLanguageModel get languageModel {
  var langModel = languageModelNullable;
  if (langModel == null) {
    throw ApiNotAvailableException('LanguageModel');
  }
  return langModel;
}

extension type JSLanguageModel._(JSObject _) {
  /// Check if the language model is available with the given options
  external JSPromise availability(JSAny? options);

  /// Get the parameters and capabilities of the language model
  external JSPromise params();

  /// Create a new language model session
  external JSPromise create(JSAny? options);
}

extension type JSLanguageModelSession._(JSObject _) implements JSObject {
  /// Send a prompt and get a response
  external JSPromise prompt(JSAny input, JSAny? options);

  /// Send a prompt and get a streaming response
  external JSAny promptStreaming(JSAny input, JSAny? options);

  /// Clone the current session
  external JSPromise clone(JSAny? options);

  /// Destroy the session and free resources
  external void destroy();

  /// Append messages to the session without prompting for a response
  external JSPromise append(JSArray messages, JSAbortSignal? signal);

  /// Measure how many tokens the input would consume
  external JSPromise measureInputUsage(JSAny input, JSAbortSignal? signal);

  /// Current input usage in tokens
  external int get inputUsage;

  /// Maximum input quota in tokens
  external int get inputQuota;

  /// Event fired when quota overflow occurs
  external Event get onQuotaOverflow;
}

// ReadableStream bindings for handling streaming responses
extension type JSReadableStream._(JSObject _) implements JSObject {
  /// Get a reader for this ReadableStream
  external JSReadableStreamDefaultReader getReader();
}

extension type JSReadableStreamDefaultReader._(JSObject _) implements JSObject {
  /// Read the next chunk from the stream
  external JSPromise read();

  /// Cancel the stream
  external JSPromise cancel([JSAny? reason]);

  /// Release the lock on the stream
  external void releaseLock();
}

extension type JSReadableStreamReadResult._(JSObject _) implements JSObject {
  /// Whether the stream is done
  external bool get done;

  /// The value of the current chunk
  external JSAny? get value;
}

// Data types
extension type LanguageModelParams._(JSObject _) implements JSObject {
  external factory LanguageModelParams({
    int defaultTopK,
    int maxTopK,
    double defaultTemperature,
    double maxTemperature,
  });

  external int get defaultTopK;
  external int get maxTopK;
  external double get defaultTemperature;
  external double get maxTemperature;
}

extension type ExpectedInput._(JSObject _) implements JSObject {
  external factory ExpectedInput({
    String type,
    JSArray? languages,
  });

  external String get type;
  external JSArray? get languages;
}

extension type ExpectedOutput._(JSObject _) implements JSObject {
  external factory ExpectedOutput({
    String type,
    JSArray? languages,
  });

  external String get type;
  external JSArray? get languages;
}

extension type Message._(JSObject _) implements JSObject {
  external factory Message({
    String role,
    JSAny content,
    bool? prefix,
  });

  external String get role;
  external JSAny get content;
  external bool? get prefix;
}

extension type Tool._(JSObject _) implements JSObject {
  external factory Tool({
    String name,
    String description,
    JSAny inputSchema,
    JSFunction? execute,
  });

  external String get name;
  external String get description;
  external JSAny get inputSchema;
  external JSFunction? get execute;
}

extension type LanguageModelCreateOptions._(JSObject _) implements JSObject {
  external factory LanguageModelCreateOptions({
    JSArray? initialPrompts,
    double? temperature,
    int? topK,
    JSArray? expectedInputs,
    JSArray? expectedOutputs,
    JSArray? tools,
    JSAbortSignal? signal,
    JSFunction? monitor,
  });

  external JSArray? get initialPrompts;
  external double? get temperature;
  external int? get topK;
  external JSArray? get expectedInputs;
  external JSArray? get expectedOutputs;
  external JSArray? get tools;
  external JSAbortSignal? get signal;
  external JSFunction? get monitor;
}

extension type LanguageModelPromptOptions._(JSObject _) implements JSObject {
  external factory LanguageModelPromptOptions({
    JSAny? responseConstraint,
    bool? omitResponseConstraintInput,
    JSAbortSignal? signal,
  });

  external JSAny? get responseConstraint;
  external bool? get omitResponseConstraintInput;
  external JSAbortSignal? get signal;
}

extension type LanguageModelCloneOptions._(JSObject _) implements JSObject {
  external factory LanguageModelCloneOptions({
    JSAbortSignal? signal,
  });

  external JSAbortSignal? get signal;
}

extension type LanguageModelAvailabilityOptions._(JSObject _) implements JSObject {
  external factory LanguageModelAvailabilityOptions({
    JSArray? expectedInputs,
    JSArray? expectedOutputs,
    double? temperature,
    int? topK,
  });

  external JSArray? get expectedInputs;
  external JSArray? get expectedOutputs;
  external double? get temperature;
  external int? get topK;
} 