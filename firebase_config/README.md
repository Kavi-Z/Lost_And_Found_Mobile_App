# Firebase Configuration

To set up Firebase credentials:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Save the downloaded JSON file as `serviceAccountKey.json` in this directory

Note: Never commit `serviceAccountKey.json` to version control. Add it to your `.gitignore` file.