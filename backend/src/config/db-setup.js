const pool = require('./database');

/**
 * Database setup script
 * Creates all necessary tables for the real estate platform
 */

const createTables = async () => {
  try {
    console.log('🔧 Setting up database tables...\n');

    // Enable UUID extension
    await pool.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`);

    // Users table - supports 3 types: buyer, seller, admin
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('buyer', 'seller', 'admin')),
        company_name VARCHAR(255), -- For sellers
        is_verified BOOLEAN DEFAULT FALSE,
        profile_image VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Users table created');

    // Properties table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS properties (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        seller_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(500) NOT NULL,
        description TEXT,
        property_type VARCHAR(50) NOT NULL CHECK (property_type IN ('buy', 'rent')),
        price DECIMAL(15, 2) NOT NULL,
        size_sqft DECIMAL(10, 2),
        bedrooms INTEGER,
        bathrooms INTEGER,
        furnished BOOLEAN DEFAULT FALSE,
        address_line VARCHAR(500) NOT NULL,
        city VARCHAR(100) NOT NULL,
        state VARCHAR(100),
        country VARCHAR(100) NOT NULL,
        postal_code VARCHAR(20),
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        google_maps_url TEXT,
        status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'sold', 'rented', 'pending')),
        views_count INTEGER DEFAULT 0,
        average_rating DECIMAL(3, 2) DEFAULT 0,
        total_reviews INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Properties table created');

    // Property tags table (many-to-many relationship)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS property_tags (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
        tag_name VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(property_id, tag_name)
      );
    `);
    console.log('✅ Property tags table created');

    // Rooms table (for grouping viewpoints by physical room)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS rooms (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
        room_name VARCHAR(255) NOT NULL,
        room_order INTEGER NOT NULL,
        default_viewpoint_id UUID, -- References scenes(id), set after scenes are created
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(property_id, room_order)
      );
    `);
    console.log('✅ Rooms table created');

    // Scenes table (viewpoints within rooms for 360 tour)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS scenes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
        room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
        scene_name VARCHAR(255) NOT NULL, -- Legacy: full scene name for backward compatibility
        viewpoint_name VARCHAR(255) DEFAULT 'Main View', -- Name of this viewpoint within the room
        scene_order INTEGER NOT NULL,
        is_default_viewpoint BOOLEAN DEFAULT false, -- Is this the entrance/default view for the room?
        initial_view_yaw DECIMAL(10, 6) DEFAULT 0,
        initial_view_pitch DECIMAL(10, 6) DEFAULT 0,
        initial_view_fov DECIMAL(10, 6) DEFAULT 1.5708, -- 90 degrees in radians
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(property_id, scene_order)
      );
    `);
    console.log('✅ Scenes table created');

    // Add foreign key constraint for rooms.default_viewpoint_id after scenes table exists
    await pool.query(`
      DO $$ 
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint WHERE conname = 'fk_default_viewpoint'
        ) THEN
          ALTER TABLE rooms 
          ADD CONSTRAINT fk_default_viewpoint 
          FOREIGN KEY (default_viewpoint_id) REFERENCES scenes(id) ON DELETE SET NULL;
        END IF;
      END $$;
    `);
    console.log('✅ Added foreign key constraint for default viewpoint');

    // Scene images table (for multiresolution 360 images)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS scene_images (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        scene_id UUID NOT NULL REFERENCES scenes(id) ON DELETE CASCADE,
        image_type VARCHAR(20) NOT NULL CHECK (image_type IN ('preview', 'tile')),
        resolution_level INTEGER,
        face VARCHAR(10), -- For cube maps: f, b, l, r, u, d
        tile_x INTEGER,
        tile_y INTEGER,
        file_path VARCHAR(500) NOT NULL,
        file_size INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Scene images table created');

    // Hotspots table (navigation arrows and info points in 360 tour)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS hotspots (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        scene_id UUID NOT NULL REFERENCES scenes(id) ON DELETE CASCADE,
        hotspot_type VARCHAR(20) NOT NULL CHECK (hotspot_type IN ('navigation', 'info')),
        target_scene_id UUID REFERENCES scenes(id) ON DELETE CASCADE, -- For navigation hotspots
        target_room_id UUID REFERENCES rooms(id) ON DELETE CASCADE, -- For room navigation (uses default viewpoint)
        is_room_navigation BOOLEAN DEFAULT false, -- true = go to room, false = go to specific viewpoint
        yaw DECIMAL(10, 6) NOT NULL,
        pitch DECIMAL(10, 6) NOT NULL,
        title VARCHAR(255),
        description TEXT,
        icon_url VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Hotspots table created');

    // Property images table (standard property photos, not 360)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS property_images (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
        image_url VARCHAR(500) NOT NULL,
        image_order INTEGER DEFAULT 0,
        is_cover BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Property images table created');

    // Reviews table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS reviews (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
        buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        review_text TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(property_id, buyer_id)
      );
    `);
    console.log('✅ Reviews table created');

    // Saved properties table (buyer wishlist)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS saved_properties (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(buyer_id, property_id)
      );
    `);
    console.log('✅ Saved properties table created');

    // Create indexes for better query performance
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_properties_seller ON properties(seller_id);
      CREATE INDEX IF NOT EXISTS idx_properties_type ON properties(property_type);
      CREATE INDEX IF NOT EXISTS idx_properties_status ON properties(status);
      CREATE INDEX IF NOT EXISTS idx_properties_location ON properties(latitude, longitude);
      CREATE INDEX IF NOT EXISTS idx_scenes_property ON scenes(property_id);
      CREATE INDEX IF NOT EXISTS idx_scene_images_scene ON scene_images(scene_id);
      CREATE INDEX IF NOT EXISTS idx_property_tags_property ON property_tags(property_id);
      CREATE INDEX IF NOT EXISTS idx_reviews_property ON reviews(property_id);
    `);
    console.log('✅ Indexes created');

    // Create a default admin user
    const bcrypt = require('bcryptjs');
    const adminPassword = await bcrypt.hash('admin123', 10);
    
    await pool.query(`
      INSERT INTO users (email, password_hash, full_name, user_type, is_verified)
      VALUES ('admin@realestate.com', $1, 'Admin User', 'admin', TRUE)
      ON CONFLICT (email) DO NOTHING;
    `, [adminPassword]);
    console.log('✅ Default admin user created (email: admin@realestate.com, password: admin123)');

    console.log('\n✅ Database setup completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error setting up database:', error);
    process.exit(1);
  }
};

createTables();

