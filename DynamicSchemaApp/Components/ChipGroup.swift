//
//  ChipGroup.swift
//  DynamicSchemaApp
//
//  Custom SwiftUI component for choice chips
//  Inspired by SwiftUIChipGroup
//

import SwiftUI

struct ChipGroup: View {
    let options: [ChoiceOption]
    let multipleSelection: Bool
    @Binding var selectedOptions: Set<String>
    
    private let spacing: CGFloat = 8
    private let chipHeight: CGFloat = 36
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(options) { option in
                    ChipView(
                        option: option,
                        isSelected: selectedOptions.contains(option.id),
                        multipleSelection: multipleSelection
                    ) {
                        handleChipTap(option: option)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func handleChipTap(option: ChoiceOption) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if multipleSelection {
                if selectedOptions.contains(option.id) {
                    selectedOptions.remove(option.id)
                } else {
                    selectedOptions.insert(option.id)
                }
            } else {
                if selectedOptions.contains(option.id) {
                    selectedOptions.removeAll()
                } else {
                    selectedOptions.removeAll()
                    selectedOptions.insert(option.id)
                }
            }
        }
    }
}

struct ChipView: View {
    let option: ChoiceOption
    let isSelected: Bool
    let multipleSelection: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if multipleSelection && isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Text(option.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Convenience Initializers
extension ChipGroup {
    init(options: [ChoiceOption], multipleSelection: Bool, selectedOptionIds: Binding<[String]>) {
        self.options = options
        self.multipleSelection = multipleSelection
        self._selectedOptions = Binding(
            get: { Set(selectedOptionIds.wrappedValue) },
            set: { selectedOptionIds.wrappedValue = Array($0) }
        )
    }
    
    init(options: [ChoiceOption], selectedOptionId: Binding<String?>) {
        self.options = options
        self.multipleSelection = false
        self._selectedOptions = Binding(
            get: { 
                if let id = selectedOptionId.wrappedValue {
                    return Set([id])
                }
                return Set()
            },
            set: { 
                selectedOptionId.wrappedValue = $0.first
            }
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Multiple Selection")
            .font(.headline)
        
        ChipGroup(
            options: [
                ChoiceOption(id: "tech", title: "Technology"),
                ChoiceOption(id: "design", title: "Design"),
                ChoiceOption(id: "business", title: "Business"),
                ChoiceOption(id: "health", title: "Health"),
                ChoiceOption(id: "education", title: "Education")
            ],
            multipleSelection: true,
            selectedOptions: .constant(Set(["tech", "design"]))
        )
        
        Text("Single Selection")
            .font(.headline)
        
        ChipGroup(
            options: [
                ChoiceOption(id: "beginner", title: "Beginner"),
                ChoiceOption(id: "intermediate", title: "Intermediate"),
                ChoiceOption(id: "advanced", title: "Advanced")
            ],
            multipleSelection: false,
            selectedOptions: .constant(Set(["intermediate"]))
        )
    }
    .padding()
}
