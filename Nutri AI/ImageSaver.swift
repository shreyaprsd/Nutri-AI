//
//  ImageSaver.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 28/11/25.
//

import UIKit

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_: UIImage, didFinishSavingWithError _: Error?, contextInfo _: UnsafeMutableRawPointer?) {
        print("Save Finished!")
    }
}
