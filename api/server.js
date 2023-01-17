const express = require('express');
const app = express();

// Start the server
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Listening on port ${port}...`));

let date_ob = new Date();

let api_response = {
    message: 'Automate all the things!',
    timestamp: date_ob
}

app.get('/', (req, res) => {
    res.json(api_response);
});