//
//  JKViewController.m
//  JKPicker
//
//  Created by HHL110120 on 02/24/2017.
//  Copyright (c) 2017 HHL110120. All rights reserved.
//

#import "JKViewController.h"
#import "JKPicker.h"
@interface JKViewController ()

@end

@implementation JKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    JKDatePicker *datePicker = [JKDatePicker showPickerInView:self.view window:nil];
        datePicker.format = @"y-m";
        datePicker.startDateLimit = @"2012";
        datePicker.endDateLimit = @"2016";
        datePicker.startValue = @"2012-12";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
