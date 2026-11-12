<img width="100" height="100" src="https://github.com/user-attachments/assets/1c42dda2-b778-4342-9f94-8f852c3ad652" />

# Onion Cider

Onion Cider is based on the [Reynard Browser project](https://github.com/minh-ton/reynard-browser).

Onion Cider is a Tor-enabled, **Gecko-based** web browser for iOS 15+.

Unlike other browsers on iOS that are forced to use Apple's **WebKit** engine (including Safari and all third-party browsers), Reynard uses **Gecko**. This is the same engine that powers the Firefox browser on desktop and Android devices.

Besides providing an **alternative, up-to-date browser engine**[^1], Reynard supports Firefox add-ons, including more capable ad-blocking extensions, along with privacy features such as Enhanced Tracking Protection and DNS over HTTPS. (DNS over HTTPS *doesn't* make sense with Tor, because it leaks your DNS requests to parties outside Tor, hence this is disabled in Onion Cider!)

[^1]: This is particularly useful on older iOS versions. Because WebKit is bundled with the OS, devices that no longer receive iOS updates are also stuck with an older browser engine, which can cause modern websites to break or render incorrectly.

## Installation

The latest builds are available for download on the [Releases](https://github.com/tladesignz/onion-cider/releases) page. Please note that this project is still in alpha, so expect bugs and missing features.

For common questions and troubleshooting, see the [FAQ](https://github.com/minh-ton/reynard-browser/issues/130).


**For AltStore or SideStore installations:**

Make sure to select **Keep App Extensions** during installation, as Onion Cider will not work without them.

You can also [click here](https://altdirect.app/?url=https://github.com/tladesignz/onion-cider/releases/download/0.21.0/source.json&exclude=livecontainer,stikstore,trollapps,feather) to add the AltSource for Reynard to AltStore or SideStore.

> [!IMPORTANT]
> - **LiveContainer is not supported** due to its own limitations.
> - Sideloading using a distribution certificate for signing is **not supported**.⁠
> - Other sideloading methods may be **incompatible with Reynard**, and **no support will be provided** for issues arising from them.


## Building

> [!WARNING]
> Build instructions are included below for reference. Please be aware that I **do not** provide support for issues or errors encountered during the build process.

To build the project, you'll need Xcode, [Python 3](https://www.python.org/downloads/), and [Rust & Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html).

Clone the repository.

```bash
git clone --recursive https://github.com/tladesignz/onion-cider
cd onion-cider
```

Download Gecko and apply patches.

```bash
./tools/development/update-gecko.sh
./tools/development/apply-patches.sh
```

Build dependencies and the Gecko engine.

```bash
./tools/development/build-idevice.sh

# After system or Xcocde updates only: Install Mozilla's own LLVM build chain containing the lld linker, cbindgen and WASM targets.
rm -rf ~/.mozbuild

cd engine/firefox
./mach bootstrap # choose option 2: Desktop build, no precompiled atifacts
cd ../..

# Remove iOS 27 target, which Mozilla's lld doesn't understand, yet.
sudo ./tools/development/fix-ios27.sh patch

# Run the build.
./tools/development/build-gecko.sh

# Undo changes to iOS SDK again.
sudo ./tools/development/fix-ios27.sh undo

```

To run Onion Cider, open `Reynard.xcodeproj` in Xcode and build/run it from there.

## Development Comments from the Reynard Developer

This project initially started out of curiosity. I wanted to see if I could get Gecko to run without the [BrowserEngineKit](https://developer.apple.com/documentation/browserenginekit) framework, so it could be further modified to support iOS versions as far back as possible. I got it working, and since then, I’ve been focusing on developing engine patches for better integration with iOS, fixing bugs, and turning Reynard into a full, usable browser.

If you’ve come across this repository and find it interesting, I’d love to get help or collaborate on it. I’m learning as I go here and don’t have much prior experience with iOS app development or with Gecko itself, so any contributions, feedback, or pointers would be greatly appreciated.

You can also help translate Reynard into more languages, or support the time I spend working on the project through the links below.

<a href="https://crowdin.com/project/reynard-browser"><img height="40" src="https://github.com/user-attachments/assets/5f00681e-c31a-4c7f-87fe-caaf67ee52d7" /></a>
<a href="https://buymeacoffee.com/hnimnot"><img height="40" src="https://github.com/user-attachments/assets/ea72836b-3d60-4ffc-be93-d62d5df51047" /></a>

## Acknowledgements from the Reynard Developer
- [LiveContainer](https://github.com/LiveContainer/LiveContainer): app extension handling and NSExtension usage.
- [StikDebug](https://github.com/StephenDev0/StikDebug) and [idevice](https://github.com/jkcoxson/idevice): pairing-based JIT enablement support.
- [TrollStore](https://github.com/opa334/TrollStore): spawning a binary as root and JIT enablement.
- [Amethyst-iOS](https://github.com/AngelAuraMC/Amethyst-iOS), [dolphin-ios](https://github.com/OatmealDome/dolphin-ios), [DukeX](https://github.com/MaftyManicEMU/DukeX), and [MeloNX](https://git.ryujinx.app/projects/MeloNX): Various utility functions, numerous private API usage, and JIT memory handling.
- [WebKit](https://github.com/webkit/webkit): Private API references for deeper iOS integration, such as sandboxing, hardware keyboard support, and lifecycle events.
- [Pre-existing work](https://bugzilla.mozilla.org/show_bug.cgi?id=1882872) on bringing Gecko to iOS using BrowserEngineKit: most of the difficult engine integration. 

## License

This project is licensed under the [GNU General Public License v3.0](https://github.com/tladesignz/onion-cider/blob/main/LICENSE), except for the `patches` directory containing the modifications to the Firefox Gecko engine and therefore is licensed under the [Mozilla Public License 2.0](https://github.com/tladesignz/onion-cider/blob/main/LICENSE.firefox).
