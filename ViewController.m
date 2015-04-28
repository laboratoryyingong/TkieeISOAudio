//
//  ViewController.m
//  TkieeISOAudio
//
//  Created by YIN GONG on 1/04/2015.
//  Copyright (c) 2015 YIN GONG. All rights reserved.
//

#import "ViewController.h"
#import "RecorderManager.h"
#import "ASIFormDataRequest.h"
#import "PlayerManager.h"

#import <stdio.h>
#import <stdlib.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <string.h>
#import <fcntl.h>
#import <CoreAudio/CoreAudioTypes.h>

#include <sys/time.h>
#include <time.h>




@interface ViewController () <RecordingDelegate>


@property (strong, nonatomic) IBOutlet UIProgressView *leverlMeter;

@property (strong, nonatomic) IBOutlet UILabel *consolelable;


@property (strong, nonatomic) IBOutlet UIButton *recordButton;

-(IBAction)recordButtonClicked:(id)sender;


@property (nonatomic,copy) NSString *filename;

@property (nonatomic,assign) BOOL isRecording;



// define two methods to deal with file upload successfully

-(void)uploadFailed:(ASIHTTPRequest *)theRequest;
-(void)uploadFinished:(ASIHTTPRequest *)theRequest;




@end



@implementation ViewController


@synthesize MyWeb;
@synthesize activityIndicator;
@synthesize upLoadBtn;
@synthesize txtlabel;


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
    //NSURL *websiteUrl=[NSURL URLWithString:@"http://10.233.48.110:8080/login"];
    
    NSURL *websiteUrl=[NSURL URLWithString:@"http://www.tkiee.com/login"];
    NSURLRequest *myrequest=[NSURLRequest requestWithURL:websiteUrl];
    //[self.view addSubview:MyWeb ];
    [self.MyWeb loadRequest:myrequest];
    
    self.consolelable.numberOfLines =0;
    self.consolelable.text= @"Recording Tkiee Audio";
    
    //initial levermeter
    self.leverlMeter.progress = 0;
    
    //init recordbutton
    [self.recordButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    //upload button
    
    progressIndicator.progress=0;
    
    [self.upLoadBtn addTarget:self action:@selector(uploadbtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    

    
}


-(void)viewDidUnload
{
    [self setTxtlabel:nil];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// upload button

- (IBAction)uploadbtnClicked:(id)sender
{
    
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://localhost:80/upload.php"]];
    [request setTimeOutSeconds:20];
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
    #endif
    
    [request setUploadProgressDelegate:progressIndicator];
    
    //set up delegate
    [request setDelegate:self];
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];

    
    NSFileManager *fileManeger=[NSFileManager defaultManager];
    
    // check files exist
    if([fileManeger fileExistsAtPath:self.filename])
    {
        NSLog(@"******Recording files exist******");
    }
    
    else
    {
        NSLog(@"******Recording files lost*****");
    }
    
    NSLog(@"%@",self.filename);
    
    //upload files
    
    [request setFile:self.filename forKey:@"file"];
    
    [request startAsynchronous];
    [self.txtlabel setText:@"Uploading data..."];
    
    
}

- (IBAction)toggleThrottling:(id)sender
{
    [ASIHTTPRequest setShouldThrottleBandwidthForWWAN:[(UISwitch *)sender isOn]];
}


- (void)uploadFailed:(ASIHTTPRequest *)theRequest
{
    [self.txtlabel setText:[NSString stringWithFormat:@"Request failed:\r\n%@",[[theRequest error] localizedDescription]]];
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest
{
    [self.txtlabel setText:[NSString stringWithFormat:@"Finished uploading %llu bytes of data",[theRequest postLength]]];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    // Clear out the old notification before scheduling a new one.
    if ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] > 0)
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // Create a new notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        [notification setFireDate:[NSDate date]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [notification setRepeatInterval:0];
        [notification setSoundName:@"alarmsound.caf"];
        [notification setAlertBody:@"Boom!\r\n\r\nUpload is finished!"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
#endif
    
    
    
    NSLog(@"successful");
//  NSLog([NSString stringWithFormat:@"transfer %llu ",[theRequest postLength]]);
    
    
    NSMutableDictionary *headerData=[theRequest requestHeaders];
    NSLog(@"%@",headerData);
    NSLog(@"all keys：%@",headerData.allKeys);
    NSLog(@"all values：%@",headerData.allValues);
    NSLog(@"User-Agent:%@",[headerData objectForKey:@"User-Agent"]);
    NSLog(@"Content-Type:%@",[headerData objectForKey:@"Content-Type"]);
    NSLog(@"Content-Length:%@",[headerData objectForKey:@"Content-Length"]);
    NSLog(@"Accept-Encoding:%@",[headerData objectForKey:@"Accept-Encoding"]);
    
    NSString *requestData=[theRequest responseString];
    NSLog(@"%@",requestData);
    //[txt setText:requestData];
    
    NSData *udata=[theRequest responseData];
    NSStringEncoding encodeUdata=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString *getUserData=[[NSString alloc] initWithData:udata encoding:encodeUdata];
    NSLog(@"%@",getUserData);
}





-(void)didReceiveMemoryWarning {
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
        if (![keyPath isEqualToString:@"isRecording"])
        {[self.upLoadBtn setTitle:(self.isRecording? @"May Upload":@"Not Upload") forState:UIControlStateNormal];
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

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval
{
    self.isRecording = NO;
    self.leverlMeter.progress = 0;
    self.filename = filePath;
    
    [self.consolelable performSelectorOnMainThread:@selector(setText:)
                                        withObject:[NSString stringWithFormat:@"Recording Finished: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]]
                                     waitUntilDone:NO];
}

- (void)recordingTimeout
{
    self.isRecording = NO;
    self.consolelable.text = @"OverTime";
}

- (void)recordingStopped
{
    self.isRecording = NO;
}

- (void)recordingFailed:(NSString *)failureInfoString
{
    self.isRecording = NO;
    self.consolelable.text = @"Recording failer";
}

- (void)levelMeterChanged:(float)levelMeter
{
    self.leverlMeter.progress = levelMeter;
}













@end
