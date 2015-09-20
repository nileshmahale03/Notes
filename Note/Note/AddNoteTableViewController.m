//
//  AddNoteTableViewController.m
//  Note
//
//  Created by Nilesh Mahale on 9/9/15.
//  Copyright (c) 2015 Nilesh Mahale. All rights reserved.
//

#import "AddNoteTableViewController.h"
#import <CoreData/CoreData.h>
#import "MasterTableViewController.h"

@interface AddNoteTableViewController ()

@end

@implementation AddNoteTableViewController

@synthesize note;

- (void)reloadFetchedResults:(NSNotification*)note {
    NSLog(@"Underlying data changed ... refreshing!");
    [self managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // core-data
    if (self.note) {
        NSLog(@"HI");
        [self.titleField setText:[self.note valueForKey:@"title"]];
        [self.textView setText:[self.note valueForKey:@"text"]];
    }

    // detect actionable data
    self.textView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.textView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
    self.textView.dataDetectorTypes = UIDataDetectorTypeAddress;
    self.textView.dataDetectorTypes = UIDataDetectorTypeCalendarEvent;
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    // iCloud
    // Refresh this view whenever data changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFetchedResults:)
                                                 name:@"SomethingChanged"
                                               object:[[UIApplication sharedApplication] delegate]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - save content once navigate back to main screen (so no need of Save Button)

-(void)viewWillDisappear:(BOOL)animated {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (self.note) {
        // Update existing Notes
        [self.note setValue:self.titleField.text forKey:@"title"];
        [self.note setValue:self.textView.text forKey:@"text"];
    } else {
        // Create a new Notes
        NSManagedObject *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
        [newNote setValue:self.titleField.text forKey:@"title"];
        [newNote setValue:self.textView.text forKey:@"text"];
        
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - cancel button

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - toggle between edit and detect mode

- (IBAction)tapDetected:(UITapGestureRecognizer *)sender {
    
    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.textView.editable = YES;
 
}

#pragma mark - share Extension

//-(void)viewWillAppear:(BOOL)animated {
//
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.code-programming.ShareExtension"];
//    self.titleField.text = [sharedDefaults objectForKey:@"stringKey"];
//}

@end


















