import 'dart:async';

// A worker is used to do an async task that might take a long time.  When a job
// is triggered, it will check to see if one is already running. If not, it will
// start a new job. If a job is currently running, then a counter is incremented
// so that the running job knows it should start over when it is done.
// However, it will only rerun the job one more time.
class Worker<InitialData, ResultType> {
  // The current initial data for the running job. This might
  // change while the job is running if the job is triggered again.
  late InitialData initial_data;
  Future<ResultType?> Function(InitialData, Interrupter) doJob;
  Future<void> Function(InitialData, ResultType) finishJob;

  Worker(this.doJob, this.finishJob);

  int update_counter = 0;
  bool updating = false;
  Interrupter interrupter = Interrupter();

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString() => "worker-$debug_id";

  void trigger(InitialData initialData) {
    // Log.animate.log("Calling trigger $initial_data, w/counter = $update_counter");
    initial_data = initialData;
    update_counter++;
    interrupter.stop = true; // Interrupt the current job.
    if (updating) return;
    updating = true;
    // Log.animate.log("starting runJob w/counter = $update_counter");
    _runJob();
  }

  void _runJob() async {
    int currentUpdate = 0;
    ResultType? result;
    while (currentUpdate < update_counter) {
      // At the start of the loop, we remember what the counter was. Then
      // at the end of the loop, if the counter has been incremented, then
      // we need another update. But we will only do one more update and not
      // one update for each counter increment. This protects us from a
      // rapidly changing velocity.
      currentUpdate = update_counter;
      // Log.animate.log("inside loop current = $current_update, counter=$update_counter.");
      interrupter.stop = false;
      result = await doJob(initial_data, interrupter);
      // Log.animate.log("current=$current_update, result = $result");
    }
    if (result != null) finishJob(initial_data, result);
    updating = false;
  }

  // This is just used for testing.
  Future<void> wait() async {
    while (updating) {
      await Future.delayed(Duration(seconds: 1));
    }
  }
}

class Interrupter {
  bool stop = false;
}

// TODO: do partial job, which returns <scratch space or result>
/*
   something like:
   class Interupter { bool stop = false; }
   Future<ResultData> doJob(InitialData init, Interupter interupter) async {
     while(!interulter.stop) {
       await doPartOfJob();
     }
     return result;
   }
     

*/
