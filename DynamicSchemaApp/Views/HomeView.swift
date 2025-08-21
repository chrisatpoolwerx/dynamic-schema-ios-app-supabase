//
//  HomeView.swift
//  DynamicSchemaApp
//
//  Main view that loads schema and displays dynamic cards
//

import SwiftUI

struct HomeView: View {
    @StateObject private var schemaLoader = SchemaLoader()
    @StateObject private var supabaseService = SupabaseService.shared
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if schemaLoader.isLoading {
                    loadingView
                } else if let schema = schemaLoader.schema {
                    contentView(schema: schema)
                } else {
                    errorView
                }
            }
            .navigationTitle("Dynamic Forms")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadSchemaAndCreateEntry()
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("Retry") {
                    loadSchemaAndCreateEntry()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(schemaLoader.error?.localizedDescription ?? "An unknown error occurred")
            }
            .alert("Network Error", isPresented: .constant(supabaseService.hasError)) {
                Button("OK") {
                    supabaseService.clearError()
                }
            } message: {
                Text(supabaseService.lastError ?? "Network operation failed")
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading Schema...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Content View
    private func contentView(schema: Schema) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dynamic Form Builder")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Fill out the forms below. Your responses are automatically saved.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
                // Cards
                ForEach(schema.cards) { card in
                    CardView(card: card)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
                
                // Footer
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Auto-saved to database")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Powered by Dynamic Schema Engine")
                        .font(.system(size: 12))
                        .foregroundColor(.tertiary)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .refreshable {
            await refreshData()
        }
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Failed to Load Schema")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(schemaLoader.error?.localizedDescription ?? "An unknown error occurred while loading the form schema.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Try Again") {
                loadSchemaAndCreateEntry()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    private func loadSchemaAndCreateEntry() {
        schemaLoader.loadSchema()
        
        // Create view entry in Supabase
        Task {
            await supabaseService.createViewEntry()
        }
        
        // Show error alert if schema loading failed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if schemaLoader.error != nil {
                showingErrorAlert = true
            }
        }
    }
    
    @MainActor
    private func refreshData() async {
        schemaLoader.loadSchema()
        await supabaseService.createViewEntry()
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
