
//
//  ViewController.m
//  LocalSocket
//
//  Created by vincent on 2022/6/21.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>
#import "ClientViewController.h"

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) UIButton *jumpBtn;
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
@property (nonatomic, strong) NSMutableArray *clientSockets;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.jumpBtn];
    [self startSocketService];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    // 服务端必须要保存连接的客户端，不然会断开
    [self.clientSockets addObject:newSocket];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    // 断开时移除
    if ([self.clientSockets containsObject:sock]) {
        [self.clientSockets removeObject:sock];
    }
}

#pragma mark - Action
- (void)jump {
    ClientViewController *vc = [ClientViewController new];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

#pragma mark - Private Method

- (void)startSocketService {
    NSError *error;
    BOOL result = [self.serverSocket acceptOnInterface:@"localhost" port:8080 error:&error];
    if (!result || error) {
        NSLog(@"start server socket result:%@ error:%@", @(result), error);
    } else {
        NSLog(@"server socket:%@ listen port:%d", self.serverSocket, self.serverSocket.localPort);
    }
}

- (void)stopSocketService {
    if (self.serverSocket != nil) {
        [self.serverSocket disconnect];
    }
    self.serverSocket = nil;
}

#pragma mark - Getter

- (NSMutableArray *)clientSockets {
    if (!_clientSockets) {
        _clientSockets = [NSMutableArray new];
    }
    return _clientSockets;
}

- (GCDAsyncSocket *)serverSocket {
    if (!_serverSocket) {
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _serverSocket.autoDisconnectOnClosedReadStream = YES;
    }
    return _serverSocket;
}

- (UIButton *)jumpBtn {
    if (!_jumpBtn) {
        _jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _jumpBtn.frame = CGRectMake(0, 100, 100, 50);
        _jumpBtn.backgroundColor = [UIColor grayColor];
        _jumpBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_jumpBtn setTitle:@"跳转" forState:UIControlStateNormal];
        [_jumpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_jumpBtn addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
    }
    return _jumpBtn;
}

@end

