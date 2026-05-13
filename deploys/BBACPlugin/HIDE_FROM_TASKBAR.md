# Making Tkinter Window Hide from Taskbar

## The Problem
By default, Tkinter windows show up on the Windows taskbar as separate applications, even when they're part of a VST plugin.

## The Solution
Modify your `BBAC2.py` to accept a parent window handle and make the Tkinter window a transient child.

## Step 1: Modify BBAC2.py main() function

Find your `main()` function (around line 645) and change it to:

```python
def main(parent_hwnd=None):
    root = tk.Tk()

    # If parent window provided, make this a child window
    if parent_hwnd:
        # This prevents taskbar icon
        root.wm_transient()
        root.attributes('-toolwindow', True)  # Extra insurance for Windows

        # Optional: Set parent window (requires ctypes)
        try:
            import ctypes
            hwnd = root.winfo_id()
            GWL_STYLE = -16
            WS_CHILD = 0x40000000
            user32 = ctypes.windll.user32
            # Make it a child window
            user32.SetParent(hwnd, parent_hwnd)
        except:
            pass  # If this fails, transient mode should still work

    # Load user preferences to determine which screen to show
    user_prefs = UserPrefs()
    user_prefs.load_from_file()

    if user_prefs.is_logged_in:
        user_screen = UserScreen(root)
    elif user_prefs.is_complete():
        login_screen = loginScreen(root)
    else:
        sign_in_screen = SignInScreen(root)

    root.mainloop()
```

## Step 2: Update C++ to pass parent window

In `BBACPlugin.cpp`, modify `createPythonWindow()`:

```cpp
void BBACEditorView::createPythonWindow(HWND parent)
{
    if (!BBACProcessor::isPythonInitialized())
        return;

    tkinterThread = std::make_unique<std::thread>([this, parent]()
    {
        PyGILState_STATE gstate = PyGILState_Ensure();

        try
        {
            PyObject* pModule = PyImport_ImportModule("BBAC2");
            if (!pModule)
            {
                PyErr_Print();
                PyGILState_Release(gstate);
                return;
            }

            PyObject* pFunc = PyObject_GetAttrString(pModule, "main");
            if (!pFunc || !PyCallable_Check(pFunc))
            {
                PyErr_Print();
                Py_XDECREF(pFunc);
                Py_DECREF(pModule);
                PyGILState_Release(gstate);
                return;
            }

            // Create arguments tuple with parent HWND
            PyObject* pArgs = PyTuple_New(1);
            // Convert HWND to Python integer (as unsigned long long)
            PyTuple_SetItem(pArgs, 0, PyLong_FromUnsignedLongLong((unsigned long long)parent));

            // Call main(parent_hwnd)
            PyObject* pResult = PyObject_CallObject(pFunc, pArgs);

            if (!pResult)
            {
                PyErr_Print();
            }

            Py_XDECREF(pResult);
            Py_DECREF(pArgs);
            Py_DECREF(pFunc);
            Py_DECREF(pModule);
        }
        catch (...)
        {
        }

        PyGILState_Release(gstate);
    });
}
```

## How It Works

### Method 1: `wm_transient()`
- Makes Tkinter window a "transient" window
- Transient windows don't get taskbar icons
- They stay on top of their parent
- Close when parent closes

### Method 2: `-toolwindow` attribute
- Windows-specific attribute
- Tool windows don't appear on taskbar
- Commonly used for palettes, toolbars, etc.

### Method 3: `SetParent()` (Most robust)
- Uses Windows API to make Tkinter window a true child
- Parent HWND comes from VST editor
- Child windows never show on taskbar
- Automatically positioned relative to parent

## Testing the Change

1. **Modify BBAC2.py** with the new main() function
2. **Save and rebuild** your plugin
3. **Load in DAW** and open editor
4. **Check taskbar** - window should not appear
5. **Check behavior** - window should still be visible and functional

## Fallback Behavior

If you don't pass a parent window (None), the function still works normally:
```python
if parent_hwnd:
    # Hide from taskbar
else:
    # Normal standalone window (for testing)
```

This lets you test BBAC2.py standalone:
```bash
python BBAC2.py  # Normal window with taskbar icon (testing)
```

## Alternative: Pure Tkinter Solution

If you don't want to modify the C++, you can do this in Python only:

```python
def main():
    root = tk.Tk()

    # Force window to be a tool window (no taskbar)
    root.attributes('-toolwindow', True)
    root.wm_transient()

    # Rest of your code...
```

**Note**: This works but the window won't be properly parented to the DAW, so it might not minimize when the DAW minimizes.

## Recommended Approach

**Use the full solution** (Python + C++ changes) for best results:
- ✅ No taskbar icon
- ✅ Proper parent-child relationship
- ✅ Minimizes with DAW
- ✅ Closes when VST editor closes
- ✅ Can still test standalone

The changes are minimal and the benefits are significant!
