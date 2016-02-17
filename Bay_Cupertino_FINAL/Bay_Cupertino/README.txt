PIC

CONTENTS OF THIS FILE
---------------------
 * Introduction
 * Requirements
 * Installation
 * Configuration
 * Troubleshooting
 * FAQ
 * Software Used
 * Source of Information
 * Copyright Notations
 * Instructions for Running Project
 * Templates Used
 * Maintainers
 * Information Sources

INTRODUCTION
------------
Appearances are important in influencing others’ perceptions of oneself. How one dresses is even more important in the formal setting. PIC is created to help individuals gain 
feedback on outfits they plan on using. I short, PIC is a social networking application designed to share, compare and improve on one’s outfit.
 
For more information, visit http://pic.paperplane.io/

REQUIREMENTS
------------
·      An iOS device (iOS 7 or higher) or iOS emulator
·      The device must be able to take a picture or upload a picture file
·      iPhone 5S is the most optimized device for this application
 
INSTALLATION
------------
·      This application is not available on the App Store
·      Must be run through X-code via an iPhone Emulator or a connected device
 
CONFIGURATION
-------------
·      Configure user permissions in the Settings application on your device
·      Permissions
	·      Access to camera
	·      Access to internet (Wi-Fi or Cellular Data)
 
TROUBLESHOOTING
---------------
·      If the application looks distorted, it may be due to a variance in screen resolution from the ideal iPhone 5S
·      If the application takes an unnatural time to respond (over 1 second) it may be due to Wi-Fi connection
·      Files other than images may not be uploaded onto the application
 
FAQ
---
Q: Why can’t I select photos from my gallery and upload it to my news feed?
A: PIC is an application meant to upload unaltered pictures for honest review by peers. PIC, in this manner, prevents users from portraying a false persona to their followers. 
   After all, uploading a picture that is altered no longer gives room to achieve the goals of PIC.
 
Q: Why can’t I upload media other than pictures to my news feed?
A: The act of uploading media other than pictures is not in the intention of PIC or its developers. PIC is meant to be an application that allows FBLA members to share their opinions on 
   style, fashion, and attire. Users need not to upload media other than pictures to share their opinions and clothing choices, pictures are more than sufficient.

Q. What is the cloud at the top left of my screen?
A. One of the unique features of PIC is that it allows you to take the weather into account. Using the feature allows users to look their best in good weather, and be prepared in case of 
   a bad weather forcast.

Q. Why can I delete others’ comments and why can others delete my comments?
A. While the app design allows individuals to delete others’ comments, we felt that such a feature was necessary. Since PIC’s primary audience is FBLA members, and more specifically, high 
   school students, the possibility of cyber bullying arises. To prevent such abuse of PIC, we allow individuals to delete others’ comments. This way, people 
 
SOFTWARE USED
-------------
Our integrated development environment (IOE) was X-code, which accompanies the default Apple Simulator. To create the images and components of the UI, we used both Gimp 2.0 and 
Photoshop CC. Additionally, we used Github as storage for both components of the code, as well as UI elements.

SOURCES OF INFORMATION
----------------------
Since we found promise in developing with Swift, the latest iOS programming language, and had not used the language extensively in the past, we needed to view some tutorials and access 
the internet for guidance. For assistance on the newly designed language, we referred to a tutorial made by Udemy. Udemy assisted us in setting up the workflow for the application, as 
well as certain differences in syntax. Beyond Udemy, we used Stack Overflow’s free public forums to aid us in errors we had. We also used two APIs to develop our app faster and 
essentially not write excessive code. The Parse API was used as a backend in order to eliminate the need to develop our own backend from scratch. The Parse API allows us to store all of 
our backend data such as photos and user information. The API eliminated the need to use Python, PHP, SQL and other languages to get our content with ease. The second API we used was the 
Open Weather Map API, which allows us to get weather information in a JSON format. The JSON file allowed us to extract the temperature and weather of a given location. This allowed us to 
suggest clothing to the user based on the weather and temperature at their location, or the location they will be travelling to.

COPYRIGHT NOTATIONS
-------------------
Only one resource was directly used in the development of our application. We used SwiftyJSON.swift, an open sourced swift file, to easily convert between the JSON file we got from the 
Open Weather API to a string which we could then manipulate to extract the weather and temperature. This parse to string resource was made by Ruoyu Fu and Pinglin Tang. We used this 
resource to easily parse the JSON file to a string.
Citation:
Copyright (c) 2014 Ruoyu Fu, Pinglin Tang

INSTRUCTIONS FOR RUNNING PROJECT
--------------------------------
To run PIC on Apple Simulator iPhone 5S:
First download the .zip Xcode file project. Extract the file. When opened, find and open the Xcode Project. IMPORTANT: change the simulator type to iPhone 5s by clicking on the iphone type button next to the stop button in the upper left corner. Then, Simply click the the play button at the top left corner when Xcode opens the 
project. When you are prompted for a device to use select iPhone 5S to automatically run PIC on the Simulator.

To run PIC on an iPhone:
First download the Xcode file project. When opened, find and open the file Xcode Project. Simply click the the play button at the top left corner when Xcode opens the project. Attach an 
iPhone 5S or previous generation iPhone with iOS 7 or higher. When you are prompted for a device to use select the device you have attached to automatically run PIC on your phone. Make 
sure that any prompts are accepted and the file is allowed to run. You may need to go to settings and make sure that the computer being used has permission to run application on the 
mobile device.

TEMPLATES USED
---------------
To make the website that accompanies PIC, we used an open source HTML template from Mobile Cloud. Other than this, the app was completely made using Apple’s Xcode, tutorials, the 
internet, and our minds.

MAINTAINERS
-----------
·      Shreyas Patankar
·      Abhinav Pottabathula
·      Sanket Swamy
 
INFORMATION SOURCES
-------------------
·      Stack Overflow
·      Udemy
·      Parse API
·      Open Weather Map API
·      Mitchell Hudson (Weather API Implementation Tutorial)


