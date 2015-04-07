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

@property (strong, nonatomic) IBOutlet UILabel *consolelable;

@property (strong, nonatomic) IBOutlet UIButton *recordButton;

@property (nonatomic,copy) NSString *filename;

-(IBAction)recordButtonClicked:(id)sender;

@property (nonatomic,assign) BOOL isRecording;

@end



@implementation ViewController

@synthesize MyWeb;
@synthesize activityIndicator;



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
    //Tkiee Website
    NSURL *websiteUrl=[NSURL URLWithString:@"http://www.tkiee.com"];
    NSURLRequest *request=[NSURLRequest requestWithURL:websiteUrl];
    //[self.view addSubview:MyWeb ];
    [MyWeb loadRequest:request];
    
    self.consolelable.numberOfLines =2;
    self.consolelable.text= @"Recording Tkiee Audio";
    
    //initial levermeter
     self.leverlMeter.progress = 0;
    
    //init recordbutton
    [self.recordButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [self removeObserver:self forKeyPath:@"isRecording"];
    [MyWeb release];
    [activityIndicator release];
    [super dealloc];
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









@end
