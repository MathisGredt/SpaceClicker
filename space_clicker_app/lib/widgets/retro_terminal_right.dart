import 'package:flutter/material.dart';

class RetroTerminalRight extends StatefulWidget {
  final List<String> history;
  final Function(String) onCommand;

  const RetroTerminalRight({required this.history, required this.onCommand, Key? key}) : super(key: key);

  @override
  _RetroTerminalRightState createState() => _RetroTerminalRightState();
}

class _RetroTerminalRightState extends State<RetroTerminalRight> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _submitCommand() {
    final cmd = _controller.text.trim();
    if (cmd.isNotEmpty) {
      widget.onCommand(cmd);
      _controller.clear();
    }
  }

  @override
  void didUpdateWidget(covariant RetroTerminalRight oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "=== TERMINAL COMMANDES ===",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 18),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.history.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  widget.history[index],
                  style: TextStyle(
                    color: widget.history[index].startsWith('>') ? Colors.green[300] : Colors.greenAccent,
                    fontFamily: 'Courier',
                    fontSize: 14,
                    fontWeight: widget.history[index].startsWith('>') ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
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