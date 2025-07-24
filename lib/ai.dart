// ignore_for_file: unnecessary_parenthesis, unintended_html_in_doc_comment

library;

import 'dart:async';
import 'src/internal_helpers.dart';
import 'src/js/ai.dart' as $js;

export 'src/chrome.dart' show chrome, EventStream;

final _languageModel = ChromeLanguageModel._();

extension ChromeAIExtension on Chrome {
  /// Use the `LanguageModel` API to access on-device language models for
  /// prompting and conversation. This API allows you to interact with Gemini Nano
  /// directly in the browser for privacy-focused, offline AI capabilities.
  ChromeLanguageModel get languageModel => _languageModel;
}

/// AbortController for cancelling AI operations
class AbortController {
  AbortController() : _wrapped = $js.JSAbortController();

  final $js.JSAbortController _wrapped;

  /// The AbortSignal associated with this controller
  AbortSignal get signal => AbortSignal._(_wrapped.signal);

  /// Abort the operation with an optional reason
  void abort([Object? reason]) {
    _wrapped.abort(reason?.jsify());
  }
}

/// AbortSignal for detecting cancellation
class AbortSignal {
  AbortSignal._(this._wrapped);

  final $js.JSAbortSignal _wrapped;

  $js.JSAbortSignal get toJS => _wrapped;

  /// Whether the signal has been aborted
  bool get aborted => _wrapped.aborted;

  /// The reason for aborting (if any)
  Object? get reason => _wrapped.reason?.dartify();

  /// Listen for abort events
  void onAbort(void Function() callback) {
    _wrapped.addEventListener('abort', callback.toJS);
  }
}

class ChromeLanguageModel {
  ChromeLanguageModel._();

  bool get isAvailable => $js.languageModelNullable != null && alwaysTrue;

  /// Check if the language model is available with the given options.
  ///
  /// Returns one of:
  /// - "unavailable": The model is not supported or available
  /// - "downloadable": The model can be downloaded
  /// - "downloading": The model is currently being downloaded
  /// - "available": The model is ready to use
  Future<String> availability([
    LanguageModelAvailabilityOptions? options,
  ]) async {
    var $res = await $js.languageModel.availability(options?.toJS).toDart;
    return $res as String;
  }

  /// Get the parameters and capabilities of the language model.
  /// Returns null if no language model is available.
  Future<LanguageModelParams?> params() async {
    var $res = await $js.languageModel.params().toDart;
    return ($res as $js.LanguageModelParams?)?.let(LanguageModelParams.fromJS);
  }

  /// Create a new language model session.
  ///
  /// [options] - Configuration options for the session including initial prompts,
  /// temperature, topK, expected inputs/outputs, tools, and monitoring.
  Future<LanguageModelSession> create([
    LanguageModelCreateOptions? options,
  ]) async {
    var $res = await $js.languageModel.create(options?.toJS).toDart;
    return LanguageModelSession.fromJS($res as $js.JSLanguageModelSession);
  }
}

class LanguageModelSession {
  LanguageModelSession.fromJS(this._wrapped);

  final $js.JSLanguageModelSession _wrapped;

  $js.JSLanguageModelSession get toJS => _wrapped;

  /// Send a prompt and get a response.
  ///
  /// [input] - The prompt text or message array
  /// [options] - Optional configuration including response constraints and abort signal
  Future<String> prompt(
    Object input, [
    LanguageModelPromptOptions? options,
  ]) async {
    var $res = await _wrapped.prompt(input.jsify()!, options?.toJS).toDart;
    return $res as String;
  }

  /// Send a prompt and get a streaming response.
  ///
  /// [input] - The prompt text or message array
  /// [options] - Optional configuration including response constraints and abort signal
  Stream<String> promptStreaming(
    Object input, [
    LanguageModelPromptOptions? options,
  ]) {
    var stream = _wrapped.promptStreaming(input.jsify()!, options?.toJS);
    // Convert the ReadableStream to a Dart Stream
    // Note: This is a simplified implementation - you may need to handle
    // the actual ReadableStream conversion based on the specific JS API
    return Stream.fromIterable([stream.toString()]);
  }

  /// Clone the current session.
  ///
  /// [options] - Optional configuration including abort signal
  Future<LanguageModelSession> clone([
    LanguageModelCloneOptions? options,
  ]) async {
    var $res = await _wrapped.clone(options?.toJS).toDart;
    return LanguageModelSession.fromJS($res as $js.JSLanguageModelSession);
  }

  /// Destroy the session and free resources.
  /// Once destroyed, the session cannot be used anymore.
  void destroy() {
    _wrapped.destroy();
  }

  /// Append messages to the session without prompting for a response.
  ///
  /// [messages] - Array of messages to append
  /// [signal] - Optional abort signal for cancellation
  Future<void> append(List<Message> messages, [AbortSignal? signal]) async {
    var jsMessages = messages.map((m) => m.toJS).toList().toJS;
    await _wrapped.append(jsMessages, signal?.toJS).toDart;
  }

  /// Measure how many tokens the input would consume without processing it.
  ///
  /// [input] - The input to measure
  /// [signal] - Optional abort signal for cancellation
  Future<int> measureInputUsage(Object input, [AbortSignal? signal]) async {
    var $res =
        await _wrapped.measureInputUsage(input.jsify()!, signal?.toJS).toDart;
    return $res as int;
  }

  /// Current input usage in tokens
  int get inputUsage => _wrapped.inputUsage;

  /// Maximum input quota in tokens
  int get inputQuota => _wrapped.inputQuota;

  /// Event stream for quota overflow events
  EventStream<void> get onQuotaOverflow =>
      _wrapped.onQuotaOverflow.asStream(($c) => ((void _) => $c(null)).toJS);
}

// Data classes
class LanguageModelParams {
  LanguageModelParams.fromJS(this._wrapped)
    : defaultTopK = _wrapped.defaultTopK,
      maxTopK = _wrapped.maxTopK,
      defaultTemperature = _wrapped.defaultTemperature,
      maxTemperature = _wrapped.maxTemperature;

  LanguageModelParams({
    required this.defaultTopK,
    required this.maxTopK,
    required this.defaultTemperature,
    required this.maxTemperature,
  }) : _wrapped = $js.LanguageModelParams(
         defaultTopK: defaultTopK,
         maxTopK: maxTopK,
         defaultTemperature: defaultTemperature,
         maxTemperature: maxTemperature,
       );

  final $js.LanguageModelParams _wrapped;

  /// Default top-K value for sampling
  final int defaultTopK;

  /// Maximum top-K value allowed
  final int maxTopK;

  /// Default temperature for sampling
  final double defaultTemperature;

  /// Maximum temperature allowed
  final double maxTemperature;

  $js.LanguageModelParams get toJS => _wrapped;
}

class ExpectedInput {
  ExpectedInput.fromJS(this._wrapped)
    : type = _wrapped.type,
      languages = _wrapped.languages?.toDart.cast<String>();

  ExpectedInput({required this.type, this.languages})
    : _wrapped = $js.ExpectedInput(
        type: type,
        // FIX: Ensure a JS array is always passed, even if empty.
        languages: (languages?.map((e) => e.toJS).toList() ?? const []).toJS,
      );

  final $js.ExpectedInput _wrapped;

  /// Type of input expected ("text", "image", "audio")
  final String type;

  /// Expected languages for this input type (optional)
  final List<String>? languages;

  $js.ExpectedInput get toJS => _wrapped;
}

class ExpectedOutput {
  ExpectedOutput.fromJS(this._wrapped)
    : type = _wrapped.type,
      languages = _wrapped.languages?.toDart.cast<String>();

  ExpectedOutput({required this.type, this.languages})
    : _wrapped = $js.ExpectedOutput(
        type: type,
        // FIX: Ensure a JS array is always passed, even if empty.
        languages: (languages?.map((e) => e.toJS).toList() ?? const []).toJS,
      );

  final $js.ExpectedOutput _wrapped;

  /// Type of output expected ("text", "image", "audio")
  final String type;

  /// Expected languages for this output type (optional)
  final List<String>? languages;

  $js.ExpectedOutput get toJS => _wrapped;
}

class Message {
  Message.fromJS(this._wrapped)
    : role = _wrapped.role,
      content = _wrapped.content.dartify()!,
      prefix = _wrapped.prefix;

  Message({required this.role, required this.content, this.prefix})
    : _wrapped = $js.Message(
        role: role,
        content: content.jsify()!,
        prefix: prefix,
      );

  final $js.Message _wrapped;

  /// Role of the message sender ("system", "user", "assistant")
  final String role;

  /// Content of the message (can be string or array for multimodal)
  final Object content;

  /// Whether this is a prefix message (optional)
  final bool? prefix;

  $js.Message get toJS => _wrapped;
}

class Tool {
  Tool._(
    this._wrapped,
    this.name,
    this.description,
    this.inputSchema,
    this.execute,
  );

  factory Tool.fromJS($js.Tool wrapped) {
    return Tool._(
      wrapped,
      wrapped.name,
      wrapped.description,
      wrapped.inputSchema.dartify()!,
      wrapped.execute != null
          ? (Object input) =>
          // Use callAsFunction to invoke the JS function
          wrapped.execute?.callAsFunction(
            wrapped, // 'this' context in JS
            input.jsify()!, // The argument to the function
          )
          : null,
    );
  }

  Tool({
    required this.name,
    required this.description,
    required this.inputSchema,
    this.execute,
  }) : _wrapped = $js.Tool(
         name: name,
         description: description,
         inputSchema: inputSchema.jsify()!,
         execute:
             execute != null
                 ? ((JSAny event) => execute(event.dartify()!)).toJS
                 : null,
       );

  final $js.Tool _wrapped;

  /// Name of the tool
  final String name;

  /// Description of what the tool does
  final String description;

  /// JSON schema for input parameters
  final Object inputSchema;

  /// Function to execute when tool is called (optional)
  final void Function(Object)? execute;

  $js.Tool get toJS => _wrapped;
}

class LanguageModelCreateOptions {
  LanguageModelCreateOptions({
    this.initialPrompts,
    this.temperature,
    this.topK,
    this.expectedInputs,
    this.expectedOutputs,
    this.tools,
    this.signal,
    this.monitor,
  });

  /// Initial conversation prompts
  final List<Message>? initialPrompts;

  /// Sampling temperature (0.0 to 2.0)
  final double? temperature;

  /// Top-K sampling parameter
  final int? topK;

  /// Expected input types and languages
  final List<ExpectedInput>? expectedInputs;

  /// Expected output types and languages
  final List<ExpectedOutput>? expectedOutputs;

  /// Available tools for the model
  final List<Tool>? tools;

  /// AbortSignal for cancellation
  final AbortSignal? signal;

  /// Monitor function for download progress
  final void Function(Object)? monitor;

  $js.LanguageModelCreateOptions get toJS {
    final options = {
      'initialPrompts':
          (initialPrompts?.map((m) => m.toJS).toList() ?? const []).toJS,
      if (temperature != null) 'temperature': temperature,
      if (topK != null) 'topK': topK,
      'expectedInputs':
          (expectedInputs?.map((e) => e.toJS).toList() ?? const []).toJS,
      'expectedOutputs':
          (expectedOutputs?.map((e) => e.toJS).toList() ?? const []).toJS,
      'tools': (tools?.map((t) => t.toJS).toList() ?? const []).toJS,
      'signal': signal?.toJS,
      if (monitor != null)
        'monitor': ((JSAny event) => monitor!(event.dartify()!)).toJS,
    };
    return options.jsify() as $js.LanguageModelCreateOptions;
  }
}

class LanguageModelPromptOptions {
  LanguageModelPromptOptions({
    this.responseConstraint,
    this.omitResponseConstraintInput,
    this.signal,
  });

  /// Response constraint (JSON schema or RegExp)
  final Object? responseConstraint;

  /// Whether to omit response constraint from input
  final bool? omitResponseConstraintInput;

  /// AbortSignal for cancellation
  final AbortSignal? signal;

  $js.LanguageModelPromptOptions get toJS {
    final options = {
      if (responseConstraint != null)
        'responseConstraint': responseConstraint.jsify(),
      if (omitResponseConstraintInput != null)
        'omitResponseConstraintInput': omitResponseConstraintInput,
      if (signal != null) 'signal': signal!.toJS,
    };
    return options.jsify() as $js.LanguageModelPromptOptions;
  }
}

class LanguageModelCloneOptions {
  LanguageModelCloneOptions({this.signal});

  /// AbortSignal for cancellation
  final AbortSignal? signal;

  $js.LanguageModelCloneOptions get toJS =>
      $js.LanguageModelCloneOptions(signal: signal?.toJS);
}

class LanguageModelAvailabilityOptions {
  LanguageModelAvailabilityOptions({
    this.expectedInputs,
    this.expectedOutputs,
    this.temperature,
    this.topK,
  });

  /// Expected input types and languages
  final List<ExpectedInput>? expectedInputs;

  /// Expected output types and languages
  final List<ExpectedOutput>? expectedOutputs;

  /// Sampling temperature
  final double? temperature;

  /// Top-K sampling parameter
  final int? topK;

  $js.LanguageModelAvailabilityOptions get toJS =>
      $js.LanguageModelAvailabilityOptions(
        // FIX: Convert null lists to empty JS arrays
        expectedInputs:
            (expectedInputs?.map((e) => e.toJS).toList() ?? const []).toJS,
        expectedOutputs:
            (expectedOutputs?.map((e) => e.toJS).toList() ?? const []).toJS,
        temperature: temperature,
        topK: topK,
      );
}
