//
//  FileSystemDefines.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class FileSystemDefines: NSObject {
    
    enum FileType: UInt8
    {
        case INDEX = 0
        case VERSION = 1
        case SYSTEM_SETTINGS = 2
        case TIME = 3
        case USER_SETTINGS = 4
        case GOALS = 5
        case CURRENT_TOTALS = 6
        case OFFSETS = 7
        case ALERT_MESSAGE = 8
        case POPUP_MESSAGE = 9
        case WORKOUT = 10
        case DAY_LOG = 11
        case HOUR_LOG = 12
        case MINUTE_LOG = 13
        case SLEEP_LOG = 14
        case DEBUG = 15
        case WATCH_CALIBRATION = 16
        case SUBDEVICE_FIRMWARE = 17
        case GPS = 18
        case HEART_RATE = 19
        case SWIM_WORKOUT = 20
        case PERIPHERAL_DEVICE_SETTINGS = 21
        case BATTERY_DATA = 22
        case BATTERY_SOC = 23
        case BED_SETTINGS = 24
        case IQ_WORKOUT = 25
        case IQ_SYSTEM_SETTINGS = 26
        case ALARM = 27
        case ML2_SHARED_MEMORY = 28
        case LARGE_X_VERSION = 29
        case CYCLING_SHOE_SETTINGS = 30
        case CALIBRATION = 31
        case UPDATE = 32
        case SMARTBELL_MODEL = 33
        case WIFI_SETTINGS = 34
        case SHARED_MEMORY_FILE = 35
        case HEART_RATE_MONITOR_SCAN = 36
        case SMARTBELL_BASE_SETTINGS = 37
        case UNKNOWN = 255
    }

    let fileNameString = ["INDEX", "VERSION", "SYSTEM_SETTINGS", "TIME", "USER_SETTINGS", "GOALS", "CURRENT_TOTALS", "OFFSETS", "ALERT_MESSAGE", "POPUP_MESSAGE", "WORKOUT", "DAY_LOG", "HOUR_LOG", "MINUTE_LOG", "SLEEP_LOG", "DEBUG", "WATCH_CALIBRATION", "SUBDEVICE_FIRMWARE", "GPS", "HEART_RATE", "SWIM_WORKOUT", "PERIPHERAL_DEVICE_SETTINGS", "BATTERY_DATA", "BATTERY_SOC", "BED_SETTINGS", "IQ_WORKOUT", "IQ_SYSTEM_SETTINGS", "ALARM", "ML2_SHARED_MEMORY", "LARGE_X_VERSION", "CYCLING_SHOE_SETTINGS", "CALIBRATION", "UPDATE", "SMARTBELL_MODEL", "UNKNOWN"]

    // File Header defines
    let FileNameSize: UInt8 = 25
    let DateCreatedSize: UInt8 = 7
    let DateModifiedSize: UInt8 = 7
    let VersionSize: UInt8 = 1
    let FileSizeSize: UInt8 = 4
    
    let Wifi_Name_Length = 33
    let Wifi_Encryption_Type_Length = 1
    let Wifi_Password_Length = 65
    
    let Max_Packet_Size: UInt16 = 64
    let Header_Size: UInt16 = 9
}
