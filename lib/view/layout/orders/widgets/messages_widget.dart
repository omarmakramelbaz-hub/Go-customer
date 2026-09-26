import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../auth/controller/auth_controller.dart';
import '../../chat/model/chat_model.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isMe = int.tryParse(message.userId.toString()) == context.read<AuthController>().profile?.id;
    return LayoutBuilder(builder: (context, constraints) => Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth * .82),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF327E9E) : GoDesign.canvas,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 4), bottomRight: Radius.circular(isMe ? 4 : 14))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
          Text(message.message ?? '',
            style: TextStyle(color: isMe ? Colors.white : GoDesign.ink, fontSize: 15, height: 1.5)),
          const SizedBox(height: 5),
          Text(DateMethods.formatToTime(message.messageTime?.toIso8601String()),
            style: TextStyle(color: isMe ? Colors.white70 : GoDesign.muted, fontSize: 10)),
        ]),
      ),
    ));
  }
}

// Keep the existing public painters for other chat consumers.
class TrianglePainter extends CustomPainter {
  TrianglePainter({this.color});
  final Color? color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color ?? Colors.white..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, size.height)..lineTo(size.width, size.height)..lineTo(size.width, 0)..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => oldDelegate.color != color;
}

class MeTrianglePainter extends CustomPainter {
  MeTrianglePainter({this.color});
  final Color? color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color ?? Colors.white..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, 0)..lineTo(0, size.height)..lineTo(size.width, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(MeTrianglePainter oldDelegate) => oldDelegate.color != color;
}
