import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/worker.dart';

class JobResult {
  int id;
  bool interrupted;
  JobResult(this.id, this.interrupted);
}

class Job {
  List<int>? answer;

  List<JobResult> results = [];
  List<int> get order => results.map((r) => r.id).toList();
  List<bool> get interrupted => results.map((r) => r.interrupted).toList();

  Future<List<int>?> part1(int input, Interrupter interrupter) async {
    // print("input = $input.");
    List<int> list = [];
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      list.add(input * 10 + i);
      // print("input = $input, list=$list");
      if (interrupter.stop) {
        results.add(JobResult(input, true)); //Record when it was interrupted.
        return null;
      }
    }
    results.add(JobResult(input, false));
    return list;
  }

  Future<void> part2(int input, List<int> list) async {
    // print("GREEN: input = $input, list=$list.");
    answer = list;
  }
}

void main() {
  group('worker', () {
    test('simple', () async {
      Job job = Job();
      Worker worker = Worker<int, List<int>>(job.part1, job.part2);
      worker.trigger(1);
      await Future.delayed(Duration(milliseconds: 350));
      worker.trigger(2);
      await Future.delayed(Duration(milliseconds: 290));
      worker.trigger(3);
      await Future.delayed(Duration(milliseconds: 290));
      worker.trigger(4);
      await Future.delayed(Duration(milliseconds: 290));
      worker.trigger(5);
      await worker.wait();
      // Expect the final result to be from job 5.
      expect(job.answer, [50, 51, 52, 53, 54, 55, 56, 57, 58, 59]);
      // Expect the first four jobs to be interrupted after 3 iterations.
      expect(job.order, [1, 2, 3, 4, 5]);
      expect(job.interrupted, [true, true, true, true, false]);
      worker.trigger(6);
      await worker.wait();
      expect(job.answer, [60, 61, 62, 63, 64, 65, 66, 67, 68, 69]);
      expect(job.order, [1, 2, 3, 4, 5, 6]);
      expect(job.interrupted, [true, true, true, true, false, false]);
    });
  });
}
