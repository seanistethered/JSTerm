//
//  SerialIO.h
//  JSTerm
//
//  Created by fridakitten on 15.03.25.
//

#ifndef SERIAL_IO_H
#define SERIAL_IO_H

#import <Foundation/Foundation.h>
#import "../../UI/TerminalView.h"

@interface JSKERN_SERIAL_IO : NSObject

- (void)print:(TerminalLCD*)tlcd msg:(NSString*)msg;
- (NSString*)readline:(TerminalLCD*)tlcd prompt:(NSString*)prompt;

@end

#endif
