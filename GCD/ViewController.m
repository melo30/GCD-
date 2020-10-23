//
//  ViewController.m
//  GCD
//
//  Created by 陈诚 on 2020/10/23.
//

#import "ViewController.h"

@interface ViewController ()

/// 火车票数量
@property (nonatomic, assign) NSInteger ticketSurplusCount;

/// 信号量
@property (nonatomic, strong) dispatch_semaphore_t semaphoreLock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 首先，GCD分为两步：
    // 1.创建队列
    // 2.创建任务
    
#pragma mark - 队列的创建
    // 第一个参数表示队列的唯一标识符，用于Debug，可为空。队列的名称推荐使用应用程序ID这种逆序全程域名
    // 第二个参数用来识别是串行队列还是并行队列。DISPATCH_QUEUE_SERIAL表示串行队列，DISPATCH_QUEUE_CONCURRENT表示并发队列
    
    // 创建串行队列
    dispatch_queue_t queue_serial = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_SERIAL);
    
    // 创建并发队列
    dispatch_queue_t queue_concurrent = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_CONCURRENT);
    
    // 主队列的获取方法
    dispatch_queue_t queue_main = dispatch_get_main_queue();
    
    // 全局并发队列的获取方法
    // 第一个参数表示队列优先级，第二个参数暂时没用，用0即可
    dispatch_queue_t queue_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    
#pragma mark - 任务的创建
    // 有了队列，下面来说下任务的创建方法
    // GCD 提供了同步执行任务的创建方法 dispatch_sync 和异步执行任务的创建方法 dispatch_async
    
    // 同步执行任务创建方法
    dispatch_sync(queue_serial, ^{
        
    });
    
    // 异步执行任务创建方法
    dispatch_async(queue_serial, ^{
        
    });
    
#pragma mark - 总结
    // 虽然使用 GCD 只需两步，既然我们有两种队列（串行队列 / 并发队列），两种任务执行方式（同步执行 / 异步执行），那么我们就有了四种不同的组合方式。这四种不同的组合方式是：
    
    /**
        1.同步执行 + 并发队列
        2.异步执行 + 并发队列
        3.同步执行 + 串行队列
        4.异步执行 + 串行队列
     */

    
    // 实际上，刚才还说了两种默认队列：全局并发队列、主队列。全局并发队列可以作为普通并发队列来使用。但是当前代码默认放在主队列中，所以主队列很有必要专门来研究一下，所以我们就又多了两种组合方式。这样就有六种不同的组合方式了。
    
    /**
        5.同步执行 + 主队列
        6.异步执行 + 主队列
     */
    
#pragma mark - 死锁问题，运行时会报错.
#if 0
    // 死锁1(主线程死锁)：主线程中，调用主队列queue_main + 同步执行sync
    // 原因：”主线程中追加的同步任务“ 和 ”主线程本身的任务“ 两者之间互相等待，阻塞了”主队列queue_main“
    // 最终造成了最队列所在的线程(主线程)死锁问题.
    dispatch_sync(queue_main, ^{
        // 追加任务1
        [NSThread sleepForTimeInterval:2]; //模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]); // 打印当前线程
    });
    
    // 死锁2(子线程死锁)：异步执行 + 串行队列的任务中，又嵌套了当前的串行队列，然后进行同步执行
    // 原因是：执行下面代码对导致 ”串行队列中追加的任务“ 和 ”串行队列中原有的任务“ 两者之间互相等待，阻塞了”串行队列queue_serial“，
    // 最终造成了串行队列所在的线程(子线程)死锁问题.
    dispatch_async(queue_serial, ^{ // 异步执行 + 串行队列
        dispatch_sync(queue_serial, ^{ // 同步执行 + 当前串行队列
            // 追加任务2
            [NSThread sleepForTimeInterval:2]; //模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]); // 打印当前线程
        });
    });
    
#endif
    
    
#pragma mark - GCD的基本使用
    // 1.同步执行 + 并发队列
    // 特点：在当前线程中执行任务，不会开启新线程(会一直在当前线程中)，执行完一个任务，再执行下一个任务.
//    [self syncConcurrent];
    
    // 2.异步执行 + 并发队列
    // 特点：可以开启多个线程，任务交替(同时)执行.
//    [self asyncConcurrent];
    
    // 3.同步执行 + 串行队列
    // 特点：不会开启新线程，在当前线程执行任务。任务是串行，执行完一个任务，再执行下一个任务。
//    [self syncSerial];
    
    // 4.异步执行 + 串行队列
    // 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务.
//    [self asyncSerial];
    
#pragma mark - GCD线程间的通信
//    [self comunication];

#pragma mark - GCD栅栏方法：dispatch_barrier_async
//    [self barrier];
    
#pragma mark - GCD延时执行方法 dispatch_after
//    [self after];
    
#pragma mark - GCD一次性代码(只执行一次)：disptch_once
//    [self once];
    
#pragma mark - GCD快速迭代方法：dispatch_apply
//    [self apply];
    
#pragma mark - dispatch_group_notify
//    [self groupNotify];
    
#pragma mark - dispatch_group_wait
//    [self groupWait];
    
#pragma mark - dispatch_group_enter、diaptch_group_leave
//    [self groupEnterAndLeave];
    
#pragma mark - GCD信号量：dispatch_semaphore  *****信号量是重点和难点哟*****
    // 说明：
    // 1. GCD 中的信号量是指 Dispatch Semaphore，是持有计数的信号。类似于过高速路收费站的栏杆。可以通过时，打开栏杆，不可以通过时，关闭栏杆。
    // 2.在 Dispatch Semaphore 中，使用计数来完成这个功能，计数小于 0 时等待，不可通过。计数为 0 或大于 0 时，计数减 1 且不等待，可通过。
    // 3.Dispatch Semaphore 提供了三个方法：1.dispatch_semaphore_create：创建一个 Semaphore 并初始化信号的总量、2.dispatch_semaphore_signal：发送一个信号，让信号总量+1 、3.dispatch_semaphore_wait：可以使总信号量减 1，信号总量小于 0 时就会一直等待（阻塞所在线程），否则就可以正常执行。
    // 4.信号量的使用前提是：想清楚你需要处理哪个线程等待（阻塞），又要哪个线程继续执行，然后使用信号量。
    
    // 5.Dispatch Semaphore 在实际开发中主要用于：1.保持线程同步，将异步执行任务转换为同步执行任务、2.保证线程安全，为线程加锁
    
    
    
    // 5.1.Dispatch Semaphore 线程同步
    // 我们在开发中，会遇到这样的需求：异步执行耗时任务，并使用异步执行的结果进行一些额外的操作。换句话说，相当于，将异步执行任务转换为同步执行任务。比如说：AFNetworking 中 AFURLSessionManager.m 里面 的 tasksForKeyPath：方法。通过引入信号量的方式，等待异步执行任务结果，获取到tasks，然后再返回该tasks。
    
    
    
    
    // 下面，我们来利用 Dispatch Semaphore 实现线程同步，将异步执行任务转换为同步执行任务。
//    [self semaphoreSync];
    
    
    // 接着，我们再来看下线程安全问题：经典火车票案例
    // 1.非线程安全(不使用semaphore加锁)
//    [self initTicketStatusNotSave];
    
    // 2.线程安全(使用semaphore加锁)
    [self initTicketStatusSave];
}



/**********************************************    华丽的分割线    ********************************************************************/



- (void)syncConcurrent {
    NSLog(@"currentThread---%@",[NSThread currentThread]);//打印当前线程
    NSLog(@"syncConcurrent---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_CONCURRENT);//创建并发队列
    
    dispatch_sync(queue, ^{//同步执行
        //追加任务1
        [NSThread sleepForTimeInterval:2];//模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);//打印当前线程
    });
    
    dispatch_sync(queue, ^{//同步执行
        //追加任务2
        [NSThread sleepForTimeInterval:2];//模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);//打印当前线程
    });
    
    dispatch_sync(queue, ^{//同步执行
        //追加任务3
        [NSThread sleepForTimeInterval:2];//模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);//打印当前线程
    });
    
    NSLog(@"syncConcurrent---end");
    
    // 最后说明:
    // 1.所有任务都是在当前线程（主线程）中执行的，没有开启新的线程（同步执行不具备开启新线程的能力）
    // 2.所有任务都在打印的 syncConcurrent---begin 和 syncConcurrent---end 之间执行的（同步任务 需要等待队列的任务执行结束）。
    // 3.任务按顺序执行的。按顺序执行的原因：虽然 并发队列 可以开启多个线程，并且同时执行多个任务。但是因为本身不能创建新线程，只有当前线程这一个线程（同步任务 不具备开启新线程的能力），所以也就不存在并发。而且当前线程只有等待当前队列中正在执行的任务执行完毕之后，才能继续接着执行下面的操作（同步任务 需要等待队列的任务执行结束）。所以任务只能一个接一个按顺序执行，不能同时被执行。
}

- (void)asyncConcurrent {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
        NSLog(@"asyncConcurrent---begin");
        
        dispatch_queue_t queue = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(queue, ^{
            // 追加任务 1
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        });
        
        dispatch_async(queue, ^{
            // 追加任务 2
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
        
        dispatch_async(queue, ^{
            // 追加任务 3
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        });
        
        NSLog(@"asyncConcurrent---end");
    
    // 最后说明：
    // 1.除了当前线程（主线程），系统又开启了 3 个线程，并且任务是交替/同时执行的。（异步执行 具备开启新线程的能力。且 并发队列 可开启多个线程，同时执行多个任务）。
    // 2.所有任务是在打印的 syncConcurrent---begin 和 syncConcurrent---end 之后才执行的。说明当前线程没有等待，而是直接开启了新线程，在新线程中执行任务（异步执行 不做等待，可以继续执行任务）。
    
}


- (void)syncSerial {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
        NSLog(@"syncSerial---begin");
        
        dispatch_queue_t queue = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_SERIAL);
        
        dispatch_sync(queue, ^{
            // 追加任务 1
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        });
        dispatch_sync(queue, ^{
            // 追加任务 2
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
        dispatch_sync(queue, ^{
            // 追加任务 3
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        });
        
        NSLog(@"syncSerial---end");
    
    // 最后说明：
    // 1.所有任务都是在当前线程（主线程）中执行的，并没有开启新的线程（同步执行 不具备开启新线程的能力）。
    // 2.所有任务都在打印的 syncConcurrent---begin 和 syncConcurrent---end 之间执行（同步任务 需要等待队列的任务执行结束）。
    // 3.任务是按顺序执行的（串行队列 每次只有一个任务被执行，任务一个接一个按顺序执行）。
}

- (void)asyncSerial {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
        NSLog(@"syncSerial---begin");
        
        dispatch_queue_t queue = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_SERIAL);
        
        dispatch_async(queue, ^{
            // 追加任务 1
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        });
        dispatch_async(queue, ^{
            // 追加任务 2
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
        dispatch_async(queue, ^{
            // 追加任务 3
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        });
        
        NSLog(@"syncSerial---end");
    
    // 最后说明：
    // 1.开启了一条新线程（异步执行 具备开启新线程的能力，串行队列 只开启一个线程）。
    // 2.所有任务是在打印的 syncConcurrent---begin 和 syncConcurrent---end 之后才开始执行的（异步执行 不会做任何等待，可以继续执行任务）。
    // 3.任务是按顺序执行的（串行队列 每次只有一个任务被执行，任务一个接一个按顺序执行）。
}

- (void)comunication {
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t queue_main = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 异步追加任务1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        // 回到主线程
        dispatch_async(queue_main, ^{
            // 追加在主线程中执行的任务
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
    
    // 说明：
    // 可以看到在其他线程中先执行任务，执行完了之后回到主线程执行主线程的相应操作。
}

- (void)barrier {
    dispatch_queue_t queue = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        //追加任务1
        [NSThread sleepForTimeInterval:2]; //模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]); //打印当前线程
    });
    
    dispatch_async(queue, ^{
        //追加任务2
        [NSThread sleepForTimeInterval:2]; //模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]); //打印当前线程
    });
    
    dispatch_barrier_async(queue, ^{//barrier method
        // 追加任务 barrier
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
    });
    
    dispatch_async(queue, ^{
        //追加任务3
        [NSThread sleepForTimeInterval:2]; //模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]); //打印当前线程
    });
    
    dispatch_async(queue, ^{
        //追加任务4
        [NSThread sleepForTimeInterval:2]; //模拟耗时操作
        NSLog(@"4---%@",[NSThread currentThread]); //打印当前线程
    });
    
    // 说明：在执行完栅栏前面的操作之后，才执行栅栏操作，最后再执行栅栏后边的操作。
    // 也就是先执行1、2，然后执行栅栏方法中的内容，最后执行3、4。不过1、2之间和3、4之间是随机的
}

- (void)after {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
        NSLog(@"asyncMain---begin");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 2.0 秒后异步追加任务代码到主队列，并开始执行
            NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
        });
}

- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行1次的代码(这里默认是线程安全的)
    });
    
    // 说明：
    // 我们在创建单例、或者有整个程序运行过程中只执行一次的代码时，我们就用到了 GCD 的 dispatch_once 方法。使用 dispatch_once 方法能保证某段代码在程序运行过程中只被执行 1 次，并且即使在多线程的环境下，dispatch_once 也可以保证线程安全。
}

- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"applu---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index,[NSThread currentThread]);
    });
    NSLog(@"applu---end");
    
    // 说明：
    // 我们可以利用并发队列进行异步执行。比如说遍历 0~5 这 6 个数字，for 循环的做法是每次取出一个元素，逐个遍历。dispatch_apply 可以 在多个线程中同时（异步）遍历多个数字。
    // 还有一点，无论是在串行队列，还是并发队列中，dispatch_apply 都会等待全部任务执行完毕，这点就像是同步操作，也像是队列组中的 dispatch_group_wait方法。
}

- (void)groupNotify {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
                [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 追加任务 2
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
       //等前面的异步任务1、2都执行完毕后，回到主线程执行下边任务
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程

                NSLog(@"group---end");
    });
    
    // 说明：
    // 当所有任务都执行完成之后，才执行 dispatch_group_notify 相关 block 中的任务。
}

- (void)groupWait {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
                [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
                NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 追加任务 2
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    // 等待上面的任务全部完成后，会往下继续执行(会阻塞当前线程)
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"group---end");
    
    // 说明：
    // 当所有任务执行完成之后，才执行 dispatch_group_wait 之后的操作。但是，使用dispatch_group_wait 会阻塞当前线程!
}

- (void)groupEnterAndLeave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    //创建一个组group
    dispatch_group_t group = dispatch_group_create();
    
    //创建一个队列queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
            
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
            
        NSLog(@"group---end");
    });
    
    // 说明：
    // 1.dispatch_group_enter 标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数 +1
    // 2.dispatch_group_leave 标志着一个任务离开了 group，执行一次，相当于 group 中未执行完毕任务数 -1。
    // 3.当 group 中未执行完毕任务数为0的时候，才会使 dispatch_group_wait 解除阻塞，以及执行追加到 dispatch_group_notify 中的任务。
    // 4.从 dispatch_group_enter、dispatch_group_leave 相关代码运行结果中可以看出：当所有任务执行完成之后，才执行 dispatch_group_notify 中的任务。这里的dispatch_group_enter、dispatch_group_leave 组合，其实等同于dispatch_group_async。
}

- (void)semaphoreSync {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);//初始创建时计数为 0
    
    __block int number = 0;
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        number = 100;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"semaphore---end, number = %d",number);
    
    // 说明：
    // semaphore---end 是在执行完 number = 100; 之后才打印的。而且输出结果 number 为 100。这是因为 异步执行 不会做任何等待，可以继续执行任务。
    // 执行顺序如下：
    // 1.semaphore 初始创建时计数为 0。
    // 2.异步执行 将 任务 1 追加到队列之后，不做等待，接着执行 dispatch_semaphore_wait 方法，使得semaphore 减 1，此时 semaphore == -1，当前线程进入等待状态。
    // 3.然后，追加任务 1 开始执行。任务 1 执行到 dispatch_semaphore_signal 之后，总信号量加 1，然后 semaphore == 0，正在被阻塞的线程（主线程）恢复继续执行。
    // 4.最后打印 semaphore---end,number = 100。
    
    // 5.这样就实现了线程同步，将异步执行任务转换为同步执行任务! 你学到了吗？
}


/// 非线程安全：不使用 semaphore，初始化火车票数量、卖票窗口（非线程安全）、并开始卖票
- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    //初始化火车票张数
    self.ticketSurplusCount = 50;
    
    // 创建一个串行队列queue1,代表重庆火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_SERIAL);
    // 创建一个串行队列queue2,代表成都火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self)wself = self;
    dispatch_async(queue1, ^{
        [wself saleTicketNotSafe];
    });
    dispatch_async(queue2, ^{
        [wself saleTicketNotSafe];
    });
}

/// 售卖火车票（非线程安全）
- (void)saleTicketNotSafe {
    while (1) {
        if (self.ticketSurplusCount > 0) {// 如果还有余票，继续售卖
            self.ticketSurplusCount --;
            NSLog(@"%@",[NSString stringWithFormat:@"剩余票数：%ld 窗口：%@",(long)self.ticketSurplusCount,[NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }else {// 如果已经卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完！！！！！");
            break;// 跳出while循环
        }
    }
    
    // 说明：
    // 打印结果可以看到在不考虑线程安全，不使用 semaphore 的情况下，得到票数是错乱的，这样显然不符合我们的需求，所以我们需要考虑线程安全问题。
}


/// 线程安全：使用 semaphore 加锁，初始化火车票数量、卖票窗口（线程安全）、并开始卖票
- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    self.semaphoreLock = dispatch_semaphore_create(1);//创建初始计数为1
    
    //初始化火车票张数
    self.ticketSurplusCount = 50;
    
    // 创建一个串行队列queue1,代表重庆火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_SERIAL);
    // 创建一个串行队列queue2,代表成都火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("com.manjiwang.GCD", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self)wself = self;
    dispatch_async(queue1, ^{
        [wself saleTicketNotSafe];
    });
    dispatch_async(queue2, ^{
        [wself saleTicketNotSafe];
    });
}

/// 售卖火车票（线程安全）
- (void)saleTicketSafe {
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(self.semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) { //如果还有余票，继续售卖
            self.ticketSurplusCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", (long)self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }else {// 如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完！！！！！");
            // 相当于解锁（计数+1）
            dispatch_semaphore_signal(self.semaphoreLock);
            break;;
        }
        // 相当于解锁（计数+1）
        dispatch_semaphore_signal(self.semaphoreLock);
    }
    
    // 说明：
    // 执行过程如下：
    // 1.初始化信号量计数为1
    // 2.首次一个窗口进来售卖火车票，到达dispatch_semaphore_wait时候，新号总量-1后等于0，可以正常执行卖票
    // 3.第二次下一个窗口进来售卖火车票，如果第一次还没卖票完毕的话(即 没有解锁信号量+1)，这时新号总量就为0，到达dispatch_semaphore_wait时候，新号总量-1后等于-1，这时就会一直等待（阻塞所在线程），直到上一次卖票完毕更新信号量。以后每一次如此循环，所以安全!
    // 可以看出，在考虑了线程安全的情况下，使用 dispatch_semaphore机制之后，得到的票数是正确的，没有出现混乱的情况。我们也就解决了多个线程同步的问题!
}

@end
