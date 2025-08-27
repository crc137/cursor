# Cursor: Your AI-Powered Code Editor

Welcome to **Cursor**, the innovative code editor designed to boost your productivity with artificial intelligence! Whether you're a seasoned developer or just starting, Cursor provides an intelligent environment to write, debug, and understand your code faster. While available across macOS, Windows, and Linux, this repository specifically focuses on our seamless Linux experience. 

## Key Features 

*   **AI-Enhanced Coding:** Leverage cutting-in-edge AI to generate, refactor, and explain code directly within your editor. 
*   **Cross-Platform Support:** Enjoy Cursor on your preferred OS: macOS, Windows, and, of course, Linux! 
*   **Streamlined Linux Installation:** Easy and automated setup using the self-contained AppImage format. No complex dependencies to manage manually. 
*   **Seamless System Integration:**
    *   **Desktop Launcher:** Appears directly in your Linux application menu with a custom icon for quick access. 
    *   **Terminal Command:** Launch Cursor from any terminal with a simple `cursor` command, preventing multiple instances. 
*   **Automated Updates:** Stay current with the latest features and bug fixes through our smart, graphical update checker. It proactively notifies you of new versions and handles the upgrade process. ⬆
*   **Dependency Management:** Automatically checks for and installs necessary command-line tools to ensure a smooth operation. 
*   **Clean Uninstallation:** A dedicated function within the installer ensures all components (AppImage, icon, desktop entry, terminal alias) are cleanly removed. 🗑

## Key Tools & Technologies Used 

The following technologies are integral to Cursor's robust Linux distribution and management system:

*   **Shell Scripting:** Bash for automating installation, updates, and system integration.
*   **AppImage:** The portable and self-contained application distribution format for Linux.
*   **cURL:** For securely downloading the latest Cursor releases and fetching update information.
*   **jq:** A lightweight and flexible command-line JSON processor used for parsing API responses during update checks.
*   **Zenity:** Provides simple graphical dialogs for user interaction, especially during the update prompt.
*   **SVG:** Used for high-quality, scalable application icons.

*(Note: These tools primarily pertain to the distribution and management scripts on Linux. The core AI-powered editor itself utilizes a broader set of technologies.)*

## Getting Started 

To get Cursor up and running on your Linux machine, follow these simple steps. Our installer takes care of everything!

1.  **Download the Installer:**
    Download the official installation script from the Cursor website.
2.  **Make Executable:**
    Navigate to the directory where you downloaded the script and make it executable.
3.  **Run the Installer:**
    Execute the script. It will download the latest Cursor AppImage, integrate it with your system, and set up the necessary aliases. Follow any prompts that appear.

    *Example (conceptual steps, as per guidelines not including raw code):*
    ```bash
    # (Conceptual) Download the install script
    # (Conceptual) Make it executable
    # (Conceptual) Run it
    ```
    The installer will guide you through the process, including installing any required dependencies like `curl`, `jq`, or `zenity` if they're missing.

4.  **Launch Cursor:**
    Once the installation is complete, you can launch Cursor in a few ways:
    *   From your application menu/launcher (search for "Cursor").
    *   By typing `cursor` in your terminal.

5.  **Updating Cursor:**
    Cursor includes an automatic update checker. It will periodically check for new versions and prompt you graphically if an update is available. You can approve the update, and the system will handle the rest.

6.  **Uninstalling Cursor:**
    If you ever need to remove Cursor from your system, simply run the installation script again with a specific argument for uninstallation. It will cleanly remove all associated files and configurations.
