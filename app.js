// JavaScript source code

// UserPrefs Class - Manages user preferences and localStorage
class UserPrefs {
    constructor() {
        this.username = "";
        this.password = "";
        this.email = "";
        this.sample_destination = "";
        this.project_folder = "";
        this.preferred_daw = "";
        this.is_logged_in = false;
        this.audio_export_directory = "";
        this.autoLoc_directory = "";
        this.config_manager_directory = "";
        this.anticheat_directory = "C:/Program Files/Common Files/VST3";
        this.anticheat_installed = false;

        this.loadFromStorage();
    }

    isComplete() {
        return !!(
            this.username &&
            this.password &&
            this.email &&
            this.sample_destination &&
            this.project_folder &&
            this.preferred_daw
        );
    }

    saveToStorage() {
        const data = {
            username: this.username,
            password: this.password,
            email: this.email,
            sample_destination: this.sample_destination,
            project_folder: this.project_folder,
            preferred_daw: this.preferred_daw,
            is_logged_in: this.is_logged_in,
            audio_export_directory: this.audio_export_directory,
            autoLoc_directory: this.autoLoc_directory,
            config_manager_directory: this.config_manager_directory,
            anticheat_directory: this.anticheat_directory,
            anticheat_installed: this.anticheat_installed
        };
        localStorage.setItem('userPrefs', JSON.stringify(data));
    }

    loadFromStorage() {
        const data = localStorage.getItem('userPrefs');
        if (data) {
            const parsed = JSON.parse(data);
            this.username = parsed.username || "";
            this.password = parsed.password || "";
            this.email = parsed.email || "";
            this.sample_destination = parsed.sample_destination || "";
            this.project_folder = parsed.project_folder || "";
            this.preferred_daw = parsed.preferred_daw || "";
            this.is_logged_in = parsed.is_logged_in || false;
            this.audio_export_directory = parsed.audio_export_directory || "";
            this.autoLoc_directory = parsed.autoLoc_directory || "";
            this.config_manager_directory = parsed.config_manager_directory || "";
            this.anticheat_directory = parsed.anticheat_directory || "C:/Program Files/Common Files/VST3";
            this.anticheat_installed = parsed.anticheat_installed || false;
        }
    }
}

// LoginScreen Class
class LoginScreen {
    constructor(app) {
        this.app = app;
        this.userPrefs = app.userPrefs;
    }

    render() {
        return `
            <div class="container">
                <h1 class="title">Beat Battle Anti Cheat</h1>
                <div class="warning" id="warningLabel"></div>

                <div class="form-group">
                    <label class="form-label">Username:</label>
                    <input type="text" class="form-input" id="usernameInput" value="${this.userPrefs.username}">
                </div>

                <div class="form-group">
                    <label class="form-label">Password:</label>
                    <input type="password" class="form-input" id="passwordInput" value="${this.userPrefs.password}">
                </div>

                <div class="button-frame">
                    <button class="btn" id="loginBtn">Login</button>
                    <button class="btn" id="signUpBtn">Sign Up</button>
                </div>
            </div>
        `;
    }

    attachEvents() {
        document.getElementById('loginBtn').addEventListener('click', () => this.login());
        document.getElementById('signUpBtn').addEventListener('click', () => this.app.showScreen('signIn'));
    }

    login() {
        const usernameInput = document.getElementById('usernameInput');
        const passwordInput = document.getElementById('passwordInput');
        const warningLabel = document.getElementById('warningLabel');

        const enteredUsername = usernameInput.value;
        const enteredPassword = passwordInput.value;

        // Reset styles
        usernameInput.classList.remove('error');
        passwordInput.classList.remove('error');
        warningLabel.textContent = '';

        let incompleteFields = [];

        if (!enteredUsername) {
            usernameInput.classList.add('error');
            incompleteFields.push('Username');
        }

        if (!enteredPassword) {
            passwordInput.classList.add('error');
            incompleteFields.push('Password');
        }

        if (incompleteFields.length > 0) {
            console.log(`Please complete the following fields: ${incompleteFields.join(', ')}`);
            return;
        }

        // Check if account exists
        if (!this.userPrefs.isComplete()) {
            warningLabel.textContent = '⚠ Account not created. Please sign up first.';
            console.log('Account not created. Please sign up first.');
            return;
        }

        // Verify credentials
        if (enteredUsername === this.userPrefs.username && enteredPassword === this.userPrefs.password) {
            this.userPrefs.is_logged_in = true;
            this.userPrefs.saveToStorage();
            console.log('Login successful!');
            this.app.showScreen('user');
        } else {
            warningLabel.textContent = '⚠ Invalid username or password.';
            console.log('Invalid username or password.');
        }
    }
}

// SignInScreen Class
class SignInScreen {
    constructor(app) {
        this.app = app;
        this.userPrefs = app.userPrefs;
    }

    render() {
        return `
            <div class="container">
                <h1 class="title">Beat Battle Anti Cheat</h1>

                <div class="form-group">
                    <label class="form-label">Username:</label>
                    <input type="text" class="form-input" id="usernameInput" value="${this.userPrefs.username}">
                </div>

                <div class="form-group">
                    <label class="form-label">Email:</label>
                    <input type="email" class="form-input" id="emailInput" value="${this.userPrefs.email}">
                </div>

                <div class="form-group">
                    <label class="form-label">Password:</label>
                    <input type="password" class="form-input" id="passwordInput" value="${this.userPrefs.password}">
                </div>

                <label class="daw-label">Preferred DAW:</label>
                <div class="daw-buttons">
                    <button class="daw-btn ${this.userPrefs.preferred_daw === 'FL Studio' ? 'selected' : ''}" data-daw="FL Studio">FL Studio</button>
                    <button class="daw-btn ${this.userPrefs.preferred_daw === 'Logic Pro' ? 'selected' : ''}" data-daw="Logic Pro">Logic Pro</button>
                    <button class="daw-btn ${this.userPrefs.preferred_daw === 'Ableton' ? 'selected' : ''}" data-daw="Ableton">Ableton</button>
                </div>

                <div class="button-frame">
                    <button class="btn" id="signInBtn">Sign In</button>
                    <button class="btn btn-google" id="signInGoogleBtn">Sign in with Google</button>
                    <button class="btn btn-discord" id="signInDiscordBtn">Sign in with Discord</button>
                    <button class="btn" id="loginNavBtn">Login</button>
                </div>
            </div>
        `;
    }

    attachEvents() {
        document.getElementById('signInBtn').addEventListener('click', () => this.signIn());
        document.getElementById('signInGoogleBtn').addEventListener('click', () => this.signInWithGoogle());
        document.getElementById('signInDiscordBtn').addEventListener('click', () => this.signInWithDiscord());
        document.getElementById('loginNavBtn').addEventListener('click', () => this.app.showScreen('login'));

        // DAW buttons
        document.querySelectorAll('.daw-btn').forEach(btn => {
            btn.addEventListener('click', () => this.selectDAW(btn.dataset.daw));
        });
    }

    selectDAW(daw) {
        if (this.userPrefs.preferred_daw === daw) {
            // Deselect if clicking the same one
            this.userPrefs.preferred_daw = '';
            document.querySelectorAll('.daw-btn').forEach(btn => btn.classList.remove('selected'));
        } else {
            // Select new DAW
            this.userPrefs.preferred_daw = daw;
            document.querySelectorAll('.daw-btn').forEach(btn => {
                if (btn.dataset.daw === daw) {
                    btn.classList.add('selected');
                } else {
                    btn.classList.remove('selected');
                }
            });
        }
    }

    signIn() {
        const usernameInput = document.getElementById('usernameInput');
        const emailInput = document.getElementById('emailInput');
        const passwordInput = document.getElementById('passwordInput');

        this.userPrefs.username = usernameInput.value;
        this.userPrefs.email = emailInput.value;
        this.userPrefs.password = passwordInput.value;

        // Reset error styles
        usernameInput.classList.remove('error');
        emailInput.classList.remove('error');
        passwordInput.classList.remove('error');

        let incompleteFields = [];

        if (!this.userPrefs.username) {
            usernameInput.classList.add('error');
            incompleteFields.push('Username');
        }

        if (!this.userPrefs.email) {
            emailInput.classList.add('error');
            incompleteFields.push('Email');
        }

        if (!this.userPrefs.password) {
            passwordInput.classList.add('error');
            incompleteFields.push('Password');
        }

        if (!this.userPrefs.preferred_daw) {
            incompleteFields.push('Preferred DAW');
        }

        if (incompleteFields.length > 0) {
            console.log(`Please complete the following fields: ${incompleteFields.join(', ')}`);
        } else {
            // Set is_logged_in to true since account is complete
            this.userPrefs.is_logged_in = true;
            this.userPrefs.saveToStorage();
            console.log('Sign in successful! All fields complete and saved to localStorage');
            console.log(`Username: ${this.userPrefs.username}`);
            console.log(`Email: ${this.userPrefs.email}`);
            console.log(`Preferred DAW: ${this.userPrefs.preferred_daw}`);

            // Go to UserScreen
            this.app.showScreen('user');
        }
    }

    signInWithGoogle() {
        console.log('Sign in with Google clicked');
        alert('Google OAuth integration coming soon!');
        // TODO: Implement Google OAuth
    }

    signInWithDiscord() {
        console.log('Sign in with Discord clicked');
        alert('Discord OAuth integration coming soon!');
        // TODO: Implement Discord OAuth
    }
}

// UserScreen Class
class UserScreen {
    constructor(app) {
        this.app = app;
        this.userPrefs = app.userPrefs;
    }

    render() {
        const showInstall = !this.userPrefs.anticheat_installed;
        const showReconfigureReinstall = this.userPrefs.anticheat_installed;

        return `
            <div class="container">
                <h1 class="title">User Profile</h1>

                <div class="profile-info">
                    <div class="profile-item">
                        <div class="profile-label">Username:</div>
                        <div class="profile-value">${this.userPrefs.username}</div>
                    </div>

                    <div class="profile-item">
                        <div class="profile-label">Email:</div>
                        <div class="profile-value">${this.userPrefs.email}</div>
                    </div>

                    <div class="profile-item">
                        <div class="profile-label">Sample Destination:</div>
                        <div class="profile-value">${this.userPrefs.sample_destination || 'Not configured'}</div>
                    </div>

                    <div class="profile-item">
                        <div class="profile-label">Project Folder:</div>
                        <div class="profile-value">${this.userPrefs.project_folder || 'Not configured'}</div>
                    </div>

                    <div class="profile-item">
                        <div class="profile-label">Preferred DAW:</div>
                        <div class="profile-value">${this.userPrefs.preferred_daw}</div>
                    </div>

                    <div class="profile-item">
                        <div class="profile-label">Anti-Cheat Status:</div>
                        <div class="profile-value">${this.userPrefs.anticheat_installed ? '✓ Installed' : '✗ Not Installed'}</div>
                    </div>
                </div>

                <div class="button-frame">
                    ${showInstall ? `
                        <button class="btn btn-install" id="installAnticheatBtn">Install Anti-Cheat</button>
                    ` : ''}
                    ${showReconfigureReinstall ? `
                        <button class="btn" id="reconfigureBtn">Reconfigure</button>
                        <button class="btn" id="reinstallBtn">Reinstall</button>
                    ` : ''}
                    <button class="btn" id="generateSamplesBtn" ${!this.userPrefs.anticheat_installed ? 'disabled' : ''}>Generate Samples</button>
                    <button class="btn" id="settingsBtn">Settings</button>
                    <button class="btn" id="logoutBtn">Log Out</button>
                </div>
            </div>
        `;
    }

    attachEvents() {
        // Install button
        const installBtn = document.getElementById('installAnticheatBtn');
        if (installBtn) {
            installBtn.addEventListener('click', () => this.installAnticheat());
        }

        // Reconfigure button
        const reconfigureBtn = document.getElementById('reconfigureBtn');
        if (reconfigureBtn) {
            reconfigureBtn.addEventListener('click', () => this.reconfigureAnticheat());
        }

        // Reinstall button
        const reinstallBtn = document.getElementById('reinstallBtn');
        if (reinstallBtn) {
            reinstallBtn.addEventListener('click', () => this.reinstallAnticheat());
        }

        // Generate Samples (only enabled if anticheat installed)
        const generateBtn = document.getElementById('generateSamplesBtn');
        if (generateBtn && !generateBtn.disabled) {
            generateBtn.addEventListener('click', () => this.generateSamples());
        }

        document.getElementById('settingsBtn').addEventListener('click', () => this.openSettings());
        document.getElementById('logoutBtn').addEventListener('click', () => this.logout());
    }

    installAnticheat() {
        console.log('Install Anti-Cheat clicked');

        // Trigger download of installer
        const link = document.createElement('a');
        link.href = 'bbac://install'; // Protocol handler
        link.click();

        // Show instructions
        const confirmed = confirm(
            'Anti-Cheat Installer\n\n' +
            '1. The BBACSetup.exe installer will download\n' +
            '2. Run the installer when download completes\n' +
            '3. Click OK after installation is complete\n\n' +
            'Click OK to mark as installed, or Cancel to try again later.'
        );

        if (confirmed) {
            this.userPrefs.anticheat_installed = true;
            this.userPrefs.saveToStorage();
            this.app.showScreen('user'); // Refresh to show new buttons
            alert('Anti-Cheat marked as installed! You can now generate samples.');
        }
    }

    reconfigureAnticheat() {
        console.log('Reconfigure Anti-Cheat clicked');

        // Show configuration dialog
        const newPath = prompt(
            'Enter Anti-Cheat installation path:',
            this.userPrefs.anticheat_directory
        );

        if (newPath !== null && newPath.trim() !== '') {
            this.userPrefs.anticheat_directory = newPath.trim();
            this.userPrefs.saveToStorage();
            alert('Anti-Cheat path updated to: ' + newPath);
        }
    }

    reinstallAnticheat() {
        console.log('Reinstall Anti-Cheat clicked');

        const confirmed = confirm(
            'This will download and reinstall the Anti-Cheat plugin.\n\n' +
            'Proceed with reinstallation?'
        );

        if (confirmed) {
            // Trigger reinstall
            const link = document.createElement('a');
            link.href = 'bbac://install';
            link.click();

            alert(
                'Reinstaller downloading...\n\n' +
                'Run BBACSetup.exe when download completes.'
            );
        }
    }

    generateSamples() {
        console.log('Generate Samples clicked');
        this.app.showScreen('game');
    }

    openSettings() {
        console.log('Settings clicked - to be implemented');
        alert('Settings feature coming soon!');
    }

    logout() {
        this.userPrefs.is_logged_in = false;
        this.userPrefs.saveToStorage();
        console.log('Logged out successfully');
        this.app.showScreen('login');
    }
}

// GameScreen Class
class GameScreen {
    constructor(app) {
        this.app = app;
        this.userPrefs = app.userPrefs;
        this.selectedSamples = [];
        this.allSamples = [];
        this.loadSamples();
    }

    async loadSamples() {
        try {
            // Load samples from manifest.json
            const response = await fetch('sampleDatabase/manifest.json');
            const data = await response.json();
            this.allSamples = data.files || [];

            console.log(`Loaded ${this.allSamples.length} samples from manifest`);

        } catch (error) {
            console.error('Error loading samples:', error);
            this.allSamples = [];
        }
    }

    selectRandomSamples() {
        if (this.allSamples.length < 5) {
            console.error('Not enough samples available');
            return;
        }

        // Shuffle and pick 5 random samples
        const shuffled = [...this.allSamples].sort(() => Math.random() - 0.5);
        this.selectedSamples = shuffled.slice(0, 5);

        console.log('Selected samples:', this.selectedSamples);
    }

    render() {
        // Select random samples when rendering
        this.selectRandomSamples();

        const sampleButtons = this.selectedSamples
            .map((sample, index) => `
                <button class="sample-btn" data-index="${index}">
                    ${sample}
                </button>
            `)
            .join('');

        return `
            <div class="container">
                <h1 class="title">Sample Generator</h1>

                <div class="sample-list">
                    <h2 class="section-title">Selected Samples (5):</h2>
                    ${sampleButtons || '<p>No samples selected</p>'}
                </div>

                <div class="button-frame">
                    <button class="btn" id="downloadZipBtn">Download ZIP</button>
                    <button class="btn" id="backBtn">Back</button>
                </div>

                <div class="status-area">
                    <p id="statusMessage"></p>
                </div>
            </div>
        `;
    }

    attachEvents() {
        document.getElementById('downloadZipBtn').addEventListener('click', () => this.downloadZip());
        document.getElementById('backBtn').addEventListener('click', () => this.app.showScreen('user'));

        // Optional: Add click events to sample buttons to play preview
        document.querySelectorAll('.sample-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const index = parseInt(e.target.dataset.index);
                this.playSample(index);
            });
        });
    }

    playSample(index) {
        const sample = this.selectedSamples[index];
        const audio = new Audio(`sampleDatabase/${sample}`);
        audio.play();
        console.log(`Playing: ${sample}`);
    }

    async downloadZip() {
        const statusMsg = document.getElementById('statusMessage');
        statusMsg.textContent = 'Creating ZIP file...';

        try {
            // Create zip using JSZip
            const JSZip = window.JSZip;
            if (!JSZip) {
                throw new Error('JSZip library not loaded');
            }

            const zip = new JSZip();

            // Add each selected sample to the zip
            for (const sample of this.selectedSamples) {
                statusMsg.textContent = `Adding ${sample} to ZIP...`;

                const response = await fetch(`sampleDatabase/${sample}`);
                const blob = await response.blob();
                zip.file(sample, blob);
            }

            // Generate the zip file
            statusMsg.textContent = 'Generating ZIP file...';
            const zipBlob = await zip.generateAsync({ type: 'blob' });

            // Create filename with timestamp
            const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
            const zipFilename = `BBAC_Samples_${timestamp}.zip`;

            // Download the zip
            statusMsg.textContent = 'Starting download...';
            const url = URL.createObjectURL(zipBlob);
            const link = document.createElement('a');
            link.href = url;
            link.download = zipFilename;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(url);

            // Connect to AutoLocSamples
            statusMsg.textContent = 'Notifying native app...';
            await this.notifyAutoLocSamples(zipFilename);

        } catch (error) {
            console.error('Error creating zip:', error);
            statusMsg.textContent = `Error: ${error.message}`;
        }
    }

    async notifyAutoLocSamples(zipFilename) {
        const statusMsg = document.getElementById('statusMessage');

        try {
            const autoLoc = this.app.autoLocClient;

            if (!autoLoc.connected) {
                statusMsg.textContent = 'Connecting to native app...';
                await autoLoc.connect();
                await new Promise(resolve => setTimeout(resolve, 1000)); // Wait for connection
            }

            if (!autoLoc.connected) {
                throw new Error('Could not connect to AutoLocSamples. Make sure it is running.');
            }

            // Send watch and extract command
            autoLoc.watchAndExtract(zipFilename, this.userPrefs.sample_destination);
            statusMsg.textContent = 'Native app is watching for download...';

        } catch (error) {
            console.error('Error notifying AutoLocSamples:', error);
            statusMsg.textContent = `Warning: ${error.message}. ZIP downloaded to Downloads folder.`;
        }
    }
}

// AutoLocSamples Client
class AutoLocClient {
    constructor() {
        this.ws = null;
        this.connected = false;
        this.messageCallbacks = [];
    }

    async connect() {
        return new Promise((resolve, reject) => {
            try {
                this.ws = new WebSocket('ws://localhost:8765');

                this.ws.onopen = () => {
                    this.connected = true;
                    console.log('✓ Connected to AutoLocSamples');
                    resolve();
                };

                this.ws.onmessage = (event) => {
                    const data = JSON.parse(event.data);
                    console.log('AutoLoc status:', data);

                    // Call all registered callbacks
                    this.messageCallbacks.forEach(callback => callback(data));
                };

                this.ws.onerror = (error) => {
                    this.connected = false;
                    console.error('AutoLoc connection error:', error);
                    reject(error);
                };

                this.ws.onclose = () => {
                    this.connected = false;
                    console.log('AutoLoc disconnected');
                };

                // Timeout after 2 seconds
                setTimeout(() => {
                    if (!this.connected) {
                        reject(new Error('Connection timeout'));
                    }
                }, 2000);

            } catch (error) {
                reject(error);
            }
        });
    }

    watchAndExtract(filename, destination) {
        if (!this.connected) {
            console.error('Not connected to AutoLocSamples');
            return;
        }

        this.ws.send(JSON.stringify({
            action: 'watch_and_extract',
            filename: filename,
            destination: destination
        }));

        console.log(`Sent watch request for: ${filename} -> ${destination}`);
    }

    onMessage(callback) {
        this.messageCallbacks.push(callback);
    }
}

// Main App Class
class App {
    constructor() {
        this.userPrefs = new UserPrefs();
        this.currentScreen = null;
        this.autoLocClient = new AutoLocClient();

        this.screens = {
            login: new LoginScreen(this),
            signIn: new SignInScreen(this),
            user: new UserScreen(this),
            game: new GameScreen(this)
        };

        this.init();
    }

    init() {
        // Determine which screen to show on startup
        if (this.userPrefs.is_logged_in) {
            this.showScreen('user');
        } else if (this.userPrefs.isComplete()) {
            this.showScreen('login');
        } else {
            this.showScreen('signIn');
        }
    }

    showScreen(screenName) {
        const appDiv = document.getElementById('app');
        const screen = this.screens[screenName];

        if (screen) {
            this.currentScreen = screenName;
            appDiv.innerHTML = screen.render();
            screen.attachEvents();
        }
    }
}

// Initialize the app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new App();
});