# 📸 How to Upload 360° Virtual Tour Images

## 📁 Test Images Folder
Place your 360° panoramic images in this folder: `/home/nafee-khan/jomi_joma_basha_bari/test_360_images/`

---

## 🎯 Quick Guide

### **Step 1: Get 360° Panoramic Images**

Download free 360° equirectangular panorama images from:
- https://www.flickr.com/groups/equirectangular/
- Search "equirectangular panorama free" on Google Images
- Use your own 360° camera images (Ricoh Theta, Insta360, etc.)

**Requirements:**
- Format: JPG or PNG
- Type: Equirectangular projection (360° x 180°)
- Recommended size: 4096x2048 or higher

Save 3 images in this folder:
- `living-room.jpg`
- `kitchen.jpg`
- `bedroom.jpg`

---

## 🚀 Upload Commands

### **Your Property & Scene IDs:**

- **Property ID:** `3bc20da2-411d-443b-b17e-7b54873e9163`
- **Seller Token:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJmYmY5NzQ4MS05MDY2LTRiMzUtYTJlZS03ODE4ZTQ3ODZjZjAiLCJpYXQiOjE3NjExNjQ2NDAsImV4cCI6MTc2MTc2OTQ0MH0.KRqThOwo-lvXsxlcoQ6Jc6INhPJadfhhVpxbNXkaM-g`

**Scene IDs:**
- Living Room: `d45c63d8-50a8-47ad-905f-3d7748e313dc`
- Kitchen: `f8d889b7-d010-41a3-9ee5-6cd2ef77481d`
- Master Bedroom: `55fd4e54-b0dd-44b2-8722-18eedda55ebb`

---

## 📤 Upload Images to Scenes

### **1. Upload to Living Room:**

```bash
cd /home/nafee-khan/jomi_joma_basha_bari/test_360_images

curl -X POST http://localhost:3001/api/scenes/d45c63d8-50a8-47ad-905f-3d7748e313dc/images \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJmYmY5NzQ4MS05MDY2LTRiMzUtYTJlZS03ODE4ZTQ3ODZjZjAiLCJpYXQiOjE3NjExNjQ2NDAsImV4cCI6MTc2MTc2OTQ0MH0.KRqThOwo-lvXsxlcoQ6Jc6INhPJadfhhVpxbNXkaM-g" \
  -F "image_type=preview" \
  -F "resolution_level=0" \
  -F "scene_images=@living-room.jpg"
```

### **2. Upload to Kitchen:**

```bash
curl -X POST http://localhost:3001/api/scenes/f8d889b7-d010-41a3-9ee5-6cd2ef77481d/images \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJmYmY5NzQ4MS05MDY2LTRiMzUtYTJlZS03ODE4ZTQ3ODZjZjAiLCJpYXQiOjE3NjExNjQ2NDAsImV4cCI6MTc2MTc2OTQ0MH0.KRqThOwo-lvXsxlcoQ6Jc6INhPJadfhhVpxbNXkaM-g" \
  -F "image_type=preview" \
  -F "resolution_level=0" \
  -F "scene_images=@kitchen.jpg"
```

### **3. Upload to Master Bedroom:**

```bash
curl -X POST http://localhost:3001/api/scenes/55fd4e54-b0dd-44b2-8722-18eedda55ebb/images \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJmYmY5NzQ4MS05MDY2LTRiMzUtYTJlZS03ODE4ZTQ3ODZjZjAiLCJpYXQiOjE3NjExNjQ2NDAsImV4cCI6MTc2MTc2OTQ0MH0.KRqThOwo-lvXsxlcoQ6Jc6INhPJadfhhVpxbNXkaM-g" \
  -F "image_type=preview" \
  -F "resolution_level=0" \
  -F "scene_images=@bedroom.jpg"
```

---

## ✅ Verify Upload

Check if images were uploaded:

```bash
curl -s http://localhost:3001/api/scenes/d45c63d8-50a8-47ad-905f-3d7748e313dc | jq .
```

You should see the image file path in the response.

---

## 🌐 View in Browser

### **Option 1: Direct Viewer**
```
http://localhost:3001/viewer?propertyId=3bc20da2-411d-443b-b17e-7b54873e9163
```

### **Option 2: React App**
1. Go to: `http://localhost:3000`
2. Click "View 360° Virtual Tour" button
3. Click on scene buttons (Living Room, Kitchen, Master Bedroom)
4. Enjoy your 360° tour!

---

## 🎮 Navigation Features

Once images are uploaded, you can:
- **Drag** to rotate 360°
- **Scroll** to zoom in/out
- **Click scene buttons** to switch between rooms
- See all 3 rooms in your virtual tour!

---

## 🔧 Troubleshooting

### Images not showing?
1. Check file paths are correct
2. Ensure backend is running on port 3001
3. Check file was uploaded: `ls -la /home/nafee-khan/jomi_joma_basha_bari/backend/uploads/properties/`

### Can't find 360° images?
Use these free resources:
- https://www.flickr.com/groups/equirectangular/
- https://polyhaven.com/hdris (HDRI section)
- https://hdrihaven.com/

### Token expired?
Login again and get new token:
```bash
curl -s -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seller@demo.com",
    "password": "demo123"
  }' | jq -r '.data.token'
```

---

## 📝 Notes

- Images are stored in: `/home/nafee-khan/jomi_joma_basha_bari/backend/uploads/properties/`
- Each scene can have multiple images
- Higher resolution = better quality but slower loading
- Equirectangular format is required (360° x 180° panorama)


