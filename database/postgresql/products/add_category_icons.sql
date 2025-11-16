-- Add icon_url column to categories table
ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon_url VARCHAR(255);

-- Update existing categories or insert new ones with icons
-- First, let's insert the new categories if they don't exist

INSERT INTO categories (name, slug, description, icon_url, is_active, created_at, updated_at)
VALUES 
    ('TV & Appliances', 'tv-appliances', 'Televisions, Air Conditioners, Washing Machines, and more', 'https://cdn-icons-png.flaticon.com/128/2491/2491413.png', true, NOW(), NOW()),
    ('Mobiles & Tablets', 'mobiles-tablets', 'Smartphones, Tablets, and Mobile Accessories', 'https://cdn-icons-png.flaticon.com/128/3845/3845874.png', true, NOW(), NOW()),
    ('Fashion', 'fashion', 'Clothing, Footwear, and Fashion Accessories', 'https://cdn-icons-png.flaticon.com/128/3081/3081559.png', true, NOW(), NOW()),
    ('Electronics', 'electronics', 'Laptops, Cameras, Gaming, and Electronic Gadgets', 'https://cdn-icons-png.flaticon.com/128/4882/4882480.png', true, NOW(), NOW()),
    ('Grocery', 'grocery', 'Food Products, Beverages, and Daily Essentials', 'https://cdn-icons-png.flaticon.com/128/3050/3050158.png', true, NOW(), NOW())
ON CONFLICT (name) DO UPDATE SET
    icon_url = EXCLUDED.icon_url,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Update Electronics category if it exists
UPDATE categories 
SET icon_url = 'https://cdn-icons-png.flaticon.com/128/4882/4882480.png',
    updated_at = NOW()
WHERE slug = 'electronics' AND icon_url IS NULL;
