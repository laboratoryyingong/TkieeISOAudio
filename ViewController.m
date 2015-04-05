//
//  ViewController.m
//  TkieeISOAudio
//
//  Created by YIN GONG on 1/04/2015.
//  Copyright (c) 2015 YIN GONG. All rights reserved.
//

#import "ViewController.h"
#import "RecorderManager.h"
#import "PlayerManager.h"

#import <stdio.h>
#import <stdlib.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <string.h>
#import <fcntl.h>
#include <sys/time.h>
#include <time.h>

#define tcp_port  2000
#define udp_send_port  2001
#define udp_recv_port  2002

@interface ViewController () <RecordingDelegate>

@property (strong, nonatomic) IBOutlet UIProgressView *leverlMeter;

@property (strong, nonatomic) IBOutlet UIButton *recordButton;

@property (strong, nonatomic) IBOutlet UILabel *consolelable;

@property (nonatomic,copy) NSString *filename;

-(IBAction)recordButtonClicked:(id)sender;

@property (nonatomic,assign) BOOL isRecording;

@end



@implementation ViewController

@synthesize MyUIWeb;
@synthesize udpSendBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    //Load Tkiee Website
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tkiee.com"]];
   // [self.view addSubview: MyUIWeb];
    [self.MyUIWeb loadRequest:request];
    
    self.consolelable.numberOfLines =2;
    self.consolelable.text= @"Recording Tkiee Audio";
    
    //initial levermeter
     self.leverlMeter.progress = 0;
    
    //init recordbutton
    [self.recordButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //udp send
    self.isRecording = NO;
    m_udpSocket = nil;

    

}

- (void)viewDidUnload
{
  //  [self setRecordBtn:nil];
    [self setUdpSendBtn:nil];
  //  [self setTcpSendBtn:nil];
  //  [self setIpAddrText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


/*

- (IBAction)udpSendAction:(id)sender
{
    if (m_udpSocket == nil)
    {
        [self connectUDP];
    }
//    [self sendFileWithPath:[self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]];

}


*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [self removeObserver:self forKeyPath:@"isRecording"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        if ([keyPath isEqualToString:@"isRecording"])
        {[self.recordButton setTitle:(self.isRecording? @"Pause": @"Record") forState:UIControlStateNormal];
            
            }
    }


-(IBAction)recordButtonClicked:(id)sender
    {
        if(!self.isRecording)
        {
            self.isRecording = YES;
            [RecorderManager sharedManager].delegate =self;
            [[RecorderManager sharedManager] startRecording];
        }
        else
        {
            self.isRecording = NO;
            [[RecorderManager sharedManager] stopRecording];
        }
    
    }

#pragma mark - Recording & Playing Delegate

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval {
    self.isRecording = NO;
    self.leverlMeter.progress = 0;
    self.filename = filePath;
    [self.consolelable performSelectorOnMainThread:@selector(setText:)
                                        withObject:[NSString stringWithFormat:@"Recording Finished: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]]
                                     waitUntilDone:NO];
}

- (void)recordingTimeout {
    self.isRecording = NO;
    self.consolelable.text = @"OverTime";
}

- (void)recordingStopped {
    self.isRecording = NO;
}

- (void)recordingFailed:(NSString *)failureInfoString {
    self.isRecording = NO;
    self.consolelable.text = @"Recording failer";
}

- (void)levelMeterChanged:(float)levelMeter {
    self.leverlMeter.progress = levelMeter;
}



/*

#pragma mark udp function
//创建udp socket
-(void)connectUDP{
    //初始化udp
    m_udpSocket= [[AsyncUdpSocket alloc] initWithDelegate:self];
    //绑定端口
    NSError *error = nil;
    [m_udpSocket bindToPort:udp_recv_port error:&error];
    
    [m_udpSocket enableBroadcast:YES error:&error];
    //启动接收线程
    [m_udpSocket receiveWithTimeout:-1 tag:0];
}

-(void)sendFileWithPath:(NSString*)path
{
    NSData* data = [[NSData alloc]initWithContentsOfFile:path];
    [m_udpSocket sendData:data
                   toHost:@"255.255.255.255"
                     port:udp_send_port
              withTimeout:-1
                      tag:1];
}

#pragma mark asyncudp delegate
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    //deal with data
    return YES;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"not receive udp data");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"not send udp data");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"send udp data success !!!");
}
#pragma mark tcp fucntion

-(BOOL)connectToServer
{
    //建立SOCKET连接
    int times = 0;
    do
    {
        m_tcpSocket = [self connectToServer:(char*)[ipAddrText.text UTF8String] port:tcp_port];//返回socket描述符
        if(m_tcpSocket > 0)
        {
            break;
        }
        else
        {
            times ++;
        }
        
        if( times > 2)
        {
            printf("3 connect failed\n");
            close(m_tcpSocket);
            //[self waitingViewStop];//20111212
            return NO;
        }
        //sleep(1);
        
    }while(m_tcpSocket <= 0);
    
    NSLog(@"connect success!");
    return YES;
}

//socket设置成非阻塞，连5.1秒，连成功后设置回阻塞
-(int)connectToServer:(char*)ip port:(int)nPort
{
    struct sockaddr_in servaddr;
    int sockfd;
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) //建立socket，并判断是否成功
    {
        perror("socket error");
        return -1;
    }
    memset(&servaddr, 0, sizeof(servaddr));//作用是在一段内存块中填充某个给定的值，它对较大的结构体或数组进行清零操作的一种最快方法。
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(tcp_port);
    if (inet_pton(AF_INET, [ipAddrText.text UTF8String], &(servaddr.sin_addr)) != 1)//inet_pton:IP地址转换函数，可以在将IP地址在“点分十进制”和“整数”之间转换
    {
        fprintf(stderr, "inet_pton error: invalid address\n");
        return -1;
    }
    //设置socket成非阻塞 方法1
    //int flags = fcntl(sockfd, F_GETFL,0);
    //fcntl(sockfd,F_SETFL, flags | O_NONBLOCK);
    
    //设置socket成非阻塞 方法2
    int flags;
    if((flags = fcntl(sockfd, F_GETFL)) < 0 )
    {
        perror("fcntl F_SETFL");
    }
    flags |= O_NONBLOCK;
    if(fcntl(sockfd, F_SETFL,flags) < 0)
    {
        perror("fcntl");
    }
    
    int connect_flag = connect(sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
    sleep(1);
    if (connect_flag >= 0)
    {
        printf("connect success 1 \n");
        //在connect成功之后，设成阻塞模式
        flags = fcntl(sockfd, F_GETFL,0);
        flags &= ~ O_NONBLOCK;
        fcntl(sockfd,F_SETFL, flags);
        
        return sockfd;
    }
    
    int error = 0;
    fd_set rest, west;
    struct timeval tm = {5,100};
    FD_ZERO(&rest);
    FD_ZERO(&west);
    FD_SET(sockfd, &rest);
    FD_SET(sockfd, &west);
    int maxpd = sockfd + 1;
    int flag = select(maxpd, &rest, &west, NULL, &tm);//监听套接的可读和可写条件
    if(flag < 0)
    {
        printf("select error 2\n");//慢系统调用可能会错误返回，这个以前提过
        flags = fcntl(sockfd, F_GETFL,0);
        flags &= ~ O_NONBLOCK;
        fcntl(sockfd,F_SETFL, flags);
        return -1;
    }
    
    if(FD_ISSET(sockfd, &rest) && FD_ISSET(sockfd, &west)) //如果套接口可写也可读，需要进一步判断
    {
        socklen_t len = sizeof(error);
        if(getsockopt(sockfd, SOL_SOCKET, SO_ERROR, &error, &len) < 0)
        {
            //exit(1);//获取SO_ERROR属性选项，当然getsockopt也有可能错误返回
            flags = fcntl(sockfd, F_GETFL,0);
            flags &= ~ O_NONBLOCK;
            fcntl(sockfd,F_SETFL, flags);
            return -1;
        }
        printf("error = %d\n", error);
        if(error != 0)
        {//如果error不为0， 则表示链接到此没有建立完成
            printf("connect failed 3\n");
            flags = fcntl(sockfd, F_GETFL,0);
            flags &= ~ O_NONBLOCK;
            fcntl(sockfd,F_SETFL, flags);
            return -1;
        }
        else  //如果error为0，则说明链接建立完成
        {
            printf("connect success 4\n");
            flags = fcntl(sockfd, F_GETFL,0);
            flags &= ~ O_NONBLOCK;
            fcntl(sockfd,F_SETFL, flags);
            
            return sockfd;
        }
    }
    
    if(FD_ISSET(sockfd, &west) && !FD_ISSET(sockfd, &rest)) //如果套接口可写不可读,则链接完成
    {
        printf("connect success 5\n");
        flags = fcntl(sockfd, F_GETFL,0);
        flags &= ~ O_NONBLOCK;
        fcntl(sockfd,F_SETFL, flags);
        
        return sockfd;
    }
    
    //在connect成功之后，设成阻塞模式
    flags = fcntl(sockfd, F_GETFL,0);
    flags &= ~ O_NONBLOCK;
    fcntl(sockfd,F_SETFL, flags);
    
    return sockfd;//成功时返回socket描述符
}

#define BUFFER_SIZE 1024
-(void)sendRecordAudioFileWithPath:(NSString*)filePath
{
    int len = [filePath length];
    char *audioFilePath = (char*)malloc(sizeof(char) * (len + 1));
    [filePath getCString:audioFilePath maxLength:len + 1 encoding:[NSString defaultCStringEncoding]];
    NSLog(@"audio file path is %s",audioFilePath);
    
    char buffer[BUFFER_SIZE];
    FILE *fp = fopen(audioFilePath, "r+");
    if (fp == NULL)
    {
        NSLog(@"File:\t%@ Not Found!\n", filePath);
    }
    else
    {
        bzero(buffer, BUFFER_SIZE);
        int file_block_length = 0;
        while( (file_block_length = fread(buffer, sizeof(char), BUFFER_SIZE, fp)) > 0)
        {
            //printf("file_block_length = %d\n", file_block_length);
            // 发送buffer中的字符串到设备端
            if (send(m_tcpSocket, buffer, file_block_length, 0) < 0)
            {
                NSLog(@"Send File:\t%@ Failed!\n", filePath);
                break;
            }
            bzero(buffer, sizeof(buffer));
        }
        fclose(fp);
        NSLog(@"File:\t%@ Transfer Finished!\n", filePath);
    }
}

*/

@end
