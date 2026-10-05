/*
A script is a list of:
step: <instruction>;
  text: <instruction>;
  prompt: <type> <tag>;
  wait: <wait>;

*/

class Prompt {
  String tag;
  Prompt(this.tag);
}

class ScriptItem {
  Prompt prompt;
  String text;

  ScriptItem(this.prompt, this.text);
}

class MyScript {
  final String script;

  MyScript(this.script);
}
