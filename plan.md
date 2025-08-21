# iOS Swift App: Dynamic Schema & Supabase Integration Plan

This plan details the creation of a SwiftUI-based iOS app that dynamically generates its UI from a JSON schema, supports multi-page navigation via a TabView, displays cards with various fields (text, toggle, photo capture, choice chips), and live-updates a Supabase database on view load and during field changes.

---

## Project Structure & Dependent Files

1. **DynamicSchemaApp.xcodeproj**  
   - Xcode project configuration for the Swift app.

2. **DynamicSchemaApp.swift**  
   - Main entry point of the app.
   - Sets up a TabView with at least two tabs: "Home" and "Capture".

3. **Models/SchemaModel.swift**  
   - Contains data models for parsing the JSON schema.
   - Defines `Schema`, `Card`, `Field`, and an enum `FieldType` (with cases: text, toggle, photo, choiceChip).
   - Includes `ChoiceOption` model for chip selections.
   - Includes error handling for JSON decode failures.

4. **Components/ChipGroup.swift**  
   - Custom SwiftUI component based on SwiftUIChipGroup (https://github.com/Open-Bytes/SwiftUIChipGroup).
   - Implements horizontal scrollable chip selection with single/multiple selection modes.
   - Styled according to Apple HIG with rounded corners and appropriate colors.

5. **Resources/schema.json**  
   - The JSON file that defines the UI layout.
   - Sample content:
     ```json
     {
       "cards": [
         {
           "title": "User Information",
           "fields": [
             { "type": "text", "label": "Name", "placeholder": "Enter your name" },
             { "type": "toggle", "label": "Receive Notifications", "value": true },
             { "type": "photo", "label": "Profile Photo" },
             { 
               "type": "choiceChip", 
               "label": "Preferred Categories", 
               "multipleSelection": true,
               "options": [
                 { "id": "tech", "title": "Technology" },
                 { "id": "design", "title": "Design" },
                 { "id": "business", "title": "Business" },
                 { "id": "health", "title": "Health" }
               ]
             }
           ]
         },
         {
           "title": "Preferences",
           "fields": [
             { "type": "toggle", "label": "Dark Mode Enabled", "value": false },
             { "type": "text", "label": "Favorite Color", "placeholder": "Enter your favorite color" },
             { 
               "type": "choiceChip", 
               "label": "Experience Level", 
               "multipleSelection": false,
               "options": [
                 { "id": "beginner", "title": "Beginner" },
                 { "id": "intermediate", "title": "Intermediate" },
                 { "id": "advanced", "title": "Advanced" }
               ]
             }
           ]
         }
       ]
     }
     ```
   - Must be added to the app bundle.

6. **Views/HomeView.swift**  
   - Loads and decodes `schema.json` using `JSONDecoder`.
   - Uses a `ForEach` to iterate over cards and display them via `CardView`.
   - In `onAppear`, invokes `SupabaseService.createViewEntry()` to record a view load.
   - Implements alerts for JSON parsing or network errors.

7. **Views/CardView.swift**  
   - Renders each card using a modern, minimalist design (rounded corners, subtle shadows, ample spacing).
   - Iterates through the card's fields:
     - **Text Field:** Uses a `TextField` with a placeholder.
     - **Toggle:** Uses a `Toggle` linked to a local state variable.
     - **Photo Capture:** Provides a `Button` that presents the photo capture view.
     - **Choice Chip:** Uses the custom `ChipGroup` component with single/multiple selection.
   - Uses `onChange` for each field to trigger live updates via `SupabaseService.updateField(...)`.

8. **Views/PhotoCaptureView.swift**  
   - Implements photo capture via a SwiftUI wrapper around `UIImagePickerController` using `UIViewControllerRepresentable`.
   - Contains a Coordinator to handle delegate methods.
   - Binds the captured image back to the calling CardView.
   - Displays an alert if camera access is denied or capture fails.

9. **Views/CaptureView.swift**  
   - Optionally, a dedicated view for comprehensive photo capture.
   - Can reuse `PhotoCaptureView` for presenting a full-screen capture interface.

10. **Services/SupabaseService.swift**  
    - A singleton service managing all Supabase interactions.
    - **createViewEntry():**
      - Called on HomeView load.
      - Sends a POST request to `https://qxoyaksfqlezdzdyabdp.supabase.co/rest/v1/entries` with JSON body containing a view load flag and timestamp.
    - **updateField(fieldID: String, fieldName: String, value: Any):**
      - Sends a PATCH request for live updates.
      - Handles choice chip selections as arrays for multiple selection or single values.
    - Uses the provided public key in the headers:
      - Header "apikey": 
        ```
        eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4b3lha3NmcWxlemR6ZHlhYmRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg1NTcxNTksImV4cCI6MjA1NDEzMzE1OX0.hT65fGyNx2d3C2PYk1YEHUZ6mrLTaDHetHc5xoijA7k
        ```
      - Header "Authorization": "Bearer <public key>"
    - Implements error handling (checks HTTP status codes, logs errors, and provides user alerts as needed).

11. **Info.plist**  
    - Add the `NSCameraUsageDescription` key with a value such as:  
      "This app requires camera access to capture profile photos for dynamic entries."

---

## Implementation Steps (File-by-File)

1. **DynamicSchemaApp.swift**
   - Import SwiftUI.
   - Define the main `App` struct.
   - Setup a `TabView` with two tabs:
     - **Home Tab:** Loads `HomeView()`
     - **Capture Tab:** Loads `CaptureView()`
   - Ensure environment objects (if necessary for state sharing) are injected.

2. **Models/SchemaModel.swift**
   - Define the `FieldType` enum:
     ```swift
     enum FieldType: String, Codable {
         case text, toggle, photo, choiceChip
     }
     ```
   - Add `ChoiceOption` struct with id and title properties.
   - Declare `Field`, `Card`, and `Schema` structs with appropriate properties including choice chip options.
   - Include initializers and implement `Codable` conformance with error handling.

3. **Components/ChipGroup.swift**
   - Implement a custom SwiftUI component inspired by SwiftUIChipGroup.
   - Support both single and multiple selection modes.
   - Use `HStack` with `ScrollView` for horizontal scrolling.
   - Apply Apple HIG styling with rounded rectangles, appropriate colors, and smooth animations.
   - Bind selected values to parent view state.

4. **Resources/schema.json**
   - Create and embed the updated sample JSON schema including choice chip fields.
   - Validate that the file is correctly bundled with the app target.

5. **Views/HomeView.swift**
   - Load the schema file from the bundle using `Bundle.main.url(forResource: "schema", withExtension: "json")`.
   - Decode the JSON into the `Schema` model; handle decoding errors by showing an alert.
   - Loop through each `Card` in the schema to render a `CardView`.
   - In `onAppear`, call `SupabaseService.shared.createViewEntry()` to log the view load event.

6. **Views/CardView.swift**
   - Create a SwiftUI view with a rounded rectangle background and shadow.
   - For each field:
     - **Text Field:** Use a `@State` variable for input and render a `TextField` with the provided placeholder.
     - **Toggle:** Use a `Toggle` bound to a boolean state variable.
     - **Photo Field:** Display a `Button` labeled with the field's label that sets a state variable to present `PhotoCaptureView` as a modal sheet.
     - **Choice Chip:** Use the custom `ChipGroup` component with appropriate selection mode.
   - Use `onChange` to invoke live updates through `SupabaseService.shared.updateField(...)` when user input changes.

7. **Views/PhotoCaptureView.swift**
   - Implement a `UIViewControllerRepresentable` struct that wraps `UIImagePickerController`.
   - Create a `Coordinator` class to act as the delegate for image picking.
   - Bind the selected image to a `@Binding var selectedImage: UIImage?` and handle cancellation.
   - Provide graceful error handling if the camera is unavailable.

8. **Views/CaptureView.swift**
   - Optionally create another view that focuses solely on photo capture.
   - Reuse `PhotoCaptureView` to enable full-screen photo gathering functionality.

9. **Services/SupabaseService.swift**
   - Create a singleton (or static instance) for network services.
   - Implement the asynchronous function `createViewEntry()` that:
     - Composes a JSON payload (e.g., `{ "view_loaded": true, "timestamp": "..." }`).
     - Configures a POST request to the Supabase endpoint with appropriate headers.
     - Uses Swift's async/await with URLSession for networking.
     - Incorporates error handling for HTTP errors and unexpected response formats.
   - Similarly, implement `updateField(fieldID: String, fieldName: String, value: Any)` to send PATCH requests for live updates.
   - Handle choice chip data serialization for both single and multiple selections.

10. **Info.plist**
    - Insert the key `NSCameraUsageDescription` with a descriptive message explaining the need for camera access.

---

## Additional Considerations

- **UI/UX:**  
  Use modern typographic styling, ample white space, and subtle shadows to adhere to Apple HIG. The TabView uses clear labels, and cards feature clean layouts with rounded corners and appropriate padding. Choice chips follow Apple's design patterns with proper spacing and selection states.

- **Error Handling:**  
  Display user alerts for JSON parse failures, network errors, and camera permission issues. Validate all network responses and use proper status codes checking.

- **Live Updates:**  
  Each UI element change triggers an update call to Supabase (debounced if necessary) to avoid flooding the server with requests. Choice chip selections are properly serialized for database storage.

- **Supabase Integration:**  
  All network calls use the provided Supabase URL and public key, and headers are configured to ensure secure communication. Choice chip data is stored as JSON arrays or single values depending on selection mode.

- **Choice Chip Component:**  
  Inspired by SwiftUIChipGroup, the component supports horizontal scrolling, smooth animations, and follows Apple HIG guidelines for selection states and accessibility.

---

## Summary

- A SwiftUI app is created with dynamic UI generation driven by a JSON schema, and a TabView provides multi-page navigation.  
- Key files include DynamicSchemaApp.swift, SchemaModel.swift, ChipGroup.swift, HomeView.swift, CardView.swift, PhotoCaptureView.swift, and SupabaseService.swift.  
- The schema.json resource defines cards with text, toggle, photo, and choice chip fields that render as modern styled cards.  
- Choice chip component supports both single and multiple selection modes with horizontal scrolling.
- Error handling is robust at JSON decode, network call, and camera access levels.  
- SupabaseService utilizes async/await to POST view events and PATCH field updates using the provided Supabase URL and public key.  
- The design follows Apple HIG guidelines with clear typography, spacing, and minimalistic aesthetics.  
- The Info.plist includes the required camera usage description for photo capture functionality.

After the plan approval, I will Breakdown the plan into logical steps and create a tracker (TODO.md) to track the execution of steps in the plan. I will overwrite this file every time to update the completed steps.
