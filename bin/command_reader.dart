import 'dart:async';
import 'package:telebot.dart/telegram/msgreader.dart';

class CommandReader extends MsgReader {
    List<String> _knownCommands = [
        'help',
        'start'
    ];

    Future<Map> prepareAnswer(Map question) {
        String command = question['command'];
        String answer;
        switch(command) {
            case '/help':
                answer = _help();
                break;
            case '/start':
                answer = _start();
                break;
            default:
                answer = _start();
        }
        return new Future.value(answer);
    }

    String _help() => '''
        Это справочная информация по боту, будет дополняться.
    ''';

    String _start() => '''
        Это приветственная информация по боту, будет дополняться.
    ''';

    Future<Map> parseQuestion(Map msg) {
        String command = _getCommand(msg);
        return new Future.value({'command': command});
    }

    String _getCommand(Map msg) {
        if (msg.containsKey('text')) {
            String text = msg['text'];
            if (text[0] == '/') {
                String command = text.split(' ')[0];
                return command;
            }
        }
        return '';
    }
    
    Future<int> itsForMe(Map msg) {
        String command = _getCommand(msg);
        return new Future.value(_knownCommands.contains(command) ? 100 : 0);
    }
}
