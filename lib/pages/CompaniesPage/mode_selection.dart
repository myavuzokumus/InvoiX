import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/utils/network_check.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:invoix/widgets/warn_icon.dart';

enum ReadMode { legacy, ai }

class ModeSelection extends StatefulWidget {
  const ModeSelection({super.key, required this.onModeChanged});

  final Function(ReadMode) onModeChanged;

  @override
  State<ModeSelection> createState() => _ModeSelectionState();
}

class _ModeSelectionState extends State<ModeSelection> {

  late ReadMode _character;

  Future<void> initializeModeData() async {
    final box = await Hive.openBox('modeBox');
    box.get('isAI') ?? false ? _character = ReadMode.ai : _character = ReadMode.legacy;
    widget.onModeChanged(_character);
  }

  Future<void> changeModelData(final ReadMode? value) async {
    final box = await Hive.openBox('modeBox');
    if (await isInternetConnected()) {
      setState(() {
        _character = value!;
      });
      await box.put('isAI', _character == ReadMode.ai);
    } else {
      Toast(context,
          text: "You need to connect to the internet to use AI mode.",
          color: Colors.redAccent);
    }
    widget.onModeChanged(_character);
  }

  @override
  void initState() {
    initializeModeData();
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return Flexible(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xff723523),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10.0,
              spreadRadius: 0.5,
              offset: Offset(0, 0),
            ),
          ],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 192,
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                visualDensity: const VisualDensity(vertical: -4),
                shape: const Border.symmetric(
                  vertical: BorderSide.none,
                ),
                horizontalTitleGap: 0,
                title: const Text("Legacy Mode"),
                titleTextStyle: const TextStyle(fontSize: 18),
                leading: Radio<ReadMode>(
                  value: ReadMode.legacy,
                  groupValue: _character,
                  onChanged: (final ReadMode? value) {
                    setState(() {
                      _character = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: 192,
              child: ListTile(
                trailing: const WarnIcon(
                    message: "Internet connection needed."),
                contentPadding: const EdgeInsets.only(right: 10),
                visualDensity: const VisualDensity(vertical: -4),
                shape: const Border.symmetric(
                  vertical: BorderSide.none,
                ),
                horizontalTitleGap: 0,
                title: const Text("AI Mode ✨"),
                titleTextStyle: const TextStyle(fontSize: 18),
                leading: Radio<ReadMode>(
                  value: ReadMode.ai,
                  groupValue: _character,
                  onChanged: (final value) => changeModelData(value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
