//
//  SerialService2.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class SerialService2: NSObject {
    // Icon BLE Serial Service 2.0 Formatting and Defines

    // TX data ready values
    let DataReady: UInt8 = 0x01;
    let DataClear: UInt8 = 0x02;

    // Message format values
    let FileSystemMessage: UInt8 = 0x01;
}
