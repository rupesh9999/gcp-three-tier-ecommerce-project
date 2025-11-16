import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../../store/store';
import { fetchProducts } from '../../store/slices/productSlice';
import { productAPI } from '../../services/api';
import CategoryCard from '../../components/CategoryCard/CategoryCard';
import './HomePage.css';

interface Category {
  id: number;
  name: string;
  slug: string;
  description: string;
  iconUrl: string;
}

const HomePage: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { items, loading } = useSelector((state: RootState) => state.products);
  const [categories, setCategories] = useState<Category[]>([]);
  const [categoriesLoading, setCategoriesLoading] = useState(true);

  useEffect(() => {
    dispatch(fetchProducts({ limit: 6 }));
    
    // Fetch categories
    productAPI.getCategories()
      .then(response => {
        setCategories(response.data);
        setCategoriesLoading(false);
      })
      .catch(error => {
        console.error('Error fetching categories:', error);
        setCategoriesLoading(false);
      });
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

      <section className="categories-section">
        <div className="container">
          <h2>Shop by Category</h2>
          {categoriesLoading ? (
            <div className="loading">Loading categories...</div>
          ) : (
            <div className="categories-grid">
              {categories.map(category => (
                <CategoryCard
                  key={category.id}
                  id={category.id}
                  name={category.name}
                  slug={category.slug}
                  description={category.description}
                  iconUrl={category.iconUrl}
                />
              ))}
            </div>
          )}
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
