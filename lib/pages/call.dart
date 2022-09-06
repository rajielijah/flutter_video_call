import 'package:agora_rtc_engine/rtc_engine.dart';
import "package:flutter/material.dart";
import "package:agora_rtc_engine/rtc_local_view.dart"  as rtc_local_view;
import "package:agora_rtc_engine/rtc_remote_view.dart"  as rtc_remote_view;
import 'package:untitled/utils/string.dart';

class CallPageScreen extends StatefulWidget {
  final String? channelName;
  final ClientRole? role;
  const CallPageScreen({Key? key, this.channelName, this.role}) : super(key: key);

  @override
  State<CallPageScreen> createState() => _CallPageScreenState();
}

class _CallPageScreenState extends State<CallPageScreen> {
  final _users = <int>[];
  final _infoString = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }
  Future<void> initialize() async {
    if(appId.isEmpty) {
      setState((){
        _infoString.add("App id is missing, please provide");
        _infoString.add("Agora Engine is not starting");
      });
      return;
    }
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
    _addAgoraEventHandler();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(token, widget.channelName!, null, 0);

  }

  void _addAgoraEventHandler() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code){
      setState((){
        final info = "Error: $code";
        _infoString.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed){
      setState((){
        final info = "Join Channel: $channel, uid $uid";
        _infoString.add(info);
      });
    }, leaveChannel: (stats){
      setState((){
        _infoString.add("Leave Channel");
        _users.clear();
      });
    }, userJoined: (uid, elapsed){
      setState((){
        final info = "User Joined: $uid";
        _infoString.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed){
      setState((){
        final info = "User Offline: $uid";
        _infoString.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed){
      setState((){
        final info = "First Remote Video: $uid ${width} x $height";
        _infoString.add(info);
      });
    }));
  }
  Widget _viewRows() {
    final List<StatefulWidget> list = [];
    if(widget.role == ClientRole.Broadcaster) {
      list.add(const rtc_local_view.SurfaceView());
    }
    for(var uid in _users){
      list.add(rtc_remote_view.SurfaceView(
        uid: uid, channelId: widget.channelName!,
      ));
    }
    final views = list;
    return Column(
      children: List.generate(views.length, (index) => Expanded(child: views[index])),
    );
  }

  Widget _toolBar() {
    if(widget.role == ClientRole.Audience) return const SizedBox();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(onPressed: (){
            setState((){
              muted = !muted;
            });
            _engine.muteLocalAudioStream(muted);
          }, child: Icon(muted ? Icons.mic_off : Icons.mic,
          color: muted ? Colors.white : Colors.blueAccent, size: 20,), shape: CircleBorder(),
          elevation: 2.0, fillColor: muted ? Colors.blueAccent : Colors.white,
          padding: EdgeInsets.all(12),),
          RawMaterialButton(onPressed: () => Navigator.pop(context),
          child: Icon(Icons.call_end, color: Colors.white, size: 35,),
            shape: CircleBorder(), elevation: 2.0, fillColor: Colors.redAccent,
            padding: EdgeInsets.all(15),
          ),
          RawMaterialButton(onPressed: (){
            _engine.switchCamera();
          }, child: Icon(Icons.switch_camera, color: Colors.blueAccent, size: 20),
            shape: CircleBorder(), elevation: 2.0, fillColor: Colors.white,
            padding: EdgeInsets.all(15),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agora"), centerTitle: true,
      actions: [
        IconButton(onPressed: (){
          setState((){
            viewPanel = !viewPanel;
          });
        }, icon: Icon(Icons.info_outline))
      ],
      ),
      backgroundColor: Colors.black,
      body:Center(child: Stack(
        children: [
          _viewRows(),
          _toolBar()
        ],
      ),),
    );
  }
}
