import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:viideo_compress_smaple/api/video_compress_api.dart';
import 'package:viideo_compress_smaple/widget/button_widget.dart';
import 'package:viideo_compress_smaple/widget/progress_dialog_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Compress',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? fileVideo;
  Uint8List? thumbnailBytes;
  int? videoSize;
  MediaInfo? compressedVideoInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Compress"),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  compressedVideoInfo = null;
                  fileVideo = null;
                });
              },
              child: Text("Clear"),
              style: TextButton.styleFrom(primary: Colors.white)),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(40),
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    if (fileVideo == null) {
      return ButtonWidget(text: "Pick Video", onClicked: pickVideo);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildThumbnail(),
          SizedBox(
            height: 24,
          ),
          buildVideoInfo(),
          SizedBox(
            height: 24,
          ),
          buildVideoCompressedInfo(),
          SizedBox(
            height: 24,
          ),
          ButtonWidget(text: "Compress Video", onClicked: compressVideo)
        ],
      );
    }
  }

  Widget buildThumbnail() => thumbnailBytes == null
      ? CircularProgressIndicator()
      : Image.memory(
          thumbnailBytes!,
          height: 100,
        );

  Widget buildVideoInfo() {
    if (videoSize == null) return Container();
    final size = videoSize! / 1000;

    return Column(
      children: [
        Text(
          "Original Video Info",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          "Size: $size KB",
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget buildVideoCompressedInfo() {
    if (compressedVideoInfo == null) return Container();
    final size = compressedVideoInfo!.filesize! / 1000;

    return Column(
      children: [
        Text(
          "Compressed Video Info",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          "Size: $size KB",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          "${compressedVideoInfo!.path}",
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Future pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    if (pickedFile == null) return;
    final file = File(pickedFile.path);

    setState(() {
      fileVideo = file;
    });

    generateThumbnail(fileVideo!);
    getVideoSize(fileVideo!);
  }

  Future generateThumbnail(File file) async {
    final thumbnailBytes = await VideoCompress.getByteThumbnail(file.path);

    setState(() {
      this.thumbnailBytes = thumbnailBytes;
    });
  }

  Future getVideoSize(File file) async {
    final size = await file.length();

    setState(() {
      videoSize = size;
    });
  }

  Future compressVideo() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
              child: ProgressDialogWidget(),
            ));
    final info = await VideoCompressApi.compressVideo(fileVideo!);

    setState(() {
      compressedVideoInfo = info;
    });

    Navigator.of(context).pop();
  }
}
