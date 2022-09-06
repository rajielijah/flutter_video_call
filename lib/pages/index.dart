import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import "package:flutter/material.dart";
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/pages/call.dart';

class IndexPageScreen extends StatefulWidget {
  const IndexPageScreen({Key? key,}) : super(key: key);

  @override
  State<IndexPageScreen> createState() => _IndexPageScreenState();
}

class _IndexPageScreenState extends State<IndexPageScreen> {
  final _channelControler = TextEditingController();
  bool validator = false;
   ClientRole _clientRole = ClientRole.Broadcaster;

  void dispose() {
    _channelControler.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agora"), centerTitle: true,),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            const SizedBox(height:40),
            // Image.network("https://tinyurl.com/2p889y4k"),
            const SizedBox(height:40),
            TextField(
              controller: _channelControler,
              decoration: InputDecoration(
                errorText: validator ? "channel is mandatory" : null,
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(width: 1)
                ), hintText: "Channel name"
              ),
            ),
            RadioListTile(title : Text("Brodcaster"),
                value: ClientRole.Broadcaster, groupValue: _clientRole,
                onChanged: (ClientRole? value){
                  setState((){
                    _clientRole = value!;
                  });
                }),
            RadioListTile(title : Text("Audience"),
                value: ClientRole.Audience, groupValue: _clientRole,
                onChanged: (ClientRole? value){
                  setState((){
                    _clientRole = value!;
                  });
                }),
            ElevatedButton(onPressed: onJoin, child: Text("Join"))
          ],),
        ),
      ),
    );
  }
  Future<void> onJoin() async {
    setState((){
      _channelControler.text.isEmpty ?
          validator = true :
      validator = false;
    });
    if(_channelControler.text.isNotEmpty) {
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => CallPageScreen(
        channelName: _channelControler.text,
        role: _clientRole,
      )));
    }
  }
  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    // log(status.toString());

  }
}
