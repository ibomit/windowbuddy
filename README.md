# Little Window Buddy

**Little Window Buddy** is a Flutter-based mobile application that provides an interface to remotely control windows using a Particle Photon microcontroller. The app communicates with the Photon over the cloud, allowing users to open and close windows seamlessly through their smartphone. Ideal for smart home setups.
---

## Features
- **Remote Control**: Open and close windows with a simple tap on your phone.
- **Real-Time Status**: View the current status of the window (open, closed) directly in the app.
- **Secure Cloud Communication**: Leverages the Particle Cloud API for reliable and secure communication with the Photon device.
- **User-Friendly Interface**: Built with Flutter to ensure a clean and responsive design for both Android and iOS platforms.

---

## How It Works
1. **Hardware Integration**: 
   - A Particle Photon microcontroller is connected to the window's motorized opening/closing mechanism.
   - The Photon is programmed to receive commands from the app via the Particle Cloud API.
2. **App Communication**: 
   - The Flutter app sends commands (open/close) to the Photon using RESTful API calls.
   - The app receives and displays feedback on the current window state.
3. **Cloud-Based Control**: 
   - The app leverages the Particle Cloud for communication, ensuring the window can be controlled from anywhere with an internet connection.

---

## Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/ibomit/windowbuddy.git

## Particle Photonh 
1. **Code**:
    - You can find the code for the particle photonh in /windowbuddy/particlePhotonh/littlewindowbuddy.ino file