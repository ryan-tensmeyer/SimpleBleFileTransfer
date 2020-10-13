//
//  RequestAssemblerDisassembler.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class RequestAssemblerDisassembler: NSObject {
    
    let READ_COMMAND_SIZE_BYTES: UInt16 = 0x0007
    let OVERHEAD_SERIAL_FILE_MANAGER_BYTES: UInt16 = 0x05
    
    func readMessageAssembler(fileIndex: UInt8, startPos: UInt32, readLength: UInt16) -> [UInt8]
    {
        var readData: [UInt8] = []

        readData.append(SerialService2().FileSystemMessage)
        readData.append(SerialFileMessages().DataType_FileRead)
        readData.append(UInt8((READ_COMMAND_SIZE_BYTES & 0xFF00) >> 8))
        readData.append(UInt8(READ_COMMAND_SIZE_BYTES & 0x00FF))
        readData.append(UInt8(fileIndex))
        readData.append(UInt8((startPos & 0xFF000000) >> 24))
        readData.append(UInt8((startPos & 0x00FF0000) >> 16))
        readData.append(UInt8((startPos & 0x0000FF00) >> 8))
        readData.append(UInt8(startPos & 0x000000FF))
        readData.append(UInt8((readLength & 0xFF00) >> 8))
        readData.append(UInt8(readLength & 0x00FF))

        return readData
    }

    func writeMessageAssembler(fileIndex: UInt8, startPos: UInt32, writeData: [UInt8]) -> [UInt8]
    {
        var writeMessage: [UInt8] = []
        let messageLength: UInt16 = UInt16(writeData.count) + OVERHEAD_SERIAL_FILE_MANAGER_BYTES

        // TODO do I need to do a check here if it's a valid fileType to write to?
        // Or just not display write options for those files?
        writeMessage.append(SerialService2().FileSystemMessage)
        writeMessage.append(SerialFileMessages().DataType_FileWrite)
        writeMessage.append(UInt8((messageLength & 0xFF00) >> 8))
        writeMessage.append(UInt8(messageLength & 0x00FF))
        writeMessage.append(UInt8(fileIndex))
        writeMessage.append(UInt8((startPos & 0xFF000000) >> 24))
        writeMessage.append(UInt8((startPos & 0x00FF0000) >> 16))
        writeMessage.append(UInt8((startPos & 0x0000FF00) >> 8))
        writeMessage.append(UInt8(startPos & 0x000000FF))
        writeMessage.append(contentsOf: writeData)

        return writeMessage
    }
}
