import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayer2/audioplayer2.dart';
import 'music.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Zoomify'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Music> musicList = [
    new Music("On m'appelle l'ovni", "Jul", "assets/jul-ovni.jpg", "https://soufiamine.fr/msc/01-jul-on_mappelle_lovni.mp3"),
    new Music("L'amour est un oiseau rebelle", "Georges Bizet", "assets/carmen-bizet.jpg", "https://soufiamine.fr/msc/carmen-lamour-est-un-oiseau-rebelle-elina-garanca.mp3"),
    new Music("Pablito", "Jul", "assets/jul-la-zone-en-personne.jpg", "https://soufiamine.fr/msc/08%20Pablito.mp3"),
    new Music("Pochon Bleu", "Naps", "assets/naps-pochon-bleu.jpg", "https://soufiamine.fr/msc/15%20-%20Naps%20-%20Pochon%20bleu.mp3"),
    new Music("J.C.V.D", "Jul", "assets/jul-rien-100-rien.jpg", "https://soufiamine.fr/msc/Jul%20-%20Jcvd.mp3")
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription stateSubscription;

  Music actualMusic;

  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 30);

  PlayerState statut = PlayerState.STOPPED;
  int index = 1;
  bool mute = false;
  int maxVol = 0, currentVol = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    actualMusic = musicList[index];
    configAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    double largeur = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Colors.green[500],
        elevation: 20.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Next page',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.assistant_photo),
            tooltip: 'Next page',
            onPressed: () {},
          ),
        ],
        leading:
        IconButton(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Next page',
          onPressed: () {},
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              width: 300,
             // color: Colors.blue,
              margin: EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3)
                  )
                ]
              ),
              child: new Image.asset(actualMusic.imagePath),
            ),
            new Container(
              margin: EdgeInsets.only(top: 20.0),
              child: new Text(actualMusic.title,
                textScaleFactor: 2)
            ),
            new Container(
                margin: EdgeInsets.only(top: 5.0),
                child: new Text(actualMusic.author)
            ),
            new Container(
              margin: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  textWidthStyle(fromDuration(position), 0.8),
                  textWidthStyle(fromDuration(duree), 0.8)
                ],
              ),
            ),
            new Container(
              margin: EdgeInsets.only(left: 10, right: 10.0),
              child: new Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0.0,
                  max: duree.inSeconds.toDouble(),
                  inactiveColor: Colors.grey[500],
                  activeColor: Colors.green[500],
                  onChanged: (double d){
                    setState(() {
                      audioPlayer.seek(d);
                    });
                  }),
            ),
            new Container(
              height: largeur / 5,
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IconButton(icon: new Icon(Icons.fast_rewind), onPressed: rewind),
                  new IconButton(icon: (statut != PlayerState.PLAYING) ? new Icon(Icons.play_circle_filled) : new Icon(Icons.pause_circle_filled),
                      onPressed: (statut != PlayerState.PLAYING) ? play : pause,
                      iconSize:  50),
                  new IconButton(icon: new Icon(Icons.fast_forward), onPressed: forward),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void configAudioPlayer(){
  audioPlayer = new AudioPlayer();
  positionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
    setState(() {
      position = pos;
    });
    if (position >= duree){
      position = new Duration(seconds: 0);
    }
  });
  stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
    if (state == AudioPlayerState.PLAYING){
      setState(() {
        duree = audioPlayer.duration;
      });
    } else if (state == AudioPlayerState.STOPPED){
      setState(() {
        statut = PlayerState.STOPPED;
      });
    }
  }, onError: (message) {
    print(message);
    setState(() {
      statut = PlayerState.STOPPED;
      duree = new Duration(seconds: 0);
      position = new Duration(seconds: 0);
    });
  });
}

  Future play() async{
    await audioPlayer.play(actualMusic.musicPath);
    setState(() {
      statut = PlayerState.PLAYING;
    });
  }

  Future pause() async{
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.PAUSED;
    });
  }

  Future muted() async{
    await audioPlayer.mute(!mute);
    setState(() {
      mute = !mute;
    });
  }

  void forward(){
    if (index == musicList.length - 1){
      index = 0;
    } else {
      index++;
    }
    actualMusic = musicList[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
}

  void rewind(){
    if (position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    } else {
      if (index == 0){
        index = musicList.length - 1;
      } else {
        index++;
      }
    }
    actualMusic = musicList[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
}

  Text textWidthStyle(String data, double scale){
    return new Text(data,
    textScaleFactor: scale,
    textAlign: TextAlign.center,
    style: new TextStyle(
      color: Colors.black,
      fontSize: 15.0
    ),);
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action){
    return new IconButton(
        icon: new Icon(icone),
        iconSize: taille,
        color: Colors.white,
        onPressed: () {
          switch(action) {
            case ActionMusic.PLAY:
              play();
              break;
            case ActionMusic.PAUSE:
              pause();
              break;
            case ActionMusic.REWIND:
              rewind();
              break;
            case ActionMusic.FORWARD:
              forward();
              break;
            default: break;
          }
        }
    );
  }

  String fromDuration (Duration duree){
    return duree.toString().split('.').first;
}
}

enum ActionMusic{
  PLAY,
  PAUSE,
  REWIND,
  FORWARD
}

enum PlayerState{
  PLAYING,
  STOPPED,
  PAUSED
}
