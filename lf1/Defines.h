//
//  Header.h
//  LF1
//
//  Created by Chris on 18/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#ifndef LF1_Defines_h
#define LF1_Defines_h

#define CV_FREQUENCY_RANGE 5000
#define PRESET_BANK_KEY @"presetBank"
#define SCREEN_SCALE [[UIScreen mainScreen] scale]

#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define TRANSPORT_CHANGE_NOTIFICATION_STRING @"LF1_TRANSPORT_CHANGE"

#define AUDIO_ENGINE ((AppDelegate *)[UIApplication sharedApplication].delegate).audioEngine
#define MIDI_ENGINE ((AppDelegate *)[UIApplication sharedApplication].delegate).midiEngine
#define MAIN_VIEW_CONTROLLER ((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewController

#define MIDI_CHANGE_NOTIFICATION @"Midi_Change_Notification"

#define UNDO_STEPS 25

#define UNDO_STATE_CHANGE_NOTIFICATON @"Undo_State_Change_Notification"

#endif
