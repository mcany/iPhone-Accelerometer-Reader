//
//  ViewController.h
//  SideHop
//
//  Created by Mertcan Yigin on 3/31/15.
//  Copyright (c) 2015 Mertcan Yigin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


#define MAX_FEATURES_VALUES 100000

@interface ViewController : UIViewController
{
    IBOutlet UILabel *countX;
    IBOutlet UILabel *countY;
    IBOutlet UILabel *countZ;
    
    //unsigned int gyroCount;
    unsigned int accCount;
    
    CMAcceleration accValues[MAX_FEATURES_VALUES];
}

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet UITextField *fileName;


@property (strong, nonatomic) IBOutlet UILabel *accX;
@property (strong, nonatomic) IBOutlet UILabel *accY;
@property (strong, nonatomic) IBOutlet UILabel *accZ;



- (IBAction)recordButtonTapped:(UIButton *)sender;
- (IBAction)loadButtonTapped:(UIButton *)sender;


@end

