import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:comp5450challenge3/audio/audio_library.dart';

class AudioManager{
  final Random _rng = Random();
  final Map<String, List<AudioPlayer>> _idleAudioPlayers = {};
  final Map<String, List<AudioPlayer>> _activeAudioPlayers = {};

  AudioManager() {
    _assetWarmUp();
    for(AssetSource source in pinKnockSounds.toList()) {
      if(!_idleAudioPlayers.containsKey(source.path)) {
        _idleAudioPlayers[source.path] = [];
      }
      for(int i = 0; i <= 3; i ++){
        _idleAudioPlayers[source.path]!.add(_createAudioPlayer(source));
      }
    }
  }

  _assetWarmUp() async {
    print('_assetWarmUp');
    for(AssetSource source in pinKnockSounds) {
      AudioPlayer player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setVolume(0.0);
      await player.play(source);
      await player.dispose();
    }
  }

  AudioPlayer _createAudioPlayer(AssetSource source, {PlayerMode playerMode = PlayerMode.mediaPlayer, ReleaseMode releaseMode = ReleaseMode.stop}) {
    print('_createAudioPlayer ${source.path}');
    AudioPlayer player = AudioPlayer();
    player.setPlayerMode(playerMode);
    player.setReleaseMode(releaseMode);
    player.setSource(source);
    return player;
  }

  AudioPlayer _getAudioPlayer(AssetSource source, {PlayerMode playerMode = PlayerMode.mediaPlayer, ReleaseMode releaseMode = ReleaseMode.stop}) {
    if (!_idleAudioPlayers.containsKey(source.path)) {
      _idleAudioPlayers[source.path] = [];
      print('_getAudioPlayer ${source.path}, list created');
    }
    if (_idleAudioPlayers[source.path]!.isEmpty) {
      _idleAudioPlayers[source.path]!.add(_createAudioPlayer(source, playerMode: playerMode, releaseMode: releaseMode));
      print('_getAudioPlayer ${source.path}, new player created created');
    }

    return _idleAudioPlayers[source.path]!.removeLast();
  }

  void playSound(AssetSource source, {PlayerMode playerMode = PlayerMode.mediaPlayer, ReleaseMode releaseMode = ReleaseMode.stop}) {
    print('play sound ${source.path}, start');
    AudioPlayer player = _getAudioPlayer(source, playerMode: playerMode, releaseMode: releaseMode);
    if (!_activeAudioPlayers.containsKey(source.path)){
      _activeAudioPlayers[source.path] = []; 
      print('play sound ${source.path}, no active list');
    }
    _activeAudioPlayers[source.path]!.add(player);
    player.play(source).then((event) {
      print('PLAY COMPLETE');
      _activeAudioPlayers[source.path]!.remove(player);
      _idleAudioPlayers[source.path]!.add(player);
    });
  }

  void playPinSound(){
    AssetSource source = pinKnockSounds[_rng.nextInt(5)];
    AudioPlayer player = _getAudioPlayer(source);
    if (!_activeAudioPlayers.containsKey(source.path)){
      _activeAudioPlayers[source.path] = []; 
      print('play sound ${source.path}, no active list');
    }
    _activeAudioPlayers[source.path]!.add(player);
    player.play(source).then((event) {
      print('PLAY COMPLETE');
      _activeAudioPlayers[source.path]!.remove(player);
      _idleAudioPlayers[source.path]!.add(player);
    });
  }

  void dispose(){
    print('dispose');
    _disposePool(_activeAudioPlayers);
    _disposePool(_idleAudioPlayers);
  }

  void _disposePool(Map<String, List<AudioPlayer>> pool) {
    for (List<AudioPlayer> playerList in pool.values) {
      for(AudioPlayer player in playerList) {
        player.stop().then((void _) => player.dispose());
      }
    }
  }
}