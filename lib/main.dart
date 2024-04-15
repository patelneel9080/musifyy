import 'package:flutter/material.dart';
import 'package:musifyy/playlist_page.dart';


void main() async {
  //initialise the hive

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musify',
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const Playlistpage(),
    );
  }
}
