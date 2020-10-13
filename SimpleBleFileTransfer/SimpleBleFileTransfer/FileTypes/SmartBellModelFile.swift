//
//  SmartBellModelFile.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class SmartBellModelFile: NSObject {
    func writeData(dataToWrite: [UInt8])
    {

    }

    func availableActions() -> [FileSystemActions.FileActions]
    {
        var actions: [FileSystemActions.FileActions] = []

        actions.append(FileSystemActions.FileActions.LOAD_FILE)

        return actions
    }
}
