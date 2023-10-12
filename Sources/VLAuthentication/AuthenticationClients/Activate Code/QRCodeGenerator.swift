//
//  QRCodeGenerator.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 05/12/22.
//

import UIKit

class QRCodeGenerator {
    func generateQRCode(activationUrl:String, activationCode:String) -> UIImage? {
        let qrCodeString = activationUrl + "?code=\(activationCode)"
        // Get data from the string
        guard let data = qrCodeString.data(using: .ascii) else {return nil}
        // Get a QR CIFilter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator", parameters: nil) else {return nil}
        // Input the data
        qrFilter.setValue(data, forKey: "inputMessage")
        // Get the output image
        guard let qrImage = qrFilter.outputImage else { return nil}
//        // Scale the image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        // Do some processing to get the UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil}
        return UIImage(cgImage: cgImage)
    }
}
