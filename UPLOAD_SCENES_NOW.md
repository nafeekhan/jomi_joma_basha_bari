# ✅ Upload Your 360° Scenes - FIXED!

The database has been updated and the issue is resolved!

## New Credentials:

**Token:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIzZGVjMzI2ZS1kYTQ2LTQyMTMtOTIyZC05YjU3ZjBkNjMyYzMiLCJpYXQiOjE3NjExNzc5NDMsImV4cCI6MTc2MTc4Mjc0M30.v2bcr16YNYLDhPPueteTyGyhR6GYx6MCyLuHUDgTncQ
```

**Property ID:**
```
40ce6535-1ce6-4db9-9885-e5189fa20306
```

**Property Name:** Test Apartment with 360 Tour

---

## Run These Commands:

```bash
cd /home/nafee-khan/jomi_joma_basha_bari/test_360_images

TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIzZGVjMzI2ZS1kYTQ2LTQyMTMtOTIyZC05YjU3ZjBkNjMyYzMiLCJpYXQiOjE3NjExNzc5NDMsImV4cCI6MTc2MTc4Mjc0M30.v2bcr16YNYLDhPPueteTyGyhR6GYx6MCyLuHUDgTncQ"
PROP_ID="40ce6535-1ce6-4db9-9885-e5189fa20306"

# Upload Living Room
curl -X POST http://localhost:3001/api/scenes/properties/$PROP_ID/scenes \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Living Room" \
  -F "scene_order=0" \
  -F "image_type=preview" \
  -F "scene_images=@living-room.jpg"

# Upload Kitchen
curl -X POST http://localhost:3001/api/scenes/properties/$PROP_ID/scenes \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Kitchen" \
  -F "scene_order=1" \
  -F "image_type=preview" \
  -F "scene_images=@kitchen.jpg"

# Upload Bedroom
curl -X POST http://localhost:3001/api/scenes/properties/$PROP_ID/scenes \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Master Bedroom" \
  -F "scene_order=2" \
  -F "image_type=preview" \
  -F "scene_images=@bedroom.jpg"
```

---

## View the Tour

After uploading, open: **http://localhost:3000**

You'll see "Test Apartment with 360 Tour" - click **"View 360° Tour"** to see your virtual tour!

---

## What Was Fixed:

1. ✅ Created uploads directory
2. ✅ Updated database schema with new columns
3. ✅ Recreated property and user
4. ✅ Updated PropertyDetail.js with new property ID
5. ✅ Added better error logging

The "Server error" was because the database didn't have the `room_id` column. Now it's fixed!

