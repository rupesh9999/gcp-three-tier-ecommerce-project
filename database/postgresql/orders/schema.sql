-- Orders Database Schema

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,
    user_email VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) NOT NULL,
    shipping_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2),
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_country VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    notes TEXT,
    tracking_number VARCHAR(100),
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL,
    product_sku VARCHAR(100) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2),
    tax_amount DECIMAL(10, 2),
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create order_status_history table
CREATE TABLE IF NOT EXISTS order_status_history (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    notes TEXT,
    changed_by VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);

-- Insert sample data
INSERT INTO orders (order_number, user_id, user_email, status, subtotal, tax_amount, shipping_amount, discount_amount, total_amount, payment_method, payment_status, shipping_address_line1, shipping_city, shipping_state, shipping_country, shipping_postal_code)
VALUES 
('ORD-20251116000001-SAMPLE01', 1, 'john.doe@example.com', 'DELIVERED', 129.99, 10.40, 5.00, 0.00, 145.39, 'CREDIT_CARD', 'PAID', '123 Main St', 'San Francisco', 'CA', 'USA', '94102'),
('ORD-20251116000002-SAMPLE02', 1, 'john.doe@example.com', 'SHIPPED', 29.99, 2.40, 5.00, 0.00, 37.39, 'PAYPAL', 'PAID', '123 Main St', 'San Francisco', 'CA', 'USA', '94102');

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, product_sku, product_name, quantity, unit_price, discount_amount, tax_amount, total_price)
VALUES 
(1, 1, 'ELEC-001', 'Wireless Headphones', 1, 129.99, 0.00, 10.40, 140.39),
(2, 2, 'CLOTH-001', 'Cotton T-Shirt', 1, 29.99, 0.00, 2.40, 32.39);

-- Insert sample status history
INSERT INTO order_status_history (order_id, status, notes, changed_by)
VALUES 
(1, 'PENDING', 'Order created', 'SYSTEM'),
(1, 'CONFIRMED', 'Payment confirmed', 'SYSTEM'),
(1, 'PROCESSING', 'Order being processed', 'SYSTEM'),
(1, 'SHIPPED', 'Order shipped', 'WAREHOUSE'),
(1, 'DELIVERED', 'Order delivered', 'COURIER'),
(2, 'PENDING', 'Order created', 'SYSTEM'),
(2, 'CONFIRMED', 'Payment confirmed', 'SYSTEM'),
(2, 'SHIPPED', 'Order shipped', 'WAREHOUSE');
