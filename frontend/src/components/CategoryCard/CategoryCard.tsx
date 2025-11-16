import React from 'react';
import { Link } from 'react-router-dom';
import './CategoryCard.css';

interface CategoryCardProps {
  id: number;
  name: string;
  slug: string;
  description: string;
  iconUrl: string;
}

const CategoryCard: React.FC<CategoryCardProps> = ({ id, name, description, iconUrl }) => {
  return (
    <Link to={`/products?category=${id}`} className="category-card">
      <div className="category-icon">
        <img src={iconUrl} alt={name} />
      </div>
      <div className="category-info">
        <h3>{name}</h3>
        <p>{description}</p>
      </div>
    </Link>
  );
};

export default CategoryCard;
