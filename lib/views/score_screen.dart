import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/hole_viewmodel.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HoleViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Score")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Hål avslutat", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Nästa hål"),
              onPressed: () {
                vm.resetHole();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
