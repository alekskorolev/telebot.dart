import 'dart:async';

abstract class MsgReader {
    MsgReader() {

    }

    Future<Map> onMessage(String text, Map msg, [bool hasAnswer = false]) async {
        if (!await itsForMe(text, hasAnswer)) {
            return new Future.value(Null);
        }
        Map question = await parseQuestion(msg);
        return prepareAnswer(question);
    }

    /*
     * Prepare answer
     */
    Future<Map> prepareAnswer(Map question);

    /*
     * Parse uesr text and find question
     */
    Future<Map> parseQuestion(Map msg);

    /*
     * Check user text for contains class command
     */
    Future<bool> itsForMe(String text, [bool hasAnswer = false]);
}
