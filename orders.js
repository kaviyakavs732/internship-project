const express = require('express');
const router = express.Router();
const db = require('../db');
const auth = require('../middleware/authMiddleware');

// Place a new order
router.post('/', auth, async (req, res) => {
  const { restaurant_id, delivery_address, items } = req.body;
  const user_id = req.user.id;

  try {
    const total_amount = items.reduce(
      (sum, item) => sum + item.unit_price * item.quantity, 0
    );

    const [order] = await db.query(
      'INSERT INTO orders (user_id, restaurant_id, total_amount, delivery_address) VALUES (?, ?, ?, ?)',
      [user_id, restaurant_id, total_amount, delivery_address]
    );

    const order_id = order.insertId;

    for (const item of items) {
      await db.query(
        'INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES (?, ?, ?, ?)',
        [order_id, item.item_id, item.quantity, item.unit_price]
      );
    }

    await db.query(
      'INSERT INTO payments (order_id, method, amount) VALUES (?, ?, ?)',
      [order_id, req.body.payment_method || 'cash', total_amount]
    );

    res.json({ message: 'Order placed successfully', order_id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get order details
router.get('/:id', auth, async (req, res) => {
  try {
    const [order] = await db.query(
      `SELECT o.order_id, u.full_name, r.name AS restaurant,
       o.status, o.total_amount, o.placed_at
       FROM orders o
       JOIN users u ON o.user_id = u.user_id
       JOIN restaurants r ON o.restaurant_id = r.restaurant_id
       WHERE o.order_id = ?`,
      [req.params.id]
    );
    res.json(order[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update order status
router.patch('/:id/status', auth, async (req, res) => {
  try {
    await db.query(
      'UPDATE orders SET status = ? WHERE order_id = ?',
      [req.body.status, req.params.id]
    );
    res.json({ message: 'Order status updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;