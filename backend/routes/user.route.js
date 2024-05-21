const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chat.controller'); // Ensure the path is correct
const { MongoClient, ObjectId } = require('mongodb');
const uri = "mongodb+srv://app138709:ppf3sZgoeoryHqtY@cluster0.lfqeuvd.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

// Define the route for fetching messages
router.get('/messages', chatController.getMessages);

// Define the route for posting a message
router.post('/messages', chatController.postMessage);

module.exports = router;


async function findUser(query) {
    await client.connect();
    const database = client.db('live_chat_app');
    const collection = database.collection('users');
    return await collection.findOne(query);
}

async function insertUser(user) {
    await client.connect();
    const database = client.db('live_chat_app');
    const collection = database.collection('users');
    return await collection.insertOne(user);
}
// Define the route for user signup
router.post('/signup', async (req, res) => {
    try {
        const existingUser = await findUser({ email: req.body.email });
        if (existingUser) {
            res.json({ message: 'Email is not available' });
        } else {
            const newUser = {
                email: req.body['email'],
                password: req.body['password'],
                username: req.body['username'],
            };
            const result = await insertUser(newUser);
            if (result.insertedCount === 1) {
                res.json({ success: true, user: newUser });
            } else {
                res.status(500).json({ error: 'Failed to create user' });
            }
        }
    } catch (err) {
        console.log(err);
        res.status(500).json(err);
    }
});

// Define the route for user signin
router.post('/signin', async (req, res) => {
    try {
        const user = await findUser({ email: req.body['email'], password: req.body['password'] });
        if (user) {
            res.json({ success: true, userId: user._id, email: user.email });
        } else {
            res.status(401).json({ error: 'Invalid email or password' });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json(err);
    }
});
module.exports = router;
