import 'package:xml/xml.dart';

class LoginResponse {
  final String nsp;
  final String url;
  final String subkey;

  LoginResponse({required this.nsp, required this.url, required this.subkey});
factory LoginResponse.fromXml(String xml) {
  final document = XmlDocument.parse(xml);

  final nspElement = document.findAllElements('nsp').isNotEmpty ? document.findAllElements('nsp').first : null;
  final urlElement = document.findAllElements('url').isNotEmpty ? document.findAllElements('url').first : null;
  final subkeyElement = document.findAllElements('subkey').isNotEmpty ? document.findAllElements('subkey').first : null;

  if (nspElement != null && urlElement != null && subkeyElement != null) {
    final nsp = nspElement.text;
    final url = urlElement.text;
    final subkey = subkeyElement.text;

    return LoginResponse(nsp: nsp, url: url, subkey: subkey);
  } else {
    throw Exception('Required XML elements are missing');
  }
}


}
