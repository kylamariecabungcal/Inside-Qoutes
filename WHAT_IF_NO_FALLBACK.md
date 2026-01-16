# Ano ang Mangyayari kung Aalisin ang Hardcoded Fallback?

## Current Setup (May Fallback)

```
User types feeling
    ↓
Try Backend API
    ↓
Backend Success? → YES → Show Backend Advice ✅
    ↓ NO
Use Local Hardcoded Advice ✅ (Fallback)
```

## Kung Aalisin ang Hardcoded Fallback

### Scenario 1: Backend Available ✅
```
User types feeling
    ↓
Try Backend API
    ↓
Backend Success → Show Backend Advice ✅
```
**Result:** OK, gumagana

### Scenario 2: Backend Down/Offline ❌
```
User types feeling
    ↓
Try Backend API
    ↓
Backend Fails (No connection)
    ↓
No Fallback Available
    ↓
Result: ❌ Walang advice na makikita
        - Loading indicator lang (hindi matatapos)
        - O error message
        - User walang makukuhang sagot
```

### Scenario 3: Backend Slow/Timeout ❌
```
User types feeling
    ↓
Try Backend API (naglo-load ng matagal)
    ↓
Timeout or Error
    ↓
No Fallback
    ↓
Result: ❌ User maghihintay ng walang result
```

## Consequences

### ❌ Problems:
1. **No Offline Support** - App hindi gagana kapag walang internet
2. **Poor User Experience** - Loading lang, walang sagot
3. **Dependency on Backend** - Kailangan laging naka-on ang backend
4. **No Error Recovery** - Walang backup plan

### ✅ Solutions (Kung Aalisin ang Hardcode):

#### Option 1: Ensure Backend Always Responds
- Backend dapat laging may default advice
- Backend dapat laging available
- Add timeout handling sa frontend

#### Option 2: Better Error Handling
- Show error message sa user
- Suggest to try again
- Show "Backend unavailable" message

#### Option 3: Hybrid Approach (Recommended)
- Keep minimal fallback (default advice lang)
- Remove specific emotion detection sa frontend
- Backend handles all logic
- Frontend only shows default if backend completely fails

## Recommendation

**Huwag alisin ang fallback completely**, pero pwedeng:
1. Simplify fallback - Default advice lang (walang emotion detection)
2. Improve backend - Ensure laging may response
3. Add timeout - 5 seconds max, then fallback

