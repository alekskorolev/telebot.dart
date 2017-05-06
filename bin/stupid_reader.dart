import 'dart:async';
import 'package:telebot.dart/telegram/msgreader.dart';

class StupidReader extends MsgReader {
    Future<Map> prepareAnswer(Map question) {
        Map answer = {
            'text': 'I`m sorry, I didn`t understand the question. Your ask: ${question['text']}'
        };
        return new Future.value(answer);
    }
    Future<Map> parseQuestion(Map msg) {
        return new Future.value(msg);
    }
    Future<int> itsForMe(Map msg) {
        return new Future.value(20);
    }
}
