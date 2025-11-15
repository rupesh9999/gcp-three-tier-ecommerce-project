-- Initial data for users database
-- Version: 1.0.0
-- Description: Seed data for development and testing

-- Note: In production, admin users should be created through secure processes
-- This is for development/testing only

-- Insert test admin user (password: Admin123!)
-- Password is BCrypt hashed
INSERT INTO users (id, first_name, last_name, email, password, enabled, email_verified, created_at, updated_at)
VALUES 
(
    '550e8400-e29b-41d4-a716-446655440000',
    'Admin',
    'User',
    'admin@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye.LH2RLyPkCy.FxH6JqKRzvhj1FWpbXq',
    TRUE,
    TRUE,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440001',
    'John',
    'Doe',
    'john.doe@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye.LH2RLyPkCy.FxH6JqKRzvhj1FWpbXq',
    TRUE,
    TRUE,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'Jane',
    'Smith',
    'jane.smith@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye.LH2RLyPkCy.FxH6JqKRzvhj1FWpbXq',
    TRUE,
    TRUE,
    NOW(),
    NOW()
);

-- Insert roles for users
INSERT INTO user_roles (user_id, role, created_at)
VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'ROLE_ADMIN', NOW()),
('550e8400-e29b-41d4-a716-446655440000', 'ROLE_USER', NOW()),
('550e8400-e29b-41d4-a716-446655440001', 'ROLE_USER', NOW()),
('550e8400-e29b-41d4-a716-446655440002', 'ROLE_USER', NOW());

-- Insert sample addresses
INSERT INTO addresses (user_id, address_type, street_address, city, state, postal_code, country, is_default, created_at, updated_at)
VALUES
(
    '550e8400-e29b-41d4-a716-446655440001',
    'BOTH',
    '123 Main Street',
    'San Francisco',
    'California',
    '94102',
    'United States',
    TRUE,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'SHIPPING',
    '456 Oak Avenue',
    'Los Angeles',
    'California',
    '90001',
    'United States',
    TRUE,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'BILLING',
    '789 Pine Road',
    'Los Angeles',
    'California',
    '90002',
    'United States',
    TRUE,
    NOW(),
    NOW()
);

-- Insert audit log entries for user creation
INSERT INTO user_audit_log (user_id, action, ip_address, metadata, created_at)
VALUES
('550e8400-e29b-41d4-a716-446655440000', 'USER_CREATED', '127.0.0.1', '{"source": "initial_seed"}', NOW()),
('550e8400-e29b-41d4-a716-446655440001', 'USER_CREATED', '127.0.0.1', '{"source": "initial_seed"}', NOW()),
('550e8400-e29b-41d4-a716-446655440002', 'USER_CREATED', '127.0.0.1', '{"source": "initial_seed"}', NOW());
