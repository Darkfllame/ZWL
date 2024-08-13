# Zig Windowing Library
ZWL (Zig Windowing Library, /zwil/) is a cross-platform zig windowing library.

## Current state: ![](https://progress-bar.xyz/2?scale=22&suffix=/22)
<details>
  <summary><img src="https://progress-bar.xyz/2?scale=4&suffix=/4"/> Win32</summary>

  - [x] Window
  - [x] Event
  - ![](https://progress-bar.xyz/0?scale=2&suffix=/2) Context management
    - [ ] OpenGL
    - [ ] Vulkan
</details>
<details>
  <summary><img src="https://progress-bar.xyz/0?scale=8&suffix=/8"/> Linux</summary>
  
  - ![](https://progress-bar.xyz/0?scale=4&suffix=/4) xorg
    - [ ] Window
    - [ ] Event
    - ![](https://progress-bar.xyz/0?scale=2&suffix=/2) Context management
        - [ ] OpenGL
        - [ ] Vulkan
  - ![](https://progress-bar.xyz/0?scale=4&suffix=/4) wayland
    - [ ] Window
    - [ ] Event
    - ![](https://progress-bar.xyz/0?scale=2&suffix=/2) Context management
        - [ ] OpenGL
        - [ ] Vulkan
</details>
<details>
  <summary><img src="https://progress-bar.xyz/0?scale=8&suffix=/8"/> Apple</summary>

  - ![](https://progress-bar.xyz/0?scale=5&suffix=/5) MacOS
      - [ ] Window
      - [ ] Event
      - ![](https://progress-bar.xyz/0?scale=3&suffix=/3) Context management
          - [ ] OpenGL
          - [ ] Vulkan
          - [ ] Cocoa
  - ![](https://progress-bar.xyz/0?scale=5&suffix=/5) IOS
      - [ ] Window
      - [ ] Event
      - ![](https://progress-bar.xyz/0?scale=3&suffix=/3) Context management
          - [ ] OpenGL
          - [ ] Vulkan
          - [ ] Cocoa
</details>

###
ZWL is very WIP, so expect bugs, inconsistencies and lack of support on certain platforms. If you wish you can help me by [contributing](#contributing) to this project via pull requests or filing issues.

# Contributing
Feel free to contribute to the library by making PRs or by filing issues. My machine is a windows one, so I'll prioritize my work on the Win32 implementation.