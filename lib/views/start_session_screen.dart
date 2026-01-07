import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart'; // <-- se till att denna finns
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/session_viewmodel.dart';
import 'map_screen.dart';


final kCourses = <Course>[
  Course(
    name: "Bro Hof Slott GC",
    courseRating: 74.2,
    slopeRating: 137,
    holePars: [
      4,5,3,4,4,5,3,4,4,
      4,5,3,4,4,5,3,4,4,
    ],
    holeHcpIndex: [
      9,1,17,11,7,3,15,13,5,
      10,2,18,12,6,4,16,8,14,
    ],
  ),

  Course(
    name: "Bromma 9-hålsbanan",
    courseRating: 57.9,
    slopeRating: 97,
    holePars: [
      3,3,3,3,3,4,3,3,4,
    ],
    holeHcpIndex: [
      7,3,4,6,8,5,2,9,1,
    ],
  ),

  Course(
    name: "Drottningholm GK",
    courseRating: 71.6,
    slopeRating: 129,
    holePars: [
      4,4,3,5,4,4,3,5,4,
      4,5,3,4,4,5,3,4,4,
    ],
    holeHcpIndex: [
      11,3,17,1,9,7,15,5,13,
      12,2,18,10,6,4,16,8,14,
    ],
  ),

  Course(
    name: "Lindö Dal",
    courseRating: 69.2,
    slopeRating: 124,
    holePars: [
      4,3,4,3,4,5,4,4,5,
      4,3,4,4,3,4,4,3,5,
    ],
    holeHcpIndex: [
      11,13,3,7,1,5,15,17,9,
      10,6,4,16,8,14,2,18,12,
    ],
  ),

  Course(
    name: "Riksten",
    courseRating: 70.2,
    slopeRating: 125,
    holePars: [
      5,4,3,4,5,4,4,3,4,
      4,4,5,3,4,5,3,4,4,
    ],
    holeHcpIndex: [
      7,9,17,3,1,13,5,15,11,
      12,2,6,18,14,4,16,8,10,
    ],
  ),
];

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    // Defaultval (valfritt)
    if (kCourses.isNotEmpty) {
      _selectedCourse = kCourses.first;
    }
  }

  void _start() {
    final course = _selectedCourse;
    if (course == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Välj en golfbana.")),
      );
      return;
    }

    final mapVm = context.read<MapViewModel>();
    mapVm.resetForNewSession();

    // OBS: Detta kräver att din SessionViewModel.startSession tar emot Course.
    // Dvs: startSession({ required Course course })
    context.read<SessionViewModel>().startSession(course: course);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = _selectedCourse;

    return Scaffold(
      appBar: AppBar(title: const Text("Ny session")),
      body: Stack(
        children: [
          /// BAKGRUNDSBILD
          Positioned.fill(
            child: Image.asset(
              'assets/images/golfbild4.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// MÖRK OVERLAY FÖR LÄSBARHET
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          /// INNEHÅLL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Välj golfbana",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<Course>(
                        value: course,
                        items: kCourses
                            .map(
                              (c) => DropdownMenuItem<Course>(
                            value: c,
                            child: Text(c.name),
                          ),
                        )
                            .toList(),
                        onChanged: (c) => setState(() => _selectedCourse = c),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.95),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (course != null) ...[
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        title: const Text("Baninfo"),
                        subtitle: Text(
                          "Par: ${course.coursePar}\n"
                              "Course rating: ${course.courseRating}\n"
                              "Slope: ${course.slopeRating}\n"
                              "Hål: ${course.holePars.length}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  ElevatedButton(
                    onPressed: _start,
                    child: const Text("Starta"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
