#line 1 "/Users/wangyankun/Documents/tmp/HookHID/HookSpringBoard/HookSpringBoard/HookSpringBoard.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <dlfcn.h>
#import "IOHIDEvent.h"
#import "IOHIDEventSystem.h"
#import "IOHIDEventSystemClient.h"
#import "IOHIDUserDevice.h"
#import "IOHIDEventSystem.h"
#import "IOHIDEvent7.h"
#import "IOHIDEventTypes7.h"
#import "IOHIDEventSystemConnection.h"
#include <substrate.h>
#include <substrate.h>


static void writeFile(NSString* filepath,NSString* content,bool isNewOne)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
     NSString *path = filepath ? filepath : @"/tmp/tNew.txt" ;
    if (isNewOne || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[@"" dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
    }
    NSFileHandle *fielHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fielHandle seekToEndOfFile];  
    NSData* stringData  = [ [content stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    [fielHandle writeData:stringData]; 
}






















































































































extern "C" CFTypeRef MGCopyAnswer(CFStringRef prop);

static CFTypeRef (*orig_MGCopyAnswer)(CFStringRef prop, uint32_t* outTypeCode);

CFTypeRef new_MGCopyAnswer(CFStringRef prop, uint32_t* outTypeCode) {
    
    NSString *keyStr = (__bridge NSString*) prop;
    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = @"/tmp/tChangeSerial.txt";
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[@"" dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
    }
    NSFileHandle *fielHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fielHandle seekToEndOfFile];  
    NSData* stringData  = [ [keyStr stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    [fielHandle writeData:stringData]; 
    
    
    
    if ([keyStr isEqualToString:@"ProductVersion"]) {
        NSString *updateNumber = @"8.1.2";
        CFTypeRef refNumber = (__bridge_retained CFTypeRef)updateNumber;
        return refNumber;
    }
    
    if ([keyStr isEqualToString:@"DeviceName"]) {
        NSString *updateNumber = @"HookedName";
        CFTypeRef refNumber = (__bridge_retained CFTypeRef)updateNumber;
        return refNumber;
    }
    
    if ([keyStr isEqualToString:@"VasUgeSzVyHdB27g2XpN0g"]) {
        NSString *updateNumber = @"KF1111111111";
        return (__bridge_retained CFTypeRef)updateNumber;
        
    }
    
    if ([keyStr isEqualToString:@"UserAssignedDeviceName"]) {
        NSString *updateNumber = @"lalalalala";
        return (__bridge_retained CFTypeRef)updateNumber;
    }
    
    return orig_MGCopyAnswer(prop, outTypeCode);
}


static __attribute__((constructor)) void _logosLocalCtor_3644a684(int __unused argc, char __unused **argv, char __unused **envp)
{


    char *dylib_path = (char*)"/usr/lib/libMobileGestalt.dylib";
    void *h = dlopen(dylib_path,RTLD_GLOBAL);
    NSString *strDylibFile = @"/usr/lib/libMobileGestalt.dylib";
    if (h) {
        MSImageRef ref = MSGetImageByName([strDylibFile UTF8String]);
        void * MGCopyAnswerFn = MSFindSymbol(ref, "_MGCopyAnswer");
        MSHookFunction((void*)((uint8_t*)MGCopyAnswerFn + 8), (void*)new_MGCopyAnswer,
                    (void**)&orig_MGCopyAnswer);
    }
    
    
}



