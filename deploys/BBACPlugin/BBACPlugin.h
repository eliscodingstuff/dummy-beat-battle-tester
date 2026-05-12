#pragma once

#include "public.sdk/source/vst/vsteditcontroller.h"
#include "public.sdk/source/vst/vstaudioeffect.h"
#include "pluginterfaces/vst/ivstprocesscontext.h"
#include <Python.h>
#include <thread>
#include <memory>
#include <atomic>

namespace Steinberg {
namespace Vst {

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

protected:
    void initPython();
    void shutdownPython();
    std::unique_ptr<std::thread> pythonThread;
    std::atomic<bool> pythonShouldStop{false};
    bool pythonInitialized{false};
};

// Controller class - handles the UI (we have none)
class BBACController : public EditController
{
public:
    static FUnknown* createInstance(void*) { return (IEditController*)new BBACController(); }

    tresult PLUGIN_API initialize(FUnknown* context) override
    {
        return EditController::initialize(context);
    }
};

} // namespace Vst
} // namespace Steinberg
