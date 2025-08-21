//
//  CardView.swift
//  DynamicSchemaApp
//
//  Dynamic card view that renders fields based on schema
//

import SwiftUI

struct CardView: View {
    let card: Card
    @State private var fieldValues: [String: Any] = [:]
    @State private var choiceSelections: [String: Set<String>] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Card Title
            Text(card.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.bottom, 8)
            
            // Dynamic Fields
            ForEach(card.fields) { field in
                fieldView(for: field)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .onAppear {
            initializeFieldValues()
        }
    }
    
    @ViewBuilder
    private func fieldView(for field: Field) -> some View {
        switch field.type {
        case .text:
            textFieldView(for: field)
        case .toggle:
            toggleFieldView(for: field)
        case .photo:
            photoFieldView(for: field)
        case .choiceChip:
            choiceChipFieldView(for: field)
        }
    }
    
    // MARK: - Text Field
    private func textFieldView(for field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(field.label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            TextField(field.placeholder ?? "", text: Binding(
                get: { fieldValues[field.id] as? String ?? "" },
                set: { newValue in
                    fieldValues[field.id] = newValue
                    updateField(field: field, value: newValue)
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .font(.system(size: 15))
        }
    }
    
    // MARK: - Toggle Field
    private func toggleFieldView(for field: Field) -> some View {
        HStack {
            Text(field.label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { 
                    if let value = fieldValues[field.id] as? Bool {
                        return value
                    }
                    // Use default value from schema if available
                    if case .bool(let defaultValue) = field.value {
                        return defaultValue
                    }
                    return false
                },
                set: { newValue in
                    fieldValues[field.id] = newValue
                    updateField(field: field, value: newValue)
                }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
    
    // MARK: - Photo Field
    private func photoFieldView(for field: Field) -> some View {
        PhotoCaptureButton(label: field.label, fieldID: field.id)
    }
    
    // MARK: - Choice Chip Field
    private func choiceChipFieldView(for field: Field) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(field.label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            if let options = field.options {
                ChipGroup(
                    options: options,
                    multipleSelection: field.multipleSelection ?? false,
                    selectedOptions: Binding(
                        get: { choiceSelections[field.id] ?? Set() },
                        set: { newSelection in
                            choiceSelections[field.id] = newSelection
                            updateChoiceField(field: field, selectedOptions: newSelection)
                        }
                    )
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func initializeFieldValues() {
        for field in card.fields {
            // Initialize with default values from schema
            switch field.value {
            case .string(let value):
                fieldValues[field.id] = value
            case .bool(let value):
                fieldValues[field.id] = value
            case .stringArray(let value):
                choiceSelections[field.id] = Set(value)
            case .none:
                // Set default values based on field type
                switch field.type {
                case .text:
                    fieldValues[field.id] = ""
                case .toggle:
                    fieldValues[field.id] = false
                case .photo:
                    fieldValues[field.id] = nil
                case .choiceChip:
                    choiceSelections[field.id] = Set()
                }
            }
        }
    }
    
    private func updateField(field: Field, value: Any) {
        Task {
            await SupabaseService.shared.updateField(
                fieldID: field.id,
                fieldName: field.label,
                value: value
            )
        }
    }
    
    private func updateChoiceField(field: Field, selectedOptions: Set<String>) {
        Task {
            await SupabaseService.shared.updateChoiceField(
                fieldID: field.id,
                fieldName: field.label,
                selectedOptions: selectedOptions,
                multipleSelection: field.multipleSelection ?? false
            )
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            CardView(card: Card(
                title: "Sample Card",
                fields: [
                    Field(type: .text, label: "Name", placeholder: "Enter your name"),
                    Field(type: .toggle, label: "Enable Notifications", value: .bool(true)),
                    Field(type: .photo, label: "Profile Photo"),
                    Field(
                        type: .choiceChip,
                        label: "Categories",
                        multipleSelection: true,
                        options: [
                            ChoiceOption(id: "tech", title: "Technology"),
                            ChoiceOption(id: "design", title: "Design"),
                            ChoiceOption(id: "business", title: "Business")
                        ]
                    )
                ]
            ))
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}
