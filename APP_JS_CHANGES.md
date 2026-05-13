# App.js Changes Summary

## ✅ All Changes Completed

### 1. UserPrefs Class Updates

#### New Fields Added:
```javascript
this.email = "";
this.audio_export_directory = "";
this.autoLoc_directory = "";
this.config_manager_directory = "";
this.anticheat_directory = "C:/Program Files/Common Files/VST3"; // Default
this.anticheat_installed = false;
```

#### Updated Methods:
- `isComplete()` - Now checks for email field
- `saveToStorage()` - Saves all new fields to localStorage
- `loadFromStorage()` - Loads all new fields from localStorage with defaults

---

### 2. SignInScreen Changes

#### Removed:
- ❌ Sample Destination Folder input
- ❌ Project Folder input
- ❌ File path text fields and browse buttons

#### Added:
- ✅ Email input field (type="email")
- ✅ "Sign in with Google" button
- ✅ "Sign in with Discord" button

#### UI Layout:
```
Username: [input]
Email: [input]
Password: [input]
Preferred DAW: [FL Studio] [Logic Pro] [Ableton]
[Sign In] [Sign in with Google] [Sign in with Discord] [Login]
```

#### New Methods:
```javascript
signInWithGoogle() {
    // Shows alert: "Google OAuth integration coming soon!"
    // TODO: Implement Google OAuth
}

signInWithDiscord() {
    // Shows alert: "Discord OAuth integration coming soon!"
    // TODO: Implement Discord OAuth
}
```

---

### 3. UserScreen Changes

#### Added Profile Fields:
- Email (displays user email)
- Anti-Cheat Status (shows ✓ Installed or ✗ Not Installed)
- Sample Destination shows "Not configured" if empty
- Project Folder shows "Not configured" if empty

#### Button Logic:

**Before Installation:**
```
[Install Anti-Cheat]
[Generate Samples] (DISABLED)
[Settings]
[Log Out]
```

**After Installation:**
```
[Reconfigure]
[Reinstall]
[Generate Samples] (ENABLED)
[Settings]
[Log Out]
```

#### New Methods:

**installAnticheat():**
```javascript
- Triggers protocol handler: bbac://install
- Shows installation instructions
- Prompts user to confirm installation
- Sets anticheat_installed = true
- Refreshes screen to show Reconfigure/Reinstall buttons
- Enables Generate Samples button
```

**reconfigureAnticheat():**
```javascript
- Prompts user for new installation path
- Updates anticheat_directory in userPrefs
- Saves to localStorage
```

**reinstallAnticheat():**
```javascript
- Confirms with user
- Triggers protocol handler: bbac://install
- Shows reinstallation instructions
```

---

## User Flow Changes

### New User Registration:
```
1. Click "Sign Up" on Login screen
2. SignInScreen appears with:
   - Username field
   - Email field ← NEW
   - Password field
   - Preferred DAW selection
   - OAuth buttons (Google/Discord) ← NEW
3. Click "Sign In" (regular) or OAuth button
4. Redirected to UserScreen
```

### UserScreen Initial State:
```
User sees:
- Profile info (username, email, DAW, etc.)
- Anti-Cheat Status: ✗ Not Installed
- [Install Anti-Cheat] button
- [Generate Samples] button (DISABLED/GREYED OUT)
- [Settings] and [Log Out]
```

### Installing Anti-Cheat:
```
1. Click [Install Anti-Cheat]
2. Protocol handler opens: bbac://install
3. BBACSetup.exe downloads
4. User runs installer
5. User clicks OK in confirmation dialog
6. anticheat_installed = true
7. Screen refreshes showing:
   - Anti-Cheat Status: ✓ Installed
   - [Reconfigure] and [Reinstall] buttons (replaced Install)
   - [Generate Samples] button (NOW ENABLED)
```

### Using the App:
```
- [Generate Samples] only works after anti-cheat installed
- [Reconfigure] changes installation path
- [Reinstall] triggers fresh installation
```

---

## localStorage Structure

### Before (Old):
```json
{
    "username": "user123",
    "password": "pass123",
    "sample_destination": "C:/Music/Samples",
    "project_folder": "C:/Music/Projects",
    "preferred_daw": "FL Studio",
    "is_logged_in": true
}
```

### After (New):
```json
{
    "username": "user123",
    "password": "pass123",
    "email": "user@example.com",
    "sample_destination": "",
    "project_folder": "",
    "preferred_daw": "FL Studio",
    "is_logged_in": true,
    "audio_export_directory": "",
    "autoLoc_directory": "",
    "config_manager_directory": "",
    "anticheat_directory": "C:/Program Files/Common Files/VST3",
    "anticheat_installed": false
}
```

---

## CSS Updates Needed

Add these styles to your CSS file:

```css
/* OAuth Buttons */
.btn-google {
    background-color: #4285f4;
    color: white;
}

.btn-google:hover {
    background-color: #357ae8;
}

.btn-discord {
    background-color: #5865f2;
    color: white;
}

.btn-discord:hover {
    background-color: #4752c4;
}

/* Install Button */
.btn-install {
    background-color: #2ecc71;
    color: white;
    font-weight: bold;
}

.btn-install:hover {
    background-color: #27ae60;
}

/* Disabled Button */
.btn:disabled {
    background-color: #95a5a6;
    cursor: not-allowed;
    opacity: 0.5;
}

.btn:disabled:hover {
    background-color: #95a5a6;
}

/* Email Input */
input[type="email"] {
    /* Same styling as other inputs */
}
```

---

## Integration Notes

### OAuth Implementation (TODO):
When ready to implement OAuth:

**Google:**
```javascript
signInWithGoogle() {
    const googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
    const redirectUri = window.location.origin + '/auth/google/callback';
    const authUrl = `https://accounts.google.com/o/oauth2/v2/auth?` +
        `client_id=${googleClientId}&` +
        `redirect_uri=${redirectUri}&` +
        `response_type=code&` +
        `scope=email profile`;
    window.location.href = authUrl;
}
```

**Discord:**
```javascript
signInWithDiscord() {
    const discordClientId = 'YOUR_DISCORD_CLIENT_ID';
    const redirectUri = window.location.origin + '/auth/discord/callback';
    const authUrl = `https://discord.com/api/oauth2/authorize?` +
        `client_id=${discordClientId}&` +
        `redirect_uri=${redirectUri}&` +
        `response_type=code&` +
        `scope=identify email`;
    window.location.href = authUrl;
}
```

### Protocol Handler:
The `bbac://install` protocol should be registered in your installer to:
1. Download BBACSetup.exe
2. Or launch installer if already downloaded
3. Or open installer documentation

---

## Testing Checklist

- [ ] Sign up with new email field
- [ ] Email validation works
- [ ] OAuth buttons show alerts (placeholder)
- [ ] Login after signup works
- [ ] UserScreen shows email
- [ ] Anti-Cheat Status shows "Not Installed"
- [ ] Generate Samples button is disabled
- [ ] Install Anti-Cheat button visible
- [ ] Click Install shows dialog
- [ ] After confirming, anticheat_installed = true
- [ ] Screen refreshes with Reconfigure/Reinstall
- [ ] Generate Samples button is now enabled
- [ ] Reconfigure prompts for new path
- [ ] Reinstall shows confirmation
- [ ] All data persists in localStorage
- [ ] Logout and login preserves all settings

---

## Migration for Existing Users

Existing localStorage data will automatically upgrade:
- New fields get default values
- Old fields remain intact
- `anticheat_installed` defaults to `false`
- `anticheat_directory` defaults to VST3 path

Users with old data will see:
- Sample Destination and Project Folder (if they had them)
- Anti-Cheat Status: ✗ Not Installed
- Will need to click Install Anti-Cheat

---

## Future Enhancements

1. **Settings Screen** - Configure all directories:
   - Sample Destination
   - Project Folder
   - Audio Export Directory
   - AutoLoc Directory
   - Config Manager Directory
   - Anti-Cheat Directory

2. **OAuth Integration** - Real Google/Discord login

3. **Installer Integration** - Actual download and installation flow

4. **Status Verification** - Check if anti-cheat is actually installed via protocol

5. **Path Validation** - Verify directories exist before saving

All changes are backward compatible and ready for testing! 🎉
