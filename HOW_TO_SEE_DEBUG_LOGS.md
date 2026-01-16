# 🔍 Paano Makita ang Debug Logs sa Flutter

## Method 1: Sa VS Code / Android Studio (Pinakamadali)

### VS Code:
1. **I-click ang "Run and Debug"** sa left sidebar (o press `Ctrl+Shift+D`)
2. **I-select ang device** (phone/emulator)
3. **I-click ang "Start Debugging"** (F5) o green play button
4. **Makikita mo ang logs sa "Debug Console"** sa bottom panel

### Android Studio:
1. **I-click ang "Run" button** (green play icon)
2. **O i-click ang "Debug" button** (bug icon)
3. **Makikita mo ang logs sa "Run" tab** sa bottom panel

---

## Method 2: Sa Terminal/Command Prompt

### I-run ang app gamit ang terminal:
```bash
flutter run
```

### Dapat makita mo ang logs:
```
Launching lib/main.dart on [device] in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk (XX.XMB).
Installing build/app/outputs/flutter-apk/app.apk...
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

[logs will appear here]
```

### Habang naglo-load ang quiz, makikita mo:
```
📡 Starting quiz request...
   Difficulty: easy
   Count: 5
😊 Requesting Emotions quiz: difficulty=easy, count=5
📥 Received result: Yes
   Has questions: true
   Question count: 5
✅ Loaded 5 AI-generated Emotions quiz questions
```

---

## Method 3: Flutter DevTools (Advanced)

### I-open ang DevTools:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

O i-click ang "Open DevTools" sa VS Code/Android Studio.

---

## Method 4: I-filter ang Logs

### Sa VS Code:
1. I-click ang "Debug Console" tab
2. I-type sa search box para mag-filter
3. I-search para sa: `📡`, `😊`, `✅`, `❌`

### Sa Terminal:
```bash
flutter run | grep "📡\|😊\|✅\|❌"
```

---

## Quick Steps para Makita ang Logs:

### Option A: VS Code
1. Press `F5` o i-click ang "Run and Debug"
2. Tignan ang "Debug Console" sa bottom
3. I-filter gamit ang search box

### Option B: Terminal
1. I-open ang terminal
2. I-run: `flutter run`
3. Tignan ang output habang naglo-load ang quiz

### Option C: Android Studio
1. I-click ang "Run" o "Debug" button
2. Tignan ang "Run" tab sa bottom
3. I-scroll para makita ang logs

---

## Ano ang Dapat Makita sa Logs:

### ✅ **Kung gumagana:**
```
📡 Starting quiz request...
😊 Requesting Emotions quiz: difficulty=easy, count=5
📥 Received result: Yes
   Has questions: true
   Question count: 5
✅ Loaded 5 AI-generated Emotions quiz questions
```

### ❌ **Kung may problema:**
```
📡 Starting quiz request...
😊 Requesting Emotions quiz: difficulty=easy, count=5
❌ Error getting Emotions quiz: SocketException...
   ⚠️ Network error - cannot reach backend
```

---

## Tips:

1. **I-keep ang terminal/console open** habang nagte-test
2. **I-scroll up** para makita ang previous logs
3. **I-filter** gamit ang search para mas madaling makita
4. **I-check ang backend terminal** din para sa server logs

---

## Common Debug Messages:

- `📡 Starting quiz request...` - Nagsimula na ang request
- `😊 Requesting Emotions quiz...` - Nagse-send na sa backend
- `📥 Received result: Yes/No` - May response na
- `✅ Loaded X questions` - Successfully loaded
- `❌ Error...` - May error
- `⏱️ Request timed out` - Timeout na

---

**💡 Tip:** I-run ang app gamit ang `flutter run` sa terminal para makita ang lahat ng logs in real-time!

