//
//  ViewController.swift
//  SimpleBleFileTransfer
//
//  Created by Ryan Tensmeyer on 8/20/20.
//  Copyright © 2020 ifit. All rights reserved.
//

import UIKit
import CoreBluetooth
import AppCenter
import AppCenterCrashes


class ViewController: UIViewController, CBCentralManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    struct fileHeaderObject
    {
        var Index: UInt8
        var Filename: String
        var DateCreated: Date
        var DateModified: Date
        var ModifiedYear: Int
        var Version: UInt8
        var FileSize: UInt32
    }
    
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    private var debugString = ""
    
    @IBOutlet weak var Write_WifiName: UITextField!
    @IBOutlet weak var Write_WifiEncryptionType: UILabel!
    @IBOutlet weak var Write_WifiPassword: UITextField!
    
    @IBOutlet weak var Read_WifiName: UILabel!
    @IBOutlet weak var Read_WifiEncryptionType: UILabel!
    @IBOutlet weak var Read_WifiPassword: UILabel!
    
    
    private var centralManager : CBCentralManager!
    private var peripheral: CBPeripheral!
    private var peripheral_list: [CBPeripheral] = []
    private var rowSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MSAppCenter.start("3fd1f348-62ac-4483-8c8a-164e3a9b9db2", withServices:[
          MSCrashes.self
        ])
                
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        debugString = ""
        
    }
    
    func Print(_ string: String)
    {
        print(string)
        if debugString.count == 0 {
            debugString = string
        }else{
            debugString += "\n\(string)"
        }
        textView.text = debugString
        let bottom = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(bottom)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Print("Central state update")
        switch central.state {
        case .poweredOn:
            Print("Bluetooth is On, Starting scan.")
            peripheral_list.removeAll()
            centralManager.scanForPeripherals(withServices: nil,
                                              options: nil)
            case .unknown:
                Print("central.state is 'unknown'")
            case .resetting:
                Print("central.state is 'resetting'")
            case .unsupported:
                Print("central.state is 'unsupported'")
            case .unauthorized:
                Print("central.state is 'unauthorized'")
            case .poweredOff:
                Print("central.state is 'poweredOff'")
            @unknown default:
                Print("central.state **** Default *****")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let name = advertisementData["kCBAdvDataLocalName"] {    //filter devices by name
            if name as! String == "RyanBT" {
                Print("\nName   : \(name)")
                Print("UUID   : \(peripheral.identifier)")
                Print("RSSI   : \(RSSI)")
                for ad in advertisementData {
                    Print("AD Data: \(ad)")
                }
                
                peripheral_list.append(peripheral)  //add to list of devices
                picker.reloadAllComponents()        //reload devices being shown in Picker View
            }
        }
    }

    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            Print("Connected!!!")
            peripheral.discoverServices(nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            Print("\(error!)")
            
            let alert = UIAlertController(title: "Failed to Connect", message: "The app failed to connect to the device. Please go to:\n\nSettings->Bluetooth\n\nPress the (i) next to your device and select\n\n'Forget This Device'\n\nThen try again", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    var IconBLESerialService2_found = false
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == IconUUIDs.ifitControlService {
                    Print("ifitControlService found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([IconUUIDs.ifitControlServiceCmdChar,
                                                             IconUUIDs.ifitControlServiceRespChar,
                                                             IconUUIDs.ifitControlServiceCmdQueryChar,
                                                             IconUUIDs.ifitControlServiceCmdQueryRespChar], for: service)
                    return
                }
                if service.uuid == IconUUIDs.IconBLESerialService {
                    Print("IconBLESerialService found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([IconUUIDs.IconBLESerialServiceTx,
                                                             IconUUIDs.IconBLESerialServiceRx], for: service)
                    return
                }
                if service.uuid == IconUUIDs.IconBLESerialService2 {
                    Print("IconBLESerialService2 found")
                    IconBLESerialService2_found = true
                    characterists_found = 0
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([IconUUIDs.IconBLESerialService2Tx,
                                                             IconUUIDs.IconBLESerialService2Rx,
                                                             IconUUIDs.IconBLESerialService2TxDataRdy], for: service)
                    return
                }
            }
        }
    }
    
    var characterists_found = 0
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == IconUUIDs.ifitControlServiceCmdChar {
                    Print("ifitControlServiceCmdChar characteristic found")
                }else if characteristic.uuid == IconUUIDs.ifitControlServiceRespChar {
                    Print("ifitControlServiceRespChar characteristic found")
                }else if characteristic.uuid == IconUUIDs.ifitControlServiceCmdQueryChar {
                    Print("ifitControlServiceCmdQueryChar characteristic found")
                }else if characteristic.uuid == IconUUIDs.ifitControlServiceCmdQueryRespChar {
                    Print("ifitControlServiceCmdQueryRespChar characteristic found")
                }else if characteristic.uuid == IconUUIDs.IconBLESerialServiceTx {
                    Print("IconBLESerialServiceTx characteristic found")
                }else if characteristic.uuid == IconUUIDs.IconBLESerialServiceRx {
                    Print("IconBLESerialServiceRx characteristic found")
                }else if characteristic.uuid == IconUUIDs.IconBLESerialService2Tx {
                    Print("IconBLESerialService2Tx characteristic found")
                    characterists_found += 1
                }else if characteristic.uuid == IconUUIDs.IconBLESerialService2Rx {
                    Print("IconBLESerialService2Rx characteristic found")
                    characterists_found += 1
                }else if characteristic.uuid == IconUUIDs.IconBLESerialService2TxDataRdy {
                    Print("IconBLESerialService2TxDataRdy characteristic found")
                    characterists_found += 1
                    self.peripheral.setNotifyValue(true, for: characteristic)
                    self.peripheral.delegate = self
                }
            }
        }
        
        if IconBLESerialService2_found && characterists_found == 3 {
            getIndexFile()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        Print("got here didUpdateValueFor")
    }
    
    
    var readWriteObject = FileSystemRequestObject()
    var m_service: CBService?    // active service
    func getIndexFile()
    {
        Print("getIndexFile")
        setFileType(.INDEX)
        
        for service in peripheral.services! {
            if service.uuid == IconUUIDs.IconBLESerialService2 {
                m_service = service
                break
            }
        }
        
        startCommunication(m_service: m_service!)
    }
    
    func getWifiSettingsFile()
    {
        Print("getWifiSettingsFile")
        setFileType(.WIFI_SETTINGS)
        
        if peripheral.services == nil {
            Print("Could not reach the device, please restart the app")
            return
        }
        
        for service in peripheral.services! {
            if service.uuid == IconUUIDs.IconBLESerialService2 {
                m_service = service
                break
            }
        }
        
        startCommunication(m_service: m_service!)
    }
    
    func getTimeFile()
    {
        Print("getTimeFile")
        setFileType(.TIME)
        
        for service in peripheral.services! {
            if service.uuid == IconUUIDs.IconBLESerialService2 {
                m_service = service
                break
            }
        }
        
        startCommunication(m_service: m_service!)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return peripheral_list.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(peripheral_list[row].name ?? "(No Name)") - \(peripheral_list[row].identifier)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        label.text = "\(picker.selectedRow(inComponent: 0))"
        rowSelected = row
    }
    
    @IBAction func Button_scan(_ sender: Any) {
        self.centralManager.stopScan()
        peripheral_list.removeAll()
        picker.reloadAllComponents()
        self.centralManager.scanForPeripherals(withServices: nil,
        options: nil)
    }
    
    @IBOutlet weak var Button_connectAndSend: UIButton!
    @IBAction func Button_connectAndSend(_ sender: Any) {
        connectToDevice()
    }
    
    func connectToDevice() {
        IconBLESerialService2_found = false
        characterists_found = 0
        
        // Stop scan before connecting
        self.centralManager.stopScan()
        
        label.text = "\(picker.selectedRow(inComponent: 0))"
        
        self.peripheral = self.peripheral_list[rowSelected]
        self.peripheral.delegate = self
        
        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
        //self.centralManager.retrievePeripherals(withIdentifiers: [self.peripheral.identifier])
        //self.centralManager.cancelPeripheralConnection(self.peripheral)
    }
    
    @IBOutlet weak var Button_writeWifiFile: UIButton!
    @IBAction func Button_writeWifiFile(_ sender: Any) {
        if peripheral == nil {
            Print("You must be connected to the device")
        } else if indexFile.indices.count == 0 {
            Print("Index file has not beed read")
        }else {
            writeWifiSettings()            
        }
        //writeTimeFile()
    }
    
    @IBOutlet weak var Button_readWifiFile: UIButton!
    @IBAction func Button_readWifiFile(_ sender: Any) {
        if peripheral == nil {
            Print("You must be connected to the device")
        } else if indexFile.indices.count == 0 {
            Print("Index file has not beed read")
        }else {
            getWifiSettingsFile()
        }
        //getTimeFile()
    }
    
    @IBAction func Button_Clear(_ sender: Any) {
        debugString = ""
        textView.text = debugString
    }
    
    @IBAction func Button_DecrementEncryptionType(_ sender: Any) {
        wifisettingsFile.decrement_WifiEncryptionType()
        Write_WifiEncryptionType.text = wifisettingsFile.WifiEncryptionType_as_String()
    }
    
    @IBAction func Button_IncrementEncryptionType(_ sender: Any) {
        wifisettingsFile.increment_WifiEncryptionType()
        Write_WifiEncryptionType.text = wifisettingsFile.WifiEncryptionType_as_String()
    }
    
    
    
    
    
    
    ///
     
    var firstRequest: Bool = true
    var isWrite: Bool = false
    var isHeader: Bool = false
    var isUpdate: Bool = false
    var requestFileType: FileSystemDefines.FileType = .UNKNOWN
    var length: UInt16 = 0
    var position: UInt32 = 0
    var fileHeader = fileHeaderObject(Index: 0, Filename: "", DateCreated: Date(), DateModified: Date(), ModifiedYear: 0, Version: 0, FileSize: 0)
    var readData: [UInt8] = []
    var writeData: [UInt8] = []
    var updateIndex: Int = 0
    var updateDataLength: Int = 0
    let OVERHEAD_BYTES: UInt8 = 9
    let HEADER_SIZE: UInt16 = 0x002C
    let HEADER_START_POSITION: UInt32 = 0x00000000
    let BASE_START_POSITION: UInt32 = 0x0000002C
    let MTU_SIZE: Int = 73 - 8 - 3    // Basing off of the BT_RX_BUF_LEN, # - 8 - 3 (PDU overhead) = length
    var activeService: CBService?


    var loadFileData: String = ""   // Used for storing the data to load in the selected file

    // file objects
    var smartbellFile = SmartBellModelFile()
    var updateFile = UpdateFile()
    var currentTimeFile = TimeFile()
    var wifisettingsFile = WifiSettingsFile(wifiName: "", wifiEncryptionType: .WEP, password: "")
     
    var indexFile = ParseIndexFile(value: [])
        
    
    
    func setFileType(_ fileType: FileSystemDefines.FileType)
    {
        requestFileType = fileType
    }

    func setFileType(_ fileType: String)
    {
        let fileTypeIndex: UInt8 = UInt8(FileSystemDefines().fileNameString.firstIndex(of: fileType)!)
        requestFileType = FileSystemDefines.FileType(rawValue: fileTypeIndex) ?? FileSystemDefines.FileType.UNKNOWN
    }

    func setActionLength(_ actionLength: UInt16)
    {
        length = actionLength
    }

    func setStartPosition(startPosition: UInt32)
    {
        position = startPosition
    }

    func startCommunication(m_service: CBService)
    {
        // need to fetch the file header first
        requestFileHeader(m_service: m_service)
    }

    func setIsWrite(_ write: Bool)
    {
        isWrite = write
    }
    
    func toHex(values: [UInt8]) -> String
    {
        var returnString = "0x"
        for v in values {
            if v < 0x10 {
                returnString += "0"
            }
            returnString += String(v, radix: 16)
        }
        return returnString
    }

    func readCallback(_ c: CBUUID, _ value: [UInt8])
    {
        if(c.uuidString == IconUUIDs.IconBLESerialService2Tx.uuidString)
        {
            readData = value
            Print("SUCCESS: Data read " + toHex(values: readData))
            // TODO emit signal that read is complete
            if isHeader
            {
                Print("Parse the header")
                isHeader = false
                fileHeaderData(c: c, value: value)
            }
            else if(isUpdate)
            {
                // TODO don't need to do anything here
                Print("Load file write response")
                isUpdate = false
                isWrite = false

                // TODO emit the signal to send the next data
            ////    emit loadFileDataSending(requestFileType)
                return
            }
            else
            {
                Print("Parse the file body")
                fileBodyData(c: c, value: value)
                
                Read_WifiName.text = wifisettingsFile.get_WifiName()
                Read_WifiEncryptionType.text = wifisettingsFile.WifiEncryptionType_as_String()
                Read_WifiPassword.text = wifisettingsFile.get_Password()
            }
        }
        else
        {
            Print("ERROR: Unexpected read response!")
        }
    }

    func writeCallback(c: CBUUID, writtenValue: [UInt8])
    {
        Print("SUCCESS: Wrote to the \(c.uuidString)  characteristic")
        Print("DEBUG: Wrote \(writtenValue)")
    }


    // TODO need to use the INDEXed value, not the TYPEd value
    func requestFileHeader(m_service: CBService)
    {
        let message = RequestAssemblerDisassembler()
        activeService = m_service
        isHeader = true

        if(firstRequest)
        {
//            var success:Bool = connect(m_service, &CBService.characteristicRead, this, &fileSystemRequestObject.readCallback)
//            Q_ASSERT(success)
//            success = connect(m_service, &CBService.characteristicWritten, this, &fileSystemRequestObject.writeCallback)
//            Q_ASSERT(success)
//            firstRequest = false
        }

        let ss2DataRx: CBCharacteristic = get_ss2Data(m_service: m_service, uuid: IconUUIDs.IconBLESerialService2Rx)
        
        if(m_service.characteristics?.count == 0)
        {
            Print("ERROR: Can't start write because there is no valid SS2 Rx characteristic!")
        }

        // TODO comment these out when done debugging
//        connect(m_service, &QObject.destroyed, [] {Print("Sender got deleted!")})
//        connect(this, &QObject.destroyed, [] {Print("Receiver got deleted!")})

        // TODO this needs to use the Index, not the File Type
        if(requestFileType == .INDEX)
        {
            writeData = message.readMessageAssembler(fileIndex: 0, startPos: HEADER_START_POSITION, readLength: HEADER_SIZE)
        }
        else
        {
            writeData = message.readMessageAssembler(fileIndex: indexFile.getIndex(requestFileType), startPos: HEADER_START_POSITION, readLength: HEADER_SIZE)
        }
        
        let data: Data = Data(bytes: writeData, count: writeData.count)
        Print("Data to send: \([UInt8](data))")
        peripheral.writeValue(data, for: ss2DataRx, type: CBCharacteristicWriteType.withResponse)
    }

    func parseHeader(_ value: [UInt8])
    {
        var tempArray: [UInt8]
        var nameArray: [UInt8]
        tempArray = [UInt8](value[9..<(9+44)])  // TODO label magic numbers, 9 is offset of overhead, 44 is header length
        nameArray = [UInt8](tempArray[0..<25])   // TODO label magic number, 25 is filename length

        
        var dateComponents_created = DateComponents()
        dateComponents_created.hour = Int(tempArray[25])
        dateComponents_created.minute = Int(tempArray[26])
        dateComponents_created.second = Int(tempArray[27])
        dateComponents_created.year = Int(((UInt16(tempArray[30]) & 0x00FF) << 8) | UInt16(tempArray[31]))
        dateComponents_created.month = Int(tempArray[29])
        dateComponents_created.day = Int(tempArray[28])
        
        var dateComponents_modified = DateComponents()
        dateComponents_modified.hour = Int(tempArray[32])
        dateComponents_modified.minute = Int(tempArray[33])
        dateComponents_modified.second = Int(tempArray[34])
        dateComponents_modified.year = Int(((UInt16(tempArray[37]) & 0x00FF) << 8) | UInt16(tempArray[38]))
        dateComponents_modified.month = Int(tempArray[36])
        dateComponents_modified.day = Int(tempArray[35])
        
        fileHeader.Index = UInt8(value[4])
        fileHeader.Filename = String(decoding: nameArray, as: UTF8.self)
        let userCalendar = Calendar.current // user calendar
        fileHeader.DateCreated = userCalendar.date(from: dateComponents_created) ?? Date()
        fileHeader.DateModified = userCalendar.date(from: dateComponents_modified) ?? Date()
        fileHeader.Version = UInt8(tempArray[39])
        let temp_3 = ((UInt32(tempArray[40]) & 0x000000FF) << 24)
        let temp_2 = ((UInt32(tempArray[41]) & 0x000000FF) << 16)
        let temp_1 = ((UInt32(tempArray[42]) & 0x000000FF) << 8)
        let temp_0 = (UInt32(tempArray[43]) & 0x000000FF)
        fileHeader.FileSize = UInt32(temp_3 | temp_2 | temp_1 | temp_0)
    }
    
    func get_ss2Data(m_service: CBService, uuid: CBUUID) -> CBCharacteristic {
        var ss2Data: CBCharacteristic? = nil
        if m_service.characteristics == nil {
            Print("Could not find the service, please reconnect to the device or restart the app")
        }
        for characteristic in m_service.characteristics! {
            if characteristic.uuid == uuid {
                ss2Data = characteristic
                break
            }
        }
        return ss2Data!
    }

    func readDataReady()
    {
        Print("Read data ready")
        var ss2DataTx: CBCharacteristic
        if(activeService?.characteristics?.count == 0)
        {
            Print("ERROR: Can't start read because there is no valid SS2 Tx characteristic!")
            return
        }

        ss2DataTx = get_ss2Data(m_service: activeService!, uuid: IconUUIDs.IconBLESerialService2Tx)

        // read the waiting data
        peripheral.readValue(for: ss2DataTx)
    }
    
    func writeWifiSettings() {
        var foundWifiSettingsFile = false
        for index in indexFile.indices {
            if index.fileType == .WIFI_SETTINGS {
                foundWifiSettingsFile = true
                break
            }
        }
        
        if foundWifiSettingsFile {
            Print("Found Wifi Settings File")
            
            requestFileType = .WIFI_SETTINGS
            
            let localWifiName = Write_WifiName.text
            let localPassword = Write_WifiPassword.text
            
            if localWifiName == nil || localPassword == nil {
                Print("Invalid Wifi Name or Password")
                return
            }
            if localWifiName!.count > FileSystemDefines().Wifi_Name_Length {
                Print("Invalid Wifi Name - too long")
                return
            }
            if localPassword!.count > FileSystemDefines().Wifi_Password_Length {
                Print("Invalid Wifi Password - too long")
                return
            }
            
            Print("Wifi Settings to Write")
            Print("     Wifi Name: \(localWifiName!)")
            Print("     Encryption Type: \(wifisettingsFile.get_writeData_WifiEncryptionType())")
            Print("     Wifi Password: \(localPassword!)")
            
            let dataToWrite = WifiSettingsFile(wifiName: localWifiName!, wifiEncryptionType: wifisettingsFile.get_writeData_WifiEncryptionType(), password: localPassword!).getData()
            
            let messageQueueItem = MessageQueueItem(fileIndex: indexFile.getIndex(requestFileType), startPosition: BASE_START_POSITION, bytesToReadOrWrite: UInt16(dataToWrite.count), isRead: false, data: dataToWrite)
            messageItemQueue.append(messageQueueItem)
            sendFromMessageQueue()

//            var tempArray: [UInt8] = []
//            var startPosition = BASE_START_POSITION
//            while dataToWrite.count > 0 {
//                tempArray.removeAll()
//                if dataToWrite.count > Max_Data_Size {
//                    tempArray += dataToWrite[Int(0)...Int(Max_Data_Size-1)]
//                }else {
//                    tempArray = dataToWrite
//                }
//
//
//                writeData = message.writeMessageAssembler(fileIndex: indexFile.getIndex(requestFileType), startPos: startPosition, writeData: tempArray)
//                Print("Data Write command: \(writeData)")
//                writeFileData()
//
//                let writeCount = tempArray.count
//                dataToWrite.removeFirst(writeCount)
//                startPosition += UInt32(writeCount)
//            }
        }
    }
    
    func writeTimeFile() {
        var foundFile = false
        for index in indexFile.indices {
            if index.fileType == .WIFI_SETTINGS {
                foundFile = true
                break
            }
        }
        
        if foundFile {
            Print("Found Time File")
            
            let message = RequestAssemblerDisassembler()
            requestFileType = .TIME
            
            let date = Date()
            let calendar = Calendar.current
            let year: UInt8 = UInt8(calendar.component(.year, from: date) - 2000)
            let month: UInt8 = UInt8(calendar.component(.month, from: date))
            let day: UInt8 = UInt8(calendar.component(.day, from: date))
            let hour: UInt8 = UInt8(calendar.component(.hour, from: date))
            let minute: UInt8 = UInt8(calendar.component(.minute, from: date))
            let second: UInt8 = UInt8(calendar.component(.second, from: date))
            let timeDate_array: [UInt8] = [year, month, day, hour, minute, second, 0, 0]
            
            writeData = message.writeMessageAssembler(fileIndex: indexFile.getIndex(requestFileType), startPos: BASE_START_POSITION, writeData: timeDate_array)
            Print("Data Write command: \(writeData)")
            
            writeFileData()
        }
    }

    func getFileHeader() -> fileHeaderObject
    {
        return self.fileHeader
    }

    func getFileType() -> FileSystemDefines.FileType
    {
        return self.requestFileType
    }

    func getAvailableActions(_ fileType: FileSystemDefines.FileType) -> [FileSystemActions.FileActions]
    {
        var actions: [FileSystemActions.FileActions] = []

        switch (fileType) {
        case FileSystemDefines.FileType.SMARTBELL_MODEL:
            actions = smartbellFile.availableActions()
            break
        case FileSystemDefines.FileType.UPDATE:
            actions = updateFile.availableActions()
            break
        case FileSystemDefines.FileType.TIME:
            actions = currentTimeFile.availableActions()
            break
        default:
            break
        }

        return actions
    }

    func getAvailableActionsString(_ fileType: FileSystemDefines.FileType) -> [String]
    {
        var actions: [FileSystemActions.FileActions] = []
        var stringActions: [String] = []

        switch (fileType) {
        case FileSystemDefines.FileType.SMARTBELL_MODEL:
            actions = smartbellFile.availableActions()
            break
        case FileSystemDefines.FileType.UPDATE:
            actions = updateFile.availableActions()
            break
        case FileSystemDefines.FileType.TIME:
            actions = currentTimeFile.availableActions()
            break
        default:
            break
        }

        // Translate the available actions to the string names
        for i in 0..<actions.count
        {
            stringActions.append(FileSystemActions().fileActionStrings[Int(actions[i].rawValue)])
        }

        return stringActions
    }

    /*********************************************************************************
     *
     * Slot definitions
     *
    */
    
        
    struct MessageQueueItem //used when more than 64 bytes need to be sent
    {
        var fileIndex: UInt8
        var startPosition: UInt32
        var bytesToReadOrWrite: UInt16
        var isRead: Bool
        var data: [UInt8]
    }
    
    var messageItemQueue: [MessageQueueItem] = []
    
    let Max_Data_Size: UInt16 = FileSystemDefines().Max_Packet_Size - FileSystemDefines().Header_Size
    func fileHeaderData(c: CBUUID, value: [UInt8])
    {
        let message = RequestAssemblerDisassembler()
        var requestSize: UInt16

        Print("Got the file header!")
        
        // we now have the file header data, need to parse and then determine whether to read the rest or write the given data
        parseHeader(value)
        requestSize = UInt16(self.fileHeader.FileSize) - self.HEADER_SIZE
        
        if requestSize > Max_Data_Size {
            let messageQueueItem = MessageQueueItem(fileIndex: indexFile.getIndex(requestFileType), startPosition: BASE_START_POSITION, bytesToReadOrWrite: requestSize, isRead: true, data: [])
            messageItemQueue.append(messageQueueItem)
            sendFromMessageQueue()
        }else {

            // request the file body
            writeData.removeAll()
            if(.INDEX == requestFileType)
            {
                writeData = message.readMessageAssembler(fileIndex: 0, startPos: BASE_START_POSITION, readLength: requestSize)
            }
            else
            {
                writeData = message.readMessageAssembler(fileIndex: indexFile.getIndex(requestFileType), startPos: BASE_START_POSITION, readLength: requestSize)
            }

            if(isWrite)
            {
                writeFileData()
            }
            else
            {
                readFileData()
            }
        }
    }
    
    func sendFromMessageQueue() {
        if messageItemQueue.count > 0 {

            let message = RequestAssemblerDisassembler()
            var requestSize: UInt16 = Max_Data_Size
            
            if messageItemQueue[0].bytesToReadOrWrite < Max_Data_Size {
                requestSize = messageItemQueue[0].bytesToReadOrWrite
            }
            
            if messageItemQueue[0].isRead {
                writeData = message.readMessageAssembler(fileIndex: messageItemQueue[0].fileIndex, startPos: messageItemQueue[0].startPosition, readLength: requestSize)
                
                readFileData()
            }else {
                let DataToWrite: [UInt8] = [UInt8](messageItemQueue[0].data[0..<Int(requestSize)])
                writeData = message.writeMessageAssembler(fileIndex: messageItemQueue[0].fileIndex, startPos: messageItemQueue[0].startPosition, writeData: DataToWrite)

                writeFileData()
            }
        }
    }
    
    var concatMessage: [UInt8] = [] //used to piece together a long string of data from multiple commands
    func popMessageFromQueue(_ c: CBUUID, _ value: [UInt8]) -> Bool {
        
        if messageItemQueue.count == 0 {
            return false
        }

        var index = -1
        if value[1] == 2 { //if it was a 'read' command
            let bytesRead = ((UInt32(value[2]) & 0x000000FF) << 8) + (UInt32(value[3]) & 0x000000FF) - 5    //minus 5 for header information
            Print("\(bytesRead)")
            let fileIndex = value[4]
            Print("\(fileIndex)")
            let temp_3 = ((UInt32(value[5]) & 0x000000FF) << 24)
            let temp_2 = ((UInt32(value[6]) & 0x000000FF) << 16)
            let temp_1 = ((UInt32(value[7]) & 0x000000FF) << 8)
            let temp_0 = (UInt32(value[8]) & 0x000000FF)
            let startPosition = temp_3 + temp_2 + temp_1 + temp_0
            Print("\(startPosition)")
            
            var i = 0
            for item in messageItemQueue {
                var expectedBytesRead = Max_Data_Size
                if item.bytesToReadOrWrite < Max_Data_Size {
                    expectedBytesRead = item.bytesToReadOrWrite
                }
                
                if item.isRead &&
                    expectedBytesRead == bytesRead &&
                    item.fileIndex == fileIndex &&
                    item.startPosition == startPosition {
                    
                    index = i
                    break
                }
                i += 1
            }
            
            if index > -1 {
                let changeAmountsBy = bytesRead
                messageItemQueue[index].startPosition += changeAmountsBy
                messageItemQueue[index].bytesToReadOrWrite -= UInt16(changeAmountsBy)
                
                if concatMessage.count == 0 {
                    concatMessage += value
                }else {
                    let endIndex = ((UInt32(value[2]) & 0x000000FF) << 8) + (UInt32(value[3]) & 0x000000FF) + 3    //plus 3 for header offset
                    concatMessage += value[Int(9)...Int(endIndex)]
                }
                
                if messageItemQueue[index].bytesToReadOrWrite <= 0 {
                    messageItemQueue.remove(at: index)
                    readCallback(c, concatMessage)
                    concatMessage.removeAll()
                }
            }
        }
        
        
        if value[1] == 1 { //if it was a 'write' command
            let bytesRead = ((UInt32(value[2]) & 0x000000FF) << 8) + (UInt32(value[3]) & 0x000000FF) - 2
            let fileIndex = value[4]
            
            var i = 0
            for item in messageItemQueue {
                var expectedBytesRead = Max_Data_Size
                if item.bytesToReadOrWrite < Max_Data_Size {
                    expectedBytesRead = item.bytesToReadOrWrite
                }
                
                if item.isRead == false &&
                    expectedBytesRead == bytesRead &&
                    item.fileIndex == fileIndex &&
                    value[5] == 1 { //value[5] == 1 -> Success
                    
                    index = i
                    break
                }
                i += 1
            }
            
            if index > -1 {
                let changeAmountsBy = bytesRead
                messageItemQueue[index].startPosition += changeAmountsBy
                messageItemQueue[index].bytesToReadOrWrite -= UInt16(changeAmountsBy)
                
                
                if messageItemQueue[index].bytesToReadOrWrite <= 0 {
                    messageItemQueue.remove(at: index)
                    if indexFile.getFileType(fileIndex) == .WIFI_SETTINGS {
                        getWifiSettingsFile()
                    }
                }
            }
        }
        
        if index == -1 {
            return false
        }
        return true
    }

    func readFileData()
    {
        var ss2DataRx: CBCharacteristic
        if(activeService?.characteristics?.count == 0)
        {
            Print("ERROR: Can't start read because there is no valid SS2 Rx characteristic!")
            return
        }
        
        ss2DataRx = get_ss2Data(m_service: activeService!, uuid: IconUUIDs.IconBLESerialService2Rx)
        
        let data: Data = Data(bytes: writeData, count: writeData.count)
        Print("Data to send: \([UInt8](data))")
        peripheral.writeValue(data, for: ss2DataRx, type: CBCharacteristicWriteType.withResponse)
    }

    func writeFileData()
    {
        var ss2DataRx: CBCharacteristic
        if(activeService?.characteristics?.count == 0)
        {
            Print("ERROR: Can't start read because there is no valid SS2 Rx characteristic!")
            return
        }
        
        ss2DataRx = get_ss2Data(m_service: activeService!, uuid: IconUUIDs.IconBLESerialService2Rx)
        
        let data: Data = Data(bytes: writeData, count: writeData.count)
        Print("Data to send: \([UInt8](data))")
        peripheral.writeValue(data, for: ss2DataRx, type: CBCharacteristicWriteType.withResponse)
    }

    func fileBodyData(c: CBUUID, value: [UInt8])
    {
        Print("DEBUG: fileBodyData")
        var fileType: FileSystemDefines.FileType
        var fileBody: [UInt8] = []
        if value[1] == 2 { //if it was a read command
            fileBody = [UInt8](value[Int(OVERHEAD_BYTES)..<value.count])
            
            if(fileHeader.Index == 255)
            {
                // Handle debug file as special case
                fileType = FileSystemDefines.FileType.DEBUG
            }
            else if(fileHeader.Index == 0)
            {
                // Need this because the translated file function doesn't work on the initial INDEX request
                // because we don't know the INDEX to TYPE mapping yet
                fileType = FileSystemDefines.FileType.INDEX
            }
            else
            {
                // translate Index to file type
                fileType = indexFile.getFileType(fileHeader.Index)
            }
        }else { //if it was a write command
            fileBody = [UInt8](value[6..<value.count])
            
            
            let fileIndex = value[4]
            fileType = indexFile.getFileType(fileIndex)
        }
        

        // call the correct parser based on the file type
        switch(fileType)
        {
        case FileSystemDefines.FileType.INDEX:
            Print("Parse the INDEX file")
            indexFile = ParseIndexFile(value: fileBody)
            //writeWifiSettings()
            //getWifiSettingsFile()
            break
        case FileSystemDefines.FileType.DEBUG:
            Print("Parse the DEBUG file")
            break
        case FileSystemDefines.FileType.VERSION:
            Print("Parse the VERSION file")
            break
        case FileSystemDefines.FileType.TIME:
            Print("Parse the TIME file")
            currentTimeFile.parseData(value: fileBody)
            break
        case FileSystemDefines.FileType.WIFI_SETTINGS:
            Print("Parse the WIFI SETTINGS file")
            wifisettingsFile.parseData(value: fileBody)
            Print(wifisettingsFile.toString())
            break
        default:
            Print("This file is currently unhandled for parsing.")
            break
        }

        //emit fileRequestReady(c, fileBody)
    }

//    func createFileList(QComboBox *comboBox)
//    {
//        QVector<FileSystemDefines.FileType> fileList
//
//        fileList = indexFile->getAvailableFileTypes()
//        comboBox->clear()
//
//        for(int i = 0 i < fileList.count i++)
//        {
//            QString fileName = indexFile->getString(fileList.at(i))
//            comboBox->addItem(fileName)
//        }
//        comboBox->addItem("DEBUG")
//        comboBox->addItem("UPDATE")
//    }

    func sendUpdateFileData(_ m_service: CBService, _ updateData: String)
    {
        let stringToBytes: [UInt8] = Array(updateData.utf8)  // convert the string to byte array of hex values

        activeService = m_service
        updateIndex = 0

        // need to package the data to send
        writeData.removeAll()
        writeData = stringToBytes

        //debugLength = stringToBytes.count
        Print("DEBUG: size of entire update data to send: \(writeData.count)")

        //emit loadFileDataSending(FileSystemDefines.FileType.UPDATE)
    }

    func sendSmartbellModelFileData(_ m_service: CBService, _ updateData: String)
    {
        let stringToBytes: [UInt8] = Array(updateData.utf8)  // convert the string to byte array of hex values

        activeService = m_service
        updateIndex = 0

        // need to package the data to send
        writeData.removeAll()
        writeData = stringToBytes

        //debugLength = QString.number(writeData.count)
        Print("DEBUG: size of entire smartbell model data to send: \(writeData.count)")

        //emit loadFileDataSending(FileSystemDefines.FileType.SMARTBELL_MODEL)
    }

    func loadFileDataSending(_ fileType: FileSystemDefines.FileType)
    {
        var ss2DataRx: CBCharacteristic
        let message = RequestAssemblerDisassembler()
        var sendData: [UInt8]
        let tempSendData: [UInt8] = [UInt8](writeData[updateIndex..<(updateIndex+MTU_SIZE-Int(OVERHEAD_BYTES))])

        Print("DEBUG: update data write location: \(updateIndex)")

        if(updateIndex > writeData.count)
        {
            // TODO how to signal that we have finished writing the update data?
            Print("DEBUG: UPDATE WRITE COMPLETE!")
            return
        }

        updateDataLength = writeData.count

        isWrite = true
        isUpdate = true

        requestFileType = fileType

        Print("DEBUG: size of update snippet data to send: \(tempSendData.count)")

        ss2DataRx = get_ss2Data(m_service: activeService!, uuid: IconUUIDs.IconBLESerialService2Rx)

        sendData = message.writeMessageAssembler(fileIndex: indexFile.getIndex(requestFileType), startPos: UInt32(updateIndex), writeData: tempSendData)
        updateIndex += (MTU_SIZE-Int(OVERHEAD_BYTES))
        let data: Data = Data(bytes: sendData, count: sendData.count)
        peripheral.writeValue(data, for: ss2DataRx, type: CBCharacteristicWriteType.withResponse)
    }

    func fileRequestComplete(c: CBUUID, value: [UInt8])
    {
        Print("DEBUG: fileRequestComplete ")

        // TODO signal to MainWindow that the read is complete
        //emit fileRequestDone()
    }

//    func executeAvailableAction(QWidget *uiContext, CBService *m_service, QString currentFile, QString selectedAction)
//    {
//        if(FileSystemActions.fileActionStrings.at(FileSystemActions.FileActions.LOAD_FILE) == selectedAction)
//        {
//            // TODO fill the action box with an action that allows us to upload a file
//            // or just immediately popup the search box for the file?
//            Print("Upload the UPDATE file")
//            QFileDialog fileDialog
//            fileDialog.setOption(QFileDialog.DontUseNativeDialog)
//            QString fileName = fileDialog.getOpenFileName(uiContext, tr("Open Update File"), "/home", tr("Update file (*.txt)"))
//            fileDialog.close()
//
//            if(fileName.isEmpty()) {
//                // TODO Print out an error
//                Print("ERROR: Specified filename is invalid!")
//                return
//            }
//            else
//            {
//                Print("File path: " + fileName.toUtf8())
//
//                // read in the file
//                QFile file(fileName)
//
//                if(!file.open(QIODevice.ReadOnly))
//                {
//                    QMessageBox.information(uiContext, tr("FILE READ ERROR"), tr("Unable to open the file!"), file.errorString())
//                    return
//                }
//
//                QTextStream in(&file)
//                loadFileData.clear()
//
//                while (!in.atEnd())
//                {
//                    QString line = in.readLine()
//                    loadFileData.append(line)
//                }
//
//                file.close()
//
//                if(FileSystemDefines.fileNameString.at(FileSystemDefines.FileType.UPDATE) == currentFile)
//                {
//                    // send the data over the BLE
//                    sendUpdateFileData(m_service, loadFileData)
//                    return
//                }
//                else if(FileSystemDefines.fileNameString.at(FileSystemDefines.FileType.SMARTBELL_MODEL) == currentFile)
//                {
//                    sendSmartbellModelFileData(m_service, loadFileData)
//                    return
//                }
//                else
//                {
//                    // TODO throw an error
//                    Print("ERROR: invalid LOAD_FILE")
//                    return
//                }
//            }
//        }
//        else if(FileSystemActions.fileActionStrings.at(FileSystemActions.FileActions.SEND_DATA) == selectedAction)
//        {
//            RequestAssemblerDisassembler message
//            quint16 requestSize
//            var ss2DataRx: CBCharacteristic
//
//            requestSize = static_cast<quint16>(self.fileHeader.FileSize) - self.HEADER_SIZE
//
//            Print("SEND_DATA to " << currentFile)
//
//            // TODO populate a write popup
//
//            if(FileSystemDefines.fileNameString.at(FileSystemDefines.FileType.TIME) == currentFile)
//            {
//
//            }
//
//            // TODO this needs to use the Index, not the File Type
//            if(requestFileType == 0)
//            {
//                writeData = message.readMessageAssembler(0, HEADER_START_POSITION, HEADER_SIZE)
//            }
//            else
//            {
//                writeData = message.readMessageAssembler(indexFile->getIndex(requestFileType), HEADER_START_POSITION, HEADER_SIZE)
//            }
//
//            ss2DataRx = get_ss2Data(m_service: activeService!, uuid: IconUUIDs.IconBLESerialService2Rx)
//            let data: Data = Data(bytes: writeData, count: writeData.count)
//            peripheral.writeValue(data, for: ss2DataRx, type: CBCharacteristicWriteType.withResponse)
//        }
//        else if(FileSystemActions.fileActionStrings.at(FileSystemActions.FileActions.READ_DATA) == selectedAction)
//        {
//            // This case is fairly straightforward since this is a repeat request of the file body
//            // that was just requested
//            RequestAssemblerDisassembler message
//            quint16 requestSize
//            var ss2DataRx: CBCharacteristic
//
//            requestSize = static_cast<quint16>(self.fileHeader.FileSize) - self.HEADER_SIZE
//
//            Print("READ_DATA from " << currentFile)
//
//            // request the file body
//            writeData.clear()
//    //        if(0 == requestFileType)
//    //        {
//    //            writeData = message.readMessageAssembler(0, BASE_START_POSITION, requestSize)
//    //        }
//    //        else
//    //        {
//                writeData = message.readMessageAssembler(indexFile->getIndex(requestFileType), BASE_START_POSITION, requestSize)
//    //        }
//
//            readFileData()
//        }
//        else
//        {
//            Print("ERROR: invalid File Action")
//        }
//    }

    func getCurrentFileData() -> String
    {
        var fileData: String = ""

        if("TIME" == fileHeader.Filename)
        {
            fileData = currentTimeFile.toString()
        }

        return fileData
    }
    
}


extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
      switch characteristic.uuid {
        case IconUUIDs.IconBLESerialService2TxDataRdy:
            print(characteristic.value ?? "no value")
            if let characteristicData = characteristic.value {
                let byteArray = [UInt8](characteristicData)
                Print("Data: \(byteArray)")
                
                if byteArray.count == 1 && byteArray[0] == 1 {//Data Ready
                    readDataReady()
                }
                
            }
        case IconUUIDs.IconBLESerialService2Tx:
            print(characteristic.value ?? "no value")
            if let characteristicData = characteristic.value {
                let byteArray = [UInt8](characteristicData)
                Print("Data: \(byteArray)")

                if popMessageFromQueue(characteristic.uuid, byteArray) {
                    sendFromMessageQueue()
                }else {
                    readCallback(characteristic.uuid, byteArray)
                }

            }
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
      }
    }
    
}
