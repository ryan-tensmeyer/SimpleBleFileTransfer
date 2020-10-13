//
//  IconUUIDs.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class IconUUIDs: NSObject {

    /// MARK: - Icon services and charcteristics Identifiers
        
    // iFit Control Service UUIDs
    public static let ifitControlService = CBUUID.init(string: "00001400-555E-E99C-E511-F9F4F8DAEB24")
    public static let ifitControlServiceCmdChar = CBUUID.init(string: "00001401-555E-E99C-E511-F9F4F8DAEB24")
    public static let ifitControlServiceRespChar = CBUUID.init(string: "00001402-555E-E99C-E511-F9F4F8DAEB24")
    public static let ifitControlServiceCmdQueryChar = CBUUID.init(string: "00001403-555E-E99C-E511-F9F4F8DAEB24")
    public static let ifitControlServiceCmdQueryRespChar = CBUUID.init(string: "00001404-555E-E99C-E511-F9F4F8DAEB24")

    // Icon BLE Serial Service UUIDs
    public static let IconBLESerialService = CBUUID.init(string: "00001533-1412-efde-1523-785feabcd123")
    public static let IconBLESerialServiceTx = CBUUID.init(string: "00001535-1412-efde-1523-785feabcd123")
    public static let IconBLESerialServiceRx = CBUUID.init(string: "00001534-1412-efde-1523-785feabcd123")

    // Icon BLE Serial Service 2.0 UUIDs
    public static let IconBLESerialService2 = CBUUID.init(string: "7807ca18-6598-4c00-bc25-2fcef5d14229")
    public static let IconBLESerialService2Tx = CBUUID.init(string: "7807ca19-6598-4c00-bc25-2fcef5d14229")
    public static let IconBLESerialService2Rx = CBUUID.init(string: "7807ca1a-6598-4c00-bc25-2fcef5d14229")
    public static let IconBLESerialService2TxDataRdy = CBUUID.init(string: "7807ca1b-6598-4c00-bc25-2fcef5d14229")

}
