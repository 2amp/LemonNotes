
#import <Foundation/Foundation.h>

/**
 * Class: RiotApiUtil
 * Type: singleton api util
 * --------------------------
 * Provides a singleton util that uses NSURLSession
 * to make API calls and return the JSON data as a Dict
 */


@interface RiotApiUtil : NSObject
{
    //whatever instance variables singleton class should have
    //ex) NSString *someProperty;
}

//make instance vars a property with retain option
//ex) @property (nonatomic, retain) NSString *someProperty;


+ (RiotApiUtil *)sharedUtil;

//other instance methods
//ex) - (void)someMethod;


@end