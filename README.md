# MenuBar Sprite Follower

A fun macOS menu bar app that displays an animated sprite character that follows your mouse movements in real-time! 🎮

## Requirements

- macOS 10.15 (Catalina) or later
- Xcode 12.0 or later (for building from source)

## Installation

### Option 1: Download Release (Coming Soon)
1. Download the latest release from the [Releases](https://github.com/yourusername/menubar-sprite-follower/releases) page
2. Unzip and drag the app to your Applications folder
3. Launch the app and grant accessibility permissions when prompted

### Option 2: Build from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/menubar-sprite-follower.git
   cd menubar-sprite-follower
   ```

2. **Prepare Your Sprite Sheet** (or use the included one):
   - Create a 16-frame sprite sheet in PNG format
   - Arrange frames in a 4x4 grid layout:
     - Row 1: Down movement frames (0-3)
     - Row 2: Left movement frames (4-7)
     - Row 3: Right movement frames (8-11)
     - Row 4: Up movement frames (12-15)
   - Name the file `sprite_sheet.png`

3. **Open in Xcode**:
   - Open `MenuBarSpriteFollower.xcodeproj` in Xcode
   - Add your `sprite_sheet.png` to the project (drag and drop into Xcode)
   - Make sure "Add to target" is checked

4. **Configure Info.plist** (Optional - for hiding dock icon):
   - In project settings, go to Info tab
   - Add new row: `LSUIElement` → Boolean → YES

5. **Build and Run**:
   - Press Cmd+R to build and run
   - Grant accessibility permissions when prompted

## Usage

1. **Basic Movement**: Move your mouse around the screen and watch the sprite follow!

2. **Enlarged View**: Left-click the menu bar sprite to open a larger window showing the same animation

3. **Menu Options**: Right-click the sprite for additional options including quit

4. **Permissions**: The app needs accessibility permissions to track global mouse movement - you'll be prompted on first run

## Sprite Sheet Format

Your sprite sheet should be a PNG file arranged in a 4x4 grid (16 frames total):

```
[Down1] [Down2] [Down3] [Down4]
[Left1] [Left2] [Left3] [Left4]
[Right1][Right2][Right3][Right4]
[Up1]   [Up2]   [Up3]   [Up4]
```

Each frame will be automatically extracted and resized for the menu bar.

## Customization

You can easily customize the app by modifying these values in `AppDelegate.swift`:

- **Sprite size**: Change the `NSSize(width: 32, height: 32)` values
- **Animation speed**: Adjust `withTimeInterval: 0.15` for frame rate
- **Mouse sensitivity**: Modify `threshold: CGFloat = 10.0` for movement detection
- **Animation duration**: Change the `0.6` second delay in `animateInDirection`

## Technical Details

- **Language**: Swift 5
- **Framework**: Cocoa
- **Architecture**: Event-driven with timer-based mouse tracking
- **Memory**: Lightweight - all sprites loaded once at startup
- **Performance**: Minimal CPU usage, only processes mouse movement every 0.1 seconds

## Troubleshooting

**Sprite doesn't appear or shows default icon**:
- Ensure `sprite_sheet.png` is properly added to your Xcode project
- Check the console for error messages about loading the sprite sheet

**Sprite doesn't respond to mouse movement**:
- Grant accessibility permissions in System Preferences → Security & Privacy → Privacy → Accessibility
- Try restarting the app after granting permissions

**Animation is too fast/slow**:
- Adjust the `withTimeInterval` value in `startDirectionalAnimation()`
- Modify the delay in `animateInDirection()` for longer/shorter animations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Some ideas for improvements:

- [ ] Support for different sprite sheet layouts
- [ ] Configurable animation speeds via preferences
- [ ] Multiple sprite character options
- [ ] Sound effects
- [ ] Keyboard shortcuts for manual control

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by classic 2D game sprites and desktop pets
- Built with love for the macOS community
- The included sprite is a pokemon character and I dont own it. [Source](https://i.sstatic.net/gZ3c5.png)

## Support

If you enjoy this app, consider:
- ⭐ Starring this repository
- 🐛 Reporting bugs in the Issues section
- 💡 Suggesting new features
- 🔄 Sharing with friends who love animated desktop companions!

---

Made with ❤️ for Mac users who miss the days of desktop pets and interactive screen companions.
