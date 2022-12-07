import 'package:ai_radio_app/model/radio.dart';
import 'package:ai_radio_app/utils/ai_util.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/material.dart';


class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
   late List<MyRadio>radios;
   late MyRadio _selectedRadio;
   Color? _selectedColor;
   bool _isPlaying=false;

   final sugg = [
     "Play",
     "Stop",
     "Play rock music",
     "Play 107 FM",
     "Play next",
     "Play 104 FM",
     "Pause",
     "Play previous",
     "Play pop music"
   ];

   final AudioPlayer _audioPlayer=AudioPlayer();

   @override
  void initState() {
     super.initState();
     setupAlan();
     fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((event) {
       if (event == AudioPlayerState.PLAYING) {
       _isPlaying = true;
     } else {                            //check song play or stop
       _isPlaying = false;
     }
     setState(() {});
   });
  }
  setupAlan(){
    AlanVoice.addButton(
        "f315b7f3321e263e74932a477123567f2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) =>_handleCommand(command.data));
  }
  _handleCommand(Map<String,dynamic>response){
     switch(response["command"]){
       case "play":
         _playmusic(_selectedRadio.url);
         break;

       case "play_channel":
         final id=response["id"];
        // _audioPlayer.pause();
       MyRadio  newRadio=radios.firstWhere((element) => element.id==id);
         radios.remove(newRadio);
         radios.insert(0, newRadio);
         _playmusic(newRadio.url);
         break;

       case "stop":
         _audioPlayer.stop();
         break;
       case "next":
         final index=_selectedRadio.id;
         MyRadio newRadio;
         if(index + 1 > radios.length){
           newRadio=radios.firstWhere((element) => element.id==1);
            radios.remove(newRadio);
           radios.insert(0, newRadio);

         }else{
           newRadio=radios.firstWhere((element) => element.id==index + 1);
           radios.remove(newRadio);
           radios.insert(0, newRadio);
         }
         _playmusic(newRadio.url);
         break;

       case "previous":
         final index=_selectedRadio.id;
         MyRadio newRadio;
         if(index-1<=0){
           newRadio=radios.firstWhere((element) => element.id==1);
           radios.remove(newRadio);
           radios.insert(0, newRadio);

         }else{
           newRadio=radios.firstWhere((element) => element.id==index-1);
           radios.remove(newRadio);
           radios.insert(0, newRadio);
         }
         _playmusic(newRadio.url);
         break;

       default:
      print("Command was ${response["command"]}");
      break;
     }
  }

  fetchRadios()async {
    final radiojson=await rootBundle.loadString("assets/radio.json");
    radios =MyRadioList.fromJson(radiojson).radios;
    _selectedRadio=radios[0];
    _selectedColor=Color((int.tryParse(_selectedRadio.color))!);
    print(radios);
    setState(() {});
  }
  _playmusic(String url){
    _audioPlayer.play(url);
    _selectedRadio=radios.firstWhere((element) => element.url==url);
    print(_selectedRadio.name);
    setState(() {});

  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: _selectedColor??AIColors.primaryColor2,
          child: radios!=null?
              [100.heightBox,
                "ALL Channels".text.xl.white.semiBold.make().px16(),
            20.heightBox,
            ListView(
              padding: Vx.m0,
              shrinkWrap: true,
              children: radios.map((e) =>ListTile(
                leading: CircleAvatar(backgroundImage:NetworkImage(e.icon),
                ),
                title: "${e.name} FM".text.white.make(),
                subtitle: e.tagline.text.white.make(),
              )).toList(),

            )

          ].vStack(crossAlignment: CrossAxisAlignment.start)
          :const Offstage(),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
         Center(
           child: VxAnimatedBox()
               .size(context.screenWidth,context.screenHeight)
               .withGradient(LinearGradient(
             colors:[
                 AIColors.primaryColor2,
                _selectedColor?? AIColors.primaryColor1,
           ],
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
           )
           )
               .make(),
         ),
          [
          Center(
            child: AppBar(
              title: "AI Radio".text.xl4.bold.white.make().shimmer(
                primaryColor: Vx.purple300,secondaryColor: Vx.white),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p16(),
          ),
             20.heightBox,
             "start with -Hey Alan 👇".text.italic.semiBold.white.make(),
              10.heightBox,
             Column(
         children: [
           VxSwiper.builder(
             itemCount: sugg.length,
             height: 50.0,
            viewportFraction: 0.35,
            autoPlay: true,
            autoPlayAnimationDuration: 3.seconds,

            autoPlayCurve: Curves.linear,
            enableInfiniteScroll: true,
            itemBuilder:(context,index){
               final s=sugg[index];
               return Chip(
               label:s.text.make(),
               backgroundColor: Vx.randomColor,
              );
             },
            ),

          radios!=null ?
          Center(
            child: VxSwiper.builder(
            itemCount: radios.length,
            aspectRatio: 1.2,
            enlargeCenterPage: true,
            onPageChanged: (index) {
           _selectedRadio=radios[index];

          final colorHex = radios[index].color;
          _selectedColor = Color((int.tryParse(colorHex))!);
         setState(() {});
         },
         itemBuilder:( context, index) {
            final rad =radios[index];
           return VxBox(     //use this box to have background image
         child:  ZStack([
         Positioned(
             top: 0.0,
            right: 0.0,
           child: VxBox(
             child: rad.category
               .text
               .uppercase
               .white
               .make()
               .px16(),
             )
             .height(40)
             .black
             .alignCenter
             .withRounded(value: 10.0)
             .make(),
        ),
        Column(
         children: [
           Align(
           alignment: Alignment.bottomCenter,
           child: VStack([
             rad.name.text.xl3.white.bold.make(),   //name of the channel
                5.heightBox,
                rad.tagline.text.sm.white.semiBold.make(),

              ],
             crossAlignment: CrossAxisAlignment.center,
            ),
             ),
           ],
          ),
        Center(
         child: Align(
         alignment:Alignment.center,
         child: [Icon(
             CupertinoIcons.play_circle,
             color: Colors.white,
           ),
             10.heightBox,
            "Double tap to play".text.gray300.make(),
          ].vStack()
          ),
         )
        ],
          clip: Clip.antiAlias,
         ))
             .clip(Clip.antiAlias)
             .bgImage(
                  DecorationImage(image: NetworkImage(rad.image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                 Colors.black.withOpacity(0.3), BlendMode.darken),)
              )
                .border(color: Colors.black,width: 5.0)
               .withRounded(value: 60.0)
               .make()
               .onInkDoubleTap(() {
                  _playmusic(rad.url);
                 })
                .p16();
        },
        ).centered(),
         ):
        Center(
         child: CircularProgressIndicator(
         backgroundColor: Colors.red,
          ),
         ),
         Align(

           alignment: Alignment.bottomCenter,
          child: [
           if(_isPlaying)
           "Playing Now - ${_selectedRadio.name}FM"

         .text
         .white

         .makeCentered(),          //detail of the playing radio shown
          Icon(

         _isPlaying

         ? CupertinoIcons.stop_circle       //check song play then true otherwise stop circle
          :CupertinoIcons.play_circle,

         color: Colors.white,
         size: 50.0,

         ).onInkTap(() {

             if(_isPlaying){
              _audioPlayer.stop();                  //to stop the audioPlayer
             } else {
             _playmusic(_selectedRadio.url);      //if stop the use for play audioPlayer
            }
            })

          ].vStack()
           ).pOnly(bottom: context.percentHeight * 12)

         ],
          )
           ].vStack(),
          30.heightBox,


        ],
       //   fit: StackFit.expand,
        ),
      ),

    );
  }
}
