#!/bin/bash

# 360° Virtual Tour Image Upload Script
# Usage: Place your 360° images in this folder and run: bash upload-images.sh

SELLER_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJmYmY5NzQ4MS05MDY2LTRiMzUtYTJlZS03ODE4ZTQ3ODZjZjAiLCJpYXQiOjE3NjExNjQ2NDAsImV4cCI6MTc2MTc2OTQ0MH0.KRqThOwo-lvXsxlcoQ6Jc6INhPJadfhhVpxbNXkaM-g"
API_URL="http://localhost:3001"

# Scene IDs
LIVING_ROOM_ID="d45c63d8-50a8-47ad-905f-3d7748e313dc"
KITCHEN_ID="f8d889b7-d010-41a3-9ee5-6cd2ef77481d"
BEDROOM_ID="55fd4e54-b0dd-44b2-8722-18eedda55ebb"

echo "🏠 360° Virtual Tour Image Upload"
echo "=================================="
echo ""

cd /home/nafee-khan/jomi_joma_basha_bari/test_360_images

# Function to upload image
upload_image() {
    local scene_id=$1
    local scene_name=$2
    local image_file=$3
    
    if [ ! -f "$image_file" ]; then
        echo "⚠️  $scene_name: Image '$image_file' not found - skipping"
        return 1
    fi
    
    echo "📤 Uploading to $scene_name: $image_file"
    
    response=$(curl -s -X POST "$API_URL/api/scenes/$scene_id/images" \
      -H "Authorization: Bearer $SELLER_TOKEN" \
      -F "image_type=preview" \
      -F "resolution_level=0" \
      -F "scene_images=@$image_file")
    
    if echo "$response" | grep -q '"success":true'; then
        echo "   ✅ Success!"
        return 0
    else
        echo "   ❌ Failed: $response"
        return 1
    fi
}

# Upload images
echo "Starting upload process..."
echo ""

upload_image "$LIVING_ROOM_ID" "Living Room" "living-room.jpg"
upload_image "$KITCHEN_ID" "Kitchen" "kitchen.jpg"
upload_image "$BEDROOM_ID" "Master Bedroom" "bedroom.jpg"

echo ""
echo "=================================="
echo "✅ Upload complete!"
echo ""
echo "🌐 View your 360° tour at:"
echo "   Direct: http://localhost:3001/viewer?propertyId=3bc20da2-411d-443b-b17e-7b54873e9163"
echo "   React:  http://localhost:3000 (click 'View 360° Virtual Tour')"
echo ""


