# 🚀 Quick Start Guide

Get up and running in 5 minutes!

## Prerequisites Check

Make sure you have:
- ✅ Node.js (v16+)
- ✅ PostgreSQL (v12+)
- ✅ Flutter SDK (v3.0+)

---

## 🎯 Start Backend (Required First!)

```bash
# 1. Navigate to backend
cd backend

# 2. Install dependencies
npm install

# 3. Create .env file with database credentials
# Edit backend/.env with your PostgreSQL password

# 4. Create PostgreSQL database
psql -U postgres -c "CREATE DATABASE real_estate_db;"

# 5. Setup database tables
npm run db:setup

# 6. Start server
npm start
```

✅ Backend running on **http://localhost:3000**

---

## 📱 Start Flutter App

```bash
# 1. Navigate to Flutter app
cd flutter_app

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (Web)
flutter run -d chrome

# OR run on Android
flutter run -d android

# OR run on iOS
flutter run -d ios
```

---

## ⚛️ Start React App (Optional - Priority-1 pages only)

```bash
# 1. Navigate to React app
cd react_initial_pages

# 2. Install dependencies
npm install

# 3. Start development server
npm start
```

---

## 🔑 Default Login Credentials

After running `npm run db:setup`, you'll have a default admin user:

- **Email:** `admin@realestate.com`
- **Password:** `admin123`

---

## 🧪 Test Priority-1 Features

### Test 1: Property Detail with 360° Tour

1. Start backend server
2. Run Flutter app
3. Login with admin credentials
4. Navigate to property detail page
5. Click "View 360° Virtual Tour" button
6. Interact with the 360° viewer (drag to rotate, scroll to zoom)

### Test 2: Seller Upload Page

1. Login as seller or admin
2. Navigate to "Upload Property"
3. Tutorial will guide you through the process
4. Fill in property details (Step 1)
5. Add 360° scenes/rooms (Step 2)
6. Upload panoramic images for each room
7. Review and submit (Step 3)

---

## 📁 Project Structure Summary

```
jomi_joma_basha_bari/
├── backend/           → Node.js API (PORT 3000)
├── flutter_app/       → Flutter App (Mobile + Web)
└── react_initial_pages/ → React Demo (PORT 3001)
```

---

## 🆘 Common Issues

### Issue: Database connection failed
**Solution:** Check PostgreSQL is running and credentials in `.env` are correct

### Issue: Flutter WebView not loading 360° tour
**Solution:** Make sure backend is running on http://localhost:3000

### Issue: React dependencies error
**Solution:** Delete `node_modules` and run `npm install` again

---

## 📚 Next Steps

1. ✅ Explore the codebase
2. 🎨 Customize the theme in `flutter_app/lib/config/app_theme.dart`
3. 🔐 Create seller and buyer accounts
4. 📸 Upload your own 360° panoramic images
5. 🚀 Deploy to production (see README.md)

---

**Need help?** Check the full README.md for detailed documentation!

