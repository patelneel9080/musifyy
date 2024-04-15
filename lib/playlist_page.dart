import 'dart:io';
import 'dart:math' as math;

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:musifyy/player_page.dart';
import 'package:musifyy/utlis.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:file_picker/file_picker.dart';

class Playlistpage extends StatefulWidget {
  const Playlistpage({Key? key}) : super(key: key);

  @override
  State<Playlistpage> createState() => _PlaylistpageState();
}

class _PlaylistpageState extends State<Playlistpage>
    with SingleTickerProviderStateMixin {
  final player = AssetsAudioPlayer();
  bool isPlaying = true;
  TextEditingController searchController = TextEditingController();
  List<Audio> filteredSongs = songs; // Initially, show all songs.
  List<Audio> likedSongs = [];
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void initState() {
    openPlayer();

    player.isPlaying.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = event;
        });
      }
    });
    super.initState();
  }

  void openPlayer() async {
    try {
      await player.open(
        Playlist(audios: songs),
        autoStart: false,
        showNotification: true,
        loopMode: LoopMode.playlist,
      );
    } catch (e) {
      print('Error opening player: $e');
    }
  }

  void searchSongs(String query) {
    setState(() {
      filteredSongs = songs
          .where((song) =>
              song.metas.title!.toLowerCase().contains(query.toLowerCase()) ||
              song.metas.artist!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> addSongsFromDevice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      List<Audio> newAudios = files
          .map((file) => Audio.file(file.path, metas: Metas(title: file.path)))
          .toList();

      setState(() {
        songs.addAll(newAudios);
        filteredSongs.addAll(newAudios);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(.2),
      appBar: AppBar(
        title: const Text(
          'Musify',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height / 64),
            Row(
              children: [
                // IconButton(
                //   onPressed: addSongsFromDevice,
                //   icon: Icon(Icons.add),
                // ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) => searchSongs(query),
                    decoration: const InputDecoration(
                      hintText: "Search songs...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height / 44),
            const Text(
              "     RECOMMENDATION:-",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: size.height / 64),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSongs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListTile(
                      title: Text(
                        filteredSongs[index].metas.title!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        filteredSongs[index].metas.artist!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                            image: AssetImage(
                                filteredSongs[index].metas.image!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: () async {
                        await player.playlistPlayAtIndex(index);
                        setState(() {
                          player.getCurrentAudioImage;
                          player.getCurrentAudioTitle;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: player.current.valueOrNull != null
          ? FutureBuilder<PaletteGenerator>(
              future: getImageColors(player),
              builder: (context, snapshot) {
                final currentImage = player.getCurrentAudioImage?.path;
                return Container(
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: const Alignment(0, 5),
                      colors: [
                        snapshot.data?.lightMutedColor?.color ?? Colors.grey,
                        snapshot.data?.mutedColor?.color ?? Colors.grey,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: AnimatedBuilder(
                      animation: _animationController,
                      builder: (_, child) {
                        if (!isPlaying) {
                          _animationController.stop();
                        } else {
                          _animationController.forward();
                          _animationController.repeat();
                        }
                        return Transform.rotate(
                          angle: _animationController.value * 2 * math.pi,
                          child: child,
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: currentImage != null
                            ? AssetImage(currentImage)
                            : const AssetImage('assets/images/placeholder.png'),
                        // Placeholder image asset
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => PlayerPage(
                          player: player,
                        ),
                      ),
                    ),
                    title: buildMarquee(
                      text: player.getCurrentAudioTitle ?? '',
                    ),
                    subtitle: buildMarquee(
                      text: player.getCurrentAudioArtist ?? '',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await player.previous();
                          },
                          icon: Icon(Icons.skip_previous),
                        ),
                        IconButton(
                          onPressed: () async {
                            await player.playOrPause();
                          },
                          icon: isPlaying
                              ? Icon(Icons.pause)
                              : Icon(Icons.play_arrow),
                        ),
                        IconButton(
                          onPressed: () async {
                            await player.next();
                          },
                          icon: Icon(Icons.skip_next),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}

Widget buildMarquee({required String text}) {
  return Container(
    height: 24, // Adjust the height based on your design
    child: text.length > 20 // You can adjust the threshold as needed
        ? Marquee(
            text: text,
            // style: TextStyle(color: Colors.white),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 20.0,
            velocity: 50.0,
            startPadding: 10.0,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          )
        : Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
  );
}
