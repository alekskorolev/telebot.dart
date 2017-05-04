// Copyright (c) 2017, Aleksander Korolev. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';

import 'package:telebot.dart/telegram/botapi.dart';
import 'package:telebot.dart/telegram/msgreader.dart';

import '../config.dart';

class Reader extends MsgReader {
    Future<Map> prepareAnswer(Map question) {
        Map answer = {
            'text': 'Your ask: ${question['text']}'
        };
        print(answer);
        return new Future.value(answer);
    }
    Future<Map> parseQuestion(Map msg) {
        return new Future.value(msg);
    }
    Future<bool> itsForMe(String text, [bool hasAnswer = false]) {
        return new Future.value(!hasAnswer);
    }
}

class BlaReader extends MsgReader {
    String _name;
    BlaReader(this._name) : super();
    Random rng = new Random();
    Future<Map> prepareAnswer(Map question) {
        Map answer = {
            'text': 'I`m ${_name}. Your ask me: ${question['text']}'
        };
        print(answer);
        return new Future.value(answer);
    }
    Future<Map> parseQuestion(Map msg) {
        return new Future.value(msg);
    }
    Future<bool> itsForMe(String text, [bool hasAnswer = false]) {
        bool my = text.contains(_name);
        return new Future.value(!hasAnswer && my);
    }
}

class CalcReader extends MsgReader {
    RegExp _checker = new RegExp(r'\d+[\+\-\/\*\^]\d+');
    RegExp _parser = new RegExp(r'(\w+)');
    Future<Map> prepareAnswer(Map question) {
        Map answer = {
            'text': 'I`m Calc. Your ask me: ${question['vals'].join(' ; ')}'
        };
        print(answer);
        return new Future.value(answer);
    }
    Future<Map> parseQuestion(Map msg) {
        String text = msg['text'];
        List vals = [];
        Iterable<Match> matches = _parser.allMatches(text);
        for (Match m in matches) {
            String match = m.group(0);
            vals.add(match);
        }
        Map question = {
            'vals': vals
        };
        return new Future.value(question);
    }
    Future<bool> itsForMe(String text, [bool hasAnswer = false]) {
        bool my = text.contains(_checker);
        return new Future.value(!hasAnswer && my);
    }
}

void main(List<String> args) {
    ArgParser parser = new ArgParser()
        ..addOption('port', abbr: 'p', defaultsTo: BOT_PORT)
        ..addOption('host', abbr: 'h', defaultsTo: BOT_HOST)
        ..addOption('silent', abbr: 's', defaultsTo: 'false');

    ArgResults result = parser.parse(args);

    int port = int.parse(result['port'], onError: (val) {
        stdout.writeln('Could not parse port value "$val" into a number.');
        exit(1);
    });

    BotApi bot = new BotApi(
        TELEGRAM_KEY,
        webHookUrl: WEB_HOOK_URL,
        host: result['host'],
        port: port,
        apiUrl: TELEGRAM_BASE_URL
    );
    if (result['silent'] != 'true') {
        bot.subscribe(new BlaReader('one'));
        bot.subscribe(new CalcReader());
        bot.subscribe(new Reader());
    }
}
