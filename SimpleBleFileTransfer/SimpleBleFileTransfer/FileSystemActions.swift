//
//  FileSystemActions.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class FileSystemActions: NSObject {
    enum FileActions: UInt8
    {
        case SEND_DATA = 0
        case READ_DATA = 1
        case LOAD_FILE = 2
    }
    
    let fileActionStrings = ["Send Data", "Read Data", "Load File"]
}
