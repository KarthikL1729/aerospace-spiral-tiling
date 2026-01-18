# aerospace-spiral-tiling

Tiny background script to enable spiral tiling in Aerospace for macOS.

Did not like the default aerospace tiling, and missed i3 autotiling. This background script automatically implements a sort of static spiral tiling, that I find enough for my workflow by alternating the split orientation based on window count in the focused workspace. Steps to run:

Clone and make the script executable:

```
git clone https://github.com/KarthikL1729/aerospace-spiral-tiling.git
cd aerospace-spiral-tiling && chmod +x spiral_tiling.sh            
```

Add an exec and forget in the toml config:

```
# In .config/aerospace.toml

after-startup-command = [
    ...
  'exec-and-forget ~/aerospace-spiral-tiling/spiral_tiling.sh'
    ...
]
```

and restart aerospace. It won't automatically tile the windows that are already open spirally, since it is static tiling based on window changes. It also won't spiral tile when 2 or more windows open simultaneously.

---
