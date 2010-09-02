//
//  SMGlobals.h
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>


#define DEBUG // comment following line to disable logging messages

#ifdef DEBUG
#define SMLog NSLog
#else
#define SMLog    
#endif

#define SMWARN SMLog

#define SMLogRect(rect) \
SMLog(@"x = %4.f, y = %4.f, w = %4.f, h = %4.f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

#define SMLogPoint(pt) \
SMLog(@"x = %4.f, y = %4.f", pt.x, pt.y)

#define SMLogSize(size) \
SMLog(@"w = %4.f, h = %4.f", size.width, size.height)

#define SMSaveRelease(releasePointer) \
{ [releasePointer release]; releasePointer = nil; }

#define SMSaveCFRelease(releasePointer) \
{ CFRelease(releasePointer); releasePointer = NULL; }
