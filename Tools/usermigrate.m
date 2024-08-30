#import <Foundation/Foundation.h>

void migrateUser(NSString *username) {
    NSString *homeDir = [NSString stringWithFormat:@"/home/%@", username];
    NSString *usersDir = @"/Users";
    NSString *newHomeDir = [NSString stringWithFormat:@"%@/%@", usersDir, username];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Create /Users directory if it doesn't exist
    if (![fileManager fileExistsAtPath:usersDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:usersDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Error creating /Users directory: %@", [error localizedDescription]);
            return;
        } else {
            NSLog(@"Created /Users directory.");
        }
    }

    // Check if the user's home directory exists
    if (![fileManager fileExistsAtPath:homeDir]) {
        NSLog(@"User's home directory does not exist in /home.");
        return;
    }

    // Move the user's home directory
    NSError *moveError = nil;
    if ([fileManager moveItemAtPath:homeDir toPath:newHomeDir error:&moveError]) {
        NSLog(@"Successfully moved %@ to %@", homeDir, newHomeDir);
        
        // Update /etc/passwd
        NSString *passwdPath = @"/etc/passwd";
        NSString *passwdContents = [NSString stringWithContentsOfFile:passwdPath encoding:NSUTF8StringEncoding error:nil];
        NSString *updatedPasswdContents = [passwdContents stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:", homeDir]
                                                                                    withString:[NSString stringWithFormat:@"%@:", newHomeDir]];
        [updatedPasswdContents writeToFile:passwdPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"Updated /etc/passwd to reflect new home directory.");
    } else {
        NSLog(@"Error moving home directory: %@", [moveError localizedDescription]);
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc != 2) {
            NSLog(@"Usage: usermigrate <username>");
            return 1;
        }
        
        NSString *username = [NSString stringWithUTF8String:argv[1]];
        migrateUser(username);
    }
    return 0;
}
