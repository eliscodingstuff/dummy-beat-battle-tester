import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageTk
import os
import json
from pathlib import Path

# Color scheme
DARK_GREY = "#2b2b2b"
LIGHT_GREY = "#4a4a4a"
WHITE = "#ffffff"
BLACK = "#000000"
RED = "#ff4d4d"

class UserPrefs:
    def __init__(self, json_path=None):
        if json_path is None:
            json_path = os.path.join(os.path.dirname(__file__), "user_prefs.json")
        self.json_path = json_path

        self.username = ""
        self.password = ""
        self.sample_destination = ""
        self.project_folder = ""
        self.preferred_daw = ""
        self.is_logged_in = False

    def is_complete(self):
        return all([
            self.username,
            self.password,
            self.sample_destination,
            self.project_folder,
            self.preferred_daw
        ])

    def save_to_file(self):
        data = {
            "username": self.username,
            "password": self.password,
            "sample_destination": self.sample_destination,
            "project_folder": self.project_folder,
            "preferred_daw": self.preferred_daw,
            "is_logged_in": self.is_logged_in
        }

        with open(self.json_path, 'w') as f:
            json.dump(data, f, indent=4)

    def load_from_file(self):
        if os.path.exists(self.json_path):
            with open(self.json_path, 'r') as f:
                data = json.load(f)
                self.username = data.get("username", "")
                self.password = data.get("password", "")
                self.sample_destination = data.get("sample_destination", "")
                self.project_folder = data.get("project_folder", "")
                self.preferred_daw = data.get("preferred_daw", "")
                self.is_logged_in = data.get("is_logged_in", False)
            return True
        return False

class UserScreen:
    def __init__(self, root):
        self.root = root
        self.root.title("Beat Battle Anti Cheat - User")
        self.root.geometry("600x500")
        self.root.configure(bg=DARK_GREY)

        self.user_prefs = UserPrefs()
        self.user_prefs.load_from_file()

        self.create_widgets()

    def create_widgets(self):
        container = tk.Frame(self.root, bg=DARK_GREY)
        container.pack(expand=True, fill=tk.BOTH, padx=40, pady=40)

        title = tk.Label(
            container,
            text="User Profile",
            font=("Arial", 18, "bold"),
            bg=DARK_GREY,
            fg=RED
        )
        title.pack(pady=(0, 30))

        info_frame = tk.Frame(container, bg=DARK_GREY)
        info_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 30))

        # Username
        username_frame = tk.Frame(info_frame, bg=DARK_GREY)
        username_frame.pack(fill=tk.X, pady=10)

        username_label = tk.Label(
            username_frame,
            text="Username:",
            font=("Arial", 12, "bold"),
            bg=DARK_GREY,
            fg=WHITE,
            width=20,
            anchor=tk.W
        )
        username_label.pack(side=tk.LEFT)

        username_value = tk.Label(
            username_frame,
            text=self.user_prefs.username,
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE,
            anchor=tk.W
        )
        username_value.pack(side=tk.LEFT, fill=tk.X, expand=True)

        # Sample Destination
        sample_frame = tk.Frame(info_frame, bg=DARK_GREY)
        sample_frame.pack(fill=tk.X, pady=10)

        sample_label = tk.Label(
            sample_frame,
            text="Sample Destination:",
            font=("Arial", 12, "bold"),
            bg=DARK_GREY,
            fg=WHITE,
            width=20,
            anchor=tk.W
        )
        sample_label.pack(side=tk.LEFT)

        sample_value = tk.Label(
            sample_frame,
            text=self.user_prefs.sample_destination,
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE,
            anchor=tk.W
        )
        sample_value.pack(side=tk.LEFT, fill=tk.X, expand=True)

        # Project Folder
        project_frame = tk.Frame(info_frame, bg=DARK_GREY)
        project_frame.pack(fill=tk.X, pady=10)

        project_label = tk.Label(
            project_frame,
            text="Project Folder:",
            font=("Arial", 12, "bold"),
            bg=DARK_GREY,
            fg=WHITE,
            width=20,
            anchor=tk.W
        )
        project_label.pack(side=tk.LEFT)

        project_value = tk.Label(
            project_frame,
            text=self.user_prefs.project_folder,
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE,
            anchor=tk.W
        )
        project_value.pack(side=tk.LEFT, fill=tk.X, expand=True)

        # Preferred DAW
        daw_frame = tk.Frame(info_frame, bg=DARK_GREY)
        daw_frame.pack(fill=tk.X, pady=10)

        daw_label = tk.Label(
            daw_frame,
            text="Preferred DAW:",
            font=("Arial", 12, "bold"),
            bg=DARK_GREY,
            fg=WHITE,
            width=20,
            anchor=tk.W
        )
        daw_label.pack(side=tk.LEFT)

        daw_value = tk.Label(
            daw_frame,
            text=self.user_prefs.preferred_daw,
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE,
            anchor=tk.W
        )
        daw_value.pack(side=tk.LEFT, fill=tk.X, expand=True)

        # Buttons
        button_frame = tk.Frame(container, bg=DARK_GREY)
        button_frame.pack(pady=(20, 0))

        settings_btn = tk.Button(
            button_frame,
            text="Settings",
            font=("Arial", 14, "bold"),
            bg=LIGHT_GREY,
            fg=WHITE,
            width=12,
            command=self.open_settings
        )
        settings_btn.pack(side=tk.LEFT, padx=5)

        logout_btn = tk.Button(
            button_frame,
            text="Log Out",
            font=("Arial", 14, "bold"),
            bg=LIGHT_GREY,
            fg=WHITE,
            width=12,
            command=self.logout
        )
        logout_btn.pack(side=tk.LEFT, padx=5)

    def open_settings(self):
        print("Settings clicked - to be implemented")

    def logout(self):
        self.user_prefs.is_logged_in = False
        self.user_prefs.save_to_file()
        self.root.destroy()
        new_root = tk.Tk()
        loginScreen(new_root)
        new_root.mainloop()

class loginScreen:
    def __init__(self, root):
        self.root = root
        self.root.title("Beat Battle Anti Cheat - Login")
        self.root.geometry("500x400")
        self.root.configure(bg=DARK_GREY)

        self.user_prefs = UserPrefs()
        self.user_prefs.load_from_file()

        self.create_widgets()

    def create_widgets(self):
        container = tk.Frame(self.root, bg=DARK_GREY)
        container.pack(expand=True, fill=tk.BOTH, padx=40, pady=40)

        title = tk.Label(
            container,
            text="Beat Battle Anti Cheat",
            font=("Arial", 18, "bold"),
            bg=DARK_GREY,
            fg=RED
        )
        title.pack(pady=(0, 20))

        # Warning label for no account
        self.warning_label = tk.Label(
            container,
            text="",
            font=("Arial", 10),
            bg=DARK_GREY,
            fg=RED
        )
        self.warning_label.pack(pady=(0, 10))

        username_label = tk.Label(
            container,
            text="Username:",
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE
        )
        username_label.pack(anchor=tk.W, pady=(10, 5))

        self.username_entry = tk.Entry(
            container,
            font=("Arial", 12),
            bg=LIGHT_GREY,
            fg=WHITE,
            insertbackground=WHITE
        )
        self.username_entry.insert(0, self.user_prefs.username)
        self.username_entry.pack(fill=tk.X, pady=(0, 10))

        password_label = tk.Label(
            container,
            text="Password:",
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE
        )
        password_label.pack(anchor=tk.W, pady=(10, 5))

        self.password_entry = tk.Entry(
            container,
            font=("Arial", 12),
            bg=LIGHT_GREY,
            fg=WHITE,
            insertbackground=WHITE,
            show="*"
        )
        self.password_entry.insert(0, self.user_prefs.password)
        self.password_entry.pack(fill=tk.X, pady=(0, 20))

        button_frame = tk.Frame(container, bg=DARK_GREY)
        button_frame.pack(pady=(20, 0))

        login_btn = tk.Button(
            button_frame,
            text="Login",
            font=("Arial", 14, "bold"),
            bg=LIGHT_GREY,
            fg=WHITE,
            width=12,
            command=self.login
        )
        login_btn.pack(side=tk.LEFT, padx=5)

        switch_btn = tk.Button(
            button_frame,
            text="Sign Up",
            font=("Arial", 14, "bold"),
            bg=LIGHT_GREY,
            fg=WHITE,
            width=12,
            command=self.open_sign_in
        )
        switch_btn.pack(side=tk.LEFT, padx=5)

    def login(self):
        entered_username = self.username_entry.get()
        entered_password = self.password_entry.get()

        self.username_entry.config(highlightthickness=0)
        self.password_entry.config(highlightthickness=0)
        self.warning_label.config(text="")

        incomplete_fields = []

        if not entered_username:
            self.username_entry.config(highlightthickness=2, highlightbackground=RED, highlightcolor=RED)
            incomplete_fields.append("Username")

        if not entered_password:
            self.password_entry.config(highlightthickness=2, highlightbackground=RED, highlightcolor=RED)
            incomplete_fields.append("Password")

        if incomplete_fields:
            print(f"Please complete the following fields: {', '.join(incomplete_fields)}")
            return

        # Check if account exists (is_complete)
        if not self.user_prefs.is_complete():
            self.warning_label.config(text="⚠ Account not created. Please sign up first.")
            print("Account not created. Please sign up first.")
            return

        # Verify credentials
        if entered_username == self.user_prefs.username and entered_password == self.user_prefs.password:
            self.user_prefs.is_logged_in = True
            self.user_prefs.save_to_file()
            print("Login successful!")
            self.root.destroy()
            new_root = tk.Tk()
            UserScreen(new_root)
            new_root.mainloop()
        else:
            self.warning_label.config(text="⚠ Invalid username or password.")
            print("Invalid username or password.")

    def open_sign_in(self):
        self.root.destroy()
        new_root = tk.Tk()
        SignInScreen(new_root)
        new_root.mainloop()

class SignInScreen:
    def __init__(self, root):
        self.root = root
        self.root.title("Beat Battle Anti Cheat - Sign In")
        self.root.geometry("500x600")
        self.root.configure(bg=DARK_GREY)

        self.user_prefs = UserPrefs()
        self.user_prefs.load_from_file()

        self.sample_dest = tk.StringVar(value=self.user_prefs.sample_destination)
        self.project_folder = tk.StringVar(value=self.user_prefs.project_folder)

        self.create_widgets()
    
    def create_widgets(self):
        # Main container
        container = tk.Frame(self.root, bg=DARK_GREY)
        container.pack(expand=True, fill=tk.BOTH, padx=40, pady=40)
        
        # Title
        title = tk.Label(
            container,
            text="Beat Battle Anti Cheat",
            font=("Arial", 18, "bold"),
            bg=DARK_GREY,
            fg=RED
        )
        title.pack(pady=(0, 30))
        
        # Username
        username_label = tk.Label(
            container,
            text="Username:",
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE
        )
        username_label.pack(anchor=tk.W, pady=(10, 5))
        
        self.username_entry = tk.Entry(
            container,
            font=("Arial", 12),
            bg=LIGHT_GREY,
            fg=WHITE,
            insertbackground=WHITE
        )
        self.username_entry.insert(0, self.user_prefs.username)
        self.username_entry.pack(fill=tk.X, pady=(0, 10))
        
        # Password
        password_label = tk.Label(
            container,
            text="Password:",
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE
        )
        password_label.pack(anchor=tk.W, pady=(10, 5))
        
        self.password_entry = tk.Entry(
            container,
            font=("Arial", 12),
            bg=LIGHT_GREY,
            fg=WHITE,
            insertbackground=WHITE,
            show="*"
        )
        self.password_entry.insert(0, self.user_prefs.password)
        self.password_entry.pack(fill=tk.X, pady=(0, 10))
        
        # Sample Destination Folder
        sample_label = tk.Label(
            container,
            text="Sample Destination Folder:",
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE
        )
        sample_label.pack(anchor=tk.W, pady=(10, 5))
        
        sample_frame = tk.Frame(container, bg=DARK_GREY)
        sample_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.sample_entry = tk.Entry(
            sample_frame,
            font=("Arial", 12),
            bg=LIGHT_GREY,
            fg=WHITE,
            insertbackground=WHITE,
            textvariable=self.sample_dest
        )
        self.sample_entry.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        sample_browse = tk.Button(
            sample_frame,
            text="Browse",
            font=("Arial", 10),
            bg=LIGHT_GREY,
            fg=WHITE,
            command=lambda: self.browse_folder(self.sample_dest)
        )
        sample_browse.pack(side=tk.LEFT, padx=(5, 0))
        
        # Project Folder
        project_label = tk.Label(
            container,
            text="Project Folder:",
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE
        )
        project_label.pack(anchor=tk.W, pady=(10, 5))
        
        project_frame = tk.Frame(container, bg=DARK_GREY)
        project_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.project_entry = tk.Entry(
            project_frame,
            font=("Arial", 12),
            bg=LIGHT_GREY,
            fg=WHITE,
            insertbackground=WHITE,
            textvariable=self.project_folder
        )
        self.project_entry.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        project_browse = tk.Button(
            project_frame,
            text="Browse",
            font=("Arial", 10),
            bg=LIGHT_GREY,
            fg=WHITE,
            command=lambda: self.browse_folder(self.project_folder)
        )
        project_browse.pack(side=tk.LEFT, padx=(5, 0))
        
        # Preferred DAW
        daw_label = tk.Label(
            container,
            text="Preferred DAW:",
            font=("Arial", 12),
            bg=DARK_GREY,
            fg=WHITE
        )
        daw_label.pack(anchor=tk.W, pady=(20, 10))
        
        daw_frame = tk.Frame(container, bg=DARK_GREY)
        daw_frame.pack(fill=tk.X, pady=(0, 20))
        
        # DAW Buttons
        self.daw_buttons = {}
        daws = ["FL Studio", "Logic Pro", "Ableton"]
        for daw in daws:
            btn = tk.Button(
                daw_frame,
                text=daw,
                font=("Arial", 11),
                bg=LIGHT_GREY,
                fg=WHITE,
                width=12,
                relief=tk.RAISED,
                command=lambda d=daw: self.select_daw(d)
            )
            btn.pack(side=tk.LEFT, padx=5, expand=True)
            self.daw_buttons[daw] = btn

        if self.user_prefs.preferred_daw:
            self.select_daw(self.user_prefs.preferred_daw)

        # Button Frame for Sign In and Switch buttons
        button_frame = tk.Frame(container, bg=DARK_GREY)
        button_frame.pack(pady=(20, 0))

        # Sign In Button
        signIn_btn = tk.Button(
            button_frame,
            text="Sign In",
            font=("Arial", 14, "bold"),
            bg=LIGHT_GREY,
            fg=WHITE,
            width=12,
            command=self.signIn
        )
        signIn_btn.pack(side=tk.LEFT, padx=5)

        # Switch to Login Button
        switch_btn = tk.Button(
            button_frame,
            text="Login",
            font=("Arial", 14, "bold"),
            bg=LIGHT_GREY,
            fg=WHITE,
            width=12,
            command=self.open_login
        )
        switch_btn.pack(side=tk.LEFT, padx=5)
    
    def browse_folder(self, var):
        folder = filedialog.askdirectory()
        if folder:
            var.set(folder)
    
    def select_daw(self, daw):
        if self.user_prefs.preferred_daw == daw:
            self.user_prefs.preferred_daw = ""
            self.daw_buttons[daw].config(relief=tk.RAISED, bg=LIGHT_GREY)
        else:
            for daw_name, btn in self.daw_buttons.items():
                btn.config(relief=tk.RAISED, bg=LIGHT_GREY)

            self.user_prefs.preferred_daw = daw
            self.daw_buttons[daw].config(relief=tk.SUNKEN, bg="#5a5a5a")

    def signIn(self):
        self.user_prefs.username = self.username_entry.get()
        self.user_prefs.password = self.password_entry.get()
        self.user_prefs.sample_destination = self.sample_dest.get()
        self.user_prefs.project_folder = self.project_folder.get()

        self.username_entry.config(highlightthickness=0)
        self.password_entry.config(highlightthickness=0)
        self.sample_entry.config(highlightthickness=0)
        self.project_entry.config(highlightthickness=0)

        incomplete_fields = []

        if not self.user_prefs.username:
            self.username_entry.config(highlightthickness=2, highlightbackground=RED, highlightcolor=RED)
            incomplete_fields.append("Username")

        if not self.user_prefs.password:
            self.password_entry.config(highlightthickness=2, highlightbackground=RED, highlightcolor=RED)
            incomplete_fields.append("Password")

        if not self.user_prefs.sample_destination:
            self.sample_entry.config(highlightthickness=2, highlightbackground=RED, highlightcolor=RED)
            incomplete_fields.append("Sample Destination")

        if not self.user_prefs.project_folder:
            self.project_entry.config(highlightthickness=2, highlightbackground=RED, highlightcolor=RED)
            incomplete_fields.append("Project Folder")

        if not self.user_prefs.preferred_daw:
            incomplete_fields.append("Preferred DAW")

        if incomplete_fields:
            print(f"Please complete the following fields: {', '.join(incomplete_fields)}")
        else:
            # Set is_logged_in to true since account is complete
            self.user_prefs.is_logged_in = True
            self.user_prefs.save_to_file()
            print("Sign in successful! All fields complete and saved to user_prefs.json")
            print(f"Username: {self.user_prefs.username}")
            print(f"Sample Destination: {self.user_prefs.sample_destination}")
            print(f"Project Folder: {self.user_prefs.project_folder}")
            print(f"Preferred DAW: {self.user_prefs.preferred_daw}")

            # Go to UserScreen
            self.root.destroy()
            new_root = tk.Tk()
            UserScreen(new_root)
            new_root.mainloop()

    def open_login(self):
        self.root.destroy()
        new_root = tk.Tk()
        loginScreen(new_root)
        new_root.mainloop()

def main():
    root = tk.Tk()

    # Load user preferences to determine which screen to show
    user_prefs = UserPrefs()
    user_prefs.load_from_file()

    if user_prefs.is_logged_in:
        # User is logged in, go to UserScreen
        user_screen = UserScreen(root)
    elif user_prefs.is_complete():
        # Account exists but not logged in, go to loginScreen
        login_screen = loginScreen(root)
    else:
        # Account not complete, go to SignInScreen
        sign_in_screen = SignInScreen(root)

    root.mainloop()

if __name__ == "__main__":
    main()
