# Zig Windowing Library
ZWL (Zig Windowing Library, /zwil/) is a cross-platform zig windowing library with loop-based event polling (like SDL) and aimed to be lightweight thanks to zig's conditional compilation/lazy evaluation.

## Current state: ![](https://progress-bar.xyz/3?scale=12&suffix=/12)
<details>
  <summary><img src="https://progress-bar.xyz/3?scale=3&suffix=/3"/> Win32</summary>

  - [x] Window
  - [x] Event
  - [x] OpenGL Context
</details>
<details>
  <summary><img src="https://progress-bar.xyz/0?scale=6&suffix=/6"/> Linux</summary>
  
  - ![](https://progress-bar.xyz/0?scale=3&suffix=/3) x11
    - [ ] Window
    - [ ] Event
    - [ ] OpenGL Context
  - ![](https://progress-bar.xyz/0?scale=3&suffix=/3) wayland
    - [ ] Window
    - [ ] Event
    - [ ] OpenGL Context
</details>
<details>
  <summary><img src="https://progress-bar.xyz/0?scale=3&suffix=/3"/> MacOS</summary>

  - [ ] Window
  - [ ] Event
  - [ ] OpenGL Context
</details>

###
ZWL is very WIP, so expect bugs, inconsistencies and lack of support on certain platforms. If you wish you can help me by [contributing](#contributing) to this project via pull requests or filing issues.

# Contributing
Feel free to contribute to the library by making PRs or by filing issues. My machine is a windows one, so I'll prioritize my work (and might only work) on the Win32 implementation.