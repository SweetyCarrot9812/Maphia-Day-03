import Joi from 'joi';
import { Exercises, Rules, WodTemplates, Changelog } from '../models/mongodb.js';

const proposalSchema = Joi.object({
  type: Joi.string().valid('UPSERT_EXERCISE', 'UPSERT_WOD', 'UPSERT_RULE', 'PATCH_NOTES', 'PATCH_CUES', 'PATCH_WARMUP').required(),
  confidence: Joi.number().min(0).max(1).required(),
  target: Joi.object({
    collection: Joi.string().required(),
    id: Joi.string().required(),
  }).required(),
  data: Joi.object().required(),
  source_ref: Joi.string().optional(),
});

const autoApproveTypes = ['UPSERT_RULE', 'PATCH_NOTES', 'PATCH_CUES', 'PATCH_WARMUP'];
const minConfidence = 0.85;

export async function ingestProposals(req, res) {
  try {
    const { proposals, confirm = false } = req.body;
    const userId = req.user.sub;

    if (!proposals || !Array.isArray(proposals)) {
      return res.status(400).json({ error: 'proposals array is required' });
    }

    // Validate all proposals
    const validationErrors = [];
    for (let i = 0; i < proposals.length; i++) {
      const { error } = proposalSchema.validate(proposals[i]);
      if (error) {
        validationErrors.push(`Proposal ${i}: ${error.details[0].message}`);
      }
    }

    if (validationErrors.length > 0) {
      return res.status(400).json({ error: 'Validation errors', details: validationErrors });
    }

    const results = [];

    for (const proposal of proposals) {
      try {
        const result = await processProposal(proposal, userId, confirm);
        results.push(result);
      } catch (error) {
        results.push({
          proposal,
          status: 'error',
          error: error.message,
        });
      }
    }

    res.json({ results });
  } catch (error) {
    console.error('Ingest proposals error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}

async function processProposal(proposal, userId, confirm) {
  const { type, confidence, target, data, source_ref } = proposal;
  
  // Check if auto-approval applies
  const autoApprove = autoApproveTypes.includes(type) && confidence >= minConfidence;

  // Create snapshot before any changes
  const snapshotId = `snap_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  let existingDoc = null;
  const collection = getCollection(target.collection);
  
  if (collection) {
    existingDoc = await collection.findOne({ _id: target.id, userId });
  }

  const snapshotEntry = {
    _id: snapshotId,
    userId,
    target,
    diff: { before: existingDoc, after: data },
    autoApproved: autoApprove,
    source: 'ai',
    confidence,
    createdAt: new Date(),
  };

  await Changelog().insertOne(snapshotEntry);

  if (autoApprove || confirm) {
    // Apply the changes
    await applyProposal(proposal, userId);
    
    return {
      proposal,
      status: 'applied',
      autoApproved: autoApprove,
      snapshotId,
    };
  } else {
    // Needs confirmation
    return {
      proposal,
      status: 'needs_confirmation',
      diff: snapshotEntry.diff,
      snapshotId,
    };
  }
}

async function applyProposal(proposal, userId) {
  const { type, target, data } = proposal;
  const collection = getCollection(target.collection);
  
  if (!collection) {
    throw new Error(`Unknown collection: ${target.collection}`);
  }

  const docData = {
    ...data,
    _id: target.id,
    userId: target.collection !== 'af_rules' ? userId : undefined, // Rules are global
    updatedAt: new Date(),
  };

  // Remove undefined fields
  Object.keys(docData).forEach(key => {
    if (docData[key] === undefined) {
      delete docData[key];
    }
  });

  switch (type) {
    case 'UPSERT_EXERCISE':
    case 'UPSERT_WOD':
    case 'UPSERT_RULE':
      await collection.replaceOne(
        { _id: target.id },
        docData,
        { upsert: true }
      );
      break;
      
    case 'PATCH_NOTES':
    case 'PATCH_CUES':
    case 'PATCH_WARMUP':
      await collection.updateOne(
        { _id: target.id },
        { $set: { ...data, updatedAt: new Date() } }
      );
      break;
      
    default:
      throw new Error(`Unknown proposal type: ${type}`);
  }
}

function getCollection(collectionName) {
  switch (collectionName) {
    case 'af_exercises':
      return Exercises();
    case 'af_rules':
      return Rules();
    case 'af_wod_templates':
      return WodTemplates();
    default:
      return null;
  }
}