//
//  main.m
//  homebrusb
//
//  Created by MiniExploit on 1/24/22.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

/* borrowed from synackuk's belladonna */
typedef struct {
    int length;
    char* content;
} curl_response;

size_t download_write_buffer_callback(char* data, size_t size, size_t nmemb, curl_response* response) {
    size_t total = size * nmemb;
    if (total == 0) {
        return total;
    }
    response->content = realloc(response->content, response->length + total + 1);
    memcpy(response->content + response->length, data, total);
    response->content[response->length + total] = '\0';
    response->length += total;
    return total;
}

void checklibusb(void) {
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/local/lib/libusb-1.0.0.dylib"]){
        printf("libusb was already installed, exiting...\n");
        exit(0);
    }
}

NSString *downloadFile(NSString *url, NSString *filename) {
    FILE *f = NULL;
    CURL* handle = curl_easy_init();
    if(!handle) {
        printf("[ERROR] Could not init curl\n");
        exit(1);
    }
    curl_response response;
    response.length = 0;
    response.content = malloc(1);
    response.content[0] = '\0';

    curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, (curl_write_callback)&download_write_buffer_callback);
    curl_easy_setopt(handle, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(handle, CURLOPT_FOLLOWLOCATION, 1);
    curl_easy_setopt(handle, CURLOPT_URL, [url cStringUsingEncoding:NSASCIIStringEncoding]);

    curl_easy_perform(handle);
    curl_easy_cleanup(handle);

    if (response.length < 0) {
       printf("[ERROR] An error occured while downloading files. Exiting.");
       exit(-1);
    }

    

    NSString *tempdir = [NSString stringWithFormat:@"%@", NSTemporaryDirectory()];
    NSString *tempfile = [tempdir stringByAppendingString:filename];
    
    f = fopen([tempfile cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if(!f) {
        printf("[ERROR] Could not open file for writing content!\n");
        exit(1);
    }
    
    fwrite(response.content, response.length, 1, f);
    fclose(f);
    
   
    return tempfile;
}

void copyToLocation(NSString *path, NSString *dest) {
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
        NSString *libusb_100_dylib = downloadFile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb-1.0.0.dylib", @"libusb-1.0.0.dylib");
        NSString *libusb_10_a = downloadFile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb-1.0.a", @"libusb-1.0.a");
        NSString *libusb_10_dylib = downloadFile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb-1.0.dylib", @"libusb-1.0.dylib");
        NSString *libusb_10_pc = downloadFile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb-1.0.pc", @"libusb-1.0.pc");
        NSString *libusb_h = downloadFile(@"https://github.com/Mini-Exploit/libusb-for-homebrusb/raw/main/libusb.h", @"libusb.h");
        printf("[2] Installing libusb...\n");
        copyToLocation(libusb_100_dylib, @"/usr/local/lib/libusb-1.0.0.dylib");
        copyToLocation(libusb_10_dylib, @"/usr/local/lib/libusb-1.0.dylib");
        copyToLocation(libusb_10_a, @"/usr/local/lib/libusb-1.0.a");
        createDir(@"/usr/local/lib/pkgconfig");
        createDir(@"/usr/local/include/libusb-1.0");
        copyToLocation(libusb_10_pc, @"/usr/local/lib/pkgconfig/libusb-1.0.pc");
        copyToLocation(libusb_h, @"/usr/local/include/libusb-1.0/libusb.h");
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
        printf("[ERROR] Invalid argument: %s\n", argv[1]);
        print_help();
    }
    return 0;
}
