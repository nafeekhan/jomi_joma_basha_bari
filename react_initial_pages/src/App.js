import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import PropertyDetail from './components/PropertyDetail';
import SellerUpload from './components/SellerUpload';
import './styles/App.css';

function App() {
  return (
    <Router>
      <div className="App">
        <nav className="navbar">
          <div className="container">
            <h1 className="logo">🏠 Real Estate Platform</h1>
            <div className="nav-links">
              <Link to="/">Property Detail (360° Tour)</Link>
              <Link to="/upload">Seller Upload</Link>
            </div>
          </div>
        </nav>

        <Routes>
          <Route path="/" element={<PropertyDetail />} />
          <Route path="/upload" element={<SellerUpload />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;

