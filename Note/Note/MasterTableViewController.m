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
#import "MasterTableViewCell.h"


@interface MasterTableViewController () <UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) NSMutableArray *notes;

@property (strong, nonatomic) NSFetchRequest *searchFetchRequest; //search bar

@property (strong, nonatomic) UISearchController *searchController; //search bar

@property (strong, nonatomic) NSArray *filteredList; //search bar

//search bar
typedef NS_ENUM(NSInteger, NotesSearchScope)
{
    searchScopeTitle = 0,
    searchScopeText = 1
};

@end

@implementation MasterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.tableView.estimatedRowHeight = 68.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //hide the search bar by default
    self.tableView.contentOffset = CGPointMake(0, 44);
    
    // no serach result
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    
    // configure the search bar
    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"Scope Title",@"Title"),
                                                          NSLocalizedString(@"Scope Text",@"Text")];
    [self.searchController.searchBar setTintColor:[UIColor whiteColor]];
    [self.searchController.searchBar setBarTintColor:[UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:53.0/255.0 alpha:0.3]];
    [[UISearchBar appearance] setTintColor:[UIColor whiteColor]];
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    // soemthing new
    [self.searchController.searchBar sizeToFit];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
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
    
    if (self.searchController.active) {
        return 1;
    } else {
        return 1;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchController.active) {
        return [self.filteredList count];
    } else {
        return self.notes.count;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSManagedObject *note = nil;
    
    if (self.searchController.active) {
        note = [self.filteredList objectAtIndex:indexPath.row];
    } else {
        note = [self.notes objectAtIndex:indexPath.row];
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [note valueForKey:@"title"]]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [note valueForKey:@"text"]]];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
        
        NSManagedObject *selectedNote = nil;
        
        if (self.searchController.active) {
            selectedNote = [self.filteredList objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        } else {
            selectedNote = [self.notes objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        }
        
        AddNoteTableViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.note = selectedNote;
        
    }
}

#pragma mark - alternate row color

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:119.0/255.0 blue:34.0/255.0 alpha:1.0];
    } else if (indexPath.row == 1) {
        cell.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:62.0/255.0 blue:65.0/255.0 alpha:1.0];
    } else if (indexPath.row == 2) {
        cell.backgroundColor = [UIColor colorWithRed:177.0/255.0 green:79.0/255.0 blue:199.0/255.0 alpha:1.0];
    } else if (indexPath.row == 3) {
        cell.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:47.0/255.0 blue:203.0/255.0 alpha:1.0];
    } else if (indexPath.row == 4) {
        cell.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:168.0/255.0 blue:38.0/255.0 alpha:1.0];
    } else if (indexPath.row == 5) {
        cell.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:69.0/255.0 blue:23.0/255.0 alpha:1.0];
    } else if (indexPath.row == 6) {
        cell.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:167.0/255.0 blue:199.0/255.0 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:167.0/255.0 blue:199.0/255.0 alpha:1.0];
    }
}


#pragma mark - share sheet

- (IBAction)longPressFired:(UILongPressGestureRecognizer *)sender {
  
    NSLog(@"Long Pressed!");
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSMutableArray *itemsToShare = [NSMutableArray array];
        
        //replace sample text's with Notes' title
        [itemsToShare addObject:@"This is sample title"];
        
        [itemsToShare addObject:@"This is sample text"];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}


#pragma mark - search bar

- (NSFetchRequest *)searchFetchRequest {
    
    if (_searchFetchRequest != nil) {
        
        return _searchFetchRequest;
    }
    
    _searchFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [_searchFetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [_searchFetchRequest setSortDescriptors:sortDescriptors];
    
    return _searchFetchRequest;
}

- (void)searchForText:(NSString *)searchText scope:(NotesSearchScope)scopeOption {
    
    if (self.managedObjectContext) {
        
        NSString *predicateFormat = @"%K CONTAINS[cd] %@";
        NSString *searchAttribute = @"title";
        
        if (scopeOption == searchScopeText) {
            
            searchAttribute = @"text";
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
        [self.searchFetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        self.filteredList = [self.managedObjectContext executeFetchRequest:self.searchFetchRequest error:&error];
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
   
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:self.searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    self.searchFetchRequest = nil;
}



@end











