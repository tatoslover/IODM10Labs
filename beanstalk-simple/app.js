const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Serve static files from public directory
app.use(express.static('public'));

// Main route with the funny beanstalk poem
app.get('/', (req, res) => {
    res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Elastic Beanstalk Chronicles</title>
    <style>
        body {
            font-family: 'Comic Sans MS', cursive, sans-serif;
            background: linear-gradient(135deg, #87CEEB 0%, #98FB98 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            max-width: 800px;
            text-align: center;
            border: 3px solid #4CAF50;
        }
        .title {
            color: #2E7D32;
            font-size: 2.5em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        .poem {
            font-size: 1.2em;
            line-height: 1.8;
            color: #1B5E20;
            margin: 30px 0;
            text-align: left;
            background: #F1F8E9;
            padding: 25px;
            border-radius: 15px;
            border-left: 5px solid #4CAF50;
        }
        .author {
            font-style: italic;
            color: #558B2F;
            margin-top: 20px;
        }
        .beanstalk {
            font-size: 3em;
            color: #4CAF50;
            margin: 20px 0;
            animation: grow 2s ease-in-out infinite alternate;
        }
        .cloud {
            font-size: 2em;
            color: #87CEEB;
            margin: 10px;
            animation: float 3s ease-in-out infinite;
        }
        @keyframes grow {
            from { transform: scale(0.9); }
            to { transform: scale(1.1); }
        }
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
        }
        .footer {
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
        }
        .aws-info {
            background: #E8F5E8;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
            border: 2px solid #4CAF50;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="cloud">☁️</div>
        <h1 class="title">The Elastic Beanstalk Chronicles</h1>
        <div class="beanstalk">🌱</div>

        <div class="poem">
            <strong>🎭 The Ballad of the Elastic Beanstalk</strong><br><br>

            Once upon a time in the cloud so high,<br>
            Lived a beanstalk reaching for the sky,<br>
            Not made of beans or magic dust,<br>
            But code and servers we could trust!<br><br>

            "Deploy me here!" the developer cried,<br>
            "I need my app to run worldwide!"<br>
            The beanstalk stretched with a mighty grin,<br>
            "Just ZIP your code, let's begin!"<br><br>

            No Docker files, no complex setup,<br>
            Just drag and drop, then bottoms up!<br>
            Auto-scaling when traffic's high,<br>
            Load balancing reaching for the sky!<br><br>

            "But what about my databases?"<br>
            "I'll hook them up with greatest of eases!"<br>
            "And monitoring?" "That's built right in!"<br>
            "Rolling deployments?" "Let's begin!"<br><br>

            So if you're tired of server stress,<br>
            And infrastructure's quite a mess,<br>
            Just plant your app in Beanstalk's soil,<br>
            And watch it grow without much toil!<br><br>

            The end! 🎉<br>
            (But your app's just beginning!)
        </div>

        <div class="author">
            ~ A Poetic Tribute to AWS Elastic Beanstalk ~
        </div>

        <div class="aws-info">
            <h3>🚀 Deployment Info</h3>
            <p><strong>Environment:</strong> AWS Elastic Beanstalk</p>
            <p><strong>Runtime:</strong> Node.js ${process.version}</p>
            <p><strong>Status:</strong> Successfully Deployed! ✅</p>
            <p><strong>Instance Type:</strong> t2.micro (Free Tier)</p>
            <p><strong>Health Check:</strong> <a href="/health">Click here</a></p>
        </div>

        <div class="footer">
            <p>🌱 Grown with love in the AWS cloud 🌱</p>
            <p>Module 10 Lab - Exercise 3: Elastic Beanstalk</p>
        </div>
    </div>
</body>
</html>
    `);
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        message: 'The beanstalk is growing strong! 🌱',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        version: '1.0.0'
    });
});

// API endpoint for fun facts
app.get('/api/beanstalk-facts', (req, res) => {
    const facts = [
        "Beanstalks can grow up to 15 feet tall in the cloud! ☁️",
        "AWS Elastic Beanstalk supports Java, .NET, PHP, Node.js, Python, Ruby, Go, and Docker! 🚀",
        "The first beanstalk was planted in 2011 by Amazon! 🌱",
        "Beanstalks automatically scale based on your application's needs! 📈",
        "You can deploy new versions with zero downtime! ⚡",
        "Monitoring and health checks are built-in! 📊",
        "Load balancing happens automagically! ⚖️"
    ];

    const randomFact = facts[Math.floor(Math.random() * facts.length)];
    res.json({
        fact: randomFact,
        totalFacts: facts.length,
        timestamp: new Date().toISOString()
    });
});

// 404 handler with a fun message
app.use((req, res) => {
    res.status(404).send(`
        <h1>🌱 Oops! This leaf doesn't exist!</h1>
        <p>The beanstalk couldn't find what you're looking for.</p>
        <p><a href="/">🏠 Back to the magical beanstalk</a></p>
    `);
});

// Start the server
app.listen(port, () => {
    console.log(`🌱 The magical beanstalk is growing on port ${port}! 🌱`);
    console.log(`🌍 Visit http://localhost:${port} to see the poem!`);
});
