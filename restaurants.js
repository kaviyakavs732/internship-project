const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all open restaurants
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM restaurants WHERE is_open = true');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get menu of a restaurant
router.get('/:id/menu', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM menu_items WHERE restaurant_id = ? AND is_available = true',
      [req.params.id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;