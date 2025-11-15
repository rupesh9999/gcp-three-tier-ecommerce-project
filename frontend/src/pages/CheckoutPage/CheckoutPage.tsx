import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../../store/store';
import { createOrder } from '../../store/slices/orderSlice';
import { clearCart } from '../../store/slices/cartSlice';
import './CheckoutPage.css';

const CheckoutPage: React.FC = () => {
  const navigate = useNavigate();
  const dispatch = useDispatch<AppDispatch>();
  const { items, total } = useSelector((state: RootState) => state.cart);
  const { loading, error } = useSelector((state: RootState) => state.orders);
  
  const [shippingAddress, setShippingAddress] = useState({
    fullName: '',
    addressLine1: '',
    addressLine2: '',
    city: '',
    state: '',
    zipCode: '',
    country: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const orderData = {
      items: items.map(item => ({
        productId: item.id,
        productName: item.name,
        quantity: item.quantity,
        price: item.price,
      })),
      shippingAddress: `${shippingAddress.fullName}, ${shippingAddress.addressLine1}, ${shippingAddress.city}, ${shippingAddress.state} ${shippingAddress.zipCode}`,
    };

    try {
      await dispatch(createOrder(orderData)).unwrap();
      dispatch(clearCart());
      navigate('/orders');
    } catch (err) {
      console.error('Order creation failed:', err);
    }
  };

  return (
    <div className="checkout-page">
      <div className="container">
        <h1>Checkout</h1>
        
        <div className="checkout-content">
          <form onSubmit={handleSubmit} className="checkout-form">
            <h2>Shipping Address</h2>
            {error && <div className="error">{error}</div>}
            
            <div className="form-group">
              <label>Full Name</label>
              <input
                type="text"
                required
                value={shippingAddress.fullName}
                onChange={(e) => setShippingAddress({...shippingAddress, fullName: e.target.value})}
              />
            </div>
            
            <div className="form-group">
              <label>Address Line 1</label>
              <input
                type="text"
                required
                value={shippingAddress.addressLine1}
                onChange={(e) => setShippingAddress({...shippingAddress, addressLine1: e.target.value})}
              />
            </div>
            
            <div className="form-group">
              <label>Address Line 2 (Optional)</label>
              <input
                type="text"
                value={shippingAddress.addressLine2}
                onChange={(e) => setShippingAddress({...shippingAddress, addressLine2: e.target.value})}
              />
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label>City</label>
                <input
                  type="text"
                  required
                  value={shippingAddress.city}
                  onChange={(e) => setShippingAddress({...shippingAddress, city: e.target.value})}
                />
              </div>
              
              <div className="form-group">
                <label>State</label>
                <input
                  type="text"
                  required
                  value={shippingAddress.state}
                  onChange={(e) => setShippingAddress({...shippingAddress, state: e.target.value})}
                />
              </div>
              
              <div className="form-group">
                <label>Zip Code</label>
                <input
                  type="text"
                  required
                  value={shippingAddress.zipCode}
                  onChange={(e) => setShippingAddress({...shippingAddress, zipCode: e.target.value})}
                />
              </div>
            </div>
            
            <div className="form-group">
              <label>Country</label>
              <input
                type="text"
                required
                value={shippingAddress.country}
                onChange={(e) => setShippingAddress({...shippingAddress, country: e.target.value})}
              />
            </div>
            
            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? 'Processing...' : 'Place Order'}
            </button>
          </form>
          
          <div className="order-summary">
            <h2>Order Summary</h2>
            <div className="order-items">
              {items.map(item => (
                <div key={item.id} className="order-item">
                  <span>{item.name} x {item.quantity}</span>
                  <span>${(item.price * item.quantity).toFixed(2)}</span>
                </div>
              ))}
            </div>
            <div className="summary-totals">
              <div className="summary-row">
                <span>Subtotal:</span>
                <span>${total.toFixed(2)}</span>
              </div>
              <div className="summary-row">
                <span>Shipping:</span>
                <span>$10.00</span>
              </div>
              <div className="summary-row total">
                <span>Total:</span>
                <span>${(total + 10).toFixed(2)}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CheckoutPage;
