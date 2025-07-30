# Quick Test Guide - Health Care Management System

## 🧪 Full-Stack Application Test

This guide helps you quickly verify that the Health Care Management System (full-stack application) is working correctly on your Ubuntu 24.04 LTS machine.

## 🚀 **Quick Start Options**

### **Option 1: Docker Testing (Recommended)**
```bash
# Start all services with Docker
docker compose up -d

# Verify all containers are healthy
docker compose ps
```

### **Option 2: Development Mode Testing**
```bash
# Start both frontend and backend
npm run dev

# Or start individually:
npm run dev:frontend  # Frontend only
npm run dev:backend   # Backend only
```

## Prerequisites
- **Docker Option**: Docker and Docker Compose installed
- **Development Option**: Completed setup from `LOCAL_SETUP_GUIDE.md`
- **Project Structure**: Monorepo with frontend/ and backend/ subdirectories

## 🔍 **Docker Testing Checklist**

### ✅ 1. Container Status Test
```bash
# Check all containers are running and healthy
docker compose ps

# Expected output: All containers show "Up (healthy)" status
# - healthcare-frontend: Up (healthy)
# - healthcare-backend: Up (healthy)
# - healthcare-db: Up (healthy)
# - healthcare-nginx: Up (healthy)
```

### ✅ 2. Backend API Test
```bash
# Test backend health endpoint
curl -s http://localhost:3002/health && echo "✅ Backend server is running" || echo "❌ Backend server not responding"

# Test doctors API endpoint
curl -s http://localhost:3002/api/doctors && echo "✅ Doctors API working" || echo "❌ Doctors API failed"

# Expected response: {"success":true,"data":{"doctors":[],"pagination":...}}
```

### ✅ 3. Frontend Server Test
```bash
# Test frontend accessibility
curl -s -I http://localhost:5173 && echo "✅ Frontend server is running" || echo "❌ Frontend server not responding"

# Test Nginx reverse proxy
curl -s -I http://localhost:80 && echo "✅ Nginx proxy working" || echo "❌ Nginx proxy failed"

# Expected: HTTP/1.1 200 OK responses
```

### ✅ 4. Database Connection Test
```bash
# Test database connectivity through backend
curl -s http://localhost:3002/api/doctors | grep -q "success" && echo "✅ Database connected" || echo "❌ Database connection failed"

# Direct database test (Docker)
docker compose exec database psql -U healthcare_user -d healthcare_db -c "SELECT 1;" && echo "✅ Direct DB access working"
# Password: healthcare_password
```

## 🛠️ **Development Mode Testing Checklist**

### ✅ 1. Backend Server Test (Development)
```bash
# Check if backend server is running (development mode)
curl -s http://localhost:3002/health && echo "✅ Backend server is running" || echo "❌ Backend server not responding"

# Test API endpoints
curl -s http://localhost:3002/api/doctors | jq '.success' && echo "✅ Doctors API working" || echo "❌ Doctors API failed"
```

### ✅ 2. Frontend Server Test (Development)
```bash
# Check if frontend server is running
curl -s http://localhost:5173 | grep -q "RouteClouds Health" && echo "✅ Frontend server is running" || echo "❌ Frontend server not responding"
```

### ✅ 3. Database Connection Test (Development)
```bash
# Test database connection through API
curl -s http://localhost:3002/api/doctors | grep -q "success" && echo "✅ Database connected" || echo "❌ Database connection failed"

# Test local PostgreSQL (if running locally)
pg_isready -h localhost -p 5432 && echo "✅ Local PostgreSQL running" || echo "❌ Local PostgreSQL not running"
```

## 🌐 **Browser Testing Checklist**

### ✅ 4. Application Loading Test
1. **Docker Mode**: Open browser and navigate to: `http://localhost:5173`
2. **Development Mode**: Open browser and navigate to: `http://localhost:5173`
3. **Nginx Proxy**: Open browser and navigate to: `http://localhost:80`
4. **Expected Results:**
   - Page loads within 2-3 seconds
   - No JavaScript errors in browser console (F12)
   - Page title shows "RouteClouds Health Platform"
   - RouteClouds Health Platform content is visible
   - Responsive design works on mobile/desktop

### ✅ 5. Authentication System Test
1. **Registration Test:**
   - Navigate to: `http://localhost:5173/register`
   - Fill out registration form with test data
   - Expected: Successful registration and redirect to doctors page

2. **Login Test:**
   - Navigate to: `http://localhost:5173/login`
   - Use credentials: username: `newuser`, password: `pass123`
   - Expected: Successful login and redirect to doctors page

3. **User Welcome Message Test:**
   - After login, check header for "Welcome, [FirstName] [LastName]!"
   - Hover over welcome message to see user details tooltip
   - Expected: Full name display and hover tooltip with email

4. **API Authentication Test:**
   ```bash
   # Test protected endpoints (should require authentication)
   curl -s http://localhost:3002/api/appointments
   # Expected: {"success":false,"message":"Access token required"}
   ```

### ✅ 5. Navigation Test
Test all navigation links work correctly:

**Header Navigation:**
- [ ] Home → `http://localhost:5173/home`
- [ ] Find a Doctor → `http://localhost:5173/doctors`
- [ ] Our Services → `http://localhost:5173/services`
- [ ] Login/Logout functionality

**Hero Section Buttons:**
- [ ] "Find a Doctor" button → `http://localhost:5173/doctors`
- [ ] "Our Services" button → `http://localhost:5173/services`

### ✅ 6. Visual Components Test
Verify these elements are visible and properly styled:

**Header Section:**
- [ ] Navigation bar with logo/branding
- [ ] User welcome message (when logged in)
- [ ] Professional healthcare styling
- [ ] Responsive design (test by resizing browser)

**Hero Section:**
- [ ] Main headline about healthcare platform
- [ ] Call-to-action buttons working correctly
- [ ] Professional healthcare imagery/styling
- [ ] Proper spacing and typography

**Features Section:**
- [ ] Feature cards or sections
- [ ] Icons (Lucide React icons)
- [ ] Descriptive text about platform capabilities
- [ ] Grid or card layout

**Footer Section:**
- [ ] Footer information
- [ ] Proper styling and spacing

### ✅ 4. Responsive Design Test
Test the application at different screen sizes:

```bash
# Test different viewport sizes in browser dev tools (F12)
# Mobile: 375px width
# Tablet: 768px width  
# Desktop: 1200px width
```

**Expected Results:**
- [ ] Layout adapts to different screen sizes
- [ ] Text remains readable
- [ ] Navigation works on mobile
- [ ] No horizontal scrolling issues

### ✅ 5. Performance Test
```bash
# Check build size
npm run build
ls -lh dist/assets/

# Expected results:
# CSS file: ~12KB (gzipped ~3KB)
# JS file: ~216KB (gzipped ~69KB)
```

### ✅ 6. Development Tools Test
```bash
# Test linting
npm run lint
# Should complete without critical errors

# Test TypeScript compilation
npx tsc --noEmit
# Should complete without errors
```

### ✅ 7. Hot Reload Test
1. With dev server running, edit `src/App.tsx`
2. Make a small change (e.g., modify text)
3. Save the file
4. **Expected Result:** Browser automatically updates without full page reload

### ✅ 8. State Management Test
Open browser dev tools (F12) and check:
1. Go to Redux DevTools extension (if installed)
2. **Expected Result:** Redux store is initialized and visible

### ✅ 9. Network Test
In browser dev tools (F12), check Network tab:
1. Refresh the page
2. **Expected Results:**
   - Main HTML loads quickly
   - CSS and JS assets load without errors
   - No 404 errors
   - Total load time under 2 seconds

## 🐛 Common Issues and Solutions

### Issue: Port 5173 already in use
```bash
# Solution: Kill process using the port
sudo lsof -ti:5173 | xargs kill -9
# Or use different port
npm run dev -- --port 3000
```

### Issue: "Cannot find module" errors
```bash
# Solution: Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Issue: TypeScript errors
```bash
# Solution: Check TypeScript configuration
npx tsc --noEmit --listFiles
```

### Issue: Styling not loading
```bash
# Solution: Check Tailwind CSS setup
npm run build
# Check if CSS file is generated in dist/assets/
```

### ✅ 7. Doctor Listing Test
1. **Navigate to Doctors Page:**
   - Go to: `http://localhost:5173/doctors`
   - Expected: List of 5 doctors displayed

2. **Doctor Information Verification:**
   - [ ] Dr. Sarah Johnson (Cardiology)
   - [ ] Dr. Michael Chen (Pulmonology)
   - [ ] Dr. Emily Rodriguez (Neurology)
   - [ ] Dr. David Thompson (Orthopedics)
   - [ ] Dr. Lisa Anderson (Nephrology)

3. **Search and Filter Test:**
   - [ ] Search functionality works
   - [ ] Department filter works
   - [ ] Results update dynamically

### ✅ 8. Services Page Test
1. **Navigate to Services Page:**
   - Go to: `http://localhost:5173/services`
   - Expected: Comprehensive healthcare services page

2. **Services Content Verification:**
   - [ ] 6 major services displayed (Cardiology, Neurology, Ophthalmology, Pulmonology, Orthopedics, Nephrology)
   - [ ] Service cards with icons and descriptions
   - [ ] "Why Choose Us" section
   - [ ] Contact information section

### ✅ 9. Appointment Booking System Test
1. **Appointment Access Test:**
   - Login with credentials: `newuser` / `pass123`
   - Click "My Appointments" in header → Should go to appointments page ✅
   - Click "Book" button on any doctor card → Should go to appointment booking ✅

2. **Appointment Dashboard Test:**
   - [x] Appointments page loads correctly (no blank page) ✅
   - [x] Professional dashboard interface displays ✅
   - [x] Empty state shows "Book Your First Appointment" ✅
   - [x] Status filtering buttons work (All, Scheduled, Completed, Cancelled) ✅
   - [x] "Book New Appointment" button navigates to booking form ✅

3. **Backend API Test:**
   - [x] GET /api/appointments returns user appointments ✅
   - [x] POST /api/appointments creates new appointment ✅
   - [x] GET /api/appointments/availability/:doctorId/:date returns time slots ✅
   - [x] All appointment endpoints respond correctly ✅

4. **Issue Resolution Verification:**
   - [x] Appointments page no longer shows blank screen ✅
   - [x] React component rendering works properly ✅
   - [x] Navigation between appointment views functional ✅
   - [x] Professional healthcare UI displays correctly ✅

**Note:** Full appointment booking flow pending React Query hook integration.

### ✅ 10. Full Application Flow Test
1. **Complete User Journey:**
   - Start at home page
   - Click "Find a Doctor" → Should go to doctors page
   - Click "Our Services" → Should go to services page
   - Click "Book" on doctor card → Should go to appointment booking
   - Register new account → Should redirect to doctors page
   - Login with existing account → Should show welcome message
   - Access "My Appointments" → Should show appointment dashboard
   - Logout → Should return to public view

2. **Expected Results:**
   - [ ] All navigation works correctly
   - [ ] No broken links or 404 errors
   - [ ] Authentication state persists correctly
   - [ ] Appointment system integrates seamlessly
   - [ ] User experience is smooth and professional

## 📊 Performance Benchmarks

**Expected Performance Metrics:**
- **Development server startup:** < 1 second
- **Hot reload time:** < 500ms
- **Production build time:** < 10 seconds
- **Page load time:** < 2 seconds
- **Bundle size (gzipped):** ~72KB total

## ✅ Success Criteria

## ✅ **Success Criteria**

### **Docker Mode Success:**
- [x] All 4 containers show "Up (healthy)" status
- [x] Backend health check returns success JSON
- [x] Frontend loads at http://localhost:5173
- [x] API endpoints return correct responses
- [x] Database connection works through API
- [x] Authentication system functions properly
- [x] No critical errors in container logs

### **Development Mode Success:**
- [x] Development servers start without errors
- [x] Application loads in browser at http://localhost:5173
- [x] Backend API responds at http://localhost:3002
- [x] All visual components render correctly
- [x] Responsive design works on mobile/desktop
- [x] Hot reload functions properly
- [x] No critical console errors
- [x] TypeScript compilation passes
- [x] Authentication and API integration works

## 🛠️ **Troubleshooting Common Issues**

### **Docker Issues:**
```bash
# Container not starting
docker compose down && docker compose up -d --build

# Check container logs
docker compose logs backend
docker compose logs frontend
docker compose logs database

# Reset everything
docker compose down --volumes
docker volume rm healthcare_postgres_data
docker compose up -d
```

### **Port Conflicts:**
```bash
# Check what's using ports
lsof -ti:5173  # Frontend
lsof -ti:3002  # Backend
lsof -ti:5432  # Database

# Kill conflicting processes
kill -9 $(lsof -ti:3002)
```

### **Database Connection Issues:**
```bash
# Test database directly (Docker)
docker compose exec database psql -U healthcare_user -d healthcare_db -c "SELECT 1;"
# Password: healthcare_password

# Check backend environment
docker compose exec backend env | grep DATABASE_URL
```

### **API Issues:**
```bash
# Test backend health
curl -v http://localhost:3002/health

# Check backend logs
docker compose logs backend | tail -20

# Test with verbose output
curl -v http://localhost:3002/api/doctors
```

## 🎯 Next Steps After Successful Test

1. **Explore the codebase:**
   - Review `src/components/` for UI components
   - Check `src/store/` for Redux setup
   - Examine `src/types/` for TypeScript definitions

2. **Start development:**
   - Add new components
   - Implement API integration
   - Add routing for different pages
   - Enhance styling and features

3. **Set up testing:**
   - Write unit tests with Vitest
   - Add integration tests
   - Set up E2E testing

---

**🎉 Congratulations!** If all tests pass, your Health Care Management System is ready for development on Ubuntu 24.04 LTS!
