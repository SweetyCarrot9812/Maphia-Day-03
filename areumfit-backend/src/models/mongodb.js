import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

let client;
let db;

export async function connectToDatabase() {
  if (db) return db;

  try {
    client = new MongoClient(process.env.MONGO_URI);
    await client.connect();
    db = client.db(process.env.MONGO_DB);
    
    console.log('Connected to MongoDB');
    return db;
  } catch (error) {
    console.error('MongoDB connection error:', error);
    throw error;
  }
}

export async function closeDatabaseConnection() {
  if (client) {
    await client.close();
    console.log('Disconnected from MongoDB');
  }
}

export function getDatabase() {
  if (!db) {
    throw new Error('Database not initialized. Call connectToDatabase first.');
  }
  return db;
}

// Collection getters
export const Users = () => getDatabase().collection('af_users');
export const Exercises = () => getDatabase().collection('af_exercises');
export const Rules = () => getDatabase().collection('af_rules');
export const Sessions = () => getDatabase().collection('af_sessions');
export const Sets = () => getDatabase().collection('af_sets');
export const WodTemplates = () => getDatabase().collection('af_wod_templates');
export const Changelog = () => getDatabase().collection('af_changelog');