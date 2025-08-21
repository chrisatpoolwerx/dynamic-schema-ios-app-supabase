//
//  SupabaseService.swift
//  DynamicSchemaApp
//
//  Service for handling Supabase database interactions
//

import Foundation

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    private let baseURL = "https://qxoyaksfqlezdzdyabdp.supabase.co"
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4b3lha3NmcWxlemR6ZHlhYmRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg1NTcxNTksImV4cCI6MjA1NDEzMzE1OX0.hT65fGyNx2d3C2PYk1YEHUZ6mrLTaDHetHc5xoijA7k"
    
    @Published var isLoading = false
    @Published var lastError: String?
    
    private init() {}
    
    // MARK: - Create View Entry
    @MainActor
    func createViewEntry() async {
        isLoading = true
        lastError = nil
        
        let endpoint = "\(baseURL)/rest/v1/entries"
        
        guard let url = URL(string: endpoint) else {
            lastError = "Invalid URL"
            isLoading = false
            return
        }
        
        let payload: [String: Any] = [
            "view_loaded": true,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "session_id": UUID().uuidString,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    print("✅ View entry created successfully")
                } else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    lastError = "HTTP \(httpResponse.statusCode): \(errorMessage)"
                    print("❌ Failed to create view entry: \(lastError ?? "")")
                }
            }
            
        } catch {
            lastError = "Network error: \(error.localizedDescription)"
            print("❌ Network error creating view entry: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Update Field
    @MainActor
    func updateField(fieldID: String, fieldName: String, value: Any) async {
        let endpoint = "\(baseURL)/rest/v1/field_updates"
        
        guard let url = URL(string: endpoint) else {
            lastError = "Invalid URL"
            return
        }
        
        let payload: [String: Any] = [
            "field_id": fieldID,
            "field_name": fieldName,
            "field_value": serializeFieldValue(value),
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "session_id": UUID().uuidString
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    print("✅ Field update sent: \(fieldName) = \(value)")
                } else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("❌ Failed to update field: HTTP \(httpResponse.statusCode): \(errorMessage)")
                }
            }
            
        } catch {
            print("❌ Network error updating field: \(error)")
        }
    }
    
    // MARK: - Update Multiple Fields (for choice chips)
    @MainActor
    func updateChoiceField(fieldID: String, fieldName: String, selectedOptions: Set<String>, multipleSelection: Bool) async {
        let value: Any = multipleSelection ? Array(selectedOptions) : (selectedOptions.first ?? "")
        await updateField(fieldID: fieldID, fieldName: fieldName, value: value)
    }
    
    // MARK: - Upload Photo
    @MainActor
    func uploadPhoto(fieldID: String, fieldName: String, imageData: Data) async {
        let endpoint = "\(baseURL)/rest/v1/photo_uploads"
        
        guard let url = URL(string: endpoint) else {
            lastError = "Invalid URL"
            return
        }
        
        // Convert image to base64 for JSON payload
        let base64Image = imageData.base64EncodedString()
        
        let payload: [String: Any] = [
            "field_id": fieldID,
            "field_name": fieldName,
            "image_data": base64Image,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "session_id": UUID().uuidString,
            "file_size": imageData.count
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    print("✅ Photo uploaded: \(fieldName)")
                } else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("❌ Failed to upload photo: HTTP \(httpResponse.statusCode): \(errorMessage)")
                }
            }
            
        } catch {
            print("❌ Network error uploading photo: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    private func serializeFieldValue(_ value: Any) -> Any {
        if let stringArray = value as? [String] {
            return stringArray
        } else if let stringSet = value as? Set<String> {
            return Array(stringSet)
        } else {
            return value
        }
    }
}

// MARK: - Error Handling
extension SupabaseService {
    func clearError() {
        lastError = nil
    }
    
    var hasError: Bool {
        return lastError != nil
    }
}
