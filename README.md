LemonNotes
==========

## About
LemonNotes is an app that helps League of Legends summoners with the pick and ban phase.

## Style guide
This is just a preliminary style guide at the moment. More guidelines will be added as necessary.

- Indents are four spaces. Do not use tabs.
- One space after conditionals and loops. *Always* use brackets, even if there is only one statement in the body. Brackets go on a new line. ````else```` goes on a new line as well.

        if (!error)
        {
            [self.activityIndicator stopAnimating];
            for (TAPPlayer *player in NSArray *players)
            {
                NSLog(@"%@", player.name);
            }
        }
        else
        {
            NSLog(@"%@", error);
        }
An exception to new line brackets occurs with inline blocks since Xcode's autoindentation gets a little funky. For example,

        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertWithTitle:@"JSON Error" message:message];
        });
not

        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self showAlertWithTitle:@"JSON Error" message:message];
                       });

- Use dot notation for accessing and setting object properties. Do not use dot notation for calling parameterless methods.

        player.name = @"C9 LemonNation";
        [player addToPlayerArray];

- Pointers are written with a space after the type and no space before the variable pointer name.

        NSMutableArray *array = [[NSMutableArray alloc] init];

- Document all methods with an appropriate block comment indicating what the method does and any side effects or "gotchas" that may not be immediately obvious. 
All parameters and return values should be described, with the exception of obvious ones such as "- (IBAction)" and ":(UIView\*) view"
       /**
         * Method: signIn
         * Usage: called when user taps "Sign In"
         * --------------------------
         * Sets whatever is entered in signInField as summonerName.
         * If nothing is entered, shows a login error prompting the user to enter a
         * summoner name. Otherwise, makes the summoner name info API call.
         * 
         * @param <param name> - desc of what is given
         * @param <return type> - desc of what is returned
         */
In addition, use inline comments inside the method body to point out lines of interest.
