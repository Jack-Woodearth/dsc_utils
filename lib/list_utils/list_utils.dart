import 'dart:math';

List<List<T>> splitList<T>(List<T> source, int subSize) {
  List<List<T>> ret = [];
  for (var i = 0; i < source.length; i += subSize) {
    ret.add(source.sublist(i, min(i + 3, source.length)));
  }

  return ret;
}
