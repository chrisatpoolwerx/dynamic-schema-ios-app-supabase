//
//  CaptureView.swift
//  DynamicSchemaApp
//
//  Dedicated view for photo capture functionality
//

import SwiftUI
import AVFoundation

struct CaptureView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCameraPermissionAlert = false
    @State private var capturedImages: [CapturedImage] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Main Capture Button
                        mainCaptureButton
                        
                        // Captured Images Gallery
                        if !capturedImages.isEmpty {
                            capturedImagesView
                        }
                        
                        // Instructions
                        instructionsView
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Photo Capture")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingImagePicker) {
                PhotoCaptureView(
                    selectedImage: $selectedImage,
                    isPresented: $showingImagePicker
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
                    addCapturedImage(image)
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capture Photos")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Take photos for your dynamic forms. All images are automatically uploaded and linked to your entries.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Main Capture Button
    private var mainCaptureButton: some View {
        Button(action: {
            checkCameraPermission()
        }) {
            VStack(spacing: 16) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                
                Text("Take Photo")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Tap to capture")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(showingImagePicker ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showingImagePicker)
    }
    
    // MARK: - Captured Images View
    private var capturedImagesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Captures")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(capturedImages.count) photo\(capturedImages.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(capturedImages) { capturedImage in
                    capturedImageThumbnail(capturedImage)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func capturedImageThumbnail(_ capturedImage: CapturedImage) -> some View {
        VStack(spacing: 8) {
            Image(uiImage: capturedImage.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            Text(capturedImage.timestamp, style: .time)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Instructions View
    private var instructionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How it works")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                instructionRow(
                    icon: "1.circle.fill",
                    title: "Tap the camera button",
                    description: "Grant camera permission if prompted"
                )
                
                instructionRow(
                    icon: "2.circle.fill",
                    title: "Take your photo",
                    description: "Frame your shot and capture"
                )
                
                instructionRow(
                    icon: "3.circle.fill",
                    title: "Auto-upload",
                    description: "Photos are automatically saved to your account"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.top, 20)
    }
    
    private func instructionRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingImagePicker = true
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
    
    private func addCapturedImage(_ image: UIImage) {
        let capturedImage = CapturedImage(
            id: UUID().uuidString,
            image: image,
            timestamp: Date()
        )
        
        withAnimation(.easeInOut) {
            capturedImages.insert(capturedImage, at: 0)
        }
        
        // Upload to Supabase
        uploadImage(capturedImage)
    }
    
    private func uploadImage(_ capturedImage: CapturedImage) {
        guard let imageData = capturedImage.image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to data")
            return
        }
        
        Task {
            await SupabaseService.shared.uploadPhoto(
                fieldID: capturedImage.id,
                fieldName: "Capture Tab Photo",
                imageData: imageData
            )
        }
    }
}

// MARK: - Captured Image Model
struct CapturedImage: Identifiable {
    let id: String
    let image: UIImage
    let timestamp: Date
}

// MARK: - Preview
#Preview {
    CaptureView()
}
