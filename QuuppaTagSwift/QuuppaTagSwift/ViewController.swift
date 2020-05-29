//
//  ViewController.swift
//  QuuppaTagSwift
//
//  Created by Michael Vartanian on 5/27/20.
//  Copyright © 2020 Michael Vartanian. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

let CRC8POLY = CUnsignedChar(0x97)
let WIDTH = CUnsignedChar(8)
let TOPBIT = CUnsignedChar((1 << (WIDTH - 1)))

class ViewController: UIViewController, CBPeripheralManagerDelegate {

    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

    @IBOutlet var headerValue: UILabel!
    @IBOutlet var checksumValue: UILabel!
    @IBOutlet var dfFieldValue: UILabel!
    @IBOutlet var uUIDValue: UILabel!
    @IBOutlet var majorValue: UILabel!
    @IBOutlet var minorValue: UILabel!

    @IBOutlet var quupaTagText1: UITextField!
    @IBOutlet var quupaTagText2: UITextField!
    @IBOutlet var quupaTagText3: UITextField!
    @IBOutlet var quupaTagText4: UITextField!
    @IBOutlet var quupaTagText5: UITextField!
    @IBOutlet var quupaTagText6: UITextField!

    @IBOutlet var measuredPowerValue: UILabel!

    @IBOutlet var beaconButton: UIButton!
    @IBOutlet var updateUUIDButton: UIButton!

    let header = CUnsignedChar(0x1a)
    let major = 0x0baa
    let minor = 0x9730
    let dfField0 = CUnsignedChar(0x67)
    let dfField1 = CUnsignedChar(0xf7)
    let dfField2 = CUnsignedChar(0xdb)
    let dfField3 = CUnsignedChar(0x34)
    let dfField4 = CUnsignedChar(0xc4)
    let dfField5 = CUnsignedChar(0x03)
    let dfField6 = CUnsignedChar(0x8e)
    let dfField7 = CUnsignedChar(0x5c)

    let measuredPower = 0x56

    // form UUID with correct CRC
    var toBeCRCd = [CUnsignedChar](repeating: 0, count: 8)
    var tmpUUID = ""
    var advUUID = ""
    var beaconStatus = "OFF"

    override func viewDidLoad() {
        super.viewDidLoad()

        beaconStatus = "OFF"
        beaconButton.backgroundColor = UIColor(red: 85/255, green: 139/255, blue: 224/255, alpha: 1.0)

        let dfField = String(dfField0, radix:16) + String(dfField1, radix:16) + String(dfField2, radix:16) + String(dfField3, radix:16) + String(dfField4, radix:16) + String(dfField5, radix:16) + String(dfField6, radix:16) + String(dfField7, radix:16)
        print(dfField)
        headerValue.text = String(format:"%02X", header)
        dfFieldValue.text = String(format:"%llX", dfField)
        majorValue.text = String(format:"%04X", major)
        minorValue.text = String(format:"%04X", minor)
        measuredPowerValue.text = String(format:"%02X", measuredPower)

        quupaTagText1.text = "11"
        quupaTagText2.text = "22"
        quupaTagText3.text = "33"
        quupaTagText4.text = "44"
        quupaTagText5.text = "55"
        quupaTagText6.text = "66"

        toBeCRCd[0] = CUnsignedChar(0x15)
        toBeCRCd[1] = CUnsignedChar(header)
        toBeCRCd[2] = CUnsignedChar(UInt(quupaTagText1.text!, radix:16)!)
        toBeCRCd[3] = CUnsignedChar(UInt(quupaTagText2.text!, radix:16)!)
        toBeCRCd[4] = CUnsignedChar(UInt(quupaTagText3.text!, radix:16)!)
        toBeCRCd[5] = CUnsignedChar(UInt(quupaTagText4.text!, radix:16)!)
        toBeCRCd[6] = CUnsignedChar(UInt(quupaTagText5.text!, radix:16)!)
        toBeCRCd[7] = CUnsignedChar(UInt(quupaTagText6.text!, radix:16)!)

        var quuppaTagID = updateQuuppaTagID(input: toBeCRCd)

        print(quuppaTagID)

        print(toBeCRCd)

        let checksum = calculateChecksum(input: toBeCRCd)
        print(checksum)

        checksumValue.text = String(checksum, radix: 16)
        (tmpUUID, advUUID) = updateUUID(header: toBeCRCd[1], checksum: checksum, quuppaTagID: toBeCRCd)
        print(tmpUUID)
        print(advUUID)
        uUIDValue.text = tmpUUID
    }

    func u8CRCm(message: UInt8, remainderInput: UInt8) -> UInt8 {
        var remainder = remainderInput
        remainder ^= message;
        // Perform modulo-2 division, a bit at a time.
        for _ in 1...8 {
            // Try to divide the current data bit.
            if ((remainder & TOPBIT) != 0){
                remainder = (remainder << 1) ^ CRC8POLY;
            } else {
                remainder = (remainder << 1);
            }
        }
        return remainder
    }

    // Calculate/assemble UUID without and with dashes/hypens
    func updateUUID(header: UInt8, checksum: UInt8, quuppaTagID: [UInt8]) -> (String, String) {
        let tmpUUID = String(header) + String(format:"%02X", toBeCRCd[2]) + String(format:"%02X", toBeCRCd[3]) + String(format:"%02X", toBeCRCd[4]) + String(format:"%02X",toBeCRCd[5]) + String(format:"%02X", toBeCRCd[6]) + String(format:"%02X",toBeCRCd[7]) + String(format:"%02X", checksum) + String(format:"%02X", dfField0) + String(format:"%02X", dfField1) + String(format:"%02X", dfField2) + String(format:"%02X", dfField3) + String(format:"%02X", dfField4) + String(format:"%02X", dfField5) + String(format:"%02X", dfField6) + String(format:"%02X", dfField7)

        let advUUID = String(format:"%02X", header) + String(format:"%02X",toBeCRCd[2]) + String(format:"%02X", toBeCRCd[3]) + String(format:"%02X", toBeCRCd[4]) + "-" + String(format:"%02X",toBeCRCd[5]) + String(format:"%02X", toBeCRCd[6]) + "-" + String(format:"%02X",toBeCRCd[7]) + String(format:"%02X", checksum) + "-" + String(format:"%02X", dfField0) + String(format:"%02X", dfField1) + "-" + String(format:"%02X", dfField2) + String(format:"%02X", dfField3) + String(format:"%02X", dfField4) + String(format:"%02X", dfField5) + String(format:"%02X", dfField6) + String(format:"%02X", dfField7)

        return (tmpUUID, advUUID)
    }

    func calculateChecksum(input: [UInt8]) -> UInt8 {
        var checksum = CUnsignedChar(0)
        for i in 0...7 {
            checksum = u8CRCm(message: input[i], remainderInput: checksum)
        }
        return checksum
    }

    func updateQuuppaTagID(input: [UInt8]) -> String {
        var quuppaTagID = ""
        for i in 2...7 {
            quuppaTagID = quuppaTagID + String(toBeCRCd[i], radix: 16)
        }
        return quuppaTagID
    }

    @IBAction func toggleBeaconButton(_ sender: Any) {
        if beaconStatus == "OFF" {
            beaconButton.setTitle("ON", for: .normal)
            beaconStatus = "ON"
            beaconButton.backgroundColor = UIColor(red: 28/255, green: 85/255, blue: 176/255, alpha: 1.0)
            startLocalBeacon()
        } else {
            beaconButton.setTitle("OFF", for: .normal)

            beaconButton.backgroundColor = UIColor(red: 85/255, green: 139/255, blue: 224/255, alpha: 1.0)
            beaconStatus = "OFF"
            stopLocalBeacon()
        }
    }

    @IBAction func updateUUID(_ sender: Any) {
        print("Updating UUID...")
        toBeCRCd[2] = CUnsignedChar(UInt(quupaTagText1.text!, radix:16)!)
        toBeCRCd[3] = CUnsignedChar(UInt(quupaTagText2.text!, radix:16)!)
        toBeCRCd[4] = CUnsignedChar(UInt(quupaTagText3.text!, radix:16)!)
        toBeCRCd[5] = CUnsignedChar(UInt(quupaTagText4.text!, radix:16)!)
        toBeCRCd[6] = CUnsignedChar(UInt(quupaTagText5.text!, radix:16)!)
        toBeCRCd[7] = CUnsignedChar(UInt(quupaTagText6.text!, radix:16)!)
        var quuppaTagID = updateQuuppaTagID(input: toBeCRCd)
        let checksum = calculateChecksum(input: toBeCRCd)
        checksumValue.text = String(checksum, radix:16)
        (tmpUUID, advUUID) = updateUUID(header: toBeCRCd[1], checksum: checksum, quuppaTagID: toBeCRCd)
        uUIDValue.text = tmpUUID
    }

    func startLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }

        let uuid = UUID(uuidString: advUUID)
        let localBeaconMajor : CLBeaconMajorValue = CLBeaconMajorValue(major)
        let localBeaconMinor : CLBeaconMinorValue = CLBeaconMinorValue(minor)
        let identifier = "QuuppaTag"

        localBeacon = CLBeaconRegion(uuid: uuid!, major: localBeaconMajor, minor: localBeaconMinor, identifier: identifier)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: 86)
    }

    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(((beaconPeripheralData as NSDictionary) as! [String : Any]))
            print("Start Advertising...")
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

