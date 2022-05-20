//
//  main.m
//  homebrusb
//
//  Created by MiniExploit on 1/24/22.
//

#import <Foundation/Foundation.h>

void checklibusb(void) {
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/local/lib/libusb-1.0.0.dylib"]){
        printf("libusb was already installed, exiting...\n");
        exit(0);
    }
}

NSString *downloadfile(NSString *file, NSString *tempfilename) {
    NSTask *dl = [[NSTask alloc] init];
    NSString *tempdir = [NSString stringWithFormat:@"%@", NSTemporaryDirectory()];
    NSString *tempfile = [tempdir stringByAppendingString:tempfilename];
    dl.launchPath = @"/usr/bin/curl";
    dl.arguments = @[@"-Lo", tempfile, file];
    NSPipe * out = [NSPipe pipe];
    [dl setStandardError:out];
    [dl setStandardOutput:out];
    [dl launch];
    [dl waitUntilExit];
    if([dl terminationStatus] != 0) {
        printf("[ERROR] An error occured while downloading files. Exiting.\n");
        exit(-1);
    }
    return tempfile;
}

void copytolocation(NSString *path, NSString *dest) {
    if(![[NSFileManager defaultManager] moveItemAtPath:path toPath:dest error:nil]){printf("[ERROR] Failed to install libusb component. Exiting.\n");exit(1);};
}

void print_help() {
    printf("usage: homebrusb [options]\n");
    printf("Homebrusb - libusb installer for macOS\n");
    printf("options:\n");
    printf("    install\t\t\tInstall libusb\n");
    printf("    uninstall\t\t\tUninstall libusb\n");
    exit(1);
}

void createDir(NSString *dirname) {
    if(![[NSFileManager defaultManager] createDirectoryAtPath:dirname withIntermediateDirectories:YES attributes:nil error:nil]) {
        printf("[ERROR] Failed to create directory for components. Exiting.\n");
        exit(2);
    }
}

void removeFile(NSString *filename) {
    if(![[NSFileManager defaultManager] removeItemAtPath:filename error:nil]) {
        printf("[ERROR] An error occured while uninstalling libusb. Exiting.\n");
        exit(-2);
    } 
}

int main(int argc, char** argv) {
    if(argc != 2) print_help();
    if(strcmp(argv[1], "install") == 0) {
        checklibusb();
        printf("[1] Downloading libusb...\n");
        NSString *libusb_100_dylib = downloadfile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb-1.0.0.dylib", @"libusb-1.0.0.dylib");
        NSString *libusb_10_a = downloadfile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb-1.0.a", @"libusb-1.0.a");
        NSString *libusb_10_dylib = downloadfile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb-1.0.dylib", @"libusb-1.0.dylib");
        NSString *libusb_10_pc = downloadfile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb-1.0.pc", @"libusb-1.0.pc");
        NSString *libusb_h = downloadfile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb.h", @"libusb.h");
        printf("[2] Installing libusb...\n");
        copytolocation(libusb_100_dylib, @"/usr/local/lib/libusb-1.0.0.dylib");
        copytolocation(libusb_10_dylib, @"/usr/local/lib/libusb-1.0.dylib");
        copytolocation(libusb_10_a, @"/usr/local/lib/libusb-1.0.a");
        createDir(@"/usr/local/lib/pkgconfig");
        createDir(@"/usr/local/include/libusb-1.0");
        copytolocation(libusb_10_pc, @"/usr/local/lib/pkgconfig/libusb-1.0.pc");
        copytolocation(libusb_h, @"/usr/local/include/libusb-1.0/libusb.h");
        printf("Successfully installed libusb!\n");
    }
    else if(strcmp(argv[1], "uninstall") == 0) {
        removeFile(@"/usr/local/lib/libusb-1.0.0.dylib");
        removeFile(@"/usr/local/lib/libusb-1.0.dylib");
        removeFile(@"/usr/local/lib/libusb-1.0.a");
        removeFile(@"/usr/local/lib/pkgconfig/libusb-1.0.pc");
        removeFile(@"/usr/local/include/libusb-1.0/libusb.h");
        printf("Successfully uninstalled libusb!\n");
    }
    else {
        printf("[ERROR] Invalid argument: %s\n",argv[1]);
        print_help();
    }
    return 0;
}
