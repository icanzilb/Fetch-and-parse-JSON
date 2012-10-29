//
//  ViewController.m
//  JSONFetch
//
//  Created by Marin Todorov on 29/10/2012.
//

#import "ViewController.h"

//the JSON feed you are fetching; change this define here to another JSON url of your choice
#define kJSONURL @"http://api.kivaws.org/v1/loans/search.json?status=fundraising"

@interface ViewController ()
{
    //outlet to the text visible on screen
    IBOutlet UILabel* label;
}
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //fetch the JSON from the predefined URL
    [self fetchJSON];
}

-(IBAction)actionFetchJSON:(id)sender
{
    //the refresh button was tapped - re-fetch the JSON feed
    [self fetchJSON];
}

-(void)fetchJSON
{
    //show the user that the app is working
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    label.text = @"Loading...";
    
    //execute this block of code in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        //fetch data from the URL
        NSData* kivaData = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:kJSONURL]
                            ];

        //if data was fetched - try to parse it and turn it into an NSDictionary
        NSDictionary* json = nil;
        
        if (kivaData) {
            json = [NSJSONSerialization JSONObjectWithData:kivaData options:kNilOptions error:nil];
        }
        
        //update the UI - you have to do that on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{

            //code executed on the main queue
            [self updateUIWithDictionary: json];
        });
        
    });

}

-(void)updateUIWithDictionary:(NSDictionary*)json {
    @try {
        //cheap way to fall on the catch block, if there was no data fetched at all
        NSAssert(json, @"No JSON object fetched.");
        
        //try to fetch all the expected keys/values from the JSON
        label.text = [NSString stringWithFormat:
                      @"%@ from %@ needs %@$ %@\nYou can help by contributing as little as 25$!",
                      json[@"loans"][0][@"name"],
                      json[@"loans"][0][@"location"][@"country"],
                      json[@"loans"][0][@"loan_amount"],
                      json[@"loans"][0][@"use"],
                      nil];
    }
    @catch (NSException *exception) {
        //some of the required keys were missing
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not parse the JSON feed."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles: nil] show];
        label.text = @"There was an error fetching the JSON feed";
        NSLog(@"Exception: %@", exception);
    }
    
    //turn off the network indicator in the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
