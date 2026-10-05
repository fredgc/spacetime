import 'dart:convert';

import 'package:spacetime/scene.dart';

enum TestData {
  person('''
{
  "title": "Person Test Data Title",
  "drawables": [
    {
      "type": "person",
      "name": "P1",
      "color": 0,
      "frame": {
        "center": {
          "x": 0.0,
          "t": 0.0,
          "z": 0.0
        },
        "velocity": 0.0
      }
    }
  ],
  "time": 0.0,
  "velocity": 0.0,
  "center": {
    "x": 0.0,
    "t": 0.0,
    "z": 0.0
  },
  "zoom": 100.0,
  "version": "2.0.0"
}
  '''),

  train('''
{
  "title": "Train Test Data Title",
  "drawables": [
    {
      "type": "train",
      "name": "P1",
      "color": 1,
      "frame": {
        "center": {
          "x": -0.366,
          "t": 0.364,
          "z": 0.01
        },
        "velocity": 0.222
      }
    }
  ],
  "time": 0.5,
  "velocity": 0.123,
  "center": {
    "x": 0.1,
    "t": 0.2,
    "z": 0.3
  },
  "zoom": 100.0,
  "version": "2.0.0"
}
  '''),

  clock('''
{
  "title": "Clock Test Data Title",
  "drawables": [
    {
      "type": "clock",
      "name": "P1",
      "color": 0,
      "frame": {
        "center": {
          "x": -0.36615811373092927,
          "t": 0.3640776699029126,
          "z": 0.0
        },
        "velocity": 0.0
      }
    }
  ],
  "time": 0.0,
  "velocity": 0.0,
  "center": {
    "x": 0.0,
    "t": 0.0,
    "z": 0.0
  },
  "zoom": 100.0,
  "version": "2.0.0"
}
  '''),

  sample('''
{
  "title": "Sample Test Data Title",
  "drawables": [
    {
      "type": "event",
      "name": "an event",
      "color": 0,
      "frame": {
        "center": {
          "x": 0.0,
          "t": 0.0,
          "z": 0.1
        },
        "velocity": 0.0
      }
    },
    {
      "type": "instant",
      "name": "Inst",
      "color": 1,
      "frame": {
        "center": {
          "x": 0.45,
          "t": 0.5,
          "z": 0.2
        },
        "velocity": 0.0
      }
    },
    {
      "type": "instant",
      "name": "I2",
      "color": 2,
      "frame": {
        "center": {
          "x": 0.0,
          "t": 0.31,
          "z": 0.6
        },
        "velocity": 1.42
      }
    },
    {
      "type": "cone",
      "name": "L1",
      "color": 3,
      "frame": {
        "center": {
          "x": -1.0,
          "t": -1.2,
          "z": 0.4
        },
        "velocity": 0.0
      }
    },
    {
      "type": "person",
      "name": "P",
      "color": 0,
      "frame": {
        "center": {
          "x": -0.75,
          "t": 0.8,
          "z": 0.1
        },
        "velocity": 0.0
      }
    },
    {
      "type": "train",
      "name": "T",
      "color": 1,
      "frame": {
        "center": {
          "x": -1.2,
          "t": 1.0,
          "z": 0.1
        },
        "velocity": 0.0
      }
    },
    {
      "type": "barn",
      "name": "B",
      "color": 2,
      "frame": {
        "center": {
          "x": 0.5,
          "t": 1.0,
          "z": 0.1
        },
        "velocity": 0.0
      }
    },
    {
      "type": "flag",
      "name": "F",
      "color": 4,
      "frame": {
        "center": {
          "x": 0.1,
          "t": 1.0,
          "z": 0.1
        },
        "velocity": 0.0
      }
    },
    {
      "type": "clock",
      "name": "C1",
      "color": 0,
      "frame": {
        "center": {
          "x": 0.25,
          "t": 0.0,
          "z": 0.1
        },
        "velocity": 0.0
      }
    }
  ],
  "time": 1.42,
  "velocity": 0.12,
  "center": {
    "x": 0.0,
    "t": 0.0,
    "z": 0.0
  },
  "zoom": 100.0,
  "version": "uninitialized"
}
'''),

  error('''
{
  "title": "Error Test Data Title",
  "drawables": [
    {
      "type": "error",
      "name": "P1",
      "pt": {
        "x": -0.36615811373092927,
        "t": 0.3640776699029126,
        "z": 0.0
      },
      "color": 0,
      "frame": {
        "center": {
          "x": 0.0,
          "t": 0.0,
          "z": 0.0
        },
        "velocity": 0.0
      }
    }
  ],
  "time": 0.0,
  "velocity": 0.0,
  "center": {
    "x": 0.0,
    "t": 0.0,
    "z": 0.0
  },
  "zoom": 100.0,
  "version": "2.0.0"
}
''');

  final String json;
  const TestData(this.json);

  SceneData get data {
    var jsonMap = jsonDecode(json);
    SceneData result = SceneData.fromJson(jsonMap);
    return result;
  }

  static String toJson(SceneData data) {
    var encoder = JsonEncoder.withIndent("  ");
    return encoder.convert(data);
  }

  String url() {
    Uri uri = Uri(
      scheme: Uri.base.scheme,
      host: Uri.base.host,
      port: Uri.base.port,
      path: "/scene",
      queryParameters: {"json": json},
    );
    return uri.toString();
  }

  static SceneData clone(SceneData original) {
    var encoder = JsonEncoder.withIndent("  ");
    String json = encoder.convert(original);
    var jsonMap = jsonDecode(json);
    SceneData second = SceneData.fromJson(jsonMap);
    return second;
  }
}
