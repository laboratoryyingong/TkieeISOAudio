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



- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    //Load Tkiee Website
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tkiee.com"]];
    [self.view addSubview: MyUIWeb];
    [MyUIWeb loadRequest:request];
    
    
   //initial levermeter
    self.leverlMeter.progress =0;
    
    //init recordbutton
    [self.recordButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.consolelable.numberOfLines =0;
    self.consolelable.text= @"Recording tkiee audio";
    

}

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

// Recording Delegate

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
