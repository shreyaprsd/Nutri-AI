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
    func resizedForUpload(maxDimension: CGFloat = 1024) -> UIImage {
        let currentMax = max(size.width, size.height)
        guard currentMax > maxDimension else { return self }

        let scale = maxDimension / currentMax
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
