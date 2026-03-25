//
//  ImageSaver.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 28/11/25.
//

import OSLog
import UIKit

class ImageSaver: NSObject {
    let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "ImageSaver")
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_: UIImage, didFinishSavingWithError _: Error?, contextInfo _: UnsafeMutableRawPointer?) {
        logger.info("Image saved")
    }
}
