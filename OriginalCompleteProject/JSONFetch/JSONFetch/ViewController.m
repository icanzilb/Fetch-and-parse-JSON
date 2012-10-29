//
//  ViewController.m
//  JSONFetch
//
//  Created by Marin Todorov on 29/10/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    IBOutlet UILabel* label;
}
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //code executed in the background
        //2
        NSData* kivaData = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"]
                            ];
        //3
        NSDictionary* json = nil;
        if (kivaData) {
            json = [NSJSONSerialization
                    JSONObjectWithData:kivaData
                    options:kNilOptions
                    error:nil];
        }
        
        //4
        dispatch_async(dispatch_get_main_queue(), ^{
            //code executed on the main queue
            //5
            [self updateUIWithDictionary: json];
        });
        
    });

}

-(void)updateUIWithDictionary:(NSDictionary*)json {
    @try {
        label.text = [NSString stringWithFormat:
                      @"%@ from %@ needs %@ %@\nYou can help by contributing as little as 25$!",
                      json[@"loans"][0][@"name"],
                      json[@"loans"][0][@"location"][@"country"],
                      json[@"loans"][0][@"loan_amount"],
                      json[@"loans"][0][@"use"],
                      nil];
    }
    @catch (NSException *exception) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not parse the JSON feed."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles: nil] show];
        NSLog(@"Exception: %@", exception);
    }
}

@end
