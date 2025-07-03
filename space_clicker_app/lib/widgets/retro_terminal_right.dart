import 'package:flutter/material.dart';

class RetroTerminalRight extends StatefulWidget {
  final List<String> history;
  final Function(String) onCommand;

  const RetroTerminalRight({required this.history, required this.onCommand});

  @override
  _RetroTerminalRightState createState() => _RetroTerminalRightState();
}

class _RetroTerminalRightState extends State<RetroTerminalRight> {
  final TextEditingController _controller = TextEditingController();

  void _submitCommand() {
    final cmd = _controller.text.trim();
    if (cmd.isNotEmpty) {
      widget.onCommand(cmd);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "=== TERMINAL COMMANDES ===",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          SizedBox(height: 10),
          Text(
            "Commandes disponibles : /upgrade, /buy",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          SizedBox(height: 10),
          Flexible(
            fit: FlexFit.loose,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView(
                shrinkWrap: true,
                children: widget.history
                    .map(
                      (msg) => Text(
                    msg,
                    style: TextStyle(
                        color: Colors.greenAccent, fontFamily: 'Courier'),
                  ),
                )
                    .toList(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(
                      color: Colors.greenAccent, fontFamily: 'Courier'),
                  cursorColor: Colors.greenAccent,
                  decoration: InputDecoration(
                    hintText: 'Entrer une commande...',
                    hintStyle: TextStyle(color: Colors.green.shade200),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _submitCommand(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.greenAccent),
                onPressed: _submitCommand,
              )
            ],
          ),
        ],
      ),
    );
  }
}