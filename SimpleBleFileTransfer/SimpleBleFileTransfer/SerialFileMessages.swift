//
//  SerialFileMessages.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class SerialFileMessages: NSObject {

    // Header Structure Defines
    let HeaderStructure_DataTypeSize: UInt8 = 1
    let HeaderStructure_Length: UInt8 = 2

    // Data Type Defines
    let DataType_UnknownType: UInt8 = 0x00
    let DataType_FileWrite: UInt8 = 0x01
    let DataType_FileRead: UInt8 = 0x02
    let DataType_FileCount: UInt8 = 0x03
    let DataType_FileCreate: UInt8 = 0x04
    let DataType_FileDelete: UInt8 = 0x05
    let DataType_FullFileRead: UInt8 = 0x06
    let DataType_SupportedFeatures: UInt8 = 0x07
    let DataType_UnsupportedCommand: UInt8 = 0xDD

    // Feature Bits
    let FeatureBits_IndexFile: UInt8 = 0x01
    let FeatureBits_DebugFile: UInt8 = 0x02
    let FeatureBits_FileWrite: UInt8 = 0x04
    let FeatureBits_FileRead: UInt8 = 0x08
    let FeatureBits_FileCreate: UInt8 = 0x10
    let FeatureBits_FileDelete: UInt8 = 0x20
    let FeatureBits_FileCount: UInt8 = 0x40
    let FeatureBits_FullFileRead: UInt8 = 0x80

    // Reserved File Indexes
    let ReservedFileIndexes_Index: UInt8 = 0x00
    let ReservedFileIndexes_Update: UInt8 = 0xFD
    let ReservedFileIndexes_Debug: UInt8 = 0xFE

    // File Operation Responses
    let FileOperationResponses_UnknownError: UInt8 = 0x00
    let FileOperationResponses_Success: UInt8 = 0x01
    let FileOperationResponses_PermissionDenied: UInt8 = 0x02
    let FileOperationResponses_OutOfSpace: UInt8 = 0x03
    let FileOperationResponses_InvalidIndex: UInt8 = 0x04
    let FileOperationResponses_FileExists: UInt8 = 0x05

    // Write Payload Defines
    let WriteRequest_FileIndexSize: UInt8 = 1
    let WriteRequest_StartPositionSize: UInt8 = 4
    let WriteRequest_DataPosition: UInt8 = 5

}
