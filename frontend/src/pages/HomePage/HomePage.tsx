import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../../store/store';
import { fetchProducts } from '../../store/slices/productSlice';
import './HomePage.css';

const HomePage: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { items, loading } = useSelector((state: RootState) => state.products);

  useEffect(() => {
    dispatch(fetchProducts({ limit: 6 }));
  }, [dispatch]);

  const featuredProducts = items.slice(0, 6);

  return (
    <div className="home-page">
      <section className="hero">
        <div className="container">
          <h1>Welcome to Our E-Commerce Store</h1>
          <p>Discover amazing products at great prices</p>
          <Link to="/products" className="btn btn-primary">
            Shop Now
          </Link>
        </div>
      </section>

      <section className="featured-products">
        <div className="container">
          <h2>Featured Products</h2>
          
          {loading ? (
            <div className="loading">Loading products...</div>
          ) : (
            <div className="product-grid">
              {featuredProducts.map(product => (
                <div key={product.id} className="product-card">
                  <img src={product.imageUrl} alt={product.name} />
                  <h3>{product.name}</h3>
                  <p className="price">${product.price.toFixed(2)}</p>
                  <Link to={`/products/${product.id}`} className="btn btn-primary">
                    View Details
                  </Link>
                </div>
              ))}
            </div>
          )}
          
          <div className="view-all">
            <Link to="/products" className="btn btn-secondary">
              View All Products
            </Link>
          </div>
        </div>
      </section>

      <section className="features">
        <div className="container">
          <div className="feature-grid">
            <div className="feature-item">
              <h3>🚚 Free Shipping</h3>
              <p>On orders over $50</p>
            </div>
            <div className="feature-item">
              <h3>🔒 Secure Payment</h3>
              <p>100% secure transactions</p>
            </div>
            <div className="feature-item">
              <h3>↩️ Easy Returns</h3>
              <p>30-day return policy</p>
            </div>
            <div className="feature-item">
              <h3>💬 24/7 Support</h3>
              <p>Always here to help</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default HomePage;
