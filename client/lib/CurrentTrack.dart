import 'package:client/RequestHandler.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class TrackState {
  double length = 1000;
  double position = 0;
  bool isPlaying = false;
  String name = "Test 2";
  String status = "UNKNOWN";
  TrackState();

  static TrackState fromJSON(Map<String, dynamic> json) {
    TrackState state = TrackState();
    state.status = json['state'];
    state.isPlaying = false;
    if (state.status != "UNKNOWN") {
      state.isPlaying = json['state'] != 'IDLE';
      state.length = json['duration'];
      state.position = json['time'];
      state.name = json['track'];
    }
    return state;
  }
}

class CurrentTrackDisplay extends StatefulWidget {
  final TrackState state;
  const CurrentTrackDisplay({required this.state, Key? key}) : super(key: key);

  @override
  State<CurrentTrackDisplay> createState() => _CurrentTrackDisplayState();
}

class _CurrentTrackDisplayState extends State<CurrentTrackDisplay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      height: 150,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Image.network(
              "$baseUrl/tracks/${widget.state.name}/thumbnail",
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.music_note,
                  size: 100,
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Práve hrá",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.grey.withAlpha(170), fontSize: 15),
                ),
                Row(children: [
                  IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        if (widget.state.isPlaying) {
                          postRequest("/player/pause", {}).then((value) {
                            setState(() {
                              widget.state.isPlaying = false;
                              _animationController.reverse();
                            });
                          });
                        } else {
                          postRequest("/player/play", {}).then((value) {
                            setState(() {
                              widget.state.isPlaying = true;
                              _animationController.forward();
                            });
                          });
                        }
                      },
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _animationController,
                        size: 50,
                      )),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () => postRequest("/player/stop", {}),
                    icon: const Icon(
                      Icons.stop,
                      size: 50,
                    ),
                  ),
                  Text(widget.state.name,
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold)),
                ]),
                Slider(
                    value: widget.state.position,
                    max: widget.state.length,
                    min: 0,
                    onChangeEnd: (value) =>
                        postRequest("/player/seek", {'position': value}),
                    onChanged: (value) => setState(() {
                          widget.state.position = value;
                          if (!widget.state.isPlaying) {
                            _animationController.forward();
                          }
                          widget.state.isPlaying = true;
                        })),
              ],
            ),
          )
        ],
      ),
    );
  }
}
