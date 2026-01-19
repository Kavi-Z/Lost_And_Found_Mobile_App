# Documentation
# Lost & Find Mobile Application

## Project Overview
The Lost & Find Mobile Application is designed to help users report lost items and post found items so that owners and finders can easily communicate and recover items.

## Main Features

### Lost Item Posting
- Users can post details about lost items
- Includes item name, description, location, image, and contact mobile number

### Found Item Posting
- Users can post details about found items
- Includes found location, description, image, and contact mobile number

### User Communication
- All users can add their mobile number
- Enables direct communication between users

### Mark as Found
- After recovering an item, users can mark it as found
- Helps keep the item list up to date

### Profile Section
- Displays user details
- Users can update and change their profile information

## User Roles
- Registered users can:
  - Post lost items
  - Post found items
  - View item details
  - Communicate with other users
  - Update profile details

## Technologies Used
- Flutter
- Firebase Firestore
- Firebase Storage
- Firebase Authentication

## Database and Storage

### Firestore
- Stores user information
- Stores lost item details
- Stores found item details
- Stores item status (lost or found)

### Firebase Storage
- Stores images related to lost items
- Stores images related to found items

## Application Workflow
1. User registers or logs in
2. User posts a lost or found item
3. Other users view item details
4. Users communicate using mobile numbers
5. Item is recovered and marked as found

## Security
- Firebase Authentication for user access
- Firestore security rules to protect data

## Future Improvements
- In-app chat system
- Push notifications
- Location-based filtering
- Admin moderation panel

## License
This project is developed for educational purposes and is free to use and modify.
