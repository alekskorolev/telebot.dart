import 'dart:async';

abstract class MsgReader {
    MsgReader() {

    }

    Future<Map> onMessage(Map msg) async {
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
    Future<int> itsForMe(Map msg);
}
