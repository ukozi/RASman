# RASman

<p align="center">
<img width="396" alt="1" src="https://github.com/user-attachments/assets/b64fe8c7-266f-4b4b-b010-7d88b8ebd905">
</p>

**RASman** is a SwiftUI-based macOS application that provides an interface for managing chat rooms, and users, and user sessions on a Retro AIM server. The application allows administrators to view, create, and manage public and private chat rooms, monitor active user sessions, manage users' passwords/accounts, and send messages without an account. The purpose is to serve as a front-end to the API's provided by the Retro AIM Server project. 

## Features

- **User Management**
  - Create new users
  - Delete users
  - Change a user's password
    
<img width="900" alt="6" src="https://github.com/user-attachments/assets/33cf4815-da3d-4f84-9a77-a1faba690761">

- **Chat Room Management**
  - View a list of public and private chat rooms.
  - Create new chat rooms with a specified name and type (public or private).
  - View detailed information about each chat room, including participants.
 
<img width="900" alt="7" src="https://github.com/user-attachments/assets/b0157f53-a73e-4621-aee2-a74a0835241f">

- **User Session Management**
  - View the number of active sessions and detailed information about each session.
  - Monitor who is currently logged in and their associated details.

<img width="900" alt="5" src="https://github.com/user-attachments/assets/d48464d8-d77f-4ce7-badb-850f77b249ac">

- **Impersonation**
  - Send a message as any user to any user. 
  - Save a log of sent messages.

 <img width="900" alt="3" src="https://github.com/user-attachments/assets/80e597c5-ae31-4abf-9a34-e8179b405c0e">

- **Customization and Flexibility**
  - Built with SwiftUI for a modern, responsive macOS user interface.
  - Utilizes SwiftData for data persistence and management.

## Installation

- Download the notarized binary from the releases page and drop it into your applications folder.
- If this is the first time you've run RASman, you will need to click the 'Settings' icon (the gear in the toolbar) and give the application your RAS server information. Click Save.
- Done!

### Prerequisites

- macOS 14.0 (Sonoma) or later.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss your changes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

[Retro AIM Server](https://github.com/mk6i/retro-aim-server)

