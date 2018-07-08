/* Demo/DemoController.m

   Copyright (C) 2018 Free Software Foundation, Inc.

   Author: Stjepan Brkic <stjepanbrkicc@gmail.com>
   Date: July 2018

   This file is part of QuartzCore/CAAppKitBridge.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the
   Free Software Foundation, 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.
*/

#import "DemoController.h"

@implementation DemoController
- (void) applicationDidFinishLaunching: (id)t
{
#if 0
  NSView * view = [[NSView alloc] init];
  NSView * view2 = [[NSView alloc] init];
  NSView * view3 = [[NSView alloc] init];
  NSView * view3_5 = [[NSView alloc] init];
  NSView * view4 = [[NSView alloc] init];

  NSLog(@"%p %p %p %p %p", view, view2, view3, view3_5, view4);

  [view addSubview: view2];
  [view2 addSubview: view3];
  [view2 addSubview: view3_5];
  [view3 addSubview: view4];

  NSLog(@"view wantsLayer value: %d", [view wantsLayer]);
  NSLog(@"view2 wantsLayer value: %d", [view2 wantsLayer]);
  NSLog(@"view3 wantsLayer value: %d", [view3 wantsLayer]);
  NSLog(@"view3_5 wantsLayer value: %d", [view3_5 wantsLayer]);
  NSLog(@"view4 wantsLayer value: %d", [view4 wantsLayer]);

  NSLog(@"Setting view2 wantsLayer to true");
  [view2 setWantsLayer: YES];
  NSLog(@"view wantsLayer value: %d", [view wantsLayer]);
  NSLog(@"view2 wantsLayer value: %d", [view2 wantsLayer]);
  NSLog(@"view3 wantsLayer value: %d", [view3 wantsLayer]);
  NSLog(@"view3_5 wantsLayer value: %d", [view3_5 wantsLayer]);
  NSLog(@"view4 wantsLayer value: %d", [view4 wantsLayer]);

  CARenderer *renderer = [[CARenderer alloc] init];

  NSLog(@"addCARenderer on root layer %p", view2);
  NSLog(@"Success: %d", [view2 _gsAddCARenderer: renderer]); // Also creates OpenGL context
  NSLog(@"addCARenderer on non-root layer %p", view3);
  NSLog(@"Success: %d", [view3 _gsAddCARenderer: renderer]);

  NSLog(@"removeCARenderer from root layer %p", view2);
  NSLog(@"Success: %d", [view2 _gsRemoveCARenderer]);
  NSLog(@"removeCARenderer from non-root layer %p", view3);
  NSLog(@"Success: %d" , [view3 _gsRemoveCARenderer]);
#endif

  /* Test the drawing into the context */
  NSWindow *window = [[NSWindow alloc] initWithContentRect: NSMakeRect(0,0,800,600)
                                        styleMask: NSTitledWindowMask | NSClosableWindowMask
                                          backing: NSBackingStoreBuffered
                                            defer: NO];
  NSView * mainView = [[NSView alloc] initWithFrame: [[window contentView] frame]];
  [window setContentView: mainView];
  [mainView setWantsLayer: YES];
  NSLog(@"mainView wantsLayer value: %d", [mainView wantsLayer]);
  [window makeKeyAndOrderFront: nil];

  NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 1./60. 
                                                    target: self 
                                                  selector: @selector(drawRect:) 
                                                  userInfo: mainView 
                                                   repeats: YES];
}

-(void) drawRect: (NSTimer*)t
{
  NSView *mainView = t.userInfo;
  NSLog(@"mainView is at %p", mainView);
  [[mainView _gsCreateOpenGLContext] makeCurrentContext];
  NSLog(@"Context is at %p", [mainView _gsCreateOpenGLContext]);

  glViewport(0, 0, [mainView frame].size.width, [mainView frame].size.height);
  glClear(GL_COLOR_BUFFER_BIT);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  GLfloat vertices[] = {
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,
  };
  GLfloat colors[] = {
    1.0, 0.0, 0.0, 1.0,
    0.0, 1.0, 0.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
  };
  glVertexPointer(2, GL_FLOAT, 0, vertices);
  glColorPointer(3, GL_FLOAT, 0, colors);

  glDrawArrays(GL_TRIANGLES, 0, 6);

  glFlush();

  [[mainView _gsCreateOpenGLContext] flushBuffer];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed: (id)sender
{
  return YES;
}

-(void)dealloc
{
  [super dealloc];
}

@end
