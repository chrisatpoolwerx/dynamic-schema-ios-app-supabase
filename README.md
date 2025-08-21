
Built by https://www.blackbox.ai

---

# Dynamic Schema iOS App with Supabase Integration

## Project Overview

This project is an iOS application developed using SwiftUI that dynamically generates its user interface (UI) based on a JSON schema. The app provides multi-page navigation through a TabView and features card displays with various input fields, such as text inputs, toggle switches, image capture, and choice chips. Moreover, the app maintains real-time updates to a Supabase database when views are loaded and fields are modified.

## Installation

To run this project, you'll need to have Xcode installed on your macOS. Follow these steps to set up the project:

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd DynamicSchemaApp
   ```

2. Open the Xcode project:
   ```bash
   open DynamicSchemaApp.xcodeproj
   ```

3. Make sure the `schema.json` file is included in the app bundle.

4. Ensure that you have an active internet connection to interact with the Supabase backend.

5. You might need to configure your `Info.plist` to allow camera usage by adding the `NSCameraUsageDescription` key.

## Usage

1. Launch the app on your iOS device or simulator.
2. You can navigate between the "Home" and "Capture" tabs using the TabView.
3. On the "Home" tab, you'll see user information cards generated based on the schema. Fill in the fields as required.
4. The "Capture" tab allows you to capture a photo, which can be uploaded to the associated Supabase storage.
5. All changes in the forms update in real-time to the Supabase database.

## Features

- **Dynamic UI Generation**: The UI adapts based on the JSON schema provided.
- **Multi-Page Navigation**: Utilize a TabView to switch between different views.
- **Interactive Fields**:
  - Text input fields
  - Toggle switches
  - Photo capture functionality
  - Choice chips with single and multiple selection modes
- **Real-Time Supabase Integration**: Live updates to the Supabase database on field changes.
- **Error Handling**: Displays alerts for JSON decoding failures and network issues.
- **Modern Design**: Complies with Apple Human Interface Guidelines (HIG) for a clean user experience.

## Dependencies

The project currently does not have any external dependencies listed in `package.json`, as it primarily relies on native SwiftUI libraries and the Supabase SDK for network interactions.

## Project Structure

Here’s an overview of the main components of the project:

```
DynamicSchemaApp/
│
├── DynamicSchemaApp.xcodeproj            # Xcode project configuration
├── DynamicSchemaApp.swift                 # Main entry point of the app
├── Models/
│   ├── SchemaModel.swift                  # Data models for JSON schema
│
├── Components/
│   ├── ChipGroup.swift                    # Custom component for choice chip selection
│
├── Resources/
│   ├── schema.json                        # JSON file defining the UI layout
│
├── Views/
│   ├── HomeView.swift                     # Displays cards based on schema
│   ├── CardView.swift                     # Renders individual cards with fields
│   ├── PhotoCaptureView.swift              # Handles photo capture functionality
│   ├── CaptureView.swift                   # Dedicated capture interface
│
├── Services/
│   ├── SupabaseService.swift              # Manages interactions with Supabase
│
└── Info.plist                             # App configuration including permissions
```

## Conclusion

This iOS Swift app showcases how dynamic UI generation can provide a flexible and interactive user experience while maintaining a responsive connection to a backend database. The integration of Supabase allows for real-time updates, ensuring that user inputs are accurately captured and stored.

### Notes

- Ensure you're using the correct Supabase URL and have configured the necessary authentication for the app to function correctly.
- The choice chip component is inspired by [SwiftUIChipGroup](https://github.com/Open-Bytes/SwiftUIChipGroup).