# TimeWarp

TimeWarp measures the performance difference between running tasks sequentially, running tasks in separate threads, running tasks in a thread pool, and running tasks in separate processes (with a thread pool).

## How It Works

TimeWarp provides a class with four methods:

- `run`: Runs a task directly on the main thread.
- `thread`: Creates a new thread for each task.
- `thread_pool`: Reuses a pool of threads to run tasks.
- `process`: Creates a new process with a thread pool for a group of tasks.

Each method measures the time it takes to execute a given number of tasks and returns the total time.

## Results

Here are the results of running 50 small tasks (each sleeping for 0.1 seconds and reversing a string 100,000 times) and 200 large tasks (each sleeping for 1 second and reversing a string 1,000,000 times):

```
Running 50 small tasks...
Run: 5.72 seconds
Thread: 0.84 seconds
Thread Pool: 0.81 seconds
Process: 0.58 seconds

Running 200 large tasks...
Run: 228.40 seconds
Thread: 38.90 seconds
Thread Pool: 32.23 seconds
Process: 17.51 seconds
```

These results illustrate the benefits of multithreading and multiprocessing for I/O-bound tasks:

- The `Run` method runs tasks sequentially, so the total time is roughly the execution time of a single task multiplied by the number of tasks. This is why it takes significantly longer than the other methods, especially for the large tasks.

- The `Thread` method creates a new thread for each task, allowing tasks to be run concurrently. However, there's an overhead associated with creating a new thread for each task, which is why it's slower than the `Thread Pool` method for the large tasks.

- The `Thread Pool` method reuses a pool of threads to run tasks, allowing tasks to be run concurrently and reducing the overhead of thread creation.

- The `Process` method creates a new process for a group of tasks. Each process runs its tasks concurrently in a separate thread pool. This allows tasks to be run in true parallel on multiple CPU cores, bypassing the limitations of the Global Interpreter Lock (GIL) in Ruby. Despite the overhead of creating new processes and thread pools, the `Process` method is the fastest for both small and large tasks in these tests, demonstrating the benefits of true parallel execution for I/O-bound tasks.

By allowing tasks to run concurrently or in parallel, you can significantly reduce the total execution time compared to running tasks sequentially. However, keep in mind that multithreading and multiprocessing also add complexity to your code and can lead to issues such as race conditions if not handled correctly.

This does not mean that multithreading or multiprocessing is always the best solution. For CPU-bound tasks, multithreading may not provide any performance benefits, and in some cases, it may even make the performance worse due to the overhead of context switching. Multiprocessing can provide true parallelism for CPU-bound tasks, but the overhead of creating processes and the lack of shared memory can be drawbacks for certain types of workloads.
