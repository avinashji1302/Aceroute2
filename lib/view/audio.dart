import 'package:ace_routes/controller/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:siri_wave/siri_wave.dart';

class AudioRecord extends StatefulWidget {
  const AudioRecord({super.key});

  @override
  State<AudioRecord> createState() => _AudioRecordState();
}

class _AudioRecordState extends State<AudioRecord> {
  final AudioController _controller = AudioController();

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    await _requestPermissions();
    await _controller.init();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();

    if (status.isDenied) {
      // Show a dialog or a snackbar asking the user to enable the permission
      _showPermissionDeniedDialog();
    } else if (status.isPermanentlyDenied) {
      // Open app settings if the permission is permanently denied
      openAppSettings();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Microphone Permission Denied'),
        content: Text(
            'This app needs microphone access to record audio. Please enable microphone permissions in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audio',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                child: _controller.isRecording
                    ? SiriWaveform.ios9(
                        options: IOS9SiriWaveformOptions(
                          height: 180,
                          width: 360,
                        ),
                      )
                    : Text('')),
            Icon(
              Icons.mic,
              size: 100,
              color: _controller.isRecording ? Colors.green : Colors.black,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _controller.isRecording
                  ? () async {
                      await _controller.stopRecording();
                      setState(() {});
                    }
                  : () async {
                      await _controller.startRecording();
                      setState(() {});
                    },
              child: Text(_controller.isRecording
                  ? 'Stop Recording'
                  : 'Start Recording'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _controller.recordings.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: 10), // Space between items

                itemBuilder: (context, index) {
                  final recordingPath = _controller.recordings[index];
                  final isPlaying = _controller.playingPath == recordingPath;
                  return Container(
                    color: const Color.fromARGB(255, 211, 211, 211),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, top: 8, bottom: 8),
                      child: ListTile(
                        title: GestureDetector(
                            onTap: () {},
                            child: Text('Recording ${index + 1}')),
                        leading: IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_arrow,
                            color: Colors.black,
                            size: 50,
                          ),
                          onPressed: () async {
                            await _controller.togglePlayback(
                              recordingPath,
                              () => setState(() {
                                print('setState');
                               
                              }),
                            );
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 40,
                          ),
                          onPressed: () async {
                            await _controller.deleteRecording(recordingPath);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
