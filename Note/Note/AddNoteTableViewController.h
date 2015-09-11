//
//  AddNoteTableViewController.h
//  Note
//
//  Created by Nilesh Mahale on 9/9/15.
//  Copyright (c) 2015 Nilesh Mahale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AddNoteTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *titleField;

@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) NSManagedObject *note;

- (IBAction)save:(id)sender;

@end

