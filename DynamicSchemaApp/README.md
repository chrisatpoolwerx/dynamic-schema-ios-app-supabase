# Dynamic Schema iOS App

A SwiftUI-based iOS application that dynamically generates user interfaces from JSON schemas, featuring tab navigation, various field types, and real-time Supabase database integration.

## Features

- Dynamic UI Generation from JSON schemas
- Multiple Field Types: text, toggle, photo capture, choice chips
- Tab Navigation following Apple HIG
- Real-time Database integration with Supabase
- Modern Design with Apple Human Interface Guidelines
- Camera Integration with permissions

## Architecture

### Core Components

- SchemaModel.swift: Data models for parsing JSON schemas
- ChipGroup.swift: Custom choice chip component
- SupabaseService.swift: Database integration service
- HomeView.swift: Main form display with dynamic card rendering
- CardView.swift: Individual card component with field rendering
- PhotoCaptureView.swift: Camera integration wrapper
- CaptureView.swift: Dedicated photo capture interface

## Setup Instructions

### Prerequisites

- Xcode 15.0 or later
- iOS 16.0 or later
- Swift 5.9 or later
- Active Supabase project

### Installation

1. Clone or Download the project files
2. Open in Xcode: Create a new iOS project and replace contents
3. Configure Bundle: Set your bundle identifier in project settings
4. Add Resources: Ensure schema.json is added to the app bundle
5. Set Permissions: Verify Info.plist contains camera usage descriptions

### Supabase Configuration

The app is pre-configured with Supabase credentials in SupabaseService.swift

Required Database Tables:

```sql
CREATE TABLE entries (
    id SERIAL PRIMARY KEY,
    view_loaded BOOLEAN DEFAULT true,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    session_id UUID,
    app_version TEXT
);

CREATE TABLE field_updates (
    id SERIAL PRIMARY KEY,
    field_id TEXT NOT NULL,
    field_name TEXT NOT NULL,
    field_value JSONB,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    session_id UUID
);

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

## Usage

1. Launch: App loads schema and creates database entry
2. Home Tab: Displays dynamic forms based on schema
3. Capture Tab: Dedicated photo capture interface
4. Real-time Updates: All field changes automatically sync to database

## Testing

Test on physical device for camera functionality. Verify all field types render and sync properly.
