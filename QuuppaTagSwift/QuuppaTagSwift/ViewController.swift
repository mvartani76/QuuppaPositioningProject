//
//  ViewController.swift
//  QuuppaTagSwift
//
//  Created by Michael Vartanian on 5/27/20.
//  Copyright © 2020 Michael Vartanian. All rights reserved.
//

import UIKit

let CRC8POLY = CUnsignedChar(0x97)
let WIDTH = CUnsignedChar(8)
let TOPBIT = CUnsignedChar((1 << (WIDTH - 1)))

class ViewController: UIViewController {
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

    let header = CUnsignedChar(0x1a)
    let major = 0x0baa
    let minor = 0x9730
    let dfField = 0x67f7db34c4038e5c
    let measuredPower = 0x56

    // form UUID with correct CRC
    var toBeCRCd = [CUnsignedChar](repeating: 0, count: 8)
    var tmpUUID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
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

        var quuppaTagID = ""
        for i in 2...7 {
            quuppaTagID = quuppaTagID + String(toBeCRCd[i], radix: 16)
        }
        print(quuppaTagID)

        print(toBeCRCd)

        var checksum = CUnsignedChar(0)
        for i in 0...7 {
            checksum = u8CRCm(message: toBeCRCd[i], remainderInput: checksum)
        }

        tmpUUID = String(header, radix:16) + quuppaTagID + String(checksum, radix: 16) + String(checksum, radix: 16) + String(dfField, radix: 16)
        print(tmpUUID)

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

}

