//
//  SUXARUnarchiver.m
//  Sparkle
//
//  Created by Jean-Daniel Dupas on 16/09/09.
//  Copyright 2009 Jean-Daniel Dupas. All rights reserved.
//

#import "SUXARUnarchiver.h"
#import "SUUnarchiver_Private.h"

#import <memory>

extern "C" {
#import <xar/xar.h>
}

@interface SUXARUnarchiver ()
- (void)_extractXAR;
@end

@implementation SUXARUnarchiver

static
int32_t sa_xar_err_handler(int32_t severity, __unused int32_t instance, __unused xar_errctx_t errctxt, void *userctxt) {
  bool *ok = static_cast<bool *>(userctxt);
  *ok = severity <= XAR_SEVERITY_WARNING;
  return 0;
}

+ (BOOL)canUnarchivePath:(NSString *)path {
  if ([[path pathExtension] isEqualToString:@"xar"])
    return YES;

// XAR UTI not defined yet
//  NSString *type = [[NSWorkspace sharedWorkspace] typeOfFile:path error:NULL];
//  if (type && [[NSWorkspace sharedWorkspace] type:type conformsToType:@"public.xar"])
//    return YES;

  return NO;
}

- (void)start {
  [NSThread detachNewThreadSelector:@selector(_extractXAR) toTarget:self withObject:nil];
}
struct _xar_close {
  void operator()(xar_t x) { if (x) xar_close(x); }
};

struct _xar_iter_free {
  void operator()(xar_iter_t x) { if (x) xar_iter_free(x); }
};

static inline
void fail(SUXARUnarchiver *self) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self notifyDelegateOfFailure];
  });
}

- (void)_extractXAR {
  bool ok = true;

  @autoreleasepool {
    std::unique_ptr<const __xar_t, _xar_close> auto_x(xar_open([self.archivePath fileSystemRepresentation], READ));
    xar_t x = auto_x.get();
    if (!x)
      return fail(self);

    xar_register_errhandler(x, sa_xar_err_handler, &ok);

    std::unique_ptr<const __xar_iter_t, _xar_iter_free> auto_files(xar_iter_new());
    xar_iter_t files = auto_files.get();
    if (!files)
      return fail(self);

    xar_file_t file = xar_file_first(x, files);
    NSString *dest = [self.archivePath stringByDeletingLastPathComponent];

    while (file && ok) {
      char *buffer = xar_get_path(file);
      if (!buffer)
        return fail(self);

      NSString *filename = [[NSString alloc] initWithUTF8String:buffer];
      if (!filename)
        return fail(self);

      NSString *fspath = [dest stringByAppendingPathComponent:filename];
      if(0 != xar_extract_tofile(x, file, fspath.fileSystemRepresentation))
        return fail(self);

      // Check extracted length
      const char *sizestring = NULL;
      if(0 == xar_prop_get(file, "data/length", &sizestring)) {
        double progress = strtod(sizestring, nullptr);
        dispatch_async(dispatch_get_main_queue(), ^{
          [self notifyDelegateOfProgress:progress];
        });
      }
      /* prepare next file */
      file = xar_file_next(files);
    }
    xar_iter_free(files);
    xar_close(x);

    dispatch_async(dispatch_get_main_queue(), ^{
      [self notifyDelegateOfSuccess];
    });
  }
}

+ (void)load {
	[self registerImplementation:self];
}

@end
