const mongoose = require('mongoose');

let connected = false;

const userSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true },
    createdAt: String,
    settings: mongoose.Schema.Types.Mixed,
    quizScores: { type: Array, default: [] },
    favorites: { type: Array, default: [] },
    profile: mongoose.Schema.Types.Mixed,
  },
  { strict: false }
);

const User = mongoose.models.User || mongoose.model('User', userSchema);

async function connect(uri) {
  if (!uri) {
    console.log('No MONGODB_URI provided; skipping MongoDB connection.');
    connected = false;
    return;
  }

  try {
    await mongoose.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    connected = true;
    console.log('✅ Connected to MongoDB');
  } catch (err) {
    connected = false;
    console.error('❌ Failed to connect to MongoDB:', err.message);
    throw err;
  }
}

function isConnected() {
  return connected && mongoose.connection.readyState === 1;
}

async function loadUsers() {
  if (!isConnected()) {
    throw new Error('Not connected to MongoDB');
  }
  const users = await User.find({}).lean();
  const map = {};
  users.forEach((u) => {
    map[u.id] = u;
  });
  return map;
}

async function saveUsers(usersObj) {
  if (!isConnected()) {
    throw new Error('Not connected to MongoDB');
  }

  const ops = Object.values(usersObj).map((u) => ({
    updateOne: {
      filter: { id: u.id },
      update: { $set: u },
      upsert: true,
    },
  }));

  if (ops.length === 0) return;
  await User.bulkWrite(ops, { ordered: false });
}

module.exports = {
  connect,
  isConnected,
  loadUsers,
  saveUsers,
};
