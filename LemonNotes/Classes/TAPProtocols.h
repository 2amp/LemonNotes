
/**
 * Protocol: TAPHasLoadingState
 * Type: protocol for ViewControllers that have a loading state
 * --------------------------
 * Protocol for class that uses any type of loading state (ex. using activity indicators).
 *
 * A data retrieval class, such as one that uses NSURLSession,
 * can tell a TAPHasLoadingState to enter loading when download starts,
 * and tell it to end loading state when download finishes.
 */
@protocol TAPHasLoadingState <NSObject>

- (void)enterLoadingState;
- (void)exitLoadingState;

@end
