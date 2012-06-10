/* CALayer.m

   Copyright (C) 2012 Free Software Foundation, Inc.
   
   Author: Ivan Vučica <ivan@vucica.net>
   Date: June 2012

   Author: Amr Aboelela <amraboelela@gmail.com>
   Date: December 2011

   This file is part of QuartzCore.

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

#import "QuartzCore/CALayer.h"
#import <CoreGraphics/CoreGraphics.h>
#import <cairo/cairo.h>

NSString *const kCAGravityResize = @"CAGravityResize";
NSString *const kCAGravityResizeAspect = @"CAGravityResizeAspect";
NSString *const kCAGravityResizeAspectFill = @"CAGravityResizeAspectFill";
NSString *const kCAGravityCenter = @"CAGravityCenter";
NSString *const kCAGravityTop = @"CAGravityTop";
NSString *const kCAGravityBottom = @"CAGravityBottom";
NSString *const kCAGravityLeft = @"CAGravityLeft";
NSString *const kCAGravityRight = @"CAGravityRight";
NSString *const kCAGravityTopLeft = @"CAGravityTopLeft";
NSString *const kCAGravityTopRight = @"CAGravityTopRight";
NSString *const kCAGravityBottomLeft = @"CAGravityBottomLeft";
NSString *const kCAGravityBottomRight = @"CAGravityBottomRight";

@interface CALayer()
@property (assign) CALayer *superlayer;
@end

@implementation CALayer

@synthesize delegate=_delegate;
@synthesize contents=_contents;
@synthesize layoutManager=_layoutManager;
@synthesize superlayer=_superlayer;
@synthesize sublayers=_sublayers;
@synthesize frame=_frame;
@synthesize bounds=_bounds;
@synthesize position=_position;
@synthesize opacity=_opacity;
@synthesize affineTransform=_affineTransform;
@synthesize opaque=_opaque;
@synthesize geometryFlipped=_geometryFlipped;
@synthesize backgroundColor=_backgroundColor;
@synthesize masksToBounds=_masksToBounds;
@synthesize contentsRect=_contentsRect;
@synthesize hidden=_hidden;
@synthesize contentsGravity=_contentsGravity;
@synthesize needsDisplayOnBoundsChange=_needsDisplayOnBoundsChange;
@synthesize zPosition=_zPosition;
  
@synthesize beginTime=_beginTime;
@synthesize duration=_duration;
@synthesize repeatCount=_repeatCount;
@synthesize autoreverses=_autoreverses;
@synthesize fillMode=_fillMode;

/* *** class methods *** */
+ (id) layer
{
  return [[self new] autorelease];
}


/* *** methods *** */
- (id) init
{
  if((self = [super init]) != nil)
    {
    }
  return self;
}

- (id) initWithLayer: (CALayer*)layer
{
  /* Used when creating shadow copies of 'layer', e.g. when creating 
     presentation layer. Not to be used by app developer for copying existing
     layers. */

  if((self = [self init]) != nil)
    {
      // TODO: actually copy the properties and content
    }
  return self;
}

- (void) dealloc
{
  cairo_surface_finish(_cairoSurface);
  CGContextRelease(_opalContext);

  [super dealloc];
}

/* *** properties *** */
- (void) setBounds: (CGRect)bounds
{
  _bounds = bounds;

  cairo_surface_finish(_cairoSurface);
  CGContextRelease(_opalContext);

  _cairoSurface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, bounds.size.width, bounds.size.height);
  _opalContext = opal_new_CGContext(_cairoSurface, bounds.size);
}

- (void) setDelegate: (id)delegate
{
  _delegate = delegate;

  [self setNeedsDisplay];
}

/* *** display methods *** */

- (void) display
{
  if([_delegate respondsToSelector: @selector(displayLayer:)])
    {
      [_delegate displayLayer: self];
    }
  else
    {
      /* By default, uses -drawInContext: to update the 'contents' property. */
      [self drawInContext:_opalContext];
      self.contents = _opalContext;
    }
}
- (void) displayIfNeeded
{
  if(_needsDisplay)
    {
      [self display];
    }

  _needsDisplay = NO;
}
- (BOOL) needsDisplay
{
  return _needsDisplay;
}
- (void) setNeedsDisplay
{
  // TODO: schedule redisplay of self
  // TODO: or, mark parents dirty recursively, with root scheduling redisplay
  _needsDisplay = YES;
}
- (void) setNeedsDisplayInRect:(CGRect)r
{
  [self setNeedsDisplay];
}
- (void) drawInContext: (CGContextRef)context
{
  if([_delegate respondsToSelector: @selector(drawLayer:inContext:)])
    {
      [_delegate drawLayer:self inContext:context];
    }
}

/* layout methods */
- (void) layoutIfNeeded
{ 
}
- (void) layoutSublayers
{
}
- (void) setNeedsLayout
{
  _needsLayout = YES;
}

/* Unimplemented functions: */
#if 0
- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key;
- (void)removeAnimationForKey:(NSString *)key;
- (CAAnimation *)animationForKey:(NSString *)key;
- (void)addSublayer:(CALayer *)layer;
- (CGPoint)convertPoint:(CGPoint)p toLayer:(CALayer *)l;
- (void)removeFromSuperlayer;
- (void)insertSublayer:(CALayer *)layer atIndex:(unsigned)index;
- (void)insertSublayer:(CALayer *)layer below:(CALayer *)sibling;
- (void)insertSublayer:(CALayer *)layer above:(CALayer *)sibling;
- (void)setNeedsLayout;
- (void)layoutIfNeeded;

- (id)presentationLayer;
- (id)modelLayer;

#endif

@end

/* vim: set cindent cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1 expandtabs shiftwidth=2 tabstop=8: */