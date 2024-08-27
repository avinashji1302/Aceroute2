// audio_view.dart

import 'package:ace_routes/controller/audio_controller.dart';
import 'package:flutter/material.dart';
// import 'audio_controller.dart';


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
    await _controller.init();
    setState(() {});
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
        title: Text(
          'Audio',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Show waveform only when recording
            // if (_controller.isRecording)
            //   Container(
            //       height: 100, // Adjust height as needed
            //       color: Colors.grey[300], // Background color of the waveform
            //      ),

            SizedBox(
              height: 20,
            ),
            Icon(
              Icons.mic,
              size: 100,
              color: _controller.isRecording ? Colors.green : Colors.black,
            ),
            SizedBox(
              height: 10,
            ),
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
            SizedBox(
              height: 20,
            ),
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
                    child: ListTile(
                      title: Text('Recording ${index + 1}'),
                      subtitle: Text(recordingPath),

                      // leading: IconButton(
                      //   icon: Icon(
                      //     isPlaying ? Icons.pause : Icons.play_arrow,
                      //     color: Colors.blue,
                      //   ),
                      //   onPressed: () async {
                      //     await _controller.togglePlayback(recordingPath);
                      //     setState(() {});
                      //   },
                      // ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: const Color.fromARGB(255, 175, 13, 2),
                          size: 50,
                        ),
                        onPressed: () async {
                          await _controller.deleteRecording(recordingPath);
                          setState(() {});
                        },
                      ),

                      onTap: () async {
                        await _controller.playRecording(recordingPath);
                      },
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
