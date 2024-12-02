# Zig Windowing Library
ZWL (Zig Windowing Library, /zwil/) is a cross-platform zig windowing library with loop-based event polling (like SDL) and aimed to be lightweight thanks to zig's conditional compilation/lazy evaluation.

## Current state: ![](https://progress-bar.xyz/3?scale=12&show_text=false&title=3/12)
<details>
  <summary>Win32 <img src="https://progress-bar.xyz/3?scale=3&show_text=false&title=3/3"/></summary>

  - [x] Window
  - [x] Event
  - [x] OpenGL Context
</details>
<details>
  <summary>Linux <img src="https://progress-bar.xyz/0?scale=6&show_text=false&title=0/6"/></summary>
  
  - X11 ![](https://progress-bar.xyz/0?scale=3&show_text=false&title=0/3)
    - [ ] Window
    - [ ] Event
    - [ ] OpenGL Context
  - Wayland ![](https://progress-bar.xyz/0?scale=3&show_text=false&title=0/3)
    - [ ] Window
    - [ ] Event
    - [ ] OpenGL Context
</details>
<details>
  <summary>MacOS <img src="https://progress-bar.xyz/0?scale=3&show_text=false&title=0/3"/></summary>

  - [ ] Window
  - [ ] Event
  - [ ] OpenGL Context
</details>

###
ZWL is very WIP, so expect bugs, inconsistencies and lack of support on certain platforms. If you wish you can help me by [contributing](#contributing) to this project via pull requests or filing issues.

# Contributing
Feel free to contribute to the library by making PRs or by filing issues. My machine is a windows one, so I'll prioritize my work (and might only work) on the Win32 implementation.