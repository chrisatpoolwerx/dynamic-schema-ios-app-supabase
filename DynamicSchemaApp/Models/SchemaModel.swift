//
//  SchemaModel.swift
//  DynamicSchemaApp
//
//  Schema models for dynamic UI generation
//

import Foundation

// MARK: - Field Types
enum FieldType: String, Codable, CaseIterable {
    case text = "text"
    case toggle = "toggle"
    case photo = "photo"
    case choiceChip = "choiceChip"
}

// MARK: - Choice Option Model
struct ChoiceOption: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

// MARK: - Field Model
struct Field: Codable, Identifiable {
    let id: String
    let type: FieldType
    let label: String
    let placeholder: String?
    let value: FieldValue?
    let multipleSelection: Bool?
    let options: [ChoiceOption]?
    
    init(id: String = UUID().uuidString, type: FieldType, label: String, placeholder: String? = nil, value: FieldValue? = nil, multipleSelection: Bool? = nil, options: [ChoiceOption]? = nil) {
        self.id = id
        self.type = type
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self.multipleSelection = multipleSelection
        self.options = options
    }
}

// MARK: - Field Value (supports different types)
enum FieldValue: Codable {
    case string(String)
    case bool(Bool)
    case stringArray([String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let arrayValue = try? container.decode([String].self) {
            self = .stringArray(arrayValue)
        } else {
            throw DecodingError.typeMismatch(FieldValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode FieldValue"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .stringArray(let value):
            try container.encode(value)
        }
    }
}

// MARK: - Card Model
struct Card: Codable, Identifiable {
    let id: String
    let title: String
    let fields: [Field]
    
    init(id: String = UUID().uuidString, title: String, fields: [Field]) {
        self.id = id
        self.title = title
        self.fields = fields
    }
}

// MARK: - Schema Model
struct Schema: Codable {
    let cards: [Card]
    
    init(cards: [Card]) {
        self.cards = cards
    }
}

// MARK: - Schema Loading Error
enum SchemaError: Error, LocalizedError {
    case fileNotFound
    case invalidJSON
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Schema file not found in app bundle"
        case .invalidJSON:
            return "Invalid JSON format in schema file"
        case .decodingFailed(let error):
            return "Failed to decode schema: \(error.localizedDescription)"
        }
    }
}

// MARK: - Schema Loader
class SchemaLoader: ObservableObject {
    @Published var schema: Schema?
    @Published var error: SchemaError?
    @Published var isLoading = false
    
    func loadSchema() {
        isLoading = true
        error = nil
        
        guard let url = Bundle.main.url(forResource: "schema", withExtension: "json") else {
            error = .fileNotFound
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            schema = try decoder.decode(Schema.self, from: data)
        } catch {
            if error is DecodingError {
                self.error = .decodingFailed(error)
            } else {
                self.error = .invalidJSON
            }
        }
        
        isLoading = false
    }
}
