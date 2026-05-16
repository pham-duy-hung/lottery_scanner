import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const url =
      'https://www.minhngoc.net.vn/ket-qua-xo-so/mien-bac/15-05-2026.html';
  final r = await http.get(
    Uri.parse(url),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    },
  );
  print('status=${r.statusCode} len=${r.body.length}');
  final file = File('tool/mb_sample.html');
  await file.writeAsString(r.body);
  final idx = r.body.indexOf('67294');
  print('67294 at $idx');
  final idx2 = r.body.indexOf('Giải');
  print('Giải at $idx2 snippet=${r.body.substring(idx2, idx2 + 200)}');
}
