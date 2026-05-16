import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const url =
      'https://www.minhngoc.net.vn/ket-qua-xo-so/mien-nam/15-05-2026.html';
  final r = await http.get(Uri.parse(url), headers: {
    'User-Agent': 'Mozilla/5.0',
  });
  await File('tool/mn_sample.html').writeAsString(r.body);
  print('len=${r.body.length} vinhl=${r.body.indexOf('Vĩnh Long')}');
}
