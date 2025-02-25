import 'package:flutter/material.dart';
import 'package:atomx/atomx.dart';
import 'counter_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            AtomxBuilder(
              builder: (context) {
                final counter = _controller.counter;
                final stateText = switch (counter.state) {
                  CounterState.initial => 'Ready to start',
                  CounterState.counting => 'Counting...',
                  CounterState.paused => 'Paused',
                };

                return Column(
                  children: [
                    Text(
                      '${counter.value}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stateText,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: AtomxBuilder(
        builder: (context) {
          final counter = _controller.counter;
          final state = counter.state;

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: _controller.reset,
                tooltip: 'Reset',
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed:
                    state == CounterState.paused ? null : _controller.increment,
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed:
                    state == CounterState.counting ? _controller.pause : null,
                tooltip: 'Pause',
                child: const Icon(Icons.pause),
              ),
            ],
          );
        },
      ),
    );
  }
}
