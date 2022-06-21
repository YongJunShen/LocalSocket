//
//  ClientViewController.m
//  LocalSocket
//
//  Created by vincent on 2022/6/21.
//

#import "ClientViewController.h"
#import <GCDAsyncSocket.h>

@interface ClientViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;

@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.sendBtn];
    [self.view addSubview:self.closeBtn];
    [self socketConnect];
}

#pragma mark - GCDAsyncSocketDelegate
// 连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port {
    NSLog(@"连接成功 : %@---%d",host,port);
    [sock readDataWithTimeout:-1 tag:100];
}

// 连接断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开 socket连接 原因:%@",err);
    [self.clientSocket disconnect];
    self.clientSocket = nil;
}

//接收服务器返回来的数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"接收到tag = %ld : %ld 长度的数据",tag,data.length);
    // 这里必须要read,否则缓存区将会被关闭，timeout-1表示无限时长
    [sock readDataWithTimeout:-1 tag:100];
}

//消息发送成功（向服务器发送消息）
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"tag:%ld 发送数据成功", tag);
}


#pragma mark - Action
- (void)send {
    [self sendData];
}

- (void)close {
    [self socketDisConnect];
}

#pragma mark - Private Method

// 发送数据
- (void)sendData {
    NSString *dataStr = @"这是我发给服务端的数据";
    [self.clientSocket writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:5 tag:100];
}

- (void)socketConnect {
    if (!self.clientSocket.isConnected) {
        NSError *error;
        [self.clientSocket connectToHost:@"localHost" onPort:8080 error:&error];
        [self.clientSocket readDataWithTimeout:-1 tag:100];
    }
}

// 断开socket
- (void)socketDisConnect {
    if (self.clientSocket.isConnected) {
        [self.clientSocket disconnect];
        self.clientSocket = nil;
    }
}

#pragma mark - Getter

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(0, 100, 100, 50);
        _sendBtn.backgroundColor = [UIColor grayColor];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendBtn setTitle:@"发送数据" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(150, 100, 100, 50);
        _closeBtn.backgroundColor = [UIColor grayColor];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_closeBtn setTitle:@"断开连接" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (GCDAsyncSocket *)clientSocket {
    if (!_clientSocket) {
        _clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _clientSocket;
}

@end
