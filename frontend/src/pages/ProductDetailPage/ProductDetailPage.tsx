import React, { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../../store/store';
import { fetchProductById } from '../../store/slices/productSlice';
import { addToCart } from '../../store/slices/cartSlice';
import './ProductDetailPage.css';

const ProductDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const dispatch = useDispatch<AppDispatch>();
  const { currentProduct, loading, error } = useSelector((state: RootState) => state.products);

  useEffect(() => {
    if (id) {
      dispatch(fetchProductById(id));
    }
  }, [dispatch, id]);

  const handleAddToCart = () => {
    if (currentProduct) {
      dispatch(addToCart(currentProduct));
    }
  };

  if (loading) return <div className="loading container">Loading...</div>;
  if (error) return <div className="error container">{error}</div>;
  if (!currentProduct) return <div className="container">Product not found</div>;

  return (
    <div className="product-detail-page">
      <div className="container">
        <div className="product-detail">
          <div className="product-image">
            <img src={currentProduct.imageUrl} alt={currentProduct.name} />
          </div>
          <div className="product-info">
            <h1>{currentProduct.name}</h1>
            <div className="rating">⭐ {currentProduct.rating.toFixed(1)} / 5</div>
            <div className="price">${currentProduct.price.toFixed(2)}</div>
            <p className="description">{currentProduct.description}</p>
            <div className="stock">
              {currentProduct.stock > 0 ? (
                <span className="in-stock">In Stock: {currentProduct.stock} available</span>
              ) : (
                <span className="out-of-stock">Out of Stock</span>
              )}
            </div>
            <button onClick={handleAddToCart} className="btn btn-primary" disabled={currentProduct.stock === 0}>
              Add to Cart
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProductDetailPage;
