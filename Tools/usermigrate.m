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

    // Check if the user's home directory has already been moved
    if ([fileManager fileExistsAtPath:newHomeDir]) {
        NSLog(@"User's home directory is already at the new location: %@", newHomeDir);
        // Proceed to update /etc/passwd or /etc/master.passwd directly
    } else {
        // Check if the user's home directory exists in the old location
        if (![fileManager fileExistsAtPath:homeDir]) {
            NSLog(@"User's home directory does not exist in /home.");
            return;
        }

        // Copy the user's home directory
        NSError *copyError = nil;
        if ([fileManager copyItemAtPath:homeDir toPath:newHomeDir error:&copyError]) {
            NSLog(@"Successfully copied %@ to %@", homeDir, newHomeDir);
            
            // Delete all files in the old home directory without removing the dataset
            NSError *contentsError = nil;
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:homeDir error:&contentsError];
            
            if (contentsError) {
                NSLog(@"Error reading contents of old home directory: %@", [contentsError localizedDescription]);
            } else {
                for (NSString *file in contents) {
                    NSError *deleteError = nil;
                    NSString *filePath = [homeDir stringByAppendingPathComponent:file];
                    if (![fileManager removeItemAtPath:filePath error:&deleteError]) {
                        NSLog(@"Error deleting file %@: %@", filePath, [deleteError localizedDescription]);
                    } else {
                        NSLog(@"Deleted file: %@", filePath);
                    }
                }
            }
        } else {
            NSLog(@"Error copying home directory: %@", [copyError localizedDescription]);
            return;
        }
    }

    // Detect whether /etc/master.passwd exists
    NSString *masterPasswdPath = @"/etc/master.passwd";
    NSString *passwdPath;
    BOOL isMasterPasswd = NO;

    if ([fileManager fileExistsAtPath:masterPasswdPath]) {
        passwdPath = masterPasswdPath;
        isMasterPasswd = YES;
        NSLog(@"Detected FreeBSD system with /etc/master.passwd.");
    } else {
        passwdPath = @"/etc/passwd";
    }

    // Update the appropriate password file
    NSError *readError = nil;
    NSString *passwdContents = [NSString stringWithContentsOfFile:passwdPath encoding:NSUTF8StringEncoding error:&readError];

    if (readError) {
        NSLog(@"Error reading %@: %@", passwdPath, [readError localizedDescription]);
        return;
    }

    // Create the exact strings to replace and their replacements
    NSString *oldHomeDirString = [NSString stringWithFormat:@":%@:", homeDir]; // Including ':' to ensure the exact match
    NSString *newHomeDirString = [NSString stringWithFormat:@":%@:", newHomeDir];

    // Check if oldHomeDirString exists in passwdContents before replacing
    if ([passwdContents containsString:oldHomeDirString]) {
        NSString *updatedPasswdContents = [passwdContents stringByReplacingOccurrencesOfString:oldHomeDirString
                                                                                    withString:newHomeDirString];

        NSError *writeError = nil;
        [updatedPasswdContents writeToFile:passwdPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];

        if (writeError) {
            NSLog(@"Error updating %@: %@", passwdPath, [writeError localizedDescription]);
        } else {
            NSLog(@"Updated %@ to reflect new home directory.", passwdPath);

            // If using master.passwd, run pwd_mkdb to rebuild the user database
            if (isMasterPasswd) {
                NSTask *pwdMkdbTask = [[NSTask alloc] init];
                [pwdMkdbTask setLaunchPath:@"/usr/sbin/pwd_mkdb"];
                [pwdMkdbTask setArguments:@[@"-p", masterPasswdPath]];
                
                [pwdMkdbTask launch];
                [pwdMkdbTask waitUntilExit];
                
                if ([pwdMkdbTask terminationStatus] == 0) {
                    NSLog(@"Successfully rebuilt the user database using pwd_mkdb.");
                } else {
                    NSLog(@"Failed to rebuild the user database using pwd_mkdb.");
                }
            }
        }
    } else {
        NSLog(@"Home directory entry not found in %@ or already updated.", passwdPath);
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