import 'dart:convert';
import 'dart:typed_data';

import 'service_sprite_part0.dart';
import 'service_sprite_part1.dart';
import 'service_sprite_part2.dart';
import 'service_sprite_part3.dart';
import 'service_sprite_part4.dart';
import 'service_sprite_part5.dart';
import 'service_sprite_part6.dart';
import 'service_sprite_part7.dart';

final Uint8List goServiceSpriteBytes = base64Decode(
  goServiceSpritePart0 +
      goServiceSpritePart1 +
      goServiceSpritePart2 +
      goServiceSpritePart3 +
      goServiceSpritePart4 +
      goServiceSpritePart5 +
      goServiceSpritePart6 +
      goServiceSpritePart7,
);
