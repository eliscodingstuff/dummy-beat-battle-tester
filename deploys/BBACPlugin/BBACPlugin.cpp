#include "BBACPlugin.h"
#include "public.sdk/source/main/pluginfactory.h"
#include <windows.h>
#include <string>
#include <cstring>

namespace Steinberg {
namespace Vst {

// Plugin UIDs - these must be unique for your plugin
// You can generate new ones at https://www.guidgenerator.com/
static const FUID BBACProcessorUID(0x12345678, 0x12345678, 0x12345678, 0x12345678);
static const FUID BBACControllerUID(0x87654321, 0x87654321, 0x87654321, 0x87654321);

BBACProcessor::BBACProcessor()
{
    setControllerClass(BBACControllerUID);
}

BBACProcessor::~BBACProcessor()
{
    terminate();
}

tresult PLUGIN_API BBACProcessor::initialize(FUnknown* context)
{
    tresult result = AudioEffect::initialize(context);
    if (result != kResultOk)
        return result;

    // Add audio output bus - required for instrument classification
    addAudioOutput(STR16("Stereo Out"), SpeakerArr::kStereo);

    // Add event input bus to identify as instrument
    addEventInput(STR16("Event In"), 1);

    // Initialize Python when plugin loads
    initPython();

    return kResultOk;
}

tresult PLUGIN_API BBACProcessor::terminate()
{
    if (pythonThread && pythonThread->joinable())
        pythonThread->join();

    if (Py_IsInitialized())
        Py_Finalize();

    return AudioEffect::terminate();
}

tresult PLUGIN_API BBACProcessor::setActive(TBool state)
{
    return AudioEffect::setActive(state);
}

tresult PLUGIN_API BBACProcessor::process(ProcessData& data)
{
    // Process MIDI events (even if we don't use them, some hosts check this)
    if (data.inputEvents)
    {
        int32 eventCount = data.inputEvents->getEventCount();
        // Could process events here if needed
    }

    // Clear output buffers (silent instrument)
    if (data.numOutputs > 0 && data.outputs[0].numChannels > 0)
    {
        for (int32 channel = 0; channel < data.outputs[0].numChannels; channel++)
        {
            if (data.outputs[0].channelBuffers32)
            {
                memset(data.outputs[0].channelBuffers32[channel], 0, 
                       data.numSamples * sizeof(float));
            }
        }

        // Mark output as active
        data.outputs[0].silenceFlags = 0;
    }

    return kResultOk;
}

void BBACProcessor::initPython()
{
    Py_Initialize();

    pythonThread = std::make_unique<std::thread>([this]()
    {
        // Get the plugin DLL directory
        HMODULE hModule = NULL;
        GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | 
                           GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           (LPCSTR)&Py_Initialize, 
                           &hModule);

        char pluginPath[MAX_PATH];
        GetModuleFileNameA(hModule, pluginPath, MAX_PATH);

        // Navigate up to workspace directory
        std::string scriptDir = pluginPath;
        for (int i = 0; i < 7; i++)
        {
            size_t pos = scriptDir.find_last_of("\\/");
            if (pos != std::string::npos)
                scriptDir = scriptDir.substr(0, pos);
        }

        // Add directory to Python's sys.path
        std::string addPathCode =
            "import sys\n"
            "sys.path.append('" + scriptDir + "')\n";

        PyRun_SimpleString(addPathCode.c_str());

        // Import and run your module
        PyRun_SimpleString(
            "import BBAC2\n"
            "BBAC2.main()\n"
        );
    });
}

} // namespace Vst
} // namespace Steinberg

//------------------------------------------------------------------------
// Plugin Factory
//------------------------------------------------------------------------

BEGIN_FACTORY_DEF("BeatBattleAntiCheat",
                  "https://yourwebsite.com",
                  "mailto:your@email.com")

    DEF_CLASS2(INLINE_UID_FROM_FUID(Steinberg::Vst::BBACProcessorUID),
               PClassInfo::kManyInstances,
               kVstAudioEffectClass,
               "Beat Battle Anti Cheat",
               Vst::kDistributable | Vst::kSimpleModeSupported,
               "Instrument",
               "1.0.0",
               kVstVersionString,
               Steinberg::Vst::BBACProcessor::createInstance)

    DEF_CLASS2(INLINE_UID_FROM_FUID(Steinberg::Vst::BBACControllerUID),
               PClassInfo::kManyInstances,
               kVstComponentControllerClass,
               "Beat Battle Anti Cheat Controller",
               0,
               "",
               "1.0.0",
               kVstVersionString,
               Steinberg::Vst::BBACController::createInstance)

END_FACTORY
