import { Exercises, Rules, Sessions, Sets, WodTemplates, Changelog } from '../models/mongodb.js';

export async function syncDelta(req, res) {
  try {
    const { since } = req.query;
    const userId = req.user.sub;
    
    if (!since) {
      return res.status(400).json({ error: 'since parameter is required' });
    }

    const sinceDate = new Date(since);
    if (isNaN(sinceDate.getTime())) {
      return res.status(400).json({ error: 'Invalid date format for since parameter' });
    }

    const query = {
      userId,
      updatedAt: { $gt: sinceDate }
    };

    const [exercises, rules, sessions, sets, wodTemplates, changelog] = await Promise.all([
      Exercises().find(query).toArray(),
      Rules().find({ updatedAt: { $gt: sinceDate } }).toArray(), // Rules are global
      Sessions().find(query).toArray(),
      Sets().find(query).toArray(),
      WodTemplates().find(query).toArray(),
      Changelog().find(query).toArray(),
    ]);

    res.json({
      exercises,
      rules,
      sessions,
      sets,
      wodTemplates,
      changelog,
      syncTimestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Sync delta error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}

export async function saveSnapshot(req, res) {
  try {
    const { target, data, source = 'user' } = req.body;
    const userId = req.user.sub;

    if (!target || !data) {
      return res.status(400).json({ error: 'target and data are required' });
    }

    // Create snapshot entry in changelog
    const snapshotEntry = {
      _id: `snap_${Date.now()}`,
      userId,
      target,
      diff: { before: null, after: data },
      autoApproved: false,
      source,
      confidence: null,
      createdAt: new Date(),
    };

    await Changelog().insertOne(snapshotEntry);

    res.json({ 
      ok: true, 
      snapshotId: snapshotEntry._id,
      timestamp: snapshotEntry.createdAt 
    });
  } catch (error) {
    console.error('Save snapshot error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}