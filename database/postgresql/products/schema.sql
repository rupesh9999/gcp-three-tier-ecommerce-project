CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100),
    description TEXT,
    parent_id BIGINT REFERENCES categories(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    sku VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    compare_at_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    quantity INTEGER DEFAULT 0,
    low_stock_threshold INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    rating DOUBLE PRECISION DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    brand VARCHAR(50),
    weight_kg DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_images (
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    PRIMARY KEY (product_id, image_url)
);

CREATE TABLE IF NOT EXISTS product_tags (
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    tag VARCHAR(100) NOT NULL,
    PRIMARY KEY (product_id, tag)
);

CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_parent ON categories(parent_id);

-- Insert sample categories
INSERT INTO categories (name, slug, description) VALUES 
    ('Electronics', 'electronics', 'Electronic devices and accessories'),
    ('Clothing', 'clothing', 'Apparel and fashion items'),
    ('Home & Garden', 'home-garden', 'Home improvement and garden supplies')
ON CONFLICT (name) DO NOTHING;

-- Insert sample products
INSERT INTO products (sku, name, description, price, category_id, quantity, is_featured, brand) 
SELECT 
    'ELEC-001', 'Wireless Headphones', 'High-quality wireless headphones with noise cancellation', 
    129.99, c.id, 50, true, 'TechBrand'
FROM categories c WHERE c.slug = 'electronics'
ON CONFLICT (sku) DO NOTHING;

INSERT INTO products (sku, name, description, price, category_id, quantity, is_featured, brand)
SELECT 
    'CLOTH-001', 'Cotton T-Shirt', 'Comfortable 100% cotton t-shirt', 
    29.99, c.id, 100, false, 'FashionCo'
FROM categories c WHERE c.slug = 'clothing'
ON CONFLICT (sku) DO NOTHING;
