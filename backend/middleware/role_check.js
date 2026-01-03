// Role-based access control middleware

function requireRole(...allowedRoles) {
  return (req, res, next) => {
    // In production, extract role from JWT token
    const userRole = req.user?.role || req.headers['x-user-role'] || 'client';
    
    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({ 
        error: 'Forbidden: Insufficient permissions',
        required: allowedRoles,
        current: userRole,
      });
    }
    
    next();
  };
}

function requireAuth(req, res, next) {
  // In production, verify JWT token
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized: No token provided' });
  }
  
  // In production, decode and verify token
  // For now, mock user from token
  req.user = {
    id: 'user_123',
    role: 'client', // Extract from token
  };
  
  next();
}

module.exports = {
  requireRole,
  requireAuth,
};

