//
//  GemsIntegration.h
//  Telegraph
//
//  Created by alon muroch on 11/01/2016.
//
//

#ifndef GemsIntegration_h
#define GemsIntegration_h

/**
 * Will symobolize an added property to a telegram class
 */
#define GEMS_ADDED_PROPERTY

/**
 * Will symobolize property made public for GetGems subclassing
 */
#define GEMS_PROPERTY_EXTERN

/**
 * Will symobolize protocol made public for GetGems subclassing
 */
#define GEMS_PROTOCOL_EXTERN

/**
 * Will symobolize a method made public for GetGems subclassing
 */
#define GEMS_METHOD_EXTERN

/**
 * Will symobolize an added method for GetGems subclassing
 */
#define GEMS_ADDED_METHOD

/**
 * Will symobolize some refactoring in the original telegram code for subclassing
 */
#define GEMS_TG_REFACTORING

/**
 * Will symobolize a changed method in the original telegram code
 */
#define GEMS_TG_METHOD_CHANGED

/**
 * Will symobolize a TG method commented out
 */
#define GEMS_TG_METHOD_COMMENTEDOUT

/**
 *  Will symobolize a Telegram class being subclassed from a Gems class
 *  For example TGViewController
 */
#define GEMS_SUBCLASS

#endif /* GemsIntegration_h */
