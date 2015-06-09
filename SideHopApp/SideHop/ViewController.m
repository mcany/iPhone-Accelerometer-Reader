//
//  ViewController.m
//  SideHop
//
//  Created by Mertcan Yigin on 3/31/15.
//  Copyright (c) 2015 Mertcan Yigin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

float const kDataFrequency = 1.0f / 60.0f;
double const threshholdAccX = .85;
double const threshholdAccY = 0.6;
double const threshholdAccZ = .87;

bool thresholdX = true;
bool thresholdY = true;
bool thresholdZ = true;
int hopCountX = 0;
int hopCountY = 0;
int hopCountZ = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    countX.text = [NSString stringWithFormat:@"%.2f", 0.0];
    countY.text = [NSString stringWithFormat:@"%.2f", 0.0];
    countZ.text = [NSString stringWithFormat:@"%.2f", 0.0];
    
    self.accX.text = [NSString stringWithFormat:@"%.2f", 0.0];
    self.accY.text = [NSString stringWithFormat:@"%.2f", 0.0];
    self.accZ.text = [NSString stringWithFormat:@"%.2f", 0.0];
    
    [self.recordButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    
    [self.loadButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [self.loadButton setTitle:@"Load" forState:UIControlStateNormal];
    
    [self.fileName setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    self.fileName.text = @"test5.txt";
    [self.fileName setDelegate:self];
    
    [self updateButtonText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.fileName resignFirstResponder];
    return YES;
}

- (void)updateButtonText{
    if ([self.recordButton.currentTitle  isEqual: @"Button"] || [self.recordButton.currentTitle  isEqual: @"Stop"]  ) {
        [self.recordButton setTitle:@"Start" forState:UIControlStateNormal ];
        [self.motionManager stopDeviceMotionUpdates];
        self.motionManager = nil;
        [self persistAccelerometerValues];
        //gyroCount = 0;
        accCount = 0;
    } else {
        [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal ];
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.deviceMotionUpdateInterval = kDataFrequency;
        
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:[NSOperationQueue currentQueue]
                                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
                                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                                            }];
    }
}

- (IBAction)loadButtonTapped:(UIButton *)sender{
    //NSLog(@"Load Button Tapped!");
    [self loadAccelerometerData];
}

- (IBAction)recordButtonTapped:(UIButton *)sender {
    //NSLog(@"Record Button Tapped!");
    [self updateButtonText];
}

-(void)handleDeviceMotion:(CMDeviceMotion*)motion{
    
    if(accCount > MAX_FEATURES_VALUES)
    {
        NSLog(@"MAX VALUE ACHIEVED!");
        [self updateButtonText];
    }
    
    CMAttitude *attitude = motion.attitude;
    
    CMAcceleration userAcceleration = motion.userAcceleration;
    accCount++;
    //gyroValues[gyroCount] = attitude;
    accValues[accCount] = userAcceleration;
//    printf("%u", accCount);
//    
//    roll.text = [NSString stringWithFormat:@"%f", attitude.roll];
//    
//    pitch.text = [NSString stringWithFormat:@"%f", attitude.pitch];
//    
//    yaw.text = [NSString stringWithFormat:@"%f", attitude.yaw];
//    
//    self.accX.text = [NSString stringWithFormat:@"%f", userAcceleration.x];
//    
//    self.accY.text = [NSString stringWithFormat:@"%f", userAcceleration.y];
//    
//    self.accZ.text = [NSString stringWithFormat:@"%f", userAcceleration.z];
}

-(void) persistAccelerometerValues {
    
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:&accCount length:sizeof(int)];
    
    [data appendBytes:accValues length:accCount * sizeof(CMAcceleration)];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * fileName = self.fileName.text;
    //NSString * fileName = @"test3.txt";
    
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    [data writeToFile:appFile atomically:YES];
}

-(void) loadAccelerometerData{
    
    NSString * fileName = self.fileName.text;
    //NSString * fileName = @"test1.txt";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSData * data = [NSMutableData dataWithContentsOfFile:appFile];
    
    int count = ((int*) data.bytes)[0];
    
    //accelerometer
    CMAcceleration * accelerometerData = (CMAcceleration*)((int*)data.bytes + 1);
    [self printAccelerometerData:accelerometerData count:count prefix:'g'];
}

-(void)rawDataAlgorithm: (CMAcceleration*)data count:(NSInteger) count
{
    
    for (int i = 0; i < count-1; i++) {
        if(data[i].y < threshholdAccY && thresholdY)
        {
            hopCountY++;
            thresholdY = false;
        }
        else if (data[i].y > 0 && !thresholdY)
        {
            thresholdY = true;
        }
         printf("%f,  ", data[i].y );
    }
    
    printf("hop countY %d;\n",hopCountY);
    countY.text = [NSString stringWithFormat:@"%d", hopCountY];
}

-(double*)lowPassFilter2: (CMAcceleration*)data count:(NSInteger) count
{
    double rate = 60;
    double freq = 5;
    
    double dt = 1.0 / rate;
    double RC = 1.0 / freq;
    double alpha = dt / (dt + RC);
    
    double filteredData[count-1];
    printf("filtered data\n");
    
    for (int i = 1; i < count; i++) {
        filteredData[i-1] = alpha * data[i].y + (1-alpha) * data[i-1].y;
        printf("%f, ",filteredData[i-1] );
    }
    
    return filteredData;
}


-(void)lowPassFilter: (CMAcceleration*)data count:(NSInteger) count
{
    double rate = 60;
    double freq = 5;
    double dt = 1.0 / rate;
    double RC = 1.0 / freq;
    double alpha = dt / (dt + RC);
    
    for (int i = 1; i < count; i++) {
        double accData = alpha * data[i].y + (1-alpha) * data[i-1].y;
        
        if(accData > threshholdAccY && thresholdY)
        {
            hopCountY++;
            thresholdY = false;
        }
        else if (accData < 0 && !thresholdY)
        {
            thresholdY = true;
        }
        printf("%f,  ", data[i].y );
    }
    
    printf("lowpass hop countY %d;\n",hopCountY);
    countY.text = [NSString stringWithFormat:@"%d", hopCountY];
}

-(void)movingWindowDataAlgorithm: (CMAcceleration*)data count:(NSInteger) count
{
    for (int i = 1; i < count-1; i=i+3) {
        double accData = (data[i-1].y / 4) + (data[i].y / 2) + (data[i+1].y / 4);
        if(accData > threshholdAccY && thresholdY)
        {
            hopCountY++;
            thresholdY = false;
        }
        else if (accData < 0 && !thresholdY)
        {
            thresholdY = true;
        }
         printf("%f,  ", data[i].y );
    }
    printf("moving hop countY %d;\n",hopCountY);
    countY.text = [NSString stringWithFormat:@"%d", hopCountY];
}

-(void) printAccelerometerData:(CMAcceleration*) data count:(NSInteger) count prefix:(char) prefix{
   
     //printf("Raw Data");
    //[self rawDataAlgorithm:data count:count];
     //printf("Moving Window");
    hopCountX = 0;
    hopCountY = 0;
    hopCountZ = 0;
    thresholdY = true;
    //[self movingWindowDataAlgorithm:data count:count];
    thresholdY = true;
    hopCountX = 0;
    hopCountY = 0;
    hopCountZ = 0;
    //[self lowPassFilter2:data count:count];
    
    /*
    printf("%cx = [",prefix);
    for (int i = 0; i < count-1; i++) {
        if(data[i].x > threshholdAccX && thresholdX)
        {
            hopCountX++;
            thresholdX = false;
        }
        else if (data[i].x < 0 && !thresholdX)
        {
            thresholdX = true;
        }
        printf("%f,  ", data[i].x);
    }
    printf("%f];\n",data[count-1].x );
    */
    printf("\n%cy = [",prefix);
    for (int i = 0; i < count-1; i++) {

        if(data[i].y < threshholdAccY && thresholdY)
        {
            hopCountY++;
            thresholdY = false;
        }
        else if (data[i].y > 0 && !thresholdY)
        {
            thresholdY = true;
        }
     
        printf("%f,  ", data[i].y );
    }
    printf("%f];\n",data[count-1].y );
    /*
    printf("%cz = [",prefix);
    for (int i = 0; i < count-1; i++) {
        if(data[i].z > threshholdAccZ && thresholdZ)
        {
            hopCountZ++;
            thresholdZ = false;
        }
        else if (data[i].z < 0 && !thresholdZ)
        {
            thresholdZ = true;
        }

        printf("%f,  ", data[i].z);
    }
    printf("%f];\n",data[count-1].z);
     */
    /*
    printf("hop countX %d;\n",hopCountX);
    countX.text = [NSString stringWithFormat:@"%d", hopCountX];
    printf("hop countY %d;\n",hopCountY);
    countY.text = [NSString stringWithFormat:@"%d", hopCountY];
    printf("hop countZ %d;\n",hopCountZ);
    countZ.text = [NSString stringWithFormat:@"%d", hopCountZ];
     */
    hopCountX = 0;
    hopCountY = 0;
    hopCountZ = 0;
}

@end
