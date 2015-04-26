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


@class CL_AudioRecorder;


@interface ViewController : UIViewController <ASIHTTPRequestDelegate>

@property (nonatomic,copy)NSString *m_auth;

@property (strong, nonatomic) IBOutlet UIWebView *MyWeb;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;





@end

