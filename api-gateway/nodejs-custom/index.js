const httpProxy = require('express-http-proxy');
const express = require('express');
const app = express();

app.use('/api/json/:id', httpProxy('api-json:80', {
    proxyReqPathResolver: (req) => Promise.resolve(`/${req.params.id}.json`)
}));

app.use('/api/xml/:id', httpProxy('api-xml:80', {
    proxyReqPathResolver: (req) => Promise.resolve(`/${req.params.id}.xml`)
}));

app.use('/api/pdf/:id', httpProxy('api-pdf:80', {
    proxyReqPathResolver: (req) => Promise.resolve(`/${req.params.id}.pdf`)
}));

app.listen(8080, () => {
    console.log('API Gateway running!');
});