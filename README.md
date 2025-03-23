# Sphereseekers: Marble Maze Game

<!-- markdownlint-disable MD033 -->
<p align="center">
  <img src="sphereseekers\Assets\logo\sphereseekers_logo.png" alt="Description" width="300" height="100"/>
</p>
<!-- markdownlint-enable MD033 -->

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
│   ├── *Contains all images and materials used in the game.*
├── Scenes/
│   ├── Interface/
│   │   ├── *Contains all UI menus.*
│   ├── Levels/
│   │   ├── *Contains all level scenes.*
│   ├── Objects/
│   │   ├── *Contains all game objects and their associated scripts.*
├── Scripts/
│   ├── *Contains all general-purpose scripts not linked to specific objects.*
├── Vector/Textures/
│   ├── *Contains vector-based textures for the game.*
├── project.godot
sphereseekersWebsite/
├── Public/
│   ├── game/
│   │   ├── *Game data*
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
   - Development of levels is planned as at least one new level per week.

3. **GitHub Repository**:
   - All game files and website files are tracked in the repository.
   - Large files (e.g., executables) are excluded using `.gitignore`.
   - .pck files are accepted using git LFS.

---

## **Future Plans**

1. Implement leaderboards and scoring systems.
2. Continue the development of new levels.
3. Implemet mobile controlls

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

This project uses **Git Large File Storage (Git LFS)** to track and store large files such as `.pck` files used in Godot projects.

- Before pushing or pulling large files, install Git LFS:

   ```bash
   git lfs install
   ```

- To track `.pck**` files with GIT LFS:

   ```bash
   git lfs track "*.pck"
   ```

   this will update the .gitattributes file, this step only needs to be done oncee per file type.

- Pushing All LFS Files

   If you need to ensure all LFS-tracked files (including past commits) are uploaded to the remote for a specific brancj:

   ```bash
   git lfs push --all origin <your-branch-name>
   ```

   Use this if you are syncing LFS history or migrating to a new branch or remote.

---

## **Contact**

For questions or suggestions, please contact:

- **Project Lead**: Scott Willard
- **Repository**: [GitHub Link](https://github.com/ScottWillard/Sphereseekers)
