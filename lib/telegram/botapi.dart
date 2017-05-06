import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import './msgreader.dart';

const String API_URL = 'https://api.telegram.org/bot';
const String HOST = '127.0.0.1';
const int PORT = 80;

class BotApi {
    int _port = 80;
    String _host;
    String _botKey;
    String _webHookUrl;
    String _apiBaseUrl;
    List<MsgReader> _listeners = [];

    BotApi(
        String botKey, {
            String webHookUrl,
            String host: HOST,
            int port: PORT,
            String apiUrl: API_URL
        }
    ) {
        this._port = port;
        this._host = host;
        this._botKey = botKey;
        this._webHookUrl = webHookUrl;
        this._apiBaseUrl = apiUrl;
        var handler = const shelf.Pipeline()
            .addMiddleware(shelf.logRequests())
            .addHandler(_echoRequest);

        io.serve(handler, _host, _port).then((server) {
          print('Serving at http://${server.address.host}:${server.port}');
        });

        if (webHookUrl != Null) {
            // TODO: add reaction to other term signals besides 'Ctrl+C'
            ProcessSignal.SIGINT.watch().listen((signal) async {
              await _disableWebHook();
              exit(0);
            });
            _enableWebHook();
        }
    }

    subscribe(MsgReader reader) {
        if (_listeners.contains(reader)) {
            return;
        }
        _listeners.add(reader);
    }

    unsubscribe(MsgReader reader) {
        _listeners.remove(reader);
    }

    Future<shelf.Response> _echoRequest(shelf.Request request) async {
        if (request.url.toString() != '$_botKey/update') {
            return new shelf.Response.notFound('Page Not Found');
        }
        String body = await request.readAsString();
        Map msg;
        try {
            msg = JSON.decode(body);
        } catch(exception) {
            msg = {};
        }
        if (msg.containsKey('message') && msg['message'] is Map) {
            await _onMessage(msg['message']);
        }
        print(body);
        // формирование ответа
        return new shelf.Response.ok('Request for "${request.url}"');
    }

    Future<bool> onMessage(Map msg) => _onMessage(msg);
    Future<bool> _onMessage(Map msg) async {
        String chatId;
        try {
            chatId = msg['chat']['id'];
        } catch(exception) {
            return new Future.value(false);
        }
        Future.wait(_listeners.map((MsgReader reader) async {
            return {'chance': await reader.itsForMe(msg), 'reader': reader};
        })).then((List chances) async {
            Map maxChance = chances.reduce((Map first, Map next) {
                bool compareChance = first['chance'] > next['chance'];
                return compareChance ? first : next;
            });
            MsgReader reader = maxChance['reader'];
            Map answer = await reader.onMessage(msg);
            if (answer != Null) {
                await _sendMsg(chatId, answer['text']);
            }
        }).catchError((Error e) {
            print(e);
        });
        return new Future.value(true);
    }

    Future<bool> _sendMsg(String chat, String text) async {
        String url = '$_apiBaseUrl$_botKey/sendMessage?chat_id=$chat&text=$text';
        return _sendApi(url);
    }

    Future<bool> _enableWebHook() async {
        return _toggleWebHook(true);
    }

    Future<bool> _disableWebHook() async {
        return _toggleWebHook(false);
    }

    Future<bool> _toggleWebHook(bool state) async {
        String setUrl = state ? '?url=$_webHookUrl' : '';
        String url = '$_apiBaseUrl$_botKey/setWebhook$setUrl';
        return _sendApi(url);
    }

    // TODO: extend method for send other types messages
    Future<bool> _sendApi(String url) async {
        HttpClient client = new HttpClient();
        HttpClientRequest request = await client.getUrl(Uri.parse(url));
        HttpClientResponse response = await request.close();
        Stream contents = response.transform(UTF8.decoder);
        await for(String content in contents) {
            print(content);
        };
        return new Future.value(true);
    }
}
