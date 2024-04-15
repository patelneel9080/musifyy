import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer.newPlayer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
  Future<void> _addSongsFromDevice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? existingSongsStrings = prefs.getStringList('songs');
      List<Map<String, dynamic>> existingSongs = existingSongsStrings != null
          ? existingSongsStrings.map((e) => jsonDecode(e) as Map<String, dynamic>).toList()
          : [];
      List<PlatformFile> files = result.files;
      List<Map<String, dynamic>> newSongs = files.map((file) {
        String path = file.path!;
        String fileName = file.name!;
        String cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
        return {'name': cleanFileName, 'path': path};
      }).toList();
      existingSongs.addAll(newSongs);
      List<String> updatedSongsStrings =
      existingSongs.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('songs', updatedSongsStrings);
    }
  }
  Future<List<String>> _getSavedSongs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('songs') ?? [];
  }

  Future<List<Widget>> _buildSavedSongWidgets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List songs =
        (prefs.getStringList('songs') ?? []).map((e) => jsonDecode(e)).toList();

    return songs
        .map((song) => ListTile(
              title: Text(song['name']),
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/song_image.jpg'),
              ),
              onTap: () {
                String path = song['path'];
                audioPlayer.open(Audio.file(path), loopMode: LoopMode.single);
              },
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Music App'),
      ),
      body: FutureBuilder<List<Widget>>(
        future: _buildSavedSongWidgets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return ListView(
            children: snapshot.data ?? [],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSongsFromDevice,
        child: Icon(Icons.add),
      ),
    );
  }
}
