//
//  ViewController.h
//  TkieeISOAudio
//
//  Created by YIN GONG on 1/04/2015.
//  Copyright (c) 2015 YIN GONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"

@class CL_AudioRecorder;

#define kRecorderDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]  stringByAppendingPathComponent:@"Recorders"]


@interface ViewController : UIViewController
{
    AsyncUdpSocket   *m_udpSocket;
    int              m_tcpSocket;

}

@property (strong, nonatomic) IBOutlet UIWebView *MyUIWeb;

@property (strong, nonatomic) IBOutlet UIButton *udpSendBtn;

- (IBAction)udpSendAction:(id)sender;





@end

