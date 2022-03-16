import 'package:animated_overflow/animated_overflow.dart';
import 'package:client/CurrentTrack.dart';
import 'package:client/RequestHandler.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Púšťač CDčiek"),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: getTracks(),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return SingleChildScrollView(
                child: Column(
                    children: snapshot.data!
                        .map((e) => TrackEntry(
                              title: e,
                            ))
                        .toList()),
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        bottomSheet: StreamBuilder(
            stream: getPeriodicStream(),
            builder: (context, snapshot) {
              print(snapshot.data);
              if (snapshot.hasData &&
                  (snapshot.data as TrackState).status != "UNKNOWN") {
                return BottomSheet(
                  enableDrag: false,
                  backgroundColor:
                      Theme.of(context).bottomSheetTheme.backgroundColor,
                  builder: (context) => CurrentTrackDisplay(
                    state: snapshot.data as TrackState,
                  ),
                  onClosing: () => {},
                );
              } else {
                return const SizedBox(
                  width: 0,
                  height: 0,
                );
              }
            })); // const CurrentTrackDisplay());
  }

  Stream<TrackState> getPeriodicStream() async* {
    yield* Stream.periodic(const Duration(seconds: 1), (_) {
      return getStatus();
    }).asyncMap(
      (value) async => await value,
    );
  }

  Future<TrackState> getStatus() async {
    Map<String, dynamic> json = await getRequest("/player/status");
    return TrackState.fromJSON(json);
  }
}

class TrackEntry extends StatelessWidget {
  final String title;
  const TrackEntry({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
          onTap: () => postRequest("/tracks/$title/play", {}),
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Row(
              children: [
                Image.network("$baseUrl/tracks/$title/thumbnail",
                    errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.music_note,
                    size: 100,
                  );
                }),
                AnimatedOverflow(
                  animatedOverflowDirection:
                      AnimatedOverflowDirection.HORIZONTAL,
                  maxWidth: 400,
                  speed: 50,
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
