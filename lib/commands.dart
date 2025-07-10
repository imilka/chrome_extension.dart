// ignore_for_file: unnecessary_parenthesis, unintended_html_in_doc_comment

library;

import 'src/internal_helpers.dart';
import 'src/js/commands.dart' as $js;
import 'src/js/tabs.dart' as $js_tabs;
import 'tabs.dart';

export 'src/chrome.dart' show chrome, EventStream;

final _commands = ChromeCommands._();

extension ChromeCommandsExtension on Chrome {
  /// Use the commands API to add keyboard shortcuts that trigger actions in
  /// your extension, for example, an action to open the browser action or send
  /// a command to the e xtension.
  ChromeCommands get commands => _commands;
}

class ChromeCommands {
  ChromeCommands._();

  bool get isAvailable => $js.chrome.commandsNullable != null && alwaysTrue;

  /// Returns all the registered extension commands for this extension and their
  /// shortcut (if active). Before Chrome 110, this command did not return
  /// `_execute_action`.
  /// [returns] Called to return the registered commands.
  Future<List<Command>> getAll() async {
    var result = await $js.chrome.commands.getAll().toDart;
    final dartified = result.dartify();

    // Handle the case where dartified is a Map instead of a List
    List<dynamic> commandsList;
    if (dartified is List) {
      commandsList = dartified;
    } else if (dartified is Map) {
      // If it's a map, try to extract values or handle as array-like object
      commandsList = dartified.values.toList();
    } else {
      // Fallback: assume it's an iterable or convert to list
      commandsList = (dartified as Iterable?)?.toList() ?? [];
    }

    return commandsList
        .map<Command>((e) => Command.fromJS($js.Command(
              name: e['name'] as String?,
              description: e['description'] as String?,
              shortcut: e['shortcut'] as String?,
            )))
        .toList();
  }

  /// Fired when a registered command is activated using a keyboard shortcut.
  EventStream<OnCommandEvent> get onCommand =>
      $js.chrome.commands.onCommand.asStream(
        ($c) =>
            (String command, $js_tabs.Tab? tab) {
              return $c(
                OnCommandEvent(command: command, tab: tab?.let(Tab.fromJS)),
              );
            }.toJS,
      );
}

class Command {
  Command.fromJS(this._wrapped);

  Command({
    /// The name of the Extension Command
    String? name,

    /// The Extension Command description
    String? description,

    /// The shortcut active for this command, or blank if not active.
    String? shortcut,
  }) : _wrapped = $js.Command(
         name: name,
         description: description,
         shortcut: shortcut,
       );

  final $js.Command _wrapped;

  $js.Command get toJS => _wrapped;

  /// The name of the Extension Command
  String? get name => _wrapped.name;

  set name(String? v) {
    _wrapped.name = v;
  }

  /// The Extension Command description
  String? get description => _wrapped.description;

  set description(String? v) {
    _wrapped.description = v;
  }

  /// The shortcut active for this command, or blank if not active.
  String? get shortcut => _wrapped.shortcut;

  set shortcut(String? v) {
    _wrapped.shortcut = v;
  }
}

class OnCommandEvent {
  OnCommandEvent({required this.command, required this.tab});

  final String command;

  final Tab? tab;
}
