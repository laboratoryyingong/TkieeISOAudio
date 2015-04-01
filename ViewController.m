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

@interface ViewController ()



@end

@implementation ViewController

@synthesize MyWeb;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tkiee.com"]];
    [self.MyWeb loadRequest:request];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
