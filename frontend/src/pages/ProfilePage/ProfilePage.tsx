import React, { useEffect } from 'react';
import { useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { RootState } from '../../store/store';
import './ProfilePage.css';

const ProfilePage: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useSelector((state: RootState) => state.auth);

  useEffect(() => {
    if (!user) {
      navigate('/login');
    }
  }, [user, navigate]);

  if (!user) return null;

  return (
    <div className="profile-page">
      <div className="container">
        <h1>My Profile</h1>
        
        <div className="profile-content">
          <div className="profile-section">
            <h2>Personal Information</h2>
            <div className="info-row">
              <span className="label">Name:</span>
              <span>{user.firstName} {user.lastName}</span>
            </div>
            <div className="info-row">
              <span className="label">Email:</span>
              <span>{user.email}</span>
            </div>
            <button className="btn btn-primary">Edit Profile</button>
          </div>
          
          <div className="profile-section">
            <h2>Account Settings</h2>
            <button className="btn btn-secondary">Change Password</button>
            <button className="btn btn-secondary">Manage Addresses</button>
            <button className="btn btn-secondary">Payment Methods</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;
