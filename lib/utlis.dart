import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';


const kPrimaryColor = Color(0xFFebbe8b);

// playlist songs
List<Audio> songs = [
  Audio('assets/songs/Deva Shree Ganesha.mp3',
      metas: Metas(
          title: 'Deva Shree Ganesha',
          artist: ' Ajay Gogavale and Ajay-Atul',
          image: const MetasImage.asset(
              'assets/images/deva shree ganesh.jpg'))),
  Audio('assets/songs/Gann Deva.mp3',
      metas: Metas(
          title: 'Gann Deva',
          artist: ' Divya Kumar and Sachin–Jigar',
          image: const MetasImage.asset('assets/images/ganna deva.jpeg'))),
  Audio('assets/songs/Ghamand Kar.mp3',
      metas: Metas(
          title: 'Ghamand Kar',
          artist: 'Parampara Thakur, Sachet Tandon, and Sachet–Parampara',
          image: const MetasImage.asset('assets/images/Ghamand Kar.jpg'))),
  Audio('assets/songs/Hey Ganarya.mp3',
      metas: Metas(
          title: 'Hey Ganarya',
          artist: 'Divya Kumar',
          image: const MetasImage.asset('assets/images/Hey-Ganaraya.jpg'))),
  Audio('assets/songs/Powerful HANUMAN CHALISA.mp3',
      metas: Metas(
          title: 'Powerful HANUMAN CHALISA',
          artist: 'Satish Dehra',
          image: const MetasImage.asset('assets/images/Powerful hanuman chalisa.jpeg'))),
  Audio('assets/songs/Raj Karega Khalsa.mp3',
      metas: Metas(
          title: 'Raj Karega Khalsa',
          artist: 'Daler Mehndi and Navraj Hans',
          image: const MetasImage.asset('assets/images/raj karega khalsa.jpg'))),
  Audio('assets/songs/Shoorveer 3.mp3',
      metas: Metas(
          title: 'Shoorveer 3',
          artist: 'Rapperiya Baalam',
          image: const MetasImage.asset('assets/images/Shoorver 3.jpg'))),
 ];

String durationFormat(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitMinutes:$twoDigitSeconds';
  // for example => 03:09
}

// get song cover image colors
Future<PaletteGenerator> getImageColors(AssetsAudioPlayer player) async {
  var paletteGenerator = await PaletteGenerator.fromImageProvider(
    AssetImage(player.getCurrentAudioImage?.path ?? ''),
  );
  return paletteGenerator;
}
