import axios, { AxiosInstance } from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://api.your-domain.com/api/v1';

const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (credentials: { email: string; password: string }) =>
    apiClient.post('/users/login', credentials),
  
  register: (userData: { email: string; password: string; firstName: string; lastName: string }) =>
    apiClient.post('/users/register', userData),
  
  getCurrentUser: () =>
    apiClient.get('/users/me'),
  
  updateProfile: (userId: string, data: any) =>
    apiClient.put(`/users/${userId}`, data),
};

// Product API
export const productAPI = {
  getProducts: (params?: { page?: number; limit?: number; category?: string; search?: string }) =>
    apiClient.get('/products', { params }),
  
  getProductById: (id: string) =>
    apiClient.get(`/products/${id}`),
  
  searchProducts: (query: string) =>
    apiClient.get(`/products/search?q=${query}`),
  
  getCategories: () =>
    apiClient.get('/products/categories'),
};

// Order API
export const orderAPI = {
  createOrder: (orderData: { items: any[]; shippingAddress: string }) =>
    apiClient.post('/orders', orderData),
  
  getOrders: () =>
    apiClient.get('/orders/user/me'),
  
  getOrderById: (id: string) =>
    apiClient.get(`/orders/${id}`),
  
  updateOrderStatus: (id: string, status: string) =>
    apiClient.put(`/orders/${id}/status`, { status }),
};

// Cart API (if backend manages cart)
export const cartAPI = {
  getCart: (userId: string) =>
    apiClient.get(`/cart/${userId}`),
  
  addToCart: (userId: string, productId: string, quantity: number) =>
    apiClient.post('/cart/items', { userId, productId, quantity }),
  
  removeFromCart: (userId: string, productId: string) =>
    apiClient.delete(`/cart/${userId}/items/${productId}`),
  
  clearCart: (userId: string) =>
    apiClient.delete(`/cart/${userId}`),
};

export default apiClient;
