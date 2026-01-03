//
//  CameraView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 15/11/25.
//

import Foundation
import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss // dismiss when the view is done

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController() // create the camera picker
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraDevice = .rear
        picker.showsCameraControls = true
        picker.allowsEditing = false

        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {
        // no updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss() // dismiss the picker
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            parent.dismiss() // dimiss on cancel
        }
    }
}
