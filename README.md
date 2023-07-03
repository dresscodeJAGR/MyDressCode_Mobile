# MyDressCode_Mobile
Mobile application repository

## Project presentation

The MyDressCode project is a wardrobe management platform aimed at simplifying the lives of users by managing their clothing and creating outfits. The platform offers a set of community-focused features, such as the ability to view other users' public outfits, add them to favorites, and more.

## Install git

Open a terminal and run the following command: 
```bash 
sudo apt-get install git
```

## Install the projet
For those who want to work on the project, here is a list of tasks to clone and run the project.

### Install flutter
The application is coded in Flutter, so you need to install it first.

👉🏼 Download the ZIP file for Flutter (latest version at the time of documentation)
```bash
https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.3.9-stable.zip
```

👉🏼 Navigate to the directory where you want to place Flutter using the terminal and unzip the file in that directory.
```bash
unzip ~/Downloads/flutter_macos_arm64_3.3.9-stable.zip
```

👉🏼 Add Flutter to the PATH
```bash
export PATH="$PATH:pwd/flutter/bin”
```

👉🏼 After these steps, test if Flutter has been installed by running the following command:
```bash
flutter doctor
```
If you get "zsh: command not found: flutter," continue to the next steps. Otherwise, congratulations, you have Flutter installed.

👉🏼 Run the following command:
```bash
vim $HOME/.zshrc
```

Press "i" to enter insert mode and copy-paste the following export:
```bash
export PATH=$PATH:/~/flutter/bin
```
To exit the .zshrc file, press "Esc" and enter the following command, then press Enter:
```bash
:wq!
```

Flutter should now be installed.
```bash
flutter
```

### Clone the project
To clone the project, follow these steps:

Copy the repository URL (you can copy it by clicking on the green `< > Code` button at the top of the repository)

In a terminal:

Create a directory for the project and navigate to it: 
```bash
mkdir directory_name && cd directory_name
```
  
Run the clone command:
  
```bash
git clone url
```

That's it! You're ready to code 👍🏻

### Generate project APK

With android studio, click on the `build` tab, then on `Flutter`, and finally on `Build APK`

