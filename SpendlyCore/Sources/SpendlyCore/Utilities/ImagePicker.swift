import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit

/// A SwiftUI wrapper around UIImagePickerController for selecting images
/// from the camera or photo library.
public struct ImagePicker: UIViewControllerRepresentable {
    @Binding public var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    public var sourceType: UIImagePickerController.SourceType

    public init(selectedImage: Binding<UIImage?>, sourceType: UIImagePickerController.SourceType = .photoLibrary) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        public init(_ parent: ImagePicker) {
            self.parent = parent
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif
