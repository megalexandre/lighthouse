import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/application/play_queue.dart';

import '../../support/fakes.dart';

void main() {
  final [e1, e2, e3] = TestItems.episodes;

  test('in the middle: both sides', () {
    final n = neighborsIn(TestItems.episodes, e2.id);
    expect(n.previous?.id, e1.id);
    expect(n.next?.id, e3.id);
  });

  test('at the ends: one side', () {
    expect(neighborsIn(TestItems.episodes, e1.id).previous, isNull);
    expect(neighborsIn(TestItems.episodes, e3.id).next, isNull);
  });

  test('not in the queue, or alone: nothing', () {
    expect(neighborsIn(TestItems.episodes, 'movie-1'), noNeighbors);
    expect(neighborsIn([e1], e1.id), noNeighbors);
  });
}
