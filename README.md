# Sphereseekers: Marble Maze Game

## **Project Description**

Sphereseekers is a 3D maze navigation game where players control a ball through challenging mazes filled with obstacles, reset zones, and timers. The game is designed to leverage iPhone’s gyroscope and accelerometer sensors, allowing players to tilt their device to navigate the ball. The ultimate goal is to navigate the maze and reach the exit as quickly as possible, while avoiding pitfalls and reset zones.

The project is currently being developed using the Godot Engine with GDScript. Initial development and testing are being conducted on Browsers.

---

## **Gameplay Features**

1. **Maze Navigation**:
   - Navigate the ball through complex obstacles.
   - Avoid reset zones marked with visible warnings (e.g., a skull icon).
   - Reach the exit to complete the level.

2. **Stopwatch Timer**:
   - A stopwatch tracks the time taken to complete the level.
   - The best time is displayed and updated if beaten.

3. **Level Progression**:
   - On completing a level, the next level loads automatically.
   - Levels increase in difficulty, introducing more obstacles and challenges.

4. **Gyroscope and Accelerometer Controls**:
   - Use device tilting to control the ball’s movement.
   - Real-time physics simulation for immersive gameplay.

---

## **Development Details**

### **Technology Stack**

- **Game Engine**: Godot.
- **Language**: GDScript.
- **Version Control**: GitHub repository at [https://github.com/ScottWillard/Sphereseekers](https://github.com/ScottWillard/Sphereseekers).
- **Development Platforms**:
  - **Primary**: Desktop.
  - **Secondary**: Mobile.
- **Tools**:
  - Godot Engine.
  - Git for version control.

---

## **Development Workflow**

### **1. Setting Up the Project**

1. Clone the GitHub repository:

   ```bash
   git clone https://github.com/ScottWillard/Sphereseekers.git
   ```

2. Open the project in Godot by importing the `project.godot` file.

### **2. Building the Game**

- **Level Design**:
  - Build levels using Godot’s 3D editor and scripts to achieve the desired behavior.
  - Add walls, obstacles, reset zones, and the exit area.
- **Collision and Physics**:
  - Ensure all game objects (e.g., walls, reset zones) have proper collision shapes.
  - Use `RigidBody3D` for the ball to enable realistic physics.

### **3. Mobile-Specific Development**

#### **Gyroscope and Accelerometer Controls**

- Use Godot’s Input API to read accelerometer and gyroscope data:

  ```csharp
  Vector3 tilt = Input.GetGyroscope();
  ```

- Map tilt data to ball movement for intuitive controls.

#### **Testing on Mobile**

1. Update the latest veersion on the website.
2. Play on your browser.

---

## **Repository Structure**

``` bash
sphereseekers/
├── Assets/
│   ├── *Images for the game*
├── Scenes/
│   ├── Interface/
│   │   ├── ControlsMenu.tscn
│   │   ├── MainMenu.tscn
│   │   ├── PauseMenu.tscn
│   ├── Levels/
│   │   ├── Tutorial.tscn
│   ├── Objects/
│   │   ├── Cannon/
│   │   │   ├── cannon.gd
│   │   │   ├── cannon.tscn
│   │   ├── path_with_holes/
│   │   │   ├── path_with_holes.gd
│   │   │   ├── path_with_holes.tscn
│   │   │   ├── path_with_holes_map.png
├── Scripts/
│   ├── Camera/
│   │   ├── camera_rig.gd
│   ├── Interface/
│   │   ├── ControlsMenu.gd
│   │   ├── Global.gd
│   │   ├── MainMenu.gd
│   │   ├── PauseMenu.gd
│   │   ├── SaveManager.gd
│   ├── Levels/
│   │   ├── main.gd
│   ├── Movement/
│   │   ├── ball.gd
│   ├── Objects/
│   │   ├── exit_area.gd
│   │   ├── ground.gd
│   │   ├── limit.gd
├── Vector/Textures/
│   ├── *Textures for the game*
├── project.godot
sphereseekersWebsite/
├── Public/
│   ├── game/
│   │   ├── index.html
├── src/app/
│   ├── GameEmbed.jsx
│   ├── globals.css
│   ├── page.js
Readme.md
```

---

## **Current Progress**

1. **Tutorial Level**:
   - Fully designed and functional with a working exit.

2. **Level Progression**:
   - Itemazing objects for easy development on further levels.

3. **GitHub Repository**:
   - All game files and website files are tracked in the repository.
   - Large files (e.g., executables) are excluded using `.gitignore`.

---

## **Future Plans**

1. Add more levels with increasing complexity.
2. Enhance visuals and UI for a polished look.
3. Implement leaderboards and scoring systems.

---

## **Contributing**

Team members can contribute by:

1. Cloning the repository:

   ```bash
   git clone https://github.com/ScottWillard/Sphereseekers.git
   ```

2. Creating feature branches:

   ```bash
   git checkout -b feature-branch-name
   ```

3. Committing changes:

   ```bash
   git add .
   git commit -m "Describe the changes"
   ```

4. Pushing to the repository:

   ```bash
   git push origin feature-branch-name
   ```

5. Submitting pull requests for review.

Team members can update the website by:

1. Install the HTML5 Export Template

   - In Godot, go to Editor -> Manage Export Templates.
   - Click "Download" (if no templatees are installed).
   - Under Mirror, select "Official Github Releases".
   - Click "Install" and wait for the installation to complete.

2. Configure the HTML Export in Godot.
   - Open Project -> Export.
   - Click "Add..." and select "Web" (HTML5).
   - In the export path, make sure the filename is index.html.
   - Under options make sure to mark "For Desktop" and "For Mobile" on the VRAM Texture Compression.

3. Export the Project
   - Click "Export Project".
   - Choose Sphereseekers/sphereseekersWebsite/public/game and replace the previous files.

---

## **Contact**

For questions or suggestions, please contact:

- **Project Lead**: Scott Willard
- **Repository**: [GitHub Link](https://github.com/ScottWillard/Sphereseekers)
