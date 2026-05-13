#pragma once

#include "public.sdk/source/vst/vsteditcontroller.h"
#include "public.sdk/source/vst/vstaudioeffect.h"
#include "pluginterfaces/vst/ivstprocesscontext.h"
#include "pluginterfaces/gui/iplugview.h"
#include <Python.h>
#include <windows.h>
#include <d3d11.h>
#include <string>
#include <atomic>

namespace Steinberg {
namespace Vst {

// Forward declarations
class BBACEditorView;

// Processor class - handles the audio processing (in our case, none)
class BBACProcessor : public AudioEffect
{
public:
    BBACProcessor();
    ~BBACProcessor() override;

    static FUnknown* createInstance(void*) { return (IAudioProcessor*)new BBACProcessor(); }

    tresult PLUGIN_API initialize(FUnknown* context) override;
    tresult PLUGIN_API terminate() override;
    tresult PLUGIN_API setActive(TBool state) override;
    tresult PLUGIN_API process(ProcessData& data) override;

    tresult PLUGIN_API setState(IBStream* state) override { return kResultOk; }
    tresult PLUGIN_API getState(IBStream* state) override { return kResultOk; }

    static void initializePythonOnce();
    static bool isPythonInitialized() { return pythonInitialized; }

protected:
    static bool pythonInitialized;
};

// User preferences (mirrors Python UserPrefs)
struct UserPrefs {
    std::string username;
    std::string password;
    std::string sampleDestination;
    std::string projectFolder;
    std::string preferredDAW;
    bool isLoggedIn = false;

    bool isComplete() const;
    bool loadFromFile();
    void saveToFile();
};

// Editor View - ImGui-based UI
class BBACEditorView : public CPluginView
{
public:
    BBACEditorView();
    ~BBACEditorView() override;

    tresult PLUGIN_API isPlatformTypeSupported(FIDString type) override;
    tresult PLUGIN_API attached(void* parent, FIDString type) override;
    tresult PLUGIN_API removed() override;
    tresult PLUGIN_API onSize(ViewRect* newSize) override;
    tresult PLUGIN_API getSize(ViewRect* size) override;

private:
    // DirectX 11 + ImGui setup
    void initializeD3D(HWND hwnd);
    void shutdownD3D();
    void beginFrame();
    void endFrame();

    // UI Screens
    void renderLoginScreen();
    void renderUserScreen();
    void renderSignInPrompt();

    // Python integration
    bool callPythonSignIn();
    void handleLogin();
    void handleLogout();
    void startMonitoring();
    void stopMonitoring();

    // DirectX/ImGui state
    ID3D11Device* d3dDevice = nullptr;
    ID3D11DeviceContext* d3dDeviceContext = nullptr;
    IDXGISwapChain* swapChain = nullptr;
    ID3D11RenderTargetView* mainRenderTargetView = nullptr;
    HWND hwnd = nullptr;

    // UI state
    UserPrefs userPrefs;
    char usernameInput[256] = {0};
    char passwordInput[256] = {0};
    std::string errorMessage;
    bool isMonitoring = false;
    int samplesDetected = 0;
    std::string currentProject;

    // Rendering loop
    std::atomic<bool> shouldRender{true};
    static LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);
};

// Controller class - creates the editor view
class BBACController : public EditController
{
public:
    static FUnknown* createInstance(void*) { return (IEditController*)new BBACController(); }

    tresult PLUGIN_API initialize(FUnknown* context) override;

    IPlugView* PLUGIN_API createView(const char* name) override;
};

} // namespace Vst
} // namespace Steinberg
