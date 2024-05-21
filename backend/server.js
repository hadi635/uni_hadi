const express = require('express');
const { MongoClient, ServerApiVersion, ObjectId } = require('mongodb');
const { Server } = require('socket.io');
const http = require('http');
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const fs = require('fs');

const app = express();
app.use(express.json()); // To parse JSON bodies
app.use(cors());

// Create HTTP server and pass the Express app
const server = http.createServer(app);
const io = new Server(server);

// MongoDB Atlas URI and options
const uri = "mongodb+srv://app138709:ppf3sZgoeoryHqtY@cluster0.lfqeuvd.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
const client = new MongoClient(uri, {
    serverApi: {
        version: ServerApiVersion.v1,
        strict: true,
        deprecationErrors: true,
    }
});
app.use('/', require('./routes/user.route'));

// Set up multer for image uploads
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname));
    },
});
const upload = multer({ storage: storage });

app.use('/uploads', express.static('uploads'));
const db = client.db('live_chat_app');

async function run() {
    try {
        // Ensure the uploads directory exists
        if (!fs.existsSync('uploads')) {
            fs.mkdirSync('uploads');
        }

        // Connect the client to the server
        await client.connect();
        // Send a ping to confirm a successful connection
        await client.db("user").command({ ping: 1 });
        console.log("Pinged your deployment. You successfully connected to MongoDB!");

        // Profile update route
        app.post('/update_profile', upload.single('image'), async (req, res) => {
            try {
                const { username, userId } = req.body;
                let imageUrl = req.body.imageUrl;

                if (req.file) {
                    imageUrl = `http://192.168.1.117:4000/uploads/${req.file.filename}`;
                }

                if (!ObjectId.isValid(userId)) {
                    return res.status(400).json({ success: false, message: 'Invalid user ID format' });
                }

                const user = await db.collection('users').findOne({ _id: new ObjectId(userId) });
                if (user) {
                    await db.collection('users').updateOne(
                        { _id: new ObjectId(userId) },
                        { $set: { username: username, imageUrl: imageUrl } }
                    );
                    res.json({ success: true, user: { username, imageUrl } });
                } else {
                    res.status(404).json({ success: false, message: 'User not found' });
                }
            } catch (error) {
                console.error('Error updating profile:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });

        // Create HTTP server and pass the Express app
        const server = http.createServer(app);
        const io = new Server(server);

        // Connect to socket.io
        io.on('connection', function (socket) {
            let chat = db.collection('Chats');

            // Create function to send status
            sendStatus = function (s) {
                socket.emit('status', s);
            }

            // Get chats from mongo collection
            chat.find().limit(100).sort({ _id: 1 }).toArray(function (err, res) {
                if (err) {
                    console.error('Error fetching chats:', err);
                    throw err;
                }

                // Emit messages
                socket.emit('output', res);
            });

            // Handle input events
            socket.on('input', function (data) {
                let name = data.name;
                let message = data.message;

                // Check for name and message
                if (name == '' || message == '') {
                    // Send error status
                    sendStatus('Please enter a name and message');
                } else {
                    // Insert message
                    chat.insertOne({ name: name, message: message }, function (err) {
                        if (err) {
                            console.error('Error inserting message:', err);
                            return;
                        }
                        io.emit('output', [data]);

                        // Send status object
                        sendStatus({
                            message: 'Message sent',
                            clear: true
                        });
                    });
                }
            });

            // Handle clear
            socket.on('clear', function (data) {
                // Remove all chats from collection
                chat.deleteMany({}, function (err) {
                    if (err) {
                        console.error('Error clearing chats:', err);
                        return;
                    }
                    socket.emit('cleared');
                });
            });
        });

        // Listen on port 4000
        server.listen(4000, () => {
            console.log('Server is running on port 4000');
        });
    } catch (err) {
        console.error('Error starting server:', err);
    }
}

app.get('/get_user/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;

        if (!ObjectId.isValid(userId)) {
            return res.status(400).json({ success: false, message: 'Invalid user ID format' });
        }

        const user = await db.collection('users').findOne({ _id: new ObjectId(userId) });
        if (user) {
            res.json({
                success: true,
                user: {
                    username: user.username,
                    imageUrl: user.imageUrl,
                }
            });
        } else {
            res.status(404).json({ success: false, message: 'User not found' });
        }
    } catch (error) {
        console.error('Error fetching user data:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

app.get('/messages', async (req, res) => {
    try {
        await client.connect();
        const db = client.db('live_chat_app');
        const { channel } = req.query;
        const chat = db.collection(req.query.channel);
        const messages = await chat.find(req.query.channel).limit(1000).sort({ _id: 1 }).toArray();
        res.status(200).json(messages);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/messages', async (req, res) => {
    try {
        await client.connect();
        const db = client.db('live_chat_app');
        const { university, channel, user, message } = req.body;
        const chat = db.collection('Chats');
        const newMessage = { university, channel, user, message, timestamp: new Date() };
        await chat.insertOne(newMessage);
        io.emit('output', [newMessage]);
        res.status(201).json(newMessage);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

run().catch(console.dir);
