import 'package:coopengageplus/service/RiverpodModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final riverpodEasyLevel = StateProvider<int>((ref) {
  return 0;
});

final reverpodHardLevel = ChangeNotifierProvider<Riverpodmodel>((ref) {
  return Riverpodmodel(counter: 0);
});
