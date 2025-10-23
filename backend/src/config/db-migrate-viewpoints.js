const pool = require('./database');

/**
 * Migration script to add multi-viewpoint support
 * Converts existing scenes (without rooms) to new room-based structure
 * 
 * For backward compatibility with existing test data:
 * - Each existing scene becomes a room with one viewpoint
 * - Scene name is used as both room name and viewpoint name
 * - The scene is marked as the default viewpoint for that room
 */

async function migrateToViewpointsStructure() {
  const client = await pool.connect();
  
  try {
    console.log('🔄 Starting migration to multi-viewpoint structure...\n');

    await client.query('BEGIN');

    // Find all scenes that don't have a room_id (legacy scenes)
    const { rows: orphanScenes } = await client.query(`
      SELECT 
        s.id as scene_id,
        s.property_id,
        s.scene_name,
        s.scene_order,
        s.initial_view_yaw,
        s.initial_view_pitch,
        s.initial_view_fov
      FROM scenes s
      WHERE s.room_id IS NULL
      ORDER BY s.property_id, s.scene_order
    `);

    if (orphanScenes.length === 0) {
      console.log('✅ No scenes need migration. All scenes already have rooms assigned.');
      await client.query('COMMIT');
      return;
    }

    console.log(`📊 Found ${orphanScenes.length} scenes to migrate\n`);

    let migratedCount = 0;
    let roomsCreated = 0;

    for (const scene of orphanScenes) {
      console.log(`  Processing: ${scene.scene_name} (Scene ID: ${scene.scene_id})`);

      // Create a new room for this scene
      const { rows: [newRoom] } = await client.query(`
        INSERT INTO rooms (property_id, room_name, room_order, default_viewpoint_id)
        VALUES ($1, $2, $3, NULL)
        RETURNING id, room_name
      `, [scene.property_id, scene.scene_name, scene.scene_order]);

      roomsCreated++;
      console.log(`    ✓ Created room: ${newRoom.room_name} (Room ID: ${newRoom.id})`);

      // Update the scene to link it to the new room
      await client.query(`
        UPDATE scenes 
        SET 
          room_id = $1,
          viewpoint_name = 'Main View',
          is_default_viewpoint = true
        WHERE id = $2
      `, [newRoom.id, scene.scene_id]);

      // Set this scene as the default viewpoint for the room
      await client.query(`
        UPDATE rooms 
        SET default_viewpoint_id = $1
        WHERE id = $2
      `, [scene.scene_id, newRoom.id]);

      migratedCount++;
      console.log(`    ✓ Linked scene to room as default viewpoint\n`);
    }

    await client.query('COMMIT');

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ Migration completed successfully!');
    console.log(`📦 Rooms created: ${roomsCreated}`);
    console.log(`🔗 Scenes migrated: ${migratedCount}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Show summary of migrated data
    const { rows: summary } = await client.query(`
      SELECT 
        p.title as property_title,
        r.room_name,
        COUNT(s.id) as viewpoint_count
      FROM properties p
      JOIN rooms r ON r.property_id = p.id
      LEFT JOIN scenes s ON s.room_id = r.id
      GROUP BY p.id, p.title, r.id, r.room_name
      ORDER BY p.title, r.room_order
    `);

    console.log('📋 Property Structure After Migration:');
    console.log('─────────────────────────────────────────\n');
    
    let currentProperty = '';
    for (const row of summary) {
      if (row.property_title !== currentProperty) {
        if (currentProperty !== '') console.log('');
        console.log(`📍 ${row.property_title}`);
        currentProperty = row.property_title;
      }
      console.log(`   └─ ${row.room_name}: ${row.viewpoint_count} viewpoint(s)`);
    }
    console.log('');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

// Run migration if called directly
if (require.main === module) {
  migrateToViewpointsStructure()
    .then(() => {
      console.log('✅ Migration script completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('❌ Migration script failed:', error);
      process.exit(1);
    });
}

module.exports = { migrateToViewpointsStructure };

