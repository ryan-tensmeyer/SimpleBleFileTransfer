//
//  WifiSettingsFile.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/24/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import Foundation

class WifiSettingsFile: NSObject {
    
    enum WifiEncryptionType: UInt8
    {
        case WEP = 0
        case WPA_TKIP = 1
        case WPA_AES = 2
        case WPA2_TKIP = 3
        case WPA2_AES = 4
        case WPA3 = 5
    }

    struct timeFileData_s
    {
        var WifiName: String
        var WifiEncryptionType: WifiEncryptionType
        var Password: String
    }

    var wifiSettingsFileData = timeFileData_s(WifiName: "", WifiEncryptionType: .WEP, Password: "")
    
    
    init(wifiName: String, wifiEncryptionType: WifiEncryptionType, password: String) {
        self.wifiSettingsFileData.WifiName = wifiName
        self.wifiSettingsFileData.WifiEncryptionType = wifiEncryptionType
        self.wifiSettingsFileData.Password = password
    }
    
    func parseData(value: [UInt8])
    {
        if value.count < (FileSystemDefines().Wifi_Name_Length + FileSystemDefines().Wifi_Encryption_Type_Length + FileSystemDefines().Wifi_Password_Length)
        {
            print("Invalid data body")
            return
        }
        
        var tempArray = value[0..<(0+FileSystemDefines().Wifi_Name_Length)]
        tempArray.append(0)
        var firstNull = tempArray.firstIndex(of: 0)
        if firstNull == nil  || firstNull == 0 {
            wifiSettingsFileData.WifiName = ""
        }else{
            let wifiName_uint8s = [UInt8](value[Int(0)...Int(firstNull!-1)])
            if let string = String(bytes: wifiName_uint8s, encoding: .utf8) {
                wifiSettingsFileData.WifiName = string
            } else {
                print("not a valid UTF-8 sequence")
            }
        }
        
        let startLocation_wifiEncryptionType = 33
        wifiSettingsFileData.WifiEncryptionType = WifiSettingsFile.WifiEncryptionType(rawValue: UInt8(value[startLocation_wifiEncryptionType])) ?? .WEP
        
        let startLocation_wifiPassword = 34
        tempArray = value[startLocation_wifiPassword..<(startLocation_wifiPassword+FileSystemDefines().Wifi_Password_Length)]
        tempArray.append(0)
        firstNull = tempArray.firstIndex(of: 0)
        if firstNull == nil || firstNull == startLocation_wifiPassword {
            wifiSettingsFileData.Password = ""
        }else {
            let password_uint8s = [UInt8](value[Int(startLocation_wifiPassword)...Int(firstNull!-1)])
            if let string = String(bytes: password_uint8s, encoding: .utf8) {
                wifiSettingsFileData.Password = string
            } else {
                print("not a valid UTF-8 sequence")
            }
        }
    }
    
    func getData() -> [UInt8] {
        var writeData_WifiName: [UInt8] = [UInt8](wifiSettingsFileData.WifiName.utf8)
        while writeData_WifiName.count < FileSystemDefines().Wifi_Name_Length {
            writeData_WifiName.append(0)
        }
        var writeData_Password: [UInt8] = [UInt8](wifiSettingsFileData.Password.utf8)
        while writeData_Password.count < FileSystemDefines().Wifi_Password_Length {
            writeData_Password.append(0)
        }
        
        return writeData_WifiName + [wifiSettingsFileData.WifiEncryptionType.rawValue] + writeData_Password
    }
    
    func get_WifiName() -> String {
        return wifiSettingsFileData.WifiName
    }
    func get_writeData_WifiEncryptionType() -> WifiEncryptionType {
        return wifiSettingsFileData.WifiEncryptionType
    }
    func get_Password() -> String {
        return wifiSettingsFileData.Password
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
        var wifiString: String

        wifiString = "Wifi Name: \(wifiSettingsFileData.WifiName) \n"
                + "Wifi Encryption Type: \(wifiSettingsFileData.WifiEncryptionType) \n"
                + "Wifi Password: \(wifiSettingsFileData.Password)"

        return wifiString;
    }
    
    func decrement_WifiEncryptionType() {
        var rawValue = wifiSettingsFileData.WifiEncryptionType.rawValue
        if rawValue > 0 {
            rawValue -= 1
        }else {
            rawValue = WifiEncryptionType.WPA3.rawValue
        }
        wifiSettingsFileData.WifiEncryptionType = WifiEncryptionType(rawValue: rawValue)!
    }
    
    func increment_WifiEncryptionType() {
        var rawValue = wifiSettingsFileData.WifiEncryptionType.rawValue
        if rawValue >= WifiEncryptionType.WPA3.rawValue {
            rawValue = 0
        }else {
            rawValue += 1
        }
        wifiSettingsFileData.WifiEncryptionType = WifiEncryptionType(rawValue: rawValue)!
    }
    
    func WifiEncryptionType_as_String() -> String {
        switch wifiSettingsFileData.WifiEncryptionType {
        case .WEP:
            return "0: WEP"
        case .WPA_TKIP:
            return "1: WPA_TKIP"
        case .WPA_AES:
            return "2: WPA_AES"
        case .WPA2_TKIP:
            return "3: WPA2_TKIP"
        case .WPA2_AES:
            return "4: WPA2_AES"
        case .WPA3:
            return "5: WPA3"
        }
    }
}
