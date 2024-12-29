Zybra Company Flutter Assignment

--> Project Setup
1. Clone the repository to your laptop/pc.
-> Run the following commands in your terminal to set up the project:
    flutter clean, flutter pub get, flutter run

-->Functionality Overview
1. Login/Register Screen:
   -> Upon running the app, you will be presented with a login/register screen.
   -> Enter your name and email to register a new user.
   -> Tap the Register button to navigate to the next screen.

2. Task Management Screen:
   -> On the second screen, you will see a task management interface.
   -> An Add Task button is located at the bottom of the screen. Tap it to add a new task.
   -> After adding a task, it will appear at the top of the screen, displayed by default in descending order (newest tasks first).
   
3. Task Actions:
   -> Each task is displayed in a card view, and you will have the following options:
       1. Edit: Update task details, including changing the task's status (e.g., Pending or Complete and Priorities).
       2. Delete: Remove the task from the list.
   
4. Filtering Tasks:
   -> You can filter tasks based on their status (e.g., Pending or Complete) using the Status button.
   -> You can filter tasks based on their priorities (e.g., High, Medium, Low, Newest/All first, Oldest first ) using the Filter button.

5. Architecture and Technologies Used
   -> MVVM (Model-View-ViewModel) architecture is implemented.
   -> SQLite and Hive are used for local data storage.
   -> Riverpod is used for state management.
   
Thank you! Regards
