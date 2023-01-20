const express = require('express');
const app = express();

// Start the server
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Listening on port ${port}...`));

app.get('/', (req, res) => {
    const timeElapsed = Date.now();
    const today = new Date(timeElapsed);
    let api_response = {
        message: 'Automate all the things!',
        timestamp: today.toISOString()
    }
    res.json(api_response);
});

app.use(express.static('public'))
app.use((req, res, next) => {
    res.status(404).sendFile("/app/public/404.html");
});