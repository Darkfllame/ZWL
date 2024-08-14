# Zig Windowing Library
ZWL (Zig Windowing Library, /zwil/) is a cross-platform zig windowing library with loop-based event polling (like SDL) and aimed to be lightweight thanks to zig's conditional compilation.

## Current state: ![](https://progress-bar.xyz/2?scale=22&suffix=/22)
<details>
  <summary><img src="https://progress-bar.xyz/3?scale=4&suffix=/4"/> Win32</summary>

  - [x] Window
  - [x] Event
  - ![](https://progress-bar.xyz/1?scale=2&suffix=/2) Context management
    - [x] OpenGL
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
          - [ ] Metal
</details>

###
ZWL is very WIP, so expect bugs, inconsistencies and lack of support on certain platforms. If you wish you can help me by [contributing](#contributing) to this project via pull requests or filing issues.

# Contributing
Feel free to contribute to the library by making PRs or by filing issues. My machine is a windows one, so I'll prioritize my work on the Win32 implementation.

## Contributor Note
- Constants are **CAPITAL_SNAKE_CASE**
- Files should starts with imports, type aliases, constants, main type(s) or function(s), internal/local functions
- Enums values or struct fields which are unused on a certain platform should be marked as unused in the documentation. Optionally add a todo along it.
- If you need to add an option to the build config, make so that the build argument is unconditional and in **CAPITAL_SNAKE_CASE**.
- Avoid blocking operations.
- If you need to change something in the user API, make sure it makes sense with the rest of the API.
- Follow the zen of zig (type `zig zen` in your console to get it, or check out [the documentation](https://ziglang.org/documentation/0.13.0/#Zen)).