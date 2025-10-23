# 🏠 Multi-Viewpoint Support Implementation Guide

## ✅ What's Been Implemented

### Phase 1: Database & Backend (COMPLETED ✓)

**Database Schema:**
- ✅ `rooms` table created (groups viewpoints by physical room)
- ✅ `scenes` table updated with `room_id`, `viewpoint_name`, `is_default_viewpoint` columns
- ✅ `hotspots` table updated with `target_room_id`, `is_room_navigation` columns
- ✅ Foreign key constraints added

**Migration:**
- ✅ `db-migrate-viewpoints.js` - Converts existing scenes to room-based structure
- ✅ Script command: `npm run db:migrate-viewpoints`

**Backend API:**
- ✅ Room Controller (`src/controllers/roomController.js`)
  - `POST /api/rooms/properties/:propertyId/rooms` - Create room
  - `GET /api/rooms/properties/:propertyId/rooms` - Get all rooms with viewpoints
  - `GET /api/rooms/:roomId` - Get single room
  - `PUT /api/rooms/:roomId` - Update room
  - `DELETE /api/rooms/:roomId` - Delete room
  - `PUT /api/rooms/:roomId/default-viewpoint` - Set default viewpoint

- ✅ Scene Controller Updated (`src/controllers/sceneController.js`)
  - Now accepts `room_id`, `viewpoint_name`, `is_default_viewpoint` parameters
  - Returns room information in responses

**Routes:**
- ✅ Room routes registered in `server.js`
- ✅ `/api/rooms/*` endpoints available

### Phase 2: 360° Viewer (COMPLETED ✓)

**New Viewer:**
- ✅ `public/viewer-rooms.html` - Full multi-viewpoint viewer
- ✅ Accessible at: `/viewer-rooms?propertyId=<id>`

**Features:**
- ✅ Groups viewpoints by room
- ✅ Room selector at bottom (grouped buttons)
- ✅ Viewpoint submenu on hover (shows all viewpoints for a room)
- ✅ Current location indicator at top (shows current room + viewpoint)
- ✅ Different hotspot styling:
  - Purple arrows (→) for room-to-room navigation
  - Green eye icons (👁) for viewpoint switching within same room
- ✅ Auto-loads default viewpoint when entering a room
- ✅ Smooth transitions between viewpoints

**Backward Compatibility:**
- ✅ Original `/viewer` still works for existing test data
- ✅ Migration script ensures old data works with new system

### Phase 3: React Components (COMPLETED ✓)

**Models:**
- ✅ `Room.js` model (`src/models/Room.js`)

**Components:**
- ✅ `RoomViewpointEditor.js` - Full room/viewpoint management UI
  - Add/remove rooms
  - Add/remove viewpoints per room
  - Set default viewpoint (entrance)
  - Drag-drop 360° image upload
  - Expandable room cards
  - Beautiful modern UI with gradients

- ✅ `RoomViewpointEditor.css` - Complete styling

**Status:**
- ⚠️ Components created but NOT YET integrated into SellerUpload workflow
- ⚠️ HotspotEditor needs update to support room vs viewpoint navigation

---

## 🔄 What Needs Integration

### React App Integration (Manual Steps Required)

#### 1. Update SellerUpload Workflow

**File:** `react_initial_pages/src/components/SellerUpload.js`

**Changes needed:**

```javascript
import RoomViewpointEditor from './RoomViewpointEditor';

// Add state for rooms
const [rooms, setRooms] = useState([]);

// Update steps array
const steps = [
  'Basic Information', 
  'Add Rooms & Viewpoints',  // NEW STEP 
  'Add Hotspots', 
  'Review & Submit'
];

// Add step 2 content (between basic info and hotspots)
{currentStep === 1 && (
  <div className="rooms-viewpoints-step">
    <RoomViewpointEditor 
      rooms={rooms}
      onRoomsChange={setRooms}
    />
  </div>
)}

// Update hotspots step index from 2 to 3
{currentStep === 3 && (
  <div className="hotspots-step">
    {/* Existing hotspot editor code */}
  </div>
)}

// Update review step index from 3 to 4
{currentStep === 4 && (
  <div className="review-step">
    {/* Show rooms and viewpoints */}
    {rooms.map(room => (
      <div key={room.id}>
        <strong>{room.name}</strong>: {room.viewpoints.length} viewpoint(s)
      </div>
    ))}
  </div>
)}
```

#### 2. Update HotspotEditor for Room/Viewpoint Types

**File:** `react_initial_pages/src/components/HotspotEditor.js`

**Changes needed:**

```javascript
// Add hotspot type selection
const [hotspotType, setHotspotType] = useState('room'); // 'room' or 'viewpoint'

// In target selector modal:
<select value={hotspotType} onChange={e => setHotspotType(e.target.value)}>
  <option value="room">Navigate to Room (uses default viewpoint)</option>
  <option value="viewpoint">Switch Viewpoint (within or across rooms)</option>
</select>

// When adding hotspot:
const newHotspot = {
  id: Date.now(),
  ...clickPosition,
  isRoomNavigation: hotspotType === 'room',
  targetRoomId: hotspotType === 'room' ? targetRoom.id : null,
  targetSceneId: hotspotType === 'viewpoint' ? targetViewpoint.id : null,
  title: `Go to ${targetName}`
};
```

#### 3. Update PropertyDetail to use new viewer

**File:** `react_initial_pages/src/components/PropertyDetail.js`

```javascript
// Change viewer URL:
<iframe 
  src={`${API_BASE_URL}/viewer-rooms?propertyId=${propertyId}`}
  // ...
/>
```

#### 4. Update submission logic

When submitting property, create rooms first, then viewpoints:

```javascript
// 1. Create property
const property = await createProperty(formData);

// 2. Create rooms
for (const room of rooms) {
  const roomResponse = await axios.post(
    `${API_BASE_URL}/api/rooms/properties/${property.id}/rooms`,
    {
      room_name: room.name,
      room_order: room.order
    }
  );
  
  // 3. Create viewpoints for this room
  for (const viewpoint of room.viewpoints) {
    const formData = new FormData();
    formData.append('scene_name', `${room.name} - ${viewpoint.name}`);
    formData.append('room_id', roomResponse.data.room.id);
    formData.append('viewpoint_name', viewpoint.name);
    formData.append('is_default_viewpoint', viewpoint.isDefault);
    formData.append('scene_images', viewpoint.images[0]);
    
    await axios.post(
      `${API_BASE_URL}/api/properties/${property.id}/scenes`,
      formData
    );
  }
}
```

---

### Flutter App Integration (Components Needed)

I've created the backend infrastructure, but Flutter components need to be built following the React pattern:

#### Required Flutter Files:

1. **`lib/models/room.dart`**
   - Room model similar to React Room.js
   - Properties: id, name, order, defaultViewpointId, viewpoints[]

2. **`lib/services/room_service.dart`**
   - API calls to `/api/rooms/*` endpoints

3. **`lib/screens/upload/widgets/room_viewpoint_manager.dart`**
   - Similar to React RoomViewpointEditor
   - ListView of rooms
   - ExpansionTiles for viewpoints
   - Image picker integration

4. **Update `property_upload_screen.dart`**
   - Add new step between current Step 2 and 3
   - Integrate RoomViewpointManager widget

5. **Update `hotspot_editor.dart`**
   - Add dropdown for hotspot type (room/viewpoint)
   - Support both target types in data model

---

## 🧪 Testing the Implementation

### Step 1: Reset Database (if needed)

```bash
cd backend
npm run db:setup  # Creates tables with new schema
```

### Step 2: Migrate Existing Data

```bash
npm run db:migrate-viewpoints
```

This will:
- Find all existing scenes without rooms
- Create a room for each scene
- Link scene as the default viewpoint for that room

**Output example:**
```
✅ Migration completed successfully!
📦 Rooms created: 3
🔗 Scenes migrated: 3

📋 Property Structure After Migration:
─────────────────────────────────────────
📍 Luxury Apartment Downtown
   └─ Living Room: 1 viewpoint(s)
   └─ Kitchen: 1 viewpoint(s)
   └─ Master Bedroom: 1 viewpoint(s)
```

### Step 3: Test the New Viewer

Your existing test data will work! Visit:

```
http://localhost:3001/viewer-rooms?propertyId=3bc20da2-411d-443b-b17e-7b54873e9163
```

You should see:
- Room buttons at bottom (Living Room, Kitchen, Master Bedroom)
- Each room shows its viewpoint count
- Current location displayed at top
- Existing hotspots still work (treated as room navigation by default)

### Step 4: Test Multi-Viewpoint Setup

**Using curl (for testing):**

```bash
# 1. Create a room
curl -X POST http://localhost:3001/api/rooms/properties/YOUR_PROPERTY_ID/rooms \
  -H "Authorization: Bearer YOUR_SELLER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "room_name": "Living Room",
    "room_order": 0
  }'

# Response will include room_id

# 2. Create viewpoint 1 (Center)
curl -X POST http://localhost:3001/api/properties/YOUR_PROPERTY_ID/scenes \
  -H "Authorization: Bearer YOUR_SELLER_TOKEN" \
  -F "scene_name=Living Room - Center" \
  -F "room_id=YOUR_ROOM_ID" \
  -F "viewpoint_name=Center" \
  -F "is_default_viewpoint=true" \
  -F "scene_order=0" \
  -F "scene_images=@your_360_image.jpg"

# 3. Create viewpoint 2 (Door)
curl -X POST http://localhost:3001/api/properties/YOUR_PROPERTY_ID/scenes \
  -H "Authorization: Bearer YOUR_SELLER_TOKEN" \
  -F "scene_name=Living Room - Door" \
  -F "room_id=YOUR_ROOM_ID" \
  -F "viewpoint_name=Door" \
  -F "is_default_viewpoint=false" \
  -F "scene_order=1" \
  -F "scene_images=@another_360_image.jpg"

# 4. Create hotspot for viewpoint switching
curl -X POST http://localhost:3001/api/scenes/SCENE1_ID/hotspots \
  -H "Authorization: Bearer YOUR_SELLER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "hotspot_type": "navigation",
    "target_scene_id": "SCENE2_ID",
    "is_room_navigation": false,
    "yaw": 1.5,
    "pitch": 0.2,
    "title": "View from Door"
  }'
```

---

## 📊 Database Schema Reference

### Rooms Table
```sql
CREATE TABLE rooms (
  id UUID PRIMARY KEY,
  property_id UUID REFERENCES properties(id),
  room_name VARCHAR(255),
  room_order INTEGER,
  default_viewpoint_id UUID REFERENCES scenes(id),
  created_at TIMESTAMP
);
```

### Scenes Table (Updated)
```sql
CREATE TABLE scenes (
  id UUID PRIMARY KEY,
  property_id UUID REFERENCES properties(id),
  room_id UUID REFERENCES rooms(id),  -- NEW
  scene_name VARCHAR(255),
  viewpoint_name VARCHAR(255) DEFAULT 'Main View',  -- NEW
  is_default_viewpoint BOOLEAN DEFAULT false,  -- NEW
  scene_order INTEGER,
  initial_view_yaw DECIMAL,
  initial_view_pitch DECIMAL,
  initial_view_fov DECIMAL,
  created_at TIMESTAMP
);
```

### Hotspots Table (Updated)
```sql
CREATE TABLE hotspots (
  id UUID PRIMARY KEY,
  scene_id UUID REFERENCES scenes(id),
  hotspot_type VARCHAR(20) CHECK (hotspot_type IN ('navigation', 'info')),
  target_scene_id UUID REFERENCES scenes(id),
  target_room_id UUID REFERENCES rooms(id),  -- NEW
  is_room_navigation BOOLEAN DEFAULT false,  -- NEW
  yaw DECIMAL,
  pitch DECIMAL,
  title VARCHAR(255),
  description TEXT,
  icon_url VARCHAR(500),
  created_at TIMESTAMP
);
```

---

## 🎨 UI/UX Design Decisions

### Hotspot Visual Distinction

**Room Navigation (Purple):**
- Icon: → (arrow)
- Color: #667EEA (Purple)
- Hover: #F5576C (Pink)
- Purpose: Move to a different room (loads default viewpoint)

**Viewpoint Navigation (Green):**
- Icon: 👁 (eye)
- Color: #34D399 (Green)
- Hover: #10B981 (Darker green)
- Purpose: Switch viewpoint within current or adjacent room

### Seller Workflow

1. **Step 1:** Enter property details (address, price, etc.)
2. **Step 2:** Add Rooms & Viewpoints
   - Add room name (e.g., "Living Room")
   - Add viewpoints for room (e.g., "Center", "Door", "Window")
   - Upload 360° image for each viewpoint
   - Mark entrance viewpoint as default
3. **Step 3:** Position Hotspots
   - Choose hotspot type (room navigation vs viewpoint switch)
   - Click on doors/passages in images
   - Select target (room or specific viewpoint)
4. **Step 4:** Review & Submit

### Buyer Experience

1. Opens property tour
2. Sees room selector at bottom
3. Clicks a room button → loads default (entrance) viewpoint
4. Hovers over room button → sees submenu of all viewpoints
5. Clicks viewpoint name → switches to that view
6. Clicks purple arrows on doors → moves to another room
7. Clicks green eye icons → switches viewpoint within room
8. Top overlay always shows: "Living Room (Center)"

---

## 🐛 Backward Compatibility

**Your existing test_360_images data will continue to work!**

The migration script automatically:
1. Creates a room for each existing scene
2. Marks it as the single "Main View" viewpoint
3. Sets it as the default viewpoint

Old viewer (`/viewer`) still works for legacy data.
New viewer (`/viewer-rooms`) works for both old and new data.

---

## 📝 API Endpoints Summary

### Room Management
```
POST   /api/rooms/properties/:propertyId/rooms        Create room
GET    /api/rooms/properties/:propertyId/rooms        Get all rooms with viewpoints
GET    /api/rooms/:roomId                             Get single room
PUT    /api/rooms/:roomId                             Update room
DELETE /api/rooms/:roomId                             Delete room
PUT    /api/rooms/:roomId/default-viewpoint           Set default viewpoint
```

### Scene (Viewpoint) Management
```
POST   /api/properties/:propertyId/scenes             Create viewpoint (now accepts room_id)
GET    /api/properties/:propertyId/scenes             Get all scenes (includes room info)
GET    /api/scenes/:sceneId                           Get scene details (includes room info)
POST   /api/scenes/:sceneId/images                    Upload images
POST   /api/scenes/:sceneId/hotspots                  Create hotspot (now supports room navigation)
```

---

## ✅ Testing Checklist

- [x] Database schema created
- [x] Migration script works
- [x] Room API endpoints functional
- [x] Scene controller updated
- [x] New viewer displays rooms
- [x] Viewpoint submenu shows on hover
- [x] Current location indicator displays
- [x] Hotspots distinguish between types
- [x] Old viewer still works
- [x] Old test data migrates correctly
- [ ] React SellerUpload integrated
- [ ] React HotspotEditor updated
- [ ] Flutter components created
- [ ] End-to-end property upload test
- [ ] Multi-viewpoint property test

---

## 🚀 Next Steps

1. **Integrate React Components** (see integration section above)
2. **Build Flutter Widgets** (follow React patterns)
3. **Test Full Upload Flow** (create property with multiple viewpoints)
4. **Update Documentation** (add screenshots, video walkthrough)
5. **Add Polish** (loading states, error handling, validation)

---

## 💡 Future Enhancements

- [ ] Auto-generate hotspots between viewpoints in same room
- [ ] AI-suggested viewpoint positions
- [ ] Floor plan overlay showing current position
- [ ] Minimap with viewpoint markers
- [ ] Dollhouse/floorplan view for navigation
- [ ] VR mode support
- [ ] Guided tours with narration
- [ ] Measurement tools
- [ ] Furniture placement AR

---

**Status:** Core infrastructure complete. UI integration in progress.
**Version:** 1.0.0
**Last Updated:** October 22, 2025

