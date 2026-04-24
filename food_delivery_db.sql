-- ============================================================
--  FOOD DELIVERY APP — MySQL Database
--  Internship Report Project
-- ============================================================

CREATE DATABASE IF NOT EXISTS food_delivery_app;
USE food_delivery_app;

-- ============================================================
-- TABLE 1: users
-- Stores all customers who order food
-- ============================================================
CREATE TABLE users (
    user_id      INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    phone        VARCHAR(15)  NOT NULL,
    address      TEXT,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 2: restaurants
-- Stores restaurant information
-- ============================================================
CREATE TABLE restaurants (
    restaurant_id   INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    cuisine_type    VARCHAR(50),
    address         TEXT,
    phone           VARCHAR(15),
    rating          DECIMAL(2,1) DEFAULT 0.0,
    is_open         BOOLEAN DEFAULT TRUE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 3: menu_items
-- Each restaurant has many menu items
-- ============================================================
CREATE TABLE menu_items (
    item_id         INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id   INT NOT NULL,
    item_name       VARCHAR(100) NOT NULL,
    description     TEXT,
    price           DECIMAL(8,2) NOT NULL,
    category        VARCHAR(50),   -- e.g. Starter, Main, Dessert, Drink
    is_available    BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
        ON DELETE CASCADE
);

-- ============================================================
-- TABLE 4: delivery_agents
-- Stores delivery personnel
-- ============================================================
CREATE TABLE delivery_agents (
    agent_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    phone       VARCHAR(15)  NOT NULL,
    vehicle     VARCHAR(50),        -- e.g. Bike, Car, Scooter
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 5: orders
-- Core table linking users, restaurants, and agents
-- ============================================================
CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    restaurant_id   INT NOT NULL,
    agent_id        INT,
    status          ENUM('placed','confirmed','preparing','out_for_delivery','delivered','cancelled')
                    DEFAULT 'placed',
    total_amount    DECIMAL(10,2) NOT NULL,
    delivery_address TEXT,
    placed_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    delivered_at    DATETIME,
    FOREIGN KEY (user_id)       REFERENCES users(user_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (agent_id)      REFERENCES delivery_agents(agent_id)
);

-- ============================================================
-- TABLE 6: order_items
-- Line items inside each order (many-to-many: orders <-> menu_items)
-- ============================================================
CREATE TABLE order_items (
    order_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    item_id         INT NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    unit_price      DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id)  REFERENCES menu_items(item_id)
);

-- ============================================================
-- TABLE 7: payments
-- Tracks payment for each order
-- ============================================================
CREATE TABLE payments (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL UNIQUE,
    method          ENUM('cash','card','upi','wallet') NOT NULL,
    status          ENUM('pending','completed','failed','refunded') DEFAULT 'pending',
    amount          DECIMAL(10,2) NOT NULL,
    paid_at         DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- TABLE 8: reviews
-- Users can review a restaurant after delivery
-- ============================================================
CREATE TABLE reviews (
    review_id       INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL UNIQUE,
    user_id         INT NOT NULL,
    restaurant_id   INT NOT NULL,
    rating          TINYINT CHECK (rating BETWEEN 1 AND 5),
    comment         TEXT,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)      REFERENCES orders(order_id),
    FOREIGN KEY (user_id)       REFERENCES users(user_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT INTO users (full_name, email, phone, address) VALUES
('Arjun Mehta',   'arjun@email.com',  '9876543210', '12 MG Road, Chennai'),
('Priya Sharma',  'priya@email.com',  '9123456789', '5 Anna Nagar, Chennai'),
('Ravi Kumar',    'ravi@email.com',   '9012345678', '88 T Nagar, Chennai');

INSERT INTO restaurants (name, cuisine_type, address, phone, rating) VALUES
('Spice Garden',    'Indian',   '10 Park Street, Chennai',  '044-1111111', 4.5),
('Pizza Planet',    'Italian',  '22 Anna Salai, Chennai',   '044-2222222', 4.2),
('Burger Barn',     'American', '7 Velachery Main, Chennai','044-3333333', 4.0);

INSERT INTO menu_items (restaurant_id, item_name, description, price, category) VALUES
(1, 'Butter Chicken',  'Creamy tomato chicken curry',  220.00, 'Main'),
(1, 'Garlic Naan',     'Soft flatbread with garlic',    40.00, 'Bread'),
(1, 'Mango Lassi',     'Sweet yoghurt mango drink',     60.00, 'Drink'),
(2, 'Margherita Pizza','Classic cheese & tomato pizza', 299.00, 'Main'),
(2, 'Garlic Bread',    'Toasted bread with garlic butter',99.00,'Starter'),
(3, 'Classic Burger',  'Beef patty with lettuce & sauce',180.00,'Main'),
(3, 'Fries',           'Crispy golden fries',            80.00, 'Side'),
(3, 'Coke',            '330ml cold drink',               50.00, 'Drink');

INSERT INTO delivery_agents (full_name, phone, vehicle) VALUES
('Suresh Raj',   '9001122334', 'Bike'),
('Kiran Bose',   '9005566778', 'Scooter'),
('Deepak Singh', '9009988776', 'Bike');

INSERT INTO orders (user_id, restaurant_id, agent_id, status, total_amount, delivery_address, delivered_at) VALUES
(1, 1, 1, 'delivered', 320.00, '12 MG Road, Chennai',  '2025-04-20 19:30:00'),
(2, 2, 2, 'delivered', 398.00, '5 Anna Nagar, Chennai', '2025-04-21 20:00:00'),
(3, 3, 3, 'out_for_delivery', 310.00, '88 T Nagar, Chennai', NULL);

INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES
(1, 1, 1, 220.00),
(1, 2, 2,  40.00),
(2, 4, 1, 299.00),
(2, 5, 1,  99.00),
(3, 6, 1, 180.00),
(3, 7, 1,  80.00),
(3, 8, 1,  50.00);

INSERT INTO payments (order_id, method, status, amount, paid_at) VALUES
(1, 'upi',  'completed', 320.00, '2025-04-20 18:45:00'),
(2, 'card', 'completed', 398.00, '2025-04-21 19:10:00'),
(3, 'cash', 'pending',   310.00, NULL);

INSERT INTO reviews (order_id, user_id, restaurant_id, rating, comment) VALUES
(1, 1, 1, 5, 'Amazing food, fast delivery!'),
(2, 2, 2, 4, 'Pizza was great, slightly late.');

-- ============================================================
-- USEFUL QUERIES
-- ============================================================

-- 1. View all orders with user and restaurant name
SELECT o.order_id, u.full_name AS customer, r.name AS restaurant,
       o.status, o.total_amount, o.placed_at
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id;

-- 2. Full order details (items inside each order)
SELECT o.order_id, u.full_name, mi.item_name,
       oi.quantity, oi.unit_price,
       (oi.quantity * oi.unit_price) AS subtotal
FROM order_items oi
JOIN orders o  ON oi.order_id = o.order_id
JOIN users u   ON o.user_id   = u.user_id
JOIN menu_items mi ON oi.item_id = mi.item_id;

-- 3. Revenue per restaurant
SELECT r.name, SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'delivered'
GROUP BY r.name
ORDER BY total_revenue DESC;

-- 4. Average rating per restaurant
SELECT r.name, ROUND(AVG(rv.rating), 1) AS avg_rating, COUNT(*) AS num_reviews
FROM reviews rv
JOIN restaurants r ON rv.restaurant_id = r.restaurant_id
GROUP BY r.name;

-- 5. Pending payments
SELECT o.order_id, u.full_name, p.method, p.amount, p.status
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN users u  ON o.user_id  = u.user_id
WHERE p.status = 'pending';

-- 6. Most popular menu items
SELECT mi.item_name, r.name AS restaurant,
       SUM(oi.quantity) AS total_ordered
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.item_id
JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
GROUP BY mi.item_id
ORDER BY total_ordered DESC;
