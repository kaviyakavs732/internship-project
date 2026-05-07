const express = require('express');
const router = express.Router();
const db = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Register
router.post('/register', async (req, res) => {
  const { full_name, email, phone, address, password } = req.body;
  try {
    const hashed = await bcrypt.hash(password, 10);
    await db.query(
      'INSERT INTO users (full_name, email, phone, address, password) VALUES (?, ?, ?, ?, ?)',
      [full_name, email, phone, address, hashed]
    );
    res.json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (users.length === 0)
      return res.status(404).json({ error: 'User not found' });

    const valid = await bcrypt.compare(password, users[0].password);
    if (!valid)
      return res.status(401).json({ error: 'Wrong password' });

    const token = jwt.sign(
      { id: users[0].user_id },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );
    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;