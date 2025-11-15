import React from 'react';
import './Footer.css';

const Footer: React.FC = () => {
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-content">
          <div className="footer-section">
            <h3>About Us</h3>
            <p>Modern e-commerce platform built with cutting-edge technologies.</p>
          </div>
          
          <div className="footer-section">
            <h3>Quick Links</h3>
            <ul>
              <li><a href="/">Home</a></li>
              <li><a href="/products">Products</a></li>
              <li><a href="/cart">Cart</a></li>
            </ul>
          </div>
          
          <div className="footer-section">
            <h3>Contact</h3>
            <p>Email: support@ecommerce.com</p>
            <p>Phone: +1 (555) 123-4567</p>
          </div>
          
          <div className="footer-section">
            <h3>Follow Us</h3>
            <div className="social-links">
              <a href="https://twitter.com">Twitter</a>
              <a href="https://facebook.com">Facebook</a>
              <a href="https://instagram.com">Instagram</a>
            </div>
          </div>
        </div>
        
        <div className="footer-bottom">
          <p>&copy; 2025 E-Commerce Platform. All rights reserved. Powered by Google Cloud.</p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
