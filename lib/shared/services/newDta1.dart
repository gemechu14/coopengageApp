import 'package:coopengageplus/shared/services/riverpoddata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class RiverpodData extends ConsumerWidget {
  const RiverpodData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riverpod Example"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(ref.watch(riverpodEasyLevel).toString()),
            IconButton(
              onPressed: () {
                ref.read(riverpodEasyLevel.notifier).state++;
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () {
                ref.watch(riverpodEasyLevel.notifier).state--;
                // Your logic for removing
              },
              icon: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
