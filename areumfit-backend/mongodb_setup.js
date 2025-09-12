import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

async function setupDatabase() {
  let client;
  
  try {
    console.log('Connecting to MongoDB...');
    client = new MongoClient(process.env.MONGO_URI);
    await client.connect();
    
    const db = client.db(process.env.MONGO_DB);
    console.log(`Connected to database: ${process.env.MONGO_DB}`);

    // Create collections and indexes
    console.log('Creating collections and indexes...');

    // Users collection
    await db.createCollection('af_users');
    await db.collection('af_users').createIndex({ email: 1 }, { unique: true });
    console.log('✓ af_users collection and indexes created');

    // Exercises collection
    await db.createCollection('af_exercises');
    await db.collection('af_exercises').createIndex({ userId: 1, updatedAt: 1 });
    await db.collection('af_exercises').createIndex({ userId: 1, active: 1 });
    await db.collection('af_exercises').createIndex({ userId: 1, domain: 1 });
    console.log('✓ af_exercises collection and indexes created');

    // Rules collection
    await db.createCollection('af_rules');
    await db.collection('af_rules').createIndex({ updatedAt: 1 });
    await db.collection('af_rules').createIndex({ scope: 1 });
    console.log('✓ af_rules collection and indexes created');

    // Sessions collection
    await db.createCollection('af_sessions');
    await db.collection('af_sessions').createIndex({ userId: 1, date: 1 });
    await db.collection('af_sessions').createIndex({ userId: 1, mode: 1 });
    console.log('✓ af_sessions collection and indexes created');

    // Sets collection
    await db.createCollection('af_sets');
    await db.collection('af_sets').createIndex({ sessionId: 1, createdAt: 1 });
    await db.collection('af_sets').createIndex({ exerciseId: 1, createdAt: 1 });
    await db.collection('af_sets').createIndex({ userId: 1, createdAt: 1 });
    console.log('✓ af_sets collection and indexes created');

    // WOD Templates collection
    await db.createCollection('af_wod_templates');
    await db.collection('af_wod_templates').createIndex({ userId: 1, updatedAt: 1 });
    await db.collection('af_wod_templates').createIndex({ userId: 1, active: 1 });
    console.log('✓ af_wod_templates collection and indexes created');

    // Changelog collection
    await db.createCollection('af_changelog');
    await db.collection('af_changelog').createIndex({ userId: 1, createdAt: 1 });
    await db.collection('af_changelog').createIndex({ source: 1, createdAt: 1 });
    await db.collection('af_changelog').createIndex({ autoApproved: 1, createdAt: 1 });
    console.log('✓ af_changelog collection and indexes created');

    // Insert default global rules
    console.log('Inserting default global rules...');
    const defaultRules = {
      _id: 'global_defaults_v1',
      scope: 'global',
      data: {
        defaults: {
          freeweight: { rep_range: '6-9', rest_sec: '120-180' },
          machine: { rep_range: '12-15', rest_sec: '60-90' },
          bodyweight: { rep_range: '8-12', rest_sec: '60-120' },
          cable: { rep_range: '10-15', rest_sec: '60-90' },
          RPE: 8
        },
        guardrails: {
          increment: {
            upper_body_kg: 2.5,
            lower_body_kg: 5.0,
            upper_body_lb: 5,
            lower_body_lb: 10
          }
        },
        deload: {
          cycle_weeks: 8,
          mode: 'full_rest_1w'
        }
      },
      updatedAt: new Date()
    };

    await db.collection('af_rules').replaceOne(
      { _id: defaultRules._id },
      defaultRules,
      { upsert: true }
    );
    console.log('✓ Default global rules inserted');

    // Insert sample exercise
    console.log('Inserting sample exercise...');
    const sampleExercise = {
      _id: 'incline_barbell_bench',
      userId: 'user_sample',
      domain: 'health',
      active: true,
      muscleGroup: 'chest_upper',
      name: '인클라인 바벨 벤치프레스',
      type: 'freeweight',
      repRange: '6-9',
      restSec: '120-180',
      rpe: 8,
      warmup: JSON.stringify({
        style: 'ramp',
        steps: ['30%x5', '50%x4', '70%x3', 'rest 60s']
      }),
      unit: 'kg',
      increment: JSON.stringify({
        upper_body: 2.5,
        lower_body: 5.0
      }),
      excludeUntil: null,
      visibility: 'private',
      sourceRefs: JSON.stringify(['yt:abc#12m30s']),
      updatedAt: new Date()
    };

    await db.collection('af_exercises').replaceOne(
      { _id: sampleExercise._id, userId: sampleExercise.userId },
      sampleExercise,
      { upsert: true }
    );
    console.log('✓ Sample exercise inserted');

    console.log('\\n🎉 Database setup completed successfully!');
    console.log('\\nCollections created:');
    console.log('- af_users (with email unique index)');
    console.log('- af_exercises (with userId, active, domain indexes)');
    console.log('- af_rules (with updatedAt, scope indexes)');
    console.log('- af_sessions (with userId+date, userId+mode indexes)');
    console.log('- af_sets (with sessionId, exerciseId, userId indexes)');
    console.log('- af_wod_templates (with userId+updatedAt, userId+active indexes)');
    console.log('- af_changelog (with userId+createdAt, source, autoApproved indexes)');
    console.log('\\nDefault data inserted:');
    console.log('- Global rules configuration');
    console.log('- Sample exercise (인클라인 바벨 벤치프레스)');

  } catch (error) {
    console.error('Database setup failed:', error);
  } finally {
    if (client) {
      await client.close();
      console.log('\\nDisconnected from MongoDB');
    }
  }
}

// Run setup
setupDatabase();