//
//  ViewController.h
//  TkieeISOAudio
//
//  Created by YIN GONG on 1/04/2015.
//  Copyright (c) 2015 YIN GONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "WebViewJavascriptBridge.h"


@class CL_AudioRecorder;
@class ASIFormDataRequest;


@interface ViewController : UIViewController

{
    //ASIFormDataRequest *request;
    
    IBOutlet UIProgressView *progressIndicator;

}

- (IBAction)uploadbtnClicked:(id)sender;
- (IBAction)toggleThrottling:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *txtlabel;

@property (strong, nonatomic) IBOutlet UIButton *upLoadBtn;

//Web Javascript Bridge usage

@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

@property (strong, nonatomic) IBOutlet UIWebView *MyWeb;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;





@end

