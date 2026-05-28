//
//  QXTelemetryRingBuffer.m
//  QCCore
//

#import "QXTelemetryRingBuffer.h"

@interface QXTelemetryRingBuffer ()
@property (nonatomic, strong) NSMutableArray *storage;
@property (nonatomic, assign) NSUInteger writeIndex;
@property (nonatomic, assign) NSUInteger logicalCount;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation QXTelemetryRingBuffer

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        if (capacity == 0) capacity = 1;
        _capacity     = capacity;
        _storage      = [NSMutableArray arrayWithCapacity:capacity];
        _writeIndex   = 0;
        _logicalCount = 0;
        _queue        = dispatch_queue_create("ai.qx.qcore.qxtelemetry.ring", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSUInteger)count {
    __block NSUInteger c = 0;
    dispatch_sync(self.queue, ^{
        c = self.logicalCount;
    });
    return c;
}

- (void)appendObject:(id)object {
    if (!object) {
        return;
    }
    dispatch_barrier_async(self.queue, ^{
        if (self.storage.count < self.capacity) {
            [self.storage addObject:object];
        } else {
            self.storage[self.writeIndex] = object;
        }
        self.writeIndex = (self.writeIndex + 1) % self.capacity;
        self.logicalCount++;
    });
}

- (NSArray *)snapshot {
    __block NSArray *result = nil;
    dispatch_sync(self.queue, ^{
        if (self.storage.count < self.capacity) {
            result = [self.storage copy];
            return;
        }
        // 已经写满，按时间顺序重排
        NSMutableArray *ordered = [NSMutableArray arrayWithCapacity:self.capacity];
        for (NSUInteger i = 0; i < self.capacity; i++) {
            NSUInteger idx = (self.writeIndex + i) % self.capacity;
            [ordered addObject:self.storage[idx]];
        }
        result = [ordered copy];
    });
    return result ?: @[];
}

- (void)clear {
    dispatch_barrier_async(self.queue, ^{
        [self.storage removeAllObjects];
        self.writeIndex   = 0;
        self.logicalCount = 0;
    });
}

- (NSUInteger)dropOldest:(NSUInteger)n {
    __block NSUInteger dropped = 0;
    dispatch_barrier_sync(self.queue, ^{
        NSArray *snap = [self snapshotUnsafe];
        NSUInteger toDrop = MIN(n, snap.count);
        NSArray *remain = (toDrop >= snap.count) ? @[] : [snap subarrayWithRange:NSMakeRange(toDrop, snap.count - toDrop)];
        [self.storage removeAllObjects];
        [self.storage addObjectsFromArray:remain];
        self.writeIndex   = self.storage.count % self.capacity;
        self.logicalCount = self.storage.count;
        dropped = toDrop;
    });
    return dropped;
}

- (NSArray *)snapshotUnsafe {
    if (self.storage.count < self.capacity) {
        return [self.storage copy];
    }
    NSMutableArray *ordered = [NSMutableArray arrayWithCapacity:self.capacity];
    for (NSUInteger i = 0; i < self.capacity; i++) {
        NSUInteger idx = (self.writeIndex + i) % self.capacity;
        [ordered addObject:self.storage[idx]];
    }
    return [ordered copy];
}

@end
