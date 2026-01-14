# Opti-Bridge:

> **Context:** This codebase is a snapshot from August 2023. It is a product of iterative bootstrapping; I had suffered a health crisis and could only control my computer via an eye tracker, and I used this eye tracker to write code to extend its (initially fairly limited) functionality. I am extremely grateful to Tobii and the open source Optikey project, which solved the two hardest technical parts of eye tracking: mapping gaze data to monitor coordinates (Tobii) and translating this map into input streams (Optikey).

## Project Overview:

Eye trackers are extremely limited input devices; they are noisy, often inaccurate, and encode very limited data. Using one effectively requires heavily customizing the interface to the user and their workflow. Opti-Bridge facilitates this. It contains a domain-specific language and compiler that facilitates writing custom Optikey keyboards using a syntax-dense language that is tailored to the realities of typing one character at a time with your eyes. It also provides a customizable, context-aware interaction layer that, amongst other things, allows the same gaze data to perform different actions depending on the active application (e.g. looking left of your monitor can change tabs in Firefox but rewind the video in VLC).

## Key Features:

### 1. Domain-Specific Language and Compiler (e.g. Make Keyboards.pl; shorthand.kdef)

Optikey allows users to produce custom "dynamic keyboards" (arrays of buttons that are triggered by gaze data) that can be customized to fit their use case. But their implementation requires users to write verbose XML that is difficult and laborious to write using an eye tracker. My solution was to build (what I have subsequently learned is called) a domain-specific language and compiler that provides a customizable, syntax-dense language that compiles to Optikey-compliant XML files. It has the following key features:

* **Customizable:** The language is stored separately from the compiler, in an easily-customized, external file (shorthand.kdef).

* **Flexible Grammar:** The language is designed to perform several different types of substitutions depending on the operator invoked. In particular:
    * *Wrappers (`=`):* A definition like `a=Action` tells the compiler that `a=Value` should expand to `<Action>Value</Action>`.
    * *Escape Sequences (`\`):* A definition like `l\ArrowLeft` tells the compiler to simply replace `\l` with `ArrowLeft`.
    * *Modifiers (`-`):* A definition like `^-LeftCtrl` tells the compiler to generate paired KeyDown/KeyUp events for the specified modifier. An example use is `s-^a l=ctrl-a`; this defines a button that holds down left ctrl, presses a, releases left control, and is labeled "ctrl-a". In particular, this snippet expands to:

    ```xml
    <DynamicKey Height="3" SharedSizeGroup="text">
        <ChangeKeyboard BackReturnsHere="False">KevinBottom</ChangeKeyboard>
        <KeyDown>LeftCtrl</KeyDown>
        <KeyDown>a</KeyDown>
        <KeyUp>a</KeyUp>
        <KeyUp>LeftCtrl</KeyUp>
        <Label>ctrl-a</Label>
    </DynamicKey>
    ```

* **Regex Substitutions:** A definition like `[<ChangeKeyboard.*?>KevinBottom<\/ChangeKeyboard>][.c=\k\b a=\z w=150 a=\z]` substitutes the contents of the brackets on the right for the contents of the brackets on the left in *all* compiled keyboards. This allows for easy customization of legacy code that may span multiple files. The target pattern must be a Perl-style regular expression, but the replacement can be written using the shorthand defined by the language.

* **Seamless Integration:** The compiler can seamlessly handle "mixed" files that contain both shorthand and raw XML. Users thus do not need to rewrite their existing interface, but can simply use the shorthand to modify it, and to produce new features going forward.

* **Inheritance:** The compiler has custom logic for creating a new keyboard by copying an old one and performing regex substitutions on it. For example, the syntax `copy[\k\y][close=KevinBottom][close=donotclose]` copies the keyboard in "KevinKeyboard.xml" (this is what `\k\y` expands to) but removes the close button, which I had to do at one point to work around an Optikey bug.

### 2. Context-Aware Interaction Layer (Optikey.ahk; OptikeyHotkeys.ahk; OptikeyGestures.ahk; OptikeyApps.ahk)

Optikey's dynamic keyboards are customizable but limited; there is no integrated scripting language and you cannot customize button functionality depending on context. My solution was to use Optikey to trigger key presses (especially the F13-F24 "keys"), and use AutoHotkey to intercept these key presses and execute complex logic. Some key features are:

* **Application-Specific Profiles:** The system detects the active window and maps the keys triggered by Optikey to application-specific commands. For example, looking at the bottom right of the monitor can scroll down in Firefox but press the down arrow in Windows Explorer. The exact mapping for various applications is customizable, and is defined in [`OptikeyApps.ahk`](https://github.com/kevinaimills/opti-bridge/blob/main/scripts/OptikeyApps.ahk).

* **Arbitrary Function Calls:** Intercepted key presses can be easily mapped to arbitrary functions, not just keyboard and mouse commands. The `MainCaller` function checks if it has been passed a function and, if it has, calls it and appends any specified arguments; otherwise it assumes it has been passed standard AutoHotkey syntax and executes the corresponding key/mouse commands. (See [`MainCaller`](https://github.com/kevinaimills/opti-bridge/blob/7ae1f94dc19192ac4d65d713f868b23b74a1f957/scripts/Optikey.ahk#L192) in `Optikey.ahk`).

* **Positional Compensation:** Eye tracking is inherently inaccurate, and is extremely sensitive to changes in positions. Unfortunately, while you can define different calibration profiles in Tobii, there is no convenient way to change between them. Fortunately, I discovered that Tobii stores the active profile in the Windows Registry, and updates the active profile in real time in response to Registry changes (thank you Tobii developers!). My system allows users to calibrate different profiles for their various sitting positions and to easily change between them via Optikey (which uses AutoHotkey to write to the registry).

* **Gaze "Gestures":** Eye tracking is noisy and you often need to put your eye tracker to sleep, e.g. so you can look around your room or talk to somebody who has entered it. You subsequently need a way to wake the eye tracker that can be triggered via the eye tracker itself and is unlikely to be triggered accidentally. My solution was to write (what I have subsequently learned is called) a finite state machine that runs even in "sleep mode". It stores gaze data in a rolling string (and has built-in noise rejection) which it then checks against a list of valid patterns; if it finds one, it executes the corresponding function with any specified arguments (e.g. waking the eye tracker from sleep). See [`CheckGestures`](https://github.com/kevinaimills/opti-bridge/blob/7ae1f94dc19192ac4d65d713f868b23b74a1f957/scripts/OptikeyGestures.ahk#L22) in `OptikeyGestures.ahk`.

## Attribution:

Almost everything in this repository was written from scratch by me using my eye tracker. But I did find and use some code online in the vibrant AutoHotkey community. To the best of my recollection, the only functions I did not write myself are the ones that interact with Windows processes in Optikey.ahk; but there may be other small snippets here and there. My sincere thanks to the AutoHotkey community, and my sincere apologies if I forgot to credit somebody's work.
