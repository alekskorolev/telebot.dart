// Copyright (c) 2017, Aleksander Korolev. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

import 'package:telebot.dart/telegram/botapi.dart';

import '../config.dart';
import './stupid_reader.dart';
import './command_reader.dart';

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
        bot.subscribe(new StupidReader());
        bot.subscribe(new CommandReader());
    }
}
