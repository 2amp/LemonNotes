
#import "TAPViewController.h"
#import "Constants.h"

@interface TAPViewController ()

	@property (nonatomic) NSMutableData* urlData;
	@property (nonatomic) NSString* summonerName;

@end


@implementation TAPViewController

/**
 * Method: viewDidLoad
 * Usage: called when view is loaded
 * --------------------------
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
}

/**
 * Method: didReceiveMemoryWarning
 * Usage: called when memory warning is fired
 * --------------------------
 *
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



/* ========== Controller Event Callbacks ============================== */

/**
 * Method: signIn
 * Usage: called when user taps "Sign In"
 * --------------------------
 * Sets whatever is entered in signInField as summonerName.
 * If nothing is enetered, alerts Login Error wih "Invalid Summoner Name".
 * Otherwise, calls makeApiCall.
 */
- (IBAction)signIn:(id)sender
{
	self.summonerName = self.signInField.text;
	
	if ([self.summonerName isEqual: @""])
		[self showAlertWithTitle:@"Login Error" message:@"Invalide Summoner Name"];
	else
	{
		NSString* call = @"https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/bohuim?api_key=a02d4573-4795-4568-8294-e1ac09eba851";
		[self makeApiCall:call];
	}
}



/* ========== View Alert Methods ============================== */

/**
 * Method: showAlertWithTitle:message:
 * Usage: pop alert window on screen
 * --------------------------
 * Creates an UIAlertView object with the given title & message
 * along with self as delegate, "OK" as cancel button, and no other buttons.
 * Immediately shows the window
 *
 * @param title
 * @param message
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

/**
 * Method: alerView:willDissmissWithButtonIndex
 * Usage: called when user presses a button on UIAlertView
 * --------------------------
 * Fired when "OK" button is pressed (since there are no other buttons).
 * Rests signInField to empty string.
 *
 * @param alertView
 * @param buttonIndex - index of the pressed button on the alert windows
 */
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.signInField.text = @"";
}



/* ========== API Call Methods ============================== */

/**
 * Method: makeAPICall
 * Usage: request data from Riot
 * --------------------------
 * Creates a NSURLRequest with the given callURL.
 * Makes a connection with that request and callback delegate as self.
 * 
 * @param callURL - string containing the API call as defined by Riot
 */
- (void)makeApiCall:(NSString *)callURL
{
	NSURLRequest* request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:callURL]];
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 * Mehtod: connection:didReceiveResponse
 * Usage: NSURLConnection callback when response is given
 * --------------------------
 * Initializes urlData
 * 
 * @param connection
 * @param response - response object of the connection
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.urlData = [[NSMutableData alloc] init];
}

/**
 * Mehtod: connection:didReceiveData
 * Usage: NSURLConnection callback when data is given
 * --------------------------
 * Everytime data is provided, it is appended to urlData.
 *
 * @param connection
 * @param data - NSData of data from connection
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.urlData appendData:data];
}

/**
 * Method: connectionDidFinishLoading:connection
 * Usage: NSURLConnection callback when connection is done
 * --------------------------
 * NSError object jsonParsingError is initialized as nil.
 * NSJSONSerialization is called to convert urlData(json) into NSDictionary,
 * with 0 options, and any errors reported to jsonParsingError.
 * If there's an error, show it in an alert window.
 * Otherwise, show the summonerName as title and summonerLevel as message.
 * 
 * @param connection
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSError* jsonParsingError = nil;
	NSDictionary* data = [NSJSONSerialization JSONObjectWithData:self.urlData options:0 error:&jsonParsingError];
	
	if (jsonParsingError)
		[self showAlertWithTitle:@"JSON Error" message:[jsonParsingError localizedDescription]];
	else
		[self showAlertWithTitle:self.summonerName
						 message:[NSString stringWithFormat:@"Level: %@", data[self.summonerName][@"summonerLevel"]] ];
}


@end
