import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as image;
import 'package:http/http.dart' as http;

class CroppedAvatar extends StatelessWidget {
  const CroppedAvatar({super.key, required this.photoUrl});

  final String photoUrl;

  static final _photos = <String, Uint8List>{};

  Future<Uint8List> _cropImage(String photoUrl) async {
    if (_photos[photoUrl] != null) return _photos[photoUrl]!;

    final data = await http.get(Uri.parse(photoUrl));

    var img = image.decodeImage(data.bodyBytes);

    img = img!.convert(format: img.format, numChannels: 4);

    final croppedImage = image.copyCropCircle(img,
        centerY: (img.height * 0.4).toInt(),
        radius: (img.height * 0.35).toInt());

    final result = image.encodePng(croppedImage);
    _photos[photoUrl] = result;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: compute(_cropImage, photoUrl),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
            );
          }
          if (snapshot.hasError) {
            return const CircleAvatar(
              radius: 64.0,
              backgroundImage: AssetImage('assets/profile.png'),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
