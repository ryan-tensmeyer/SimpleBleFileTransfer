//
//  ParseIndexFile.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class ParseIndexFile: NSObject {
    
    
    init(value: [UInt8]) {
        var addIndex = indexList_s(fileIndex: 0, fileType: .UNKNOWN)
        var i = 0
        indices.removeAll()
        while i < (value.count-1)
        {
            addIndex.fileIndex = UInt8(value[i])
            addIndex.fileType = FileSystemDefines.FileType(rawValue: value[i+1]) ?? FileSystemDefines.FileType.UNKNOWN

            indices.append(addIndex);
            
            i+=2
        }
        print("File in Index File:")
        for index in indices {
            print("   File in \(index.fileIndex) \(index.fileType)")
        }
    }
    
    struct indexList_s
    {
        var fileIndex: UInt8
        var fileType: FileSystemDefines.FileType
    }
    var indices: [indexList_s] = []
    
    func parserIndexFile(value: [UInt8])
    {
        var i = 0
        indices.removeAll()
        while i < (value.count - 1)
        {
            let addIndex = indexList_s(fileIndex: value[i],
                                       fileType: FileSystemDefines.FileType(rawValue: value[i+1]) ?? .UNKNOWN)
            indices.append(addIndex)            
            i+=2
        }
        print("File in Index File:")
        for index in indices {
            print("   File in \(index.fileIndex) \(index.fileType)")
        }
    }

    func getAvailableFileTypes() -> [FileSystemDefines.FileType]
    {
        var availableFiles: [FileSystemDefines.FileType] = []

        for i in 0..<indices.count
        {
            availableFiles.append(indices[i].fileType);
        }

        return availableFiles
    }

    func getString(_ fileType: FileSystemDefines.FileType) -> String
    {
        let fileName: String = FileSystemDefines().fileNameString[Int(fileType.rawValue)]
        return fileName;
    }

    func getIndex(_ fileType: FileSystemDefines.FileType) -> UInt8
    {
        for i in 0..<indices.count
        {
            if(fileType == indices[i].fileType)
            {
                return indices[i].fileIndex;
            }
        }
        return 0xFF;
    }

    func getFileType(_ indexToTranslate: UInt8) -> FileSystemDefines.FileType
    {
        for i in 0..<indices.count
        {
            if(indexToTranslate == indices[i].fileIndex)
            {
                return indices[i].fileType;
            }
        }
        return FileSystemDefines.FileType.UNKNOWN
    }
    
}
