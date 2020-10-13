//
//  TimeFile.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class TimeFile: NSObject {

    struct timeFileData_s
    {
        var currentYear: UInt8
        var currentMonth: UInt8
        var currentDay: UInt8
        var currentHour: UInt8
        var currentMinute: UInt8
        var currentSecond: UInt8
        var UTCOffset: UInt16
    }

    var timeFileData = timeFileData_s(currentYear: 0, currentMonth: 0, currentDay: 0, currentHour: 0, currentMinute: 0, currentSecond: 0, UTCOffset: 0)
    
    func parseData(value: [UInt8])
    {
        timeFileData.currentYear = UInt8(value[0]);
        timeFileData.currentMonth = UInt8(value[1])
        timeFileData.currentDay = UInt8(value[2])
        timeFileData.currentHour = UInt8(value[3])
        timeFileData.currentMinute = UInt8(value[4])
        timeFileData.currentSecond = UInt8(value[5])
        timeFileData.UTCOffset = UInt16((((0x00FF & UInt16(value[6])) << 8)
                                        | (0x00FF & UInt16(value[7]))))
    }

    func availableActions() -> [FileSystemActions.FileActions]
    {
        var actions: [FileSystemActions.FileActions] = []

        actions.append(FileSystemActions.FileActions.READ_DATA);
        actions.append(FileSystemActions.FileActions.SEND_DATA);

        return actions;
    }

    func toString() -> String
    {
        var timeString: String

        timeString = "Current Year: \(timeFileData.currentYear) \n"
                + "Current Month: \(timeFileData.currentMonth) \n"
                + "Current Day: \(timeFileData.currentDay)  \n"
                + "Current Hour: \(timeFileData.currentHour)  \n"
                + "Current Minute: \(timeFileData.currentMinute)  \n"
                + "Current Second: \(timeFileData.currentSecond)  \n"
                + "UTC Offset: \(timeFileData.UTCOffset)"

        return timeString;
    }
}
