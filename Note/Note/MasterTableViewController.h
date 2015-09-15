//
//  MasterTableViewController.h
//  Note
//
//  Created by Nilesh Mahale on 9/9/15.
//  Copyright (c) 2015 Nilesh Mahale. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MasterTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;

- (IBAction)longPressFired:(UILongPressGestureRecognizer *)sender;

@end

