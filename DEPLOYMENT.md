# Deployment Guide for Render

This guide covers deploying both backend and frontend services on Render.

## Backend Deployment (Node.js + Python)

### Using Dockerfile

1. **Create a new Web Service on Render**
   - Connect your GitHub repository
   - Select the repository
   - Set the following:
     - **Name**: `karmgyan-backend` (or your preferred name)
     - **Root Directory**: `backend`
     - **Environment**: `Docker`
     - **Dockerfile Path**: `backend/Dockerfile`
     - **Port**: `3000` (or your preferred port)

2. **Environment Variables**
   Add the following environment variables in Render dashboard:
   ```
   PORT=3000
   NODE_ENV=production
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_key
   RAZORPAY_KEY_ID=your_razorpay_key_id
   RAZORPAY_KEY_SECRET=your_razorpay_key_secret
   ```

3. **Health Check**
   The Dockerfile includes a health check endpoint. Render will automatically use it.

### Without Docker (Alternative)

If you prefer not to use Docker:
- **Build Command**: `npm install && pip3 install -r requirements.txt`
- **Start Command**: `npm start`
- **Environment**: `Node`

## Frontend Deployment (Flutter Web)

### Using Dockerfile

1. **Create a new Web Service on Render** (Recommended)
   - Connect your GitHub repository
   - Select the repository
   - Set the following:
     - **Name**: `karmgyan-frontend`
     - **Root Directory**: `.` (root)
     - **Environment**: `Docker`
     - **Dockerfile Path**: `Dockerfile`
     - **Port**: `80`

2. **Environment Variables** (Optional - for build-time configuration)
   If you need to configure the backend URL at build time, you can add:
   ```
   BACKEND_URL=https://karmgyan-backend.onrender.com
   ```
   Note: The Flutter app uses compile-time environment variables. You may need to update `lib/config/env_config.dart` to read from runtime configuration if needed.

### Alternative: Build Locally and Deploy Static Files

1. **Build Flutter Web App Locally**:
   ```bash
   flutter build web --release --web-renderer canvaskit
   ```

2. **Create a Static Site on Render**:
   - **Build Command**: `echo "Pre-built"`
   - **Publish Directory**: `build/web`

## Local Development with Docker Compose

1. **Start both services**:
   ```bash
   docker-compose up --build
   ```

2. **Access services**:
   - Frontend: http://localhost
   - Backend: http://localhost:3000

3. **Stop services**:
   ```bash
   docker-compose down
   ```

## Important Notes

1. **Backend Environment Variables**: Make sure all required environment variables are set in Render dashboard.

2. **CORS Configuration**: Update your backend CORS settings to allow requests from your frontend domain.

3. **Database**: Ensure your Supabase database is accessible from Render's servers.

4. **Python Dependencies**: The Dockerfile installs Python dependencies. Make sure `requirements.txt` is up to date.

5. **Node.js Version**: The Dockerfile uses Node 18. Update if you need a different version.

6. **Health Check**: The backend includes a `/health` endpoint for monitoring.

## Troubleshooting

### Backend Issues

- **Python scripts not working**: Check that Python 3 and all dependencies are installed correctly.
- **Port issues**: Ensure the PORT environment variable matches what Render expects.
- **Build failures**: Check build logs in Render dashboard.

### Frontend Issues

- **API calls failing**: Verify the backend URL in environment configuration.
- **Build size too large**: Consider using `--web-renderer html` instead of `canvaskit` for smaller builds.
- **CORS errors**: Update backend CORS settings.

## Security Recommendations

1. Never commit `.env` files
2. Use Render's environment variable feature for secrets
3. Enable HTTPS (Render provides this automatically)
4. Keep dependencies updated
5. Use the non-root user in Docker containers (already configured in Dockerfile)

