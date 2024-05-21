const { MongoClient } = require('mongodb');
const uri = "mongodb+srv://app138709:ppf3sZgoeoryHqtY@cluster0.lfqeuvd.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

async function getMessages(req, res) {
    try {
        await client.connect();
        const db = client.db('live_chat_app');
        const channel = req.query.channel || 'default'; // Use 'default' if no channel is provided
        const chat = db.collection(channel);
        const messages = await chat.find().limit(100).sort({ _id: 1 }).toArray();
        res.status(200).json(messages);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

async function postMessage(req, res) {
    try {
        await client.connect();
        const db = client.db('live_chat_app');
        const channel = req.body.channel || 'default'; // Use 'default' if no channel is provided
        const chat = db.collection(channel);
        const newMessage = req.body;
        await chat.insertOne(newMessage);
        res.status(201).json(newMessage);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

module.exports = { getMessages, postMessage };
