const express = require('express');
const router = express.Router();
const db = require('../db');

// Revenue per restaurant
router.get('/revenue', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT r.name, SUM(o.total_amount) AS total_revenue
       FROM orders o
       JOIN restaurants r ON o.restaurant_id = r.restaurant_id
       WHERE o.status = 'delivered'
       GROUP BY r.name
       ORDER BY total_revenue DESC`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Most popular items
router.get('/popular-items', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT mi.item_name, r.name AS restaurant,
       SUM(oi.quantity) AS total_ordered
       FROM order_items oi
       JOIN menu_items mi ON oi.item_id = mi.item_id
       JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
       GROUP BY mi.item_id
       ORDER BY total_ordered DESC`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;