# 🚀 Upload Your 360° Test Images NOW

## ✅ Database is Ready!

The database has been updated with the correct schema. Now you can upload your test images!

---

## 📋 Step 1: Set Your Credentials

Run these commands in your terminal to set up your credentials (copy-paste each line):

```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIzMjFkMmFmYS02NDYzLTQ2NTgtODVjMi0yYWI3YWRkYWU1NzMiLCJpYXQiOjE3NjExNzgyNDYsImV4cCI6MTc2MTc4MzA0Nn0.GzcaS3COOTY9UYmb3X3yegCQKX7pz-TUj23n5MVvrhs"

PROP_ID="f80bbc9c-16a0-44f0-8b46-819aa17e9745"
```

---

## 📋 Step 2: Upload Living Room Scene

```bash
curl -X POST "http://localhost:3001/api/scenes/properties/$PROP_ID/scenes" \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Living Room" \
  -F "scene_order=0" \
  -F "image_type=preview" \
  -F "image=@/home/nafee-khan/jomi_joma_basha_bari/test_360_images/living-room.jpg"
```

---

## 📋 Step 3: Upload Kitchen Scene

```bash
curl -X POST "http://localhost:3001/api/scenes/properties/$PROP_ID/scenes" \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Kitchen" \
  -F "scene_order=1" \
  -F "image_type=preview" \
  -F "image=@/home/nafee-khan/jomi_joma_basha_bari/test_360_images/kitchen.jpg"
```

---

## 📋 Step 4: Upload Bedroom Scene

```bash
curl -X POST "http://localhost:3001/api/scenes/properties/$PROP_ID/scenes" \
  -H "Authorization: Bearer $TOKEN" \
  -F "scene_name=Bedroom" \
  -F "scene_order=2" \
  -F "image_type=preview" \
  -F "image=@/home/nafee-khan/jomi_joma_basha_bari/test_360_images/bedroom.jpg"
```

---

## 🎉 Step 5: View Your Tour!

After uploading all 3 scenes, open your React app in the browser:

**http://localhost:3000**

Click the **"View 360° Tour"** button to see your virtual tour in action!

---

## 📝 Notes:

- You only need to run `TOKEN="..."` and `PROP_ID="..."` **ONCE** in your terminal session
- Then run the three upload commands one by one
- Each command should return `{"success":true,...}` if successful
- The React app is already configured with the correct property ID

---

## ❓ Troubleshooting:

If you get an error:
- Make sure backend is running on port 3001 (`http://localhost:3001/health`)
- Make sure the image files exist in `test_360_images/` folder
- Make sure TOKEN and PROP_ID are set (echo them to verify: `echo $TOKEN`)

