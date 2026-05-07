const express = require('express');
require('dotenv').config();

const app = express();
app.use(express.json());

// Routes
app.use('/auth', require('./routes/auth'));
app.use('/restaurants', require('./routes/restaurants'));
app.use('/orders', require('./routes/orders'));
app.use('/analytics', require('./routes/analytics'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});