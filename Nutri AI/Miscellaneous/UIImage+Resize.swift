//
//  UIImage+Resize.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 25/03/26.
//

import UIKit

extension UIImage {
    /// Resizes the image so its longest edge is at most `maxDimension` points.
    /// Maintains aspect ratio. Returns the original image if already small enough.
    func resizedForUpload(maxPixelDimension: CGFloat = 1024) -> UIImage {
        let pixelWidth = size.width * scale
        let pixelHeight = size.height * scale
        let currentMax = max(pixelWidth, pixelHeight)
        guard currentMax > maxPixelDimension else { return self }

        let ratio = maxPixelDimension / currentMax
        let newSize = CGSize(width: pixelWidth * ratio, height: pixelHeight * ratio)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
