class ChaoxingLoginResult {
  const ChaoxingLoginResult({
    required this.html,
    required this.finalUrl,
    required this.statusCode,
    required this.cookies,
    required this.redirectChain,
  });

  final String html;
  final String finalUrl;
  final int statusCode;
  final Map<String, String> cookies;
  final List<String> redirectChain;
}

class RsaKey {
  const RsaKey({
    required this.modulusHex,
    required this.exponentHex,
  });

  final String modulusHex;
  final String exponentHex;

  BigInt get modulus => BigInt.parse(modulusHex, radix: 16);
  BigInt get exponent => BigInt.parse(exponentHex, radix: 16);

  int get chunkSize {
    final bitLength = modulus.bitLength;
    final digitLength = (bitLength + 15) ~/ 16;
    final highIndex = digitLength > 0 ? digitLength - 1 : 0;
    return 2 * highIndex;
  }
}
