//
//  PhotoCaptureView.swift
//  DynamicSchemaApp
//
//  SwiftUI wrapper for UIImagePickerController
//

import SwiftUI
import UIKit
import AVFoundation

struct PhotoCaptureView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    let sourceType: UIImagePickerController.SourceType
    
    init(selectedImage: Binding<UIImage?>, isPresented: Binding<Bool>, sourceType: UIImagePickerController.SourceType = .camera) {
        self._selectedImage = selectedImage
        self._isPresented = isPresented
        self.sourceType = sourceType
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        
        if sourceType == .camera {
            picker.cameraDevice = .rear
            picker.cameraCaptureMode = .photo
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoCaptureView
        
        init(_ parent: PhotoCaptureView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct PhotoCaptureButton: View {
    let label: String
    let fieldID: String
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingSourceSelection = false
    @State private var showingCameraPermissionAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Button(action: {
                checkCameraPermission()
            }) {
                HStack {
                    Image(systemName: selectedImage != nil ? "checkmark.circle.fill" : "camera.fill")
                        .foregroundColor(selectedImage != nil ? .green : .blue)
                    
                    Text(selectedImage != nil ? "Photo Captured" : "Take Photo")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(selectedImage != nil ? .green : .blue)
                    
                    Spacer()
                    
                    if selectedImage != nil {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedImage != nil ? Color.green : Color.blue, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
        .confirmationDialog("Select Photo Source", isPresented: $showingSourceSelection) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Camera") {
                    showingImagePicker = true
                }
            }
            
            Button("Photo Library") {
                showingImagePicker = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoCaptureView(
                selectedImage: $selectedImage,
                isPresented: $showingImagePicker,
                sourceType: .camera
            )
        }
        .alert("Camera Access Required", isPresented: $showingCameraPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to take photos.")
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                uploadPhoto(image: image)
            }
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingSourceSelection = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingSourceSelection = true
                    } else {
                        showingCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showingCameraPermissionAlert = true
        @unknown default:
            showingCameraPermissionAlert = true
        }
    }
    
    private func uploadPhoto(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to data")
            return
        }
        
        Task {
            await SupabaseService.shared.uploadPhoto(
                fieldID: fieldID,
                fieldName: label,
                imageData: imageData
            )
        }
    }
}

#Preview {
    VStack {
        PhotoCaptureButton(label: "Profile Photo", fieldID: "profile-photo")
        PhotoCaptureButton(label: "Workspace Photo", fieldID: "workspace-photo")
    }
    .padding()
}
