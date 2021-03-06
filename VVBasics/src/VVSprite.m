
#import "VVSprite.h"
#import "VVSpriteManager.h"
#import "VVBasicMacros.h"




@implementation VVSprite


/*===================================================================================*/
#pragma mark --------------------- create/destroy
/*------------------------------------*/
+ (id) createWithRect:(NSRect)r inManager:(id)m	{
	VVSprite		*returnMe = [[VVSprite alloc] initWithRect:r inManager:m];
	if (returnMe == nil)
		return nil;
	return [returnMe autorelease];
}
- (id) initWithRect:(NSRect)r inManager:(id)m	{
	if ((m==nil)||(r.size.width==0)||(r.size.height==0)||(r.origin.x==NSNotFound)||(r.origin.y==NSNotFound))	{
		[self release];
		return nil;
	}
	if (self = [super init])	{
		deleted = NO;
		locked = NO;
		spriteIndex = -1;
		manager = m;
		spriteIndex = [manager getUniqueSpriteIndex];
		delegate = nil;
		drawCallback = nil;
		actionCallback = nil;
		
		rect = r;
		lastActionType = VVSpriteEventNULL;
		lastActionCoords = NSMakePoint(NSNotFound,NSNotFound);
		lastActionInBounds = NO;
		trackingFlag = NO;
		mouseDownCoords = NSMakePoint(NSNotFound,NSNotFound);
		lastActionDelta = NSMakePoint(NSNotFound,NSNotFound);
		mouseDownDelta = NSMakePoint(NSNotFound,NSNotFound);
		
		userInfo = nil;
		NRUserInfo = nil;
		safeString = nil;
		return self;
	}
	[self release];
	return nil;
}
- (void) prepareToBeDeleted	{
	//NSLog(@"%s",__func__);
	deleted = YES;
}
- (void) dealloc	{
	//NSLog(@"%s",__func__);
	if (!deleted)
		[self prepareToBeDeleted];
	
	manager = nil;
	VVRELEASE(userInfo);
	VVRELEASE(safeString);
	[super dealloc];
}

/*===================================================================================*/
#pragma mark --------------------- action and draw
/*------------------------------------*/

- (BOOL) checkPoint:(NSPoint)p	{
	//NSLog(@"%s",__func__);
	//NSPointLog(@"\t\tchecking point",p);
	//NSRectLog(@"\t\tagainst rect",rect);
	if (NSPointInRect(p,rect))
		return YES;
	return NO;
}


- (void) mouseDown:(NSPoint)p	{
	//NSLog(@"%s ... (%f, %f)",__func__,p.x,p.y);
	if (deleted)
		return;
	lastActionType = VVSpriteEventDown;
	lastActionCoords = p;
	if (NSPointInRect(p,rect))
		lastActionInBounds = YES;
	else
		lastActionInBounds = NO;
	trackingFlag = YES;
	mouseDownCoords = p;
	lastActionDelta = NSMakePoint(0,0);
	mouseDownDelta = NSMakePoint(0,0);
	if ((delegate==nil)||(actionCallback==nil)||(![delegate respondsToSelector:actionCallback]))
		return;
	[delegate performSelector:actionCallback withObject:self];
}
- (void) rightMouseDown:(NSPoint)p	{
	//NSLog(@"%s ... (%f, %f)",__func__,p.x,p.y);
	if (deleted)
		return;
	lastActionType = VVSpriteEventRightDown;
	lastActionCoords = p;
	if (NSPointInRect(p,rect))
		lastActionInBounds = YES;
	else
		lastActionInBounds = NO;
	trackingFlag = NO;
	mouseDownCoords = p;
	lastActionDelta = NSMakePoint(0,0);
	mouseDownDelta = NSMakePoint(0,0);
	if ((delegate==nil)||(actionCallback==nil)||(![delegate respondsToSelector:actionCallback]))
		return;
	[delegate performSelector:actionCallback withObject:self];
}
- (void) rightMouseUp:(NSPoint)p	{
	if (deleted)
		return;
	//	calculate the deltas
	if (lastActionType == VVSpriteEventRightDown)	{
		lastActionDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
		mouseDownDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
	}
	else	{
		lastActionDelta = NSMakePoint(p.x-lastActionCoords.x, p.y-lastActionCoords.y);
		mouseDownDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
	}
	//	update the action type and coords
	lastActionType = VVSpriteEventRightUp;
	lastActionCoords = p;
	if (NSPointInRect(p,rect))
		lastActionInBounds = YES;
	else
		lastActionInBounds = NO;
	trackingFlag = NO;
	//	if there's a delegate and it has an action callback, call it
	if ((delegate!=nil)&&(actionCallback!=nil)&&([delegate respondsToSelector:actionCallback]))
		[delegate performSelector:actionCallback withObject:self];
}
- (void) mouseDragged:(NSPoint)p	{
	//NSLog(@"%s ... (%f, %f)",__func__,p.x,p.y);
	if (deleted)
		return;
	//	calculate the deltas
	if (lastActionType == VVSpriteEventDown)	{
		lastActionDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
		mouseDownDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
	}
	else	{
		lastActionDelta = NSMakePoint(p.x-lastActionCoords.x, p.y-lastActionCoords.y);
		mouseDownDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
	}
	//	update the action type and coords
	lastActionType = VVSpriteEventDrag;
	lastActionCoords = p;
	if (NSPointInRect(p,rect))
		lastActionInBounds = YES;
	else
		lastActionInBounds = NO;
	//	if there's a delegate and it has an action callback, call it
	if ((delegate!=nil)&&(actionCallback!=nil)&&([delegate respondsToSelector:actionCallback]))
		[delegate performSelector:actionCallback withObject:self];
}
- (void) mouseUp:(NSPoint)p	{
	//NSLog(@"%s ... (%f, %f)",__func__,p.x,p.y);
	if (deleted)
		return;
	//	calculate the deltas
	if (lastActionType == VVSpriteEventDown)	{
		lastActionDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
		mouseDownDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
	}
	else	{
		lastActionDelta = NSMakePoint(p.x-lastActionCoords.x, p.y-lastActionCoords.y);
		mouseDownDelta = NSMakePoint(p.x-mouseDownCoords.x, p.y-mouseDownCoords.y);
	}
	//	update the action type and coords
	lastActionType = VVSpriteEventUp;
	lastActionCoords = p;
	if (NSPointInRect(p,rect))
		lastActionInBounds = YES;
	else
		lastActionInBounds = NO;
	trackingFlag = NO;
	//	if there's a delegate and it has an action callback, call it
	if ((delegate!=nil)&&(actionCallback!=nil)&&([delegate respondsToSelector:actionCallback]))
		[delegate performSelector:actionCallback withObject:self];
}
- (void) draw	{
	//NSLog(@"%s",__func__);
	if ((deleted)||(delegate==nil)||(drawCallback==nil)||(![delegate respondsToSelector:drawCallback]))
		return;
	[delegate performSelector:drawCallback withObject:self];
}
- (void) bringToFront	{
	//NSLog(@"%s",__func__);
	if ((deleted) || (manager==nil))
		return;
	//	get my manager's sprite array- if it's nil or has < 2 items, bail (nothing to do)
	MutLockArray		*managerSpriteArray = [manager spriteArray];
	if ((managerSpriteArray==nil) || ([managerSpriteArray count]<2))
		return;
	//	get a write-lock on the array, i'll be changing its order
	[managerSpriteArray wrlock];
		//	retain me so i don't get released during any of this silliness
		[self retain];
		//	remove me from my manager's sprite array
		[managerSpriteArray removeIdenticalPtr:self];
		//	add me to my manager's sprite array at the "top"
		[managerSpriteArray insertObject:self atIndex:0];
		//	autorelease me, so the impact on my retain count has been a net 0
		[self autorelease];
	//	unlock the array
	[managerSpriteArray unlock];
}
- (void) sendToBack	{
	//NSLog(@"%s",__func__);
	if ((deleted) || (manager==nil))
		return;
	//	get my manager's sprite array- if it's nil or has < 2 items, bail (nothing to do)
	MutLockArray		*managerSpriteArray = [manager spriteArray];
	if ((managerSpriteArray==nil) || ([managerSpriteArray count]<2))
		return;
	//	get a write-lock on the array, i'll be changing its order
	[managerSpriteArray wrlock];
		//	retain me so i don't get released during any of this silliness
		[self retain];
		//	remove me from my manager's sprite array
		[managerSpriteArray removeIdenticalPtr:self];
		//	add me to my manager's sprite array at the "bottom"
		[managerSpriteArray addObject:self];
		//	autorelease me, so the impact on my retain count has been a net 0
		[self autorelease];
	//	unlock the array
	[managerSpriteArray unlock];
}

/*===================================================================================*/
#pragma mark --------------------- key/value
/*------------------------------------*/

- (void) setLocked:(BOOL)n	{
	locked = n;
}
- (BOOL) locked	{
	return locked;
}
- (void) setHidden:(BOOL)n	{
	hidden = n;
}
- (BOOL) hidden	{
	return hidden;
}
- (long) spriteIndex	{
	return spriteIndex;
}
- (id) manager	{
	return manager;
}
- (void) setDelegate:(id)t	{
	delegate = t;
}
- (id) delegate	{
	return delegate;
}
- (void) setDrawCallback:(SEL)n	{
	drawCallback = n;
}
- (SEL) drawCallback	{
	return drawCallback;
}
- (void) setActionCallback:(SEL)n	{
	actionCallback = n;
}
- (SEL) actionCallback	{
	return actionCallback;
}


- (void) setRect:(NSRect)n	{
	//NSLog(@"%s ... %ld",__func__,spriteIndex);
	//NSRectLog(@"\trect",n);
	NSRect		oldRect = rect;
	NSPoint		delta = NSMakePoint(n.origin.x-oldRect.origin.x, n.origin.y-oldRect.origin.y);
	rect = n;
	lastActionCoords = NSMakePoint(lastActionCoords.x+delta.x, lastActionCoords.y+delta.y);
	mouseDownCoords = NSMakePoint(mouseDownCoords.x+delta.x, mouseDownCoords.y+delta.y);
}
- (NSRect) rect	{
	return rect;
}
- (VVSpriteEventType) lastActionType	{
	return lastActionType;
}
- (NSPoint) lastActionCoords	{
	return lastActionCoords;
}
- (BOOL) lastActionInBounds	{
	return lastActionInBounds;
}
- (BOOL) trackingFlag	{
	return trackingFlag;
}
- (NSPoint) mouseDownCoords	{
	return mouseDownCoords;
}
- (NSPoint) lastActionDelta	{
	return lastActionDelta;
}
- (NSPoint) mouseDownDelta	{
	return mouseDownDelta;
}
- (void) setUserInfo:(id)n	{
	//NSLog(@"%s ... %@",__func__,n);
	VVRELEASE(userInfo);
	if (n != nil)
		userInfo = [n retain];
}
- (id) userInfo	{
	return userInfo;
}
@synthesize NRUserInfo;
- (void) setSafeString:(id)n	{
	VVRELEASE(safeString);
	if (n != nil)
		safeString = [n retain];
}
- (id) safeString	{
	return safeString;
}


@end
