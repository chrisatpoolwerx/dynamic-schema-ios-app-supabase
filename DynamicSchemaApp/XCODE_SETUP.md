# Xcode Project Setup Guide

## 🎯 Complete iOS Swift App with Xcode Project

The DynamicSchemaApp is now a complete, ready-to-use Xcode project with all necessary files and configurations.

## 📁 Project Structure

```
DynamicSchemaApp/
├── DynamicSchemaApp.xcodeproj/          # Complete Xcode project
│   ├── project.pbxproj                  # Project configuration
│   ├── project.xcworkspace/             # Workspace settings
│   │   └── contents.xcworkspacedata
│   └── xcshareddata/xcschemes/          # Build schemes
│       └── DynamicSchemaApp.xcscheme
├── DynamicSchemaApp.swift               # App entry point
├── Models/
│   └── SchemaModel.swift                # Data models
├── Views/
│   ├── HomeView.swift                   # Main dynamic form view
│   ├── CardView.swift                   # Field rendering
│   ├── PhotoCaptureView.swift           # Camera integration
│   └── CaptureView.swift                # Photo capture tab
├── Components/
│   └── ChipGroup.swift                  # Choice chip component
├── Services/
│   └── SupabaseService.swift            # Database integration
├── Resources/
│   └── schema.json                      # UI schema definition
├── Assets.xcassets/                     # App icons & colors
│   ├── AppIcon.appiconset/
│   └── AccentColor.colorset/
├── Preview Content/                     # SwiftUI previews
│   └── Preview Assets.xcassets/
├── Info.plist                          # App configuration
├── Package.swift                       # Swift Package Manager
├── README.md                           # Setup documentation
├── PROJECT_OVERVIEW.md                 # Technical overview
└── XCODE_SETUP.md                      # This file
```

## 🚀 How to Open and Run

### Step 1: Open in Xcode
1. **Double-click** `DynamicSchemaApp.xcodeproj` to open in Xcode
2. **Alternative**: Open Xcode → File → Open → Select `DynamicSchemaApp.xcodeproj`

### Step 2: Configure Project
1. **Select the project** in the navigator (top-left)
2. **Under "Targets"** → Select "DynamicSchemaApp"
3. **General Tab**:
   - Set your **Team** (for code signing)
   - Change **Bundle Identifier** if needed (e.g., `com.yourname.dynamicschema`)
   - Verify **Deployment Target** is iOS 16.0+

### Step 3: Build and Run
1. **Select a device** or simulator from the scheme selector
2. **Press ⌘+R** or click the "Play" button to build and run
3. **For camera testing**: Use a physical device (camera not available in simulator)

## 📱 Testing Checklist

### Simulator Testing
- [x] App launches successfully
- [x] Schema loads and displays cards
- [x] Text fields accept input
- [x] Toggle switches work
- [x] Choice chips respond to selection
- [x] Tab navigation functions
- [x] Error handling displays alerts

### Physical Device Testing
- [ ] Camera permission requests properly
- [ ] Photo capture works
- [ ] Image thumbnails display
- [ ] Photo upload to Supabase functions
- [ ] All simulator tests pass on device

## 🔧 Project Configuration

### Build Settings
- **iOS Deployment Target**: 16.0
- **Swift Version**: 5.0
- **Bundle Identifier**: com.dynamicschema.app (change as needed)
- **Code Signing**: Automatic (set your team)

### Capabilities
- **Camera Usage**: Configured in Info.plist
- **Photo Library**: Configured in Info.plist
- **Network**: HTTP requests to Supabase

### Dependencies
- **No external dependencies** - Uses only native iOS frameworks
- **SwiftUI**: For modern UI development
- **Foundation**: For networking and JSON parsing
- **AVFoundation**: For camera access
- **UIKit**: For image picker integration

## 🗄️ Supabase Database Setup

### Required Tables
The app expects these tables in your Supabase project:

```sql
-- View tracking
CREATE TABLE entries (
    id SERIAL PRIMARY KEY,
    view_loaded BOOLEAN DEFAULT true,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    session_id UUID,
    app_version TEXT
);

-- Field updates
CREATE TABLE field_updates (
    id SERIAL PRIMARY KEY,
    field_id TEXT NOT NULL,
    field_name TEXT NOT NULL,
    field_value JSONB,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    session_id UUID
);

-- Photo uploads
CREATE TABLE photo_uploads (
    id SERIAL PRIMARY KEY,
    field_id TEXT NOT NULL,
    field_name TEXT NOT NULL,
    image_data TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    session_id UUID,
    file_size INTEGER
);
```

### API Configuration
- **URL**: https://qxoyaksfqlezdzdyabdp.supabase.co
- **API Key**: Pre-configured in SupabaseService.swift
- **Authentication**: Uses anon/public key for demo purposes

## 🎨 Customization

### Modify Schema
Edit `Resources/schema.json` to change the form structure:
- Add/remove cards
- Change field types
- Modify labels and options
- Update choice chip selections

### Styling
- **Colors**: Modify in Assets.xcassets/AccentColor.colorset
- **App Icon**: Replace images in Assets.xcassets/AppIcon.appiconset
- **UI Components**: Edit individual View files for custom styling

### Database Integration
- **Change Supabase URL**: Update SupabaseService.swift
- **Add new endpoints**: Extend SupabaseService methods
- **Custom data fields**: Modify the payload structures

## 🐛 Troubleshooting

### Common Issues

1. **Build Errors**
   - Ensure Xcode 15.0+ is installed
   - Check iOS deployment target is 16.0+
   - Verify all files are properly added to target

2. **Code Signing Issues**
   - Set your development team in project settings
   - Ensure bundle identifier is unique
   - Check provisioning profiles

3. **Camera Not Working**
   - Test on physical device (not simulator)
   - Check camera permissions in device settings
   - Verify Info.plist has usage descriptions

4. **Schema Not Loading**
   - Ensure schema.json is added to app bundle
   - Check JSON syntax is valid
   - Verify file is included in build phases

5. **Supabase Connection Issues**
   - Check network connectivity
   - Verify API key and URL are correct
   - Ensure database tables exist

### Debug Console
Monitor Xcode's debug console for:
- Schema loading status
- Network request logs
- Database operation results
- Error messages and stack traces

## 📚 Next Steps

### Development
1. **Test thoroughly** on multiple devices
2. **Add unit tests** for core functionality
3. **Implement error recovery** mechanisms
4. **Add analytics** and crash reporting
5. **Optimize performance** for large schemas

### Deployment
1. **Configure release build** settings
2. **Set up App Store Connect** account
3. **Create app store listing** and screenshots
4. **Submit for review** following Apple guidelines

### Enhancement Ideas
- **Offline support** with local storage
- **Push notifications** for form updates
- **Advanced field types** (date, location, etc.)
- **Form validation** and required fields
- **Multi-language support** and localization
- **Dark mode** theme support
- **Accessibility** improvements

## ✅ Project Status

**COMPLETE AND READY FOR USE**

- ✅ Full Xcode project structure
- ✅ All Swift source files
- ✅ Asset catalogs configured
- ✅ Build schemes and workspace
- ✅ Info.plist with permissions
- ✅ Supabase integration working
- ✅ Dynamic UI generation functional
- ✅ Camera integration implemented
- ✅ Choice chips component ready
- ✅ Modern Apple HIG design
- ✅ Comprehensive documentation

**Ready to open in Xcode and run immediately!**
