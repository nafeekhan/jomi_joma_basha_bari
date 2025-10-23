# 🚀 Quick Test Setup

## Upload 3 Test Images

Property ID: `3fe7f232-c6b9-4b08-af97-fd7e969f029a`
Token: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIzZGZmODFjMC00YTljLTQ2NjUtOGQ0Yy0wYmQzY2I0NWQ5YWYiLCJpYXQiOjE3NjExNzY0NzEsImV4cCI6MTc2MTc4MTI3MX0.UgyRLdKSjZtC0LgFobrVFnoFfxttJ4rxMj6g0J4pZVw`

### Run these commands:

```bash
cd /home/nafee-khan/jomi_joma_basha_bari/test_360_images

TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIzZGZmODFjMC00YTljLTQ2NjUtOGQ0Yy0wYmQzY2I0NWQ5YWYiLCJpYXQiOjE3NjExNzY0NzEsImV4cCI6MTc2MTc4MTI3MX0.UgyRLdKSjZtC0LgFobrVFnoFfxttJ4rxMj6g0J4pZVw"
PROP_ID="3fe7f232-c6b9-4b08-af97-fd7e969f029a"

# Living Room
curl -X POST http://localhost:3001/api/properties/$PROP_ID/scenes \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Living Room" \
  -F "scene_order=0" \
  -F "scene_images=@living-room.jpg"

# Kitchen
curl -X POST http://localhost:3001/api/properties/$PROP_ID/scenes \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Kitchen" \
  -F "scene_order=1" \
  -F "scene_images=@kitchen.jpg"

# Bedroom
curl -X POST http://localhost:3001/api/properties/$PROP_ID/scenes \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Master Bedroom" \
  -F "scene_order=2" \
  -F "scene_images=@bedroom.jpg"
```

## View the Tour

After uploading, go to: http://localhost:3000

You'll see the property with a "View 360° Tour" button.

Click it to see your virtual tour!

