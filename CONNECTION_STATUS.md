# Backend-Frontend Connection Status

## ✅ Connection Status: CONNECTED

### Frontend (Flutter App)
- ✅ `RestApiService` initialized in `main.dart`
- ✅ Anonymous authentication on app start
- ✅ Settings sync to backend
- ✅ Quiz scores saved to backend
- ✅ Profile page fetches from backend
- ✅ Favorites page fetches from backend

### Backend (Node.js Server)
- ✅ Server configured on port 3000
- ✅ API endpoints ready
- ✅ CORS enabled
- ✅ Data storage configured

### Connection Points

1. **Authentication**
   - `main.dart` → `RestApiService.signInAnonymously()`
   - Connects to: `POST /api/auth/anonymous`

2. **Settings**
   - `main.dart` → `RestApiService.saveUserSettings()`
   - Connects to: `PUT /api/users/:userId/settings`

3. **Quiz Scores**
   - `emotions_quiz_page.dart` → `RestApiService.saveQuizScore()`
   - `bible_verse_quiz_page.dart` → `RestApiService.saveQuizScore()`
   - Connects to: `POST /api/users/:userId/quiz-scores`

4. **Profile**
   - `profile_page.dart` → `RestApiService.getQuizScores()`
   - Connects to: `GET /api/users/:userId/quiz-scores`

5. **Favorites**
   - `favorites_page.dart` → `RestApiService.getFavorites()`
   - `favorites_page.dart` → `RestApiService.removeFavorite()`
   - Connects to: `GET/POST/DELETE /api/users/:userId/favorites`

### Backend URL Configuration

Current setting in `lib/services/rest_api_service.dart`:
```dart
String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
```

### To Test Connection

1. **Start Backend Server:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Test API:**
   ```bash
   curl http://localhost:3000/api/health
   ```
   Should return: `{"status":"ok","message":"Inside Qoutes API is running"}`

3. **Run Flutter App:**
   ```bash
   flutter run
   ```

4. **Verify Connection:**
   - Open app → Settings → Change theme/language
   - Play a quiz → Check Profile page for scores
   - Check backend/data/users.json for saved data

### Troubleshooting

If connection fails:
1. Make sure backend server is running (`npm run dev` in backend folder)
2. Check the `baseUrl` in `rest_api_service.dart` matches your setup:
   - Android Emulator: `http://10.0.2.2:3000/api`
   - iOS Simulator: `http://localhost:3000/api`
   - Physical Device: `http://YOUR_IP:3000/api`
3. Check firewall settings
4. Verify CORS is enabled in backend

