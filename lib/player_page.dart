import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musifyy/utlis.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:palette_generator/palette_generator.dart';

import 'app_const.dart';
class PlayerPage extends StatefulWidget {
  const PlayerPage({required this.player, Key? key}) : super(key: key);
  final AssetsAudioPlayer player;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final player = AssetsAudioPlayer();
  List<Audio> filteredSongs = List.from(songs);

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = true;
  bool isReplayMode = false;
  bool isShuffleMode = false;
  String? fileName; // Variable to store the file name

  Future<void> _addSongsFromDevice() async {
    // Implement logic to select songs from device storage
    // For example, using file picker or any other package
    // For demonstration, I'm assuming the user has selected a single audio file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      fileName = result.files.single.name; // Extract file name
      if (filePath != null && fileName != null) {
        await widget.player.open(Audio.file(filePath, metas: Metas(
          title: fileName, // Assign file name as title
        )));
      }
    }
  }
  @override
  void initState() {
    widget.player.isPlaying.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = event;
        });
      }
    });

    widget.player.onReadyToPlay.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration?.duration ?? Duration.zero;
        });
      }
    });

    widget.player.currentPosition.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _addSongsFromDevice,
            icon: Icon(CupertinoIcons.add, color: Colors.white),
          )
        ],
        centerTitle: true,
        title: Text(
          "NOW PLAYING",
          style: GoogleFonts.aBeeZee(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder<PaletteGenerator>(
            future: getImageColors(widget.player),
            builder: (context, snapshot) {
              return Container(
                color: snapshot.data?.mutedColor?.color,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            height: MediaQuery.of(context).size.height / 1.5,
            child: Column(
              children: [
                Text(
                  fileName ?? "", // Display the file name of the selected song
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: size.height / 86,
                ),
                Text(
                  widget.player.getCurrentAudioArtist,
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 34,
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Text(
                        durationFormat(position),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const VerticalDivider(
                        color: Colors.white54,
                        thickness: 2,
                        width: 25,
                        indent: 2,
                        endIndent: 2,
                      ),
                      Text(
                        durationFormat(duration - position),
                        style: const TextStyle(color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: SleekCircularSlider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              initialValue: position.inSeconds.toDouble(),
              onChange: (value) async {
                await widget.player.seek(Duration(seconds: value.toInt()));
              },
              innerWidget: (percentage) {
                final currentImage = widget.player.getCurrentAudioImage?.path;
                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: currentImage != null
                        ? AssetImage(currentImage)
                        : AssetImage('assets/images/placeholder.png'), // Placeholder image asset
                  ),
                );
              },
              appearance: CircularSliderAppearance(
                size: 330,
                angleRange: 300,
                startAngle: 300,
                customColors: CustomSliderColors(
                  progressBarColor: kPrimaryColor,
                  dotColor: kPrimaryColor,
                  trackColor: Colors.grey.withOpacity(.4),
                ),
                customWidths: CustomSliderWidths(
                  trackWidth: 6,
                  handlerSize: 10,
                  progressBarWidth: 6,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.3,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        isShuffleMode = !isShuffleMode;
                      });

                      await widget.player.shuffle;
                    },
                    icon:  Icon(
                      Icons.shuffle,
                      size: 35,
                      color: isShuffleMode ? Colors.blue : Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await widget.player.previous();
                    },
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await widget.player.playOrPause();
                    },
                    padding: EdgeInsets.zero,
                    icon: isPlaying
                        ? const Icon(
                      Icons.pause_circle,
                      size: 50,
                      color: Colors.white,
                    )
                        : const Icon(
                      Icons.play_circle,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await widget.player.next();
                    },
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        isReplayMode = !isReplayMode;
                      });

                      await widget.player.setLoopMode(
                        isReplayMode ? LoopMode.single : LoopMode.playlist,
                      );
                    },
                    icon: Icon(
                      Icons.replay_rounded,
                      size: 35,
                      color: isReplayMode ? Colors.blue : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
