import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:tagmusicplayer/classes/playlist.dart';

class PlayerWidget extends StatefulWidget {
  final MyAudioHandler playlist;

  const PlayerWidget({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  AudioPlayer get player => widget.playlist.player;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Slider(
          onChanged: (v) {
            final duration = _duration;
            if (duration == null) {
              return;
            }
            final position = v * duration.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
                  _duration != null &&
                  _position!.inMilliseconds > 0 &&
                  _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
        ),
        Text(
          _position != null
              ? '$_positionText / $_durationText'
              : _duration != null
                  ? _durationText
                  : 'No Song Loaded',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.durationStream.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.positionStream.listen(
      (p) => setState(() => _position = p),
    );
  }
}

class VolumeWidget extends StatefulWidget {
  final AudioPlayer player;

  const VolumeWidget({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VolumeWidget();
  }
}

class _VolumeWidget extends State<VolumeWidget> {
  AudioPlayer get player => widget.player;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Slider(
          min: 0.0,
          divisions: 10,
          max: 1.0,
          onChanged: (v) {
            setState(() {});
            player.setVolume(v);
          },
          value: player.volume,
        ),
      ],
    );
  }
}

/*
 Currently not implemented in the plugin
 -> Check Again later TODO

class BalanceWidget extends StatefulWidget {
  final AudioPlayer player;

  const BalanceWidget({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BalanceWidget();
  }
}

class _BalanceWidget extends State<BalanceWidget> {
  AudioPlayer get player => widget.player;
  double balance = 0.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Slider(
          min: -1.0,
          max: 1.0,
          onChanged: (v) {
            balance = v;
            setState(() {});
            player.setBalance(v);
          },
          value: balance,
        ),
        TextButton(
          onPressed: () {
            balance = 0.0;
            setState(() {});
            player.setBalance(0.0);
          },
          child: Text(
            balance.toString(),
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
*/
