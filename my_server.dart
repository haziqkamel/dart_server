import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final server = await createServer();
  print('Server started: ${server.address.address}:${server.port}');
  await handleRequests(server);
}

Future<void> handleRequests(HttpServer server) async {
  await for (HttpRequest req in server) {
    switch (req.method) {
      case 'GET':
        handleGet(req);
        break;
      case 'POST':
        handlePost(req);
        break;
      default:
        handleDefault(req);
        break;
    }
  }
}

String myString = 'Hello from a Dart Server';

// Handle default method request
void handleDefault(HttpRequest req) {
  req.response.statusCode = HttpStatus.methodNotAllowed;
  Map<String, dynamic> res = {
    'response_code': req.response.statusCode,
    'message': 'Unsupported Request ${req.method}',
  };

  req.response
    ..write(jsonEncode(res))
    ..close();
}

//#region POST request
// Handle request method POST
void handlePost(HttpRequest req) async {
  final path = req.requestedUri.path;

  switch (path) {
    case '/abx':
      handlePostAbx(req);
      break;
  }
}

void handlePostAbx(HttpRequest req) {
  final queryParams = req.uri.queryParameters;
  req.response.headers.contentType = ContentType.json;
  Map<String, dynamic> res = {
    'response_code': req.response.statusCode,
    'data': null,
  };

  if (queryParams.isEmpty) {
    req.response
      ..write(jsonEncode(res))
      ..close();
  } else if (queryParams['consignmentNo'] != null) {
    try {
      String? consignmentNo = queryParams['consignmentNo'];
      if (consignmentNo == null) return;
      res['data'] = {
        "consignmentNo": consignmentNo,
        "totalCon": 100,
        "missingCon": 10
      };
      req.response
        ..write(jsonEncode(res))
        ..close();
    } catch (ex) {
      req.response
        ..write('Something went wrong!')
        ..close();
    }
  } else {
    req.response.statusCode = HttpStatus.badRequest;
    res['response_code'] = HttpStatus.badRequest;
    req.response
      ..write(jsonEncode(res))
      ..close();
  }
}
//#endregion

//#region GET request
// Handle request method GET
void handleGet(HttpRequest req) {
  final path = req.uri.path;
  switch (path) {
    case '/fruit':
      handleGetFruit(req);
      break;
    case '/abx':
      handleGetAbx(req);
      break;
    default:
      handleGetDefault(req);
  }
}

/// Handle GET request /abx
void handleGetAbx(HttpRequest req) {
  final queryParams = req.uri.queryParameters;
  req.response.headers.contentType = ContentType.json;
  Map<String, dynamic> jsonRes = {
    'response_code': req.response.statusCode,
    'data': null,
  };

  if (queryParams.isEmpty) {
    req.response
      ..write(jsonEncode(jsonRes))
      ..close();
  } else {
    if (queryParams['consignment'] == 'null') {
      req.response.statusCode = HttpStatus.badRequest;
      jsonRes['response_code'] = HttpStatus.badRequest;
      req.response
        ..write(jsonEncode(jsonRes))
        ..close();
    } else {
      jsonRes['data'] = {
        "motherCon": "SF 54444",
        "totalCon": 2,
        "missingCon": 1
      };
      req.response
        ..write(jsonEncode(jsonRes))
        ..close();
    }
  }
}

/// handle unavailable path request
void handleGetDefault(HttpRequest req) {
  req.response
    ..statusCode = HttpStatus.badRequest
    ..close();
}

/// Handle GET request /fruits
List<String> fruits = ['Apple', 'Orange', 'Banana', 'Grape'];
void handleGetFruit(HttpRequest req) {
  final queryParams = req.uri.queryParameters;
  Map<String, dynamic> jsonRes = {
    'response_code': req.response.statusCode,
    'fruits': fruits
  };

  // Return all fruit if there are no query paramaters
  if (queryParams.isEmpty) {
    req.response
      ..write(jsonEncode(jsonRes))
      ..close();
    return;
  }

  // Find any fruit that starts with the 'prefix'
  final prefix = queryParams['prefix'];
  final matchesFruitAtPrefix =
      fruits.where((fruit) => fruit.startsWith(prefix ?? '')).toList();

  // Respond based on the matches found
  try {
    if (matchesFruitAtPrefix.isEmpty) {
      jsonRes['fruits'] = [];
      req.response
        ..write(jsonEncode(jsonRes))
        ..close();
    } else {
      jsonRes['fruits'] = matchesFruitAtPrefix;
      req.response
        ..write(jsonEncode(jsonRes))
        ..close();
    }
  } catch (ex) {
    jsonRes['fruits'] = [];
    jsonRes['response_code'] = HttpStatus.badRequest;
    req.response
      ..write(jsonEncode(jsonRes))
      ..close();
  }
}
//#endregion

/// Create Dart server with bind IPv4 and port
Future<HttpServer> createServer() async {
  final address = InternetAddress.loopbackIPv4;
  const port = 5000;
  return await HttpServer.bind(address, port);
}
