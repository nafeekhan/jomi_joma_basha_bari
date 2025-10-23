# Real Estate E-Commerce Platform with 360° Virtual Tours

A full-stack real estate platform built with **Flutter** (mobile + web), **Node.js/Express**, **PostgreSQL**, and **Marzipano** for immersive 360° property tours.

---

## 🌟 Features

### ✅ Priority-1 Features (Fully Implemented)

#### 1. **Property Detail Page with 360° Virtual Tour**
- Immersive 360° panoramic tours using Marzipano JavaScript library
- Embedded in Flutter WebView for seamless mobile/web experience
- Lazy-loading of scenes (rooms load only when accessed)
- Interactive navigation between rooms via hotspots
- Property details: price, location, specs, reviews
- Google Maps integration with copy-to-clipboard address

#### 2. **Seller Upload Page**
- Intuitive multi-step wizard for property uploads
- **Tooltips, hints, and guided tutorial** for easy onboarding
- 360° panoramic image upload with drag-and-drop
- Multiple scenes/rooms per property
- Form validation and error handling
- Real-time progress tracking

### 🔜 Priority-2 Features (Architected, Ready to Expand)

- Advanced search with map location points and radius filtering
- Multi-filter search: price, size, rooms, tags, ratings
- Multiple user types: Buyer, Seller, Admin
- Authentication and authorization system
- Property management (CRUD operations)

---

## 📁 Project Structure

```
jomi_joma_basha_bari/
├── backend/                    # Node.js + Express API
│   ├── src/
│   │   ├── config/            # Database and config files
│   │   ├── controllers/       # API controllers
│   │   ├── middlewares/       # Auth, validation, upload
│   │   ├── models/            # (Using PostgreSQL with direct queries)
│   │   ├── routes/            # API routes
│   │   └── utils/             # Helper functions
│   ├── public/                # Marzipano viewer HTML & JS
│   ├── uploads/               # Uploaded property images
│   ├── server.js              # Express server entry point
│   └── package.json
│
├── flutter_app/               # Flutter (Mobile + Web)
│   ├── lib/
│   │   ├── config/            # API config, theme
│   │   ├── models/            # Data models
│   │   ├── services/          # API services
│   │   ├── screens/
│   │   │   ├── auth/          # Login, register
│   │   │   ├── home/          # Home screen
│   │   │   ├── property_detail/ # Property detail + 360 tour
│   │   │   ├── upload/        # Seller upload with hints
│   │   │   └── search/        # Advanced search (scaffolded)
│   │   ├── widgets/           # Reusable widgets
│   │   └── utils/             # Storage, helpers
│   ├── assets/                # Images, icons
│   └── pubspec.yaml
│
├── react_initial_pages/       # React implementation (Priority-1 only)
│   ├── src/
│   │   ├── components/
│   │   │   ├── PropertyDetail.js  # Property detail + 360 tour
│   │   │   └── SellerUpload.js    # Seller upload with hints
│   │   ├── styles/            # CSS files
│   │   ├── App.js
│   │   └── index.js
│   ├── public/
│   └── package.json
│
└── README.md
```

---

## 🚀 Installation & Setup

### Prerequisites

- **Node.js** (v16 or higher)
- **npm** or **yarn**
- **PostgreSQL** (v12 or higher)
- **Flutter SDK** (v3.0 or higher)

---

### 1. Backend Setup (Node.js + Express + PostgreSQL)

#### Step 1: Install Dependencies

```bash
cd backend
npm install
```

#### Step 2: Configure Environment Variables

The backend uses environment variables. Update the following values in `backend/.env`:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=real_estate_db
DB_USER=postgres
DB_PASSWORD=your_password_here

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRE=7d

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_PATH=./uploads/properties

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:8080
```

#### Step 3: Set Up PostgreSQL Database

1. Create a new PostgreSQL database:

```bash
psql -U postgres
CREATE DATABASE real_estate_db;
\q
```

2. Run the database setup script:

```bash
npm run db:setup
```

This will create all necessary tables and a default admin user:
- **Email:** `admin@realestate.com`
- **Password:** `admin123`

#### Step 4: Start the Backend Server

```bash
npm start
# or for development with auto-reload:
npm run dev
```

The server will start on `http://localhost:3000`

#### Step 5: Verify Backend is Running

Visit `http://localhost:3000` in your browser. You should see:

```json
{
  "success": true,
  "message": "Real Estate Platform API",
  "version": "1.0.0"
}
```

---

### 2. Flutter App Setup (Mobile + Web)

#### Step 1: Install Flutter Dependencies

```bash
cd flutter_app
flutter pub get
```

#### Step 2: Update API Configuration

Edit `flutter_app/lib/config/api_config.dart` and update the base URL if needed:

```dart
static const String baseUrl = 'http://localhost:3000';
```

For Android emulator, use: `http://10.0.2.2:3000`  
For iOS simulator, use: `http://localhost:3000`

#### Step 3: Run on Web

```bash
flutter run -d chrome
```

#### Step 4: Run on Mobile

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

#### Step 5: Build for Production

**Web:**
```bash
flutter build web
```

**Android APK:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
```

---

### 3. React App Setup (Priority-1 Pages Only)

The React implementation includes only the **Property Detail** and **Seller Upload** pages.

#### Step 1: Install Dependencies

```bash
cd react_initial_pages
npm install
```

#### Step 2: Start Development Server

```bash
npm start
```

The app will open at `http://localhost:3000`

#### Step 3: Build for Production

```bash
npm run build
```

---

## 📖 API Documentation

### Authentication

#### Register
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "seller@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "user_type": "seller",
  "company_name": "ABC Realty"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "seller@example.com",
  "password": "password123"
}
```

### Properties

#### Get All Properties
```http
GET /api/properties?page=1&limit=20&property_type=buy&min_price=100000&max_price=500000
```

#### Get Property by ID
```http
GET /api/properties/:id
```

#### Create Property (Seller only)
```http
POST /api/properties
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Modern 3BR Apartment",
  "description": "Beautiful apartment...",
  "property_type": "buy",
  "price": 450000,
  "bedrooms": 3,
  "bathrooms": 2,
  "size_sqft": 1500,
  "furnished": true,
  "address_line": "123 Main St",
  "city": "New York",
  "country": "USA"
}
```

### Scenes (360° Tour)

#### Get Scenes for Property
```http
GET /api/properties/:propertyId/scenes
```

#### Get Scene by ID (with images and hotspots)
```http
GET /api/scenes/:sceneId
```

#### Create Scene with Images (Seller only)
```http
POST /api/properties/:propertyId/scenes
Authorization: Bearer <token>
Content-Type: multipart/form-data

scene_name: Living Room
scene_order: 0
scene_images: [File, File, ...]
```

### Marzipano Viewer

#### View 360° Tour
```http
GET /viewer?propertyId=<property-id>
```

---

## 🎨 Key Technologies

### Backend
- **Node.js** + **Express.js** - RESTful API
- **PostgreSQL** - Relational database
- **JWT** - Authentication
- **Multer** - File uploads
- **Marzipano** - 360° viewer library

### Frontend (Flutter)
- **Flutter** - Cross-platform framework
- **WebView** - For Marzipano integration
- **Provider** / **GetX** - State management
- **http** / **dio** - API communication
- **Google Maps** - Location features
- **Image Picker** - Image uploads

### Frontend (React)
- **React** 18
- **React Router** - Navigation
- **Axios** - HTTP client
- **React Dropzone** - File uploads
- **React Tooltip** - Interactive hints

---

## 🏗️ Architecture Highlights

### Modular & Reusable Components

#### 360° Tour Viewer Component (Flutter)
Location: `flutter_app/lib/screens/property_detail/widgets/virtual_tour_viewer.dart`

**Reusable in any Flutter project:**
```dart
VirtualTourViewer(
  propertyId: 'property-123',
  propertyTitle: 'My Property',
)
```

#### Seller Upload Component (Flutter)
Location: `flutter_app/lib/screens/upload/property_upload_screen.dart`

Features:
- Multi-step wizard
- Integrated tooltips via `tutorial_coach_mark`
- Scene upload with image management

### Lazy Loading

360° scenes are **lazy-loaded**:
1. Initial page load fetches only scene metadata (names, order)
2. Images/hotspots load **only when user navigates** to that scene
3. Reduces initial load time and bandwidth

---

## 🔐 Security Features

- **JWT-based authentication**
- **Role-based access control** (Buyer, Seller, Admin)
- **Input validation** using `express-validator`
- **Password hashing** with bcrypt
- **Secure file uploads** with file type validation
- **CORS protection**

---

## 🌐 Deployment

### Backend (Node.js)

**Option 1: Traditional Server**
```bash
npm run build
NODE_ENV=production node server.js
```

**Option 2: Docker**
```dockerfile
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

**Option 3: Cloud Platforms**
- Heroku
- AWS Elastic Beanstalk
- Google Cloud Run
- DigitalOcean App Platform

### Flutter (Mobile)

- **Android:** Upload APK to Google Play Store
- **iOS:** Upload to Apple App Store via Xcode

### Flutter (Web)

Deploy `flutter_app/build/web/` to:
- Firebase Hosting
- Netlify
- Vercel
- AWS S3 + CloudFront

### React

Deploy `react_initial_pages/build/` to:
- Netlify
- Vercel
- GitHub Pages

---

## 📱 User Roles & Permissions

| Feature | Buyer | Seller | Admin |
|---------|-------|--------|-------|
| Browse properties | ✅ | ✅ | ✅ |
| View 360° tours | ✅ | ✅ | ✅ |
| Upload properties | ❌ | ✅ | ✅ |
| Edit own properties | ❌ | ✅ | ✅ |
| Delete any property | ❌ | ❌ | ✅ |
| Leave reviews | ✅ | ❌ | ✅ |

---

## 🧪 Testing

### Backend
```bash
cd backend
npm test
```

### Flutter
```bash
cd flutter_app
flutter test
```

### React
```bash
cd react_initial_pages
npm test
```

---

## 📝 Future Enhancements (Priority-2)

- [ ] Advanced map-based search with multiple location points
- [ ] Payment integration for bookings
- [ ] Messaging system between buyers and sellers
- [ ] Property comparison tool
- [ ] Email notifications
- [ ] Social media sharing
- [ ] Analytics dashboard
- [ ] Multi-language support

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the ISC License.

---

## 👥 Authors

- **Developer** - Full-stack real estate platform with 360° tours

---

## 🙏 Acknowledgments

- **Marzipano** by Google - 360° media viewer
- **Flutter Team** - Cross-platform framework
- **Express.js** - Web framework for Node.js
- **PostgreSQL** - Database system

---

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Email: support@example.com

---

## 🎯 Getting Started (Quick Start)

1. **Clone the repository**
```bash
git clone <repository-url>
cd jomi_joma_basha_bari
```

2. **Set up PostgreSQL** and create database

3. **Start Backend**
```bash
cd backend
npm install
npm run db:setup
npm start
```

4. **Start Flutter App**
```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

5. **Login with default admin**
- Email: `admin@realestate.com`
- Password: `admin123`

---

**🏠 Happy Building! Explore the future of real estate with immersive 360° tours!**

