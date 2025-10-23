# 🎯 Hotspot Creation Feature Guide

## Overview

The hotspot creation feature allows sellers to add **interactive navigation arrows** directly on 360° images, enabling visitors to click on doors and passages to seamlessly move between rooms in a virtual tour.

This feature has been implemented in **both React and Flutter apps**.

---

## ✨ Features

### Visual Hotspot Positioning
- **Click/Tap to Place**: Sellers can click (React) or tap (Flutter) directly on doors/passages in 360° images
- **Visual Markers**: Circular purple arrows appear at hotspot positions
- **Real-time Preview**: See exactly where hotspots will appear before confirming
- **Interactive Feedback**: Hotspots change color on hover/tap and show tooltips

### Smart Coordinate Calculation
- Automatically converts click/tap positions to **yaw** and **pitch** coordinates
- Uses equirectangular projection math for accurate 3D positioning
- Displays coordinates in degrees for verification

### Target Room Selection
- Modal dialog shows available target rooms
- Only shows rooms that exist (can't link to non-existent rooms)
- Clear labeling: "Go to [Room Name]"

### Hotspot Management
- **Add Multiple Hotspots**: Create as many connections as needed
- **Remove Hotspots**: Delete unwanted hotspots with one click
- **List View**: See all hotspots with their coordinates
- **Selection**: Click on markers to select and view details

---

## 🚀 How to Use

### React App (Seller Upload Page)

1. **Navigate to Upload Property**
   - Go to `/upload` route in the React app

2. **Complete Steps 1 & 2**
   - **Step 1**: Fill in basic property information
   - **Step 2**: Upload 360° images for each room/scene
   - Click **Next** after uploading images

3. **Step 3: Add Hotspots** (NEW!)
   - You'll see each uploaded scene with its 360° image preview
   - **Click on doors/passages** in the image where you want navigation arrows
   - A modal appears asking "Select Target Room"
   - **Choose the room** this door/passage leads to
   - A purple arrow marker appears at the clicked position
   - Repeat for all connections between rooms

4. **Step 4: Review & Submit**
   - Review shows: `Scene name (X images, Y hotspots)`
   - Submit the property

### Flutter App (Property Upload Screen)

1. **Open Property Upload**
   - Navigate to the Property Upload screen

2. **Complete Steps 1 & 2**
   - **Step 1**: Enter basic property details
   - **Step 2**: Add scenes and upload 360° images
   - Tap **Continue** after uploading

3. **Step 3: Add Hotspots** (NEW!)
   - Each scene shows its first 360° image
   - **Tap on doors/passages** in the image
   - A dialog appears: "Select Target Room"
   - **Tap the target room** button
   - A purple arrow marker appears on the image
   - Repeat for all room connections

4. **Step 4: Review & Submit**
   - Review shows hotspot counts for each scene
   - Tap **Submit Property**

---

## 🎨 UI Components

### React Components

#### `<HotspotEditor />` Component
**Location**: `react_initial_pages/src/components/HotspotEditor.js`

**Props**:
- `scene`: Object with scene data and images
- `allScenes`: Array of all scenes for target selection
- `onHotspotsChange`: Callback when hotspots are added/removed

**Features**:
- Clickable equirectangular image preview
- Visual hotspot markers with tooltips
- Target room selector modal
- Hotspots list with remove buttons
- Instructions panel

**CSS**: `react_initial_pages/src/styles/HotspotEditor.css`

#### Integrated into `<SellerUpload />`
**Location**: `react_initial_pages/src/components/SellerUpload.js`

**Changes**:
- Added Step 3: "Add Hotspots"
- Each scene gets a `hotspots` array
- `handleHotspotsChange()` function updates scene hotspots
- Review step shows hotspot counts

### Flutter Widgets

#### `HotspotEditor` Widget
**Location**: `flutter_app/lib/screens/upload/widgets/hotspot_editor.dart`

**Parameters**:
- `scene`: Scene model with image paths
- `allScenes`: List of all scenes
- `onHotspotsChanged`: Callback with hotspot list

**Features**:
- `GestureDetector` on image for tap detection
- Positioned hotspot markers with animations
- AlertDialog for target selection
- Hotspots list with delete buttons
- Instructions container

#### Integrated into `PropertyUploadScreen`
**Location**: `flutter_app/lib/screens/upload/property_upload_screen.dart`

**Changes**:
- Added Step 3: "Add Hotspots"
- `_sceneHotspots` Map to store hotspots per scene
- `_buildHotspotsStep()` method
- Review step shows detailed hotspot counts

---

## 🔢 Coordinate System

### Equirectangular Projection Math

The hotspot positioning uses equirectangular (lat/long) projection formulas:

```javascript
// Convert pixel position to spherical coordinates
const yaw = (x / imageWidth) * 2π - π      // Horizontal angle (-π to π)
const pitch = (y / imageHeight) * π - π/2  // Vertical angle (-π/2 to π/2)
```

**Yaw**: Horizontal rotation (-180° to +180°)
- -180° = Far left
- 0° = Center
- +180° = Far right

**Pitch**: Vertical rotation (-90° to +90°)
- -90° = Looking straight down
- 0° = Looking straight ahead
- +90° = Looking straight up

---

## 🎯 Hotspot Data Model

### React (JavaScript)
```javascript
{
  id: 1234567890,              // Timestamp
  x: 150,                       // Pixel X position
  y: 200,                       // Pixel Y position
  yaw: -0.785,                  // Radians
  pitch: 0.261,                 // Radians
  targetSceneId: "scene-123",   // Target scene ID
  targetSceneName: "Kitchen",   // Display name
  title: "Go to Kitchen"        // Hotspot title
}
```

### Flutter (Dart)
```dart
class HotspotModel {
  final String id;
  final double x;
  final double y;
  final double yaw;
  final double pitch;
  final String targetSceneId;
  final String targetSceneName;
  final String title;
}
```

---

## 🎨 Visual Design

### Hotspot Marker Styling

**Default State**:
- 50px circular button
- Purple background (`#667EEA`)
- White border (3px)
- White arrow icon (→)
- Drop shadow for depth

**Hover/Selected State**:
- Scales to 120%
- Changes to pink (`#F5576C`)
- Elevated z-index

**Preview State** (while positioning):
- Yellow/amber color (`#FBBF18`)
- Pulsing animation
- Question mark icon (?)

### Color Palette
- **Primary**: `#667EEA` (Purple) - Navigation hotspots
- **Accent**: `#F5576C` (Pink) - Hover/selected state
- **Preview**: `#FBBF18` (Amber) - Temporary placement
- **Info**: `#3B82F6` (Blue) - Instructions
- **Danger**: `#EF4444` (Red) - Delete button

---

## 📋 User Guidance

### In-App Instructions

Both apps include:
1. **Info boxes** explaining the feature
2. **Step-by-step instructions**:
   - Tap/click on doors or passages
   - Select target room
   - Navigation arrow appears
   - Repeat for all connections
3. **Tips**:
   - Need at least 2 rooms for connections
   - Position hotspots where visitors would naturally look
4. **Empty state messages**:
   - "Add rooms first" if no scenes uploaded
   - "No hotspots yet" if none added

### Tooltips & Hints

**React**:
- Overlay text: "💡 Click anywhere to add a navigation hotspot"
- Hotspot tooltips on hover showing target room
- Modal with position coordinates

**Flutter**:
- Overlay text: "💡 Tap anywhere to add a navigation hotspot"
- Selected hotspot shows tooltip with remove button
- AlertDialog with coordinates display

---

## 🔧 Technical Implementation

### React Implementation

**Key Files**:
- `HotspotEditor.js` - Main component
- `HotspotEditor.css` - Styling
- `SellerUpload.js` - Integration

**State Management**:
```javascript
const [hotspots, setHotspots] = useState([]);
const [clickPosition, setClickPosition] = useState(null);
const [showTargetSelector, setShowTargetSelector] = useState(false);
```

**Click Handler**:
```javascript
const handleImageClick = (e) => {
  const rect = viewerRef.current.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;
  
  const yaw = ((x / width) * 2 * Math.PI) - Math.PI;
  const pitch = ((y / height) * Math.PI) - (Math.PI / 2);
  
  setClickPosition({ x, y, yaw, pitch });
  setShowTargetSelector(true);
};
```

### Flutter Implementation

**Key Files**:
- `hotspot_editor.dart` - Widget
- `property_upload_screen.dart` - Integration

**State Management**:
```dart
List<HotspotModel> hotspots = [];
Offset? clickPosition;
bool showTargetSelector = false;
```

**Tap Handler**:
```dart
void _handleImageTap(TapDownDetails details, List<Scene> availableScenes) {
  final x = localPosition.dx;
  final y = localPosition.dy - offset;
  
  final yaw = (x / imageWidth) * 2 * 3.14159 - 3.14159;
  final pitch = (y / imageHeight) * 3.14159 - 3.14159 / 2;
  
  setState(() {
    clickPosition = Offset(x, y);
    showTargetSelector = true;
  });
  
  _showTargetSelectorDialog(availableScenes, x, y, yaw, pitch);
}
```

---

## 🧪 Testing the Feature

### Test Scenario 1: Basic Hotspot Creation

1. Upload a property with 3 rooms:
   - Living Room
   - Kitchen
   - Bedroom

2. In "Add Hotspots" step:
   - Click on Living Room door → Select "Kitchen"
   - Click on Kitchen door → Select "Living Room"
   - Click on Kitchen passage → Select "Bedroom"
   - Click on Bedroom door → Select "Kitchen"

3. Verify:
   - Purple arrows appear at clicked positions
   - Review shows correct hotspot counts
   - Property submits successfully

### Test Scenario 2: Edge Cases

1. **Single Room**: Should show tip about needing 2+ rooms
2. **No Images**: Should show "Upload images first" message
3. **Remove Hotspot**: Click hotspot → Click remove → Verify deletion
4. **Cancel Placement**: Click image → Click cancel in modal

---

## 📱 Screenshots & Examples

### React App Flow
```
Step 1: Basic Info → Step 2: Upload Images → Step 3: Add Hotspots → Step 4: Review
                                               ↓
                                    [Image with click detection]
                                               ↓
                                    [Target room selector modal]
                                               ↓
                                    [Purple arrow markers appear]
```

### Flutter App Flow
```
Step 1: Details → Step 2: Scenes → Step 3: Hotspots → Step 4: Submit
                                      ↓
                            [Tap on image preview]
                                      ↓
                            [AlertDialog selector]
                                      ↓
                            [Positioned markers]
```

---

## 🚀 Future Enhancements

Possible improvements:
1. **Drag & Drop**: Move hotspots after placement
2. **Hotspot Icons**: Different icons for different room types
3. **Preview Mode**: Test navigation before submitting
4. **Bulk Import**: CSV upload for many hotspots
5. **Smart Suggestions**: AI-suggested hotspot positions
6. **Hotspot Labels**: Custom text labels on markers
7. **Animation Settings**: Configure marker animations

---

## 🐛 Troubleshooting

### Issue: Hotspots Not Appearing
**Solution**: Ensure images are uploaded before adding hotspots

### Issue: Can't Select Target Room
**Solution**: Add at least 2 rooms/scenes in Step 2

### Issue: Wrong Coordinates
**Solution**: Click directly on the door/passage center

### Issue: Markers Overlapping
**Solution**: Click slightly different positions for each hotspot

---

## 📚 Related Documentation

- **Main README**: `/README.md`
- **Quick Start Guide**: `/QUICK_START.md`
- **API Documentation**: Backend API endpoints
- **360° Viewer**: Marzipano integration guide
- **Upload Instructions**: `/test_360_images/UPLOAD_INSTRUCTIONS.md`

---

## 💡 Best Practices

### For Sellers
1. Upload high-quality 360° images first
2. Position hotspots at natural transition points (doors, hallways)
3. Create bidirectional links (Room A → Room B and Room B → Room A)
4. Test the tour flow before finalizing
5. Add hotspots to all major room connections

### For Developers
1. Use equirectangular images for proper coordinate mapping
2. Validate yaw/pitch ranges before saving
3. Handle edge cases (no scenes, single room)
4. Provide clear user feedback (tooltips, messages)
5. Store hotspot data in normalized format

---

## 📞 Support

For issues or questions:
- Check this guide first
- Review the component code
- Test with sample images in `/test_360_images/`
- Verify backend API is running

---

**Last Updated**: October 22, 2025
**Version**: 1.0.0
**Status**: ✅ Fully Implemented (React & Flutter)

