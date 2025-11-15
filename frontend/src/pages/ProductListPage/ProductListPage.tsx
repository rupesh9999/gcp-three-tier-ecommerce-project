import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Link } from 'react-router-dom';
import { AppDispatch, RootState } from '../../store/store';
import { fetchProducts, searchProducts } from '../../store/slices/productSlice';
import { addToCart } from '../../store/slices/cartSlice';
import './ProductListPage.css';

const ProductListPage: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { items, loading, error } = useSelector((state: RootState) => state.products);
  const [searchQuery, setSearchQuery] = useState('');
  const [category, setCategory] = useState('');

  useEffect(() => {
    dispatch(fetchProducts({ page: 1, limit: 12, category }));
  }, [dispatch, category]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      dispatch(searchProducts(searchQuery));
    }
  };

  const handleAddToCart = (product: any) => {
    dispatch(addToCart(product));
  };

  return (
    <div className="product-list-page">
      <div className="container">
        <h1>Products</h1>
        
        <div className="filters">
          <form onSubmit={handleSearch} className="search-form">
            <input
              type="text"
              placeholder="Search products..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="search-input"
            />
            <button type="submit" className="btn btn-primary">Search</button>
          </form>
          
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="category-select"
          >
            <option value="">All Categories</option>
            <option value="electronics">Electronics</option>
            <option value="clothing">Clothing</option>
            <option value="books">Books</option>
            <option value="home">Home & Garden</option>
          </select>
        </div>

        {error && <div className="error">{error}</div>}

        {loading ? (
          <div className="loading">Loading products...</div>
        ) : (
          <div className="product-grid">
            {items.map(product => (
              <div key={product.id} className="product-card">
                <Link to={`/products/${product.id}`}>
                  <img src={product.imageUrl} alt={product.name} />
                  <h3>{product.name}</h3>
                </Link>
                <p className="description">{product.description.substring(0, 100)}...</p>
                <p className="price">${product.price.toFixed(2)}</p>
                <div className="rating">⭐ {product.rating.toFixed(1)}</div>
                <div className="card-actions">
                  <Link to={`/products/${product.id}`} className="btn btn-secondary">
                    View Details
                  </Link>
                  <button
                    onClick={() => handleAddToCart(product)}
                    className="btn btn-primary"
                  >
                    Add to Cart
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {items.length === 0 && !loading && (
          <div className="no-products">
            <p>No products found.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default ProductListPage;
