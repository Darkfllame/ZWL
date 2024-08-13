# Zig Windowing Library
ZWL (Zig Windowing Library, /zwil/) is a cross-platform zig windowing library.

## Current state: ![](https://progress-bar.xyz/2?scale=25&suffix=/25)
- ![](https://progress-bar.xyz/2?scale=5&suffix=/5) Win32
  - [x] Window
  - [x] Event
  - ![](https://progress-bar.xyz/0?scale=2&suffix=/2) Context management
    - [ ] OpenGL
    - [ ] Vulkan (probably)
- ![](https://progress-bar.xyz/0?scale=10&suffix=/10) Linux
  - ![](https://progress-bar.xyz/0?scale=5&suffix=/5) xorg
    - [ ] Window
    - [ ] Event
    - ![](https://progress-bar.xyz/0?scale=2&suffix=/2) Context management
        - [ ] OpenGL
        - [ ] Vulkan (probably)
  - ![](https://progress-bar.xyz/0?scale=5&suffix=/5) wayland
    - [ ] Window
    - [ ] Event
    - ![](https://progress-bar.xyz/0?scale=2&suffix=/2) Context management
        - [ ] OpenGL
        - [ ] Vulkan (probably)
- ![](https://progress-bar.xyz/0?scale=10&suffix=/10) Apple
    - ![](https://progress-bar.xyz/0?scale=5&suffix=/5) MacOS
        - [ ] Window
        - [ ] Event
        - ![](https://progress-bar.xyz/0?scale=3&suffix=/3) Context management
            - [ ] OpenGL
            - [ ] Vulkan (probably)
            - [ ] Cocoa
    - ![](https://progress-bar.xyz/0?scale=5&suffix=/5) IOS
        - [ ] Window
        - [ ] Event
        - ![](https://progress-bar.xyz/0?scale=3&suffix=/3) Context management
            - [ ] OpenGL
            - [ ] Vulkan (probably)
            - [ ] Cocoa
###
ZWL is very WIP, so expect bugs, inconsistencies and lack of support on certain platforms. If you wish you can help me by [contributing](#contributing) to this project via pull requests or filing issues.

# Contributing
Feel free to contribute to the library by making PRs or by filing issues. My machine is a windows one, so I'll prioritize my work on the Win32 implementation.