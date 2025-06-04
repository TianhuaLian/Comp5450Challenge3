import 'package:audioplayers/audioplayers.dart';

class AudioManager{
  final List<AudioPlayer> _idleAudioPlayer = [];
  final List<AudioPlayer> _activeAudioPlayer = [];

  AudioManager({int startingAudioPlayperCount = 5}) {
    for (int count = 0; count < startingAudioPlayperCount ;count++) {
      _idleAudioPlayer.add(AudioPlayer());
    }
  }

  void playSound(String asset) {
    AssetSource source = AssetSource(asset);
    AudioPlayer player = _idleAudioPlayer.isEmpty ? AudioPlayer() : _idleAudioPlayer.removeLast();
    _activeAudioPlayer.add(player);
    player.play(source).then((void _) {
      _activeAudioPlayer.remove(player);
      _idleAudioPlayer.add(AudioPlayer());
    });
  }


  void dispose(){
    for (AudioPlayer activePlayer in _activeAudioPlayer) {
      activePlayer.stop().then((void _) => activePlayer.dispose());
    }
    _activeAudioPlayer.clear();
    for (AudioPlayer idlePlayer in _idleAudioPlayer) {
      idlePlayer.dispose();
    }
    _idleAudioPlayer.clear();
  }
}