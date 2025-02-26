import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoDemo(),
    );
  }
}

class VideoDemo extends StatefulWidget {
  const VideoDemo({super.key});

  @override
  VideoDemoState createState() => VideoDemoState();
}

class VideoDemoState extends State<VideoDemo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      // Load video from assets
      _controller = VideoPlayerController.asset('assets/video/mov_bbb.mp4');

      // Initialize the video player
      _initializeVideoPlayerFuture = _controller.initialize().then((_) {
        print("Video initialized successfully");
        setState(() {}); // Refresh UI after initialization
      }).catchError((error) {
        print("Error initializing video: $error");
        setState(() {
          _hasError = true;
        });
      });

      _controller.setLooping(true);
      _controller.setVolume(1.0);
    } catch (e) {
      print("Exception in video initialization: $e");
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player Demo"),
      ),
      body: _hasError
          ? const Center(child: Text("Error loading video"))
          : FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller.value.hasError) {
              print("Video player error: ${_controller.value.errorDescription}");
              return const Center(child: Text("Error loading video"));
            }
            return Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isInitialized) {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isInitialized && _controller.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }
}