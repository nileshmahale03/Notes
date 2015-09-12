//
//  MasterTableViewController.m
//  Note
//
//  Created by Nilesh Mahale on 9/9/15.
//  Copyright (c) 2015 Nilesh Mahale. All rights reserved.
//

#import "MasterTableViewController.h"
#import <CoreData/CoreData.h>
#import "AddNoteTableViewController.h"

@interface MasterTableViewController ()

@property (strong, nonatomic) NSMutableArray *notes;

@end

@implementation MasterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // fetch the Note from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
    self.notes = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.notes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSManagedObject *note = [self.notes objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [note valueForKey:@"title"]]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [note valueForKey:@"text"]]];
    
    return cell;
}


#pragma mark - Edit Button

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if(editing) {
        //Do something for edit mode
        NSLog(@"Editing Mode");
    }
    
    else {
        //Do something for non-edit mode
        NSLog(@"Non-Editing Mode");
    }
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSString *stringToMove = [self.notes objectAtIndex:fromIndexPath.row];
    [self.notes removeObjectAtIndex:fromIndexPath.row];
    [self.notes insertObject:stringToMove atIndex:toIndexPath.row];
}

#pragma mark - swipe to Delete Button

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [context deleteObject:[self.notes objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // remove object from table view
        [self.notes removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Segues Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"none"]) {
        NSManagedObject *selectedNote = [self.notes objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        AddNoteTableViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.note = selectedNote;
        
    }
}

#pragma mark - alternate row color

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0) {
//        cell.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:119.0/255.0 blue:34.0/255.0 alpha:1.0];
//    } else if (indexPath.row == 1) {
//        cell.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:62.0/255.0 blue:65.0/255.0 alpha:1.0];
//    } else if (indexPath.row == 2) {
//        cell.backgroundColor = [UIColor colorWithRed:177.0/255.0 green:79.0/255.0 blue:199.0/255.0 alpha:1.0];
//    } else if (indexPath.row == 3) {
//        cell.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:47.0/255.0 blue:203.0/255.0 alpha:1.0];
//    } else if (indexPath.row == 4) {
//        cell.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:168.0/255.0 blue:38.0/255.0 alpha:1.0];
//    } else if (indexPath.row == 5) {
//        cell.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:69.0/255.0 blue:23.0/255.0 alpha:1.0];
//    } else if (indexPath.row == 6) {
//        cell.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:167.0/255.0 blue:199.0/255.0 alpha:1.0];
//    } else {
//        cell.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:167.0/255.0 blue:199.0/255.0 alpha:1.0];
//    }
//}


@end











