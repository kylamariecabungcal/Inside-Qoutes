# Backend Setup Guide

## Quick Start

### 1. Install Backend Dependencies

```bash
cd backend
npm install
```

### 2. Start Backend Server

```bash
# Development mode (with auto-reload)
npm run dev

# Or production mode
npm start
```

The server will run on `http://localhost:3000`

### 3. Update Flutter App URL (if needed)

Open `lib/services/rest_api_service.dart` and check the `baseUrl`:

- **Android Emulator**: `http://10.0.2.2:3000/api` ✅ (already set)
- **iOS Simulator**: `http://localhost:3000/api`
- **Physical Device**: `http://YOUR_COMPUTER_IP:3000/api`

To find your computer's IP:
- Windows: `ipconfig` (look for IPv4 Address)
- Mac/Linux: `ifconfig` or `ip addr`

### 4. Run Flutter App

```bash
flutter run
```

## Testing Connection

1. Start the backend server
2. Test the API:
```bash
curl http://localhost:3000/api/health
```

Should return: `{"status":"ok","message":"Inside Qoutes API is running"}`

3. Run the Flutter app
4. The app will automatically:
   - Sign in anonymously
   - Sync settings to backend
   - Save quiz scores to backend
   - Display profile statistics
   - Manage favorites

## Features Connected

✅ **Settings Sync** - Theme and language saved to backend
✅ **Quiz Scores** - All quiz results tracked in backend
✅ **User Profile** - Statistics and history displayed
✅ **Favorites** - Save and manage favorites

## Troubleshooting

### Backend not connecting
- Make sure backend server is running (`npm run dev`)
- Check the `baseUrl` in `rest_api_service.dart`
- For Android emulator, use `10.0.2.2:3000`
- For physical device, use your computer's IP address

### CORS errors
- Backend already has CORS enabled
- If issues persist, check `backend/server.js` CORS configuration

### Port already in use
- Change PORT in `backend/server.js` or use environment variable
- Update `baseUrl` in Flutter app accordingly

## Data Storage

Data is stored in `backend/data/users.json`. For production, use a real database.

