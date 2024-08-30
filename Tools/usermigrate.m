#import <Foundation/Foundation.h>
#include <sys/utsname.h>
#include <pwd.h>
#include <grp.h>

// Function to determine if the system is FreeBSD
BOOL isFreeBSD() {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *osName = [NSString stringWithUTF8String:systemInfo.sysname];
    return [osName isEqualToString:@"FreeBSD"];
}

// Function to run pwd_mkdb with hardcoded path and arguments (only for FreeBSD)
BOOL runPwdMkdb() {
    if (!isFreeBSD()) {
        NSLog(@"pwd_mkdb is not applicable on non-FreeBSD systems.");
        return NO;
    }

    // Change the working directory to root to avoid issues with the current directory
    if (![[NSFileManager defaultManager] changeCurrentDirectoryPath:@"/"]) {
        NSLog(@"Failed to change directory to /");
        return NO;
    }

    // Hardcoded path and arguments for pwd_mkdb
    NSString *pwdMkdbPath = @"/usr/sbin/pwd_mkdb";
    NSArray *arguments = @[@"-p", @"/etc/master.passwd"];

    NSTask *pwdMkdbTask = [[NSTask alloc] init];
    [pwdMkdbTask setLaunchPath:pwdMkdbPath];
    [pwdMkdbTask setArguments:arguments];

    NSLog(@"Launching pwd_mkdb with path: %@ and arguments: %@", pwdMkdbPath, arguments);

    [pwdMkdbTask setEnvironment:@{ @"PATH" : @"/usr/sbin:/usr/bin:/bin:/sbin" }];

    NSPipe *pipe = [NSPipe pipe];
    [pwdMkdbTask setStandardOutput:pipe];
    [pwdMkdbTask setStandardError:pipe];

    NSFileHandle *file = [pipe fileHandleForReading];

    @try {
        [pwdMkdbTask launch];
        [pwdMkdbTask waitUntilExit];
    } @catch (NSException *exception) {
        NSLog(@"Failed to launch pwd_mkdb: %@", exception);
        return NO;
    }

    NSData *outputData = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];

    if ([pwdMkdbTask terminationStatus] == 0) {
        NSLog(@"Successfully rebuilt the user database using pwd_mkdb.");
        return YES;
    } else {
        NSLog(@"Failed to rebuild the user database using pwd_mkdb. Output: %@", output);
        return NO;
    }
}

// Function to change ownership of the new home directory
BOOL changeOwnership(NSString *path, NSString *username) {
    struct passwd *pw = getpwnam([username UTF8String]);
    if (pw == NULL) {
        NSLog(@"Failed to get user information for %@", username);
        return NO;
    }

    uid_t uid = pw->pw_uid;
    gid_t gid = pw->pw_gid;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = @{ NSFileOwnerAccountID: @(uid),
                                  NSFileGroupOwnerAccountID: @(gid) };

    NSError *error = nil;
    BOOL success = [fileManager setAttributes:attributes ofItemAtPath:path error:&error];

    if (!success) {
        NSLog(@"Failed to change ownership of %@: %@", path, [error localizedDescription]);
    } else {
        NSLog(@"Successfully changed ownership of %@ to %@:%@", path, username, username);
    }

    return success;
}

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

            // Change ownership of the new home directory
            if (!changeOwnership(newHomeDir, username)) {
                NSLog(@"Failed to set correct ownership for the new home directory.");
                return;
            }

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

    // Check if /etc/passwd still contains the old home directory entry
    NSString *passwdPath = @"/etc/passwd";
    NSError *passwdReadError = nil;
    NSString *passwdContents = [NSString stringWithContentsOfFile:passwdPath encoding:NSUTF8StringEncoding error:&passwdReadError];

    if (passwdReadError) {
        NSLog(@"Error reading %@: %@", passwdPath, [passwdReadError localizedDescription]);
        return;
    }

    NSString *oldHomeDirString = [NSString stringWithFormat:@":%@:", homeDir];
    NSString *newHomeDirString = [NSString stringWithFormat:@":%@:", newHomeDir];

    if ([passwdContents containsString:oldHomeDirString]) {
        NSLog(@"Old home directory entry still exists in /etc/passwd, updating /etc/master.passwd and retrying...");

        if (isFreeBSD()) {
            // Update /etc/master.passwd if needed
            NSString *masterPasswdPath = @"/etc/master.passwd";
            NSError *masterReadError = nil;
            NSString *masterPasswdContents = [NSString stringWithContentsOfFile:masterPasswdPath encoding:NSUTF8StringEncoding error:&masterReadError];

            if (masterReadError) {
                NSLog(@"Error reading %@: %@", masterPasswdPath, [masterReadError localizedDescription]);
                return;
            }

            if ([masterPasswdContents containsString:oldHomeDirString]) {
                NSString *updatedMasterPasswdContents = [masterPasswdContents stringByReplacingOccurrencesOfString:oldHomeDirString
                                                                                                       withString:newHomeDirString];
                NSError *masterWriteError = nil;
                [updatedMasterPasswdContents writeToFile:masterPasswdPath atomically:YES encoding:NSUTF8StringEncoding error:&masterWriteError];

                if (masterWriteError) {
                    NSLog(@"Error updating %@: %@", masterPasswdPath, [masterWriteError localizedDescription]);
                    return;
                } else {
                    NSLog(@"Updated /etc/master.passwd to reflect new home directory.");
                }
            }
        } else {
            // Update /etc/passwd directly on Linux
            NSString *updatedPasswdContents = [passwdContents stringByReplacingOccurrencesOfString:oldHomeDirString
                                                                                       withString:newHomeDirString];
            NSError *passwdWriteError = nil;
            [updatedPasswdContents writeToFile:passwdPath atomically:YES encoding:NSUTF8StringEncoding error:&passwdWriteError];

            if (passwdWriteError) {
                NSLog(@"Error updating /etc/passwd: %@", [passwdWriteError localizedDescription]);
                return;
            } else {
                NSLog(@"Updated /etc/passwd to reflect new home directory.");
                return;
            }
        }

        // Retry running pwd_mkdb to update /etc/passwd
        if (isFreeBSD()) {
            BOOL success = NO;
            int attempts = 0;
            const int maxAttempts = 5; // Retry up to 5 times

            while (attempts < maxAttempts) {
                success = runPwdMkdb();

                // Recheck if /etc/passwd is updated successfully
                NSError *checkError = nil;
                NSString *checkPasswdContents = [NSString stringWithContentsOfFile:@"/etc/passwd"
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:&checkError];

                if (checkError) {
                    NSLog(@"Error reading /etc/passwd: %@", [checkError localizedDescription]);
                    break;
                }

                if (![checkPasswdContents containsString:oldHomeDirString]) {
                    NSLog(@"Successfully updated /etc/passwd.");
                    break;
                }

                NSLog(@"Retrying pwd_mkdb as /etc/passwd still contains the old entry...");
                attempts++;
            }

            if (!success) {
                NSLog(@"Failed to update /etc/passwd after %d attempts.", maxAttempts);
            }
        }
    } else {
        NSLog(@"Home directory entry not found in /etc/passwd or already updated.");
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