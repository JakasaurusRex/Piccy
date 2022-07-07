# Piccy

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Piccy is an image sharing iOS application made for users to have fun with and create memories and connections with friends and family. The flow of the app involves a user logging on once a day to search an image api (Google Images or Imgur) in the app for a picture related to a randomly selected topic of the day for every user. Users will have a 5 minute timer to search for a picture. After selecting an image the user shares their image with their friends on the application. The goal is to pick funny pictures related to the theme and try to find the best of your friends. If you manage to pick a picture within the 5 minute time limit, you will be able to give out awards or the equivalent of likes to 3 posts that day. A stretch goal is to allow users to customize their profile with accumulated awards or likes. If the user does not manage to choose a picture within 5 minutes, they will be able to post their piccy so that they can view others posts but they will not be able to give out awards. 

The application will be made using Xcode and coded in Objective-C over the course of a 5 week time period. This document will be used alongside this trello page to track the progress of the app. The wireframe of the app can be found here made using Figma.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Social Networking App
- **Mobile:** Mobile would be the perfect place for this app since almost everyone has a phone so there would be the maximum userbase here.
- **Story:** Allows users to create memories and funny stories to share with each other.
- **Market:** High school and college students, friend groups and families. 
- **Habit:** People will use it every day to have fun with their friends and family or compete with others.
- **Scope:** Version 1 would include the original mode and friend stats and profile and Version 2 can include the secondary mode and maybe more options.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User accounts
* User profiles 
* Daily Piccy Feature
* Searching an Image API
* User Retention
* Logging in
* Logging Out
* Registering for a new account
* Friends List
* Adding friends
* Forgot your password
* Home feed of posts from your friends
* Checking if user password was updated or if user is connected to internet
* Randomized Daily topic
* 5 minute timer 
* Posts on user profile
* Viewing other users profiles
* Daily reset
* Alerts and info for new users
* Nice UI that works on all modern iOS devices


**Optional Nice-to-have Stories**

* Liking/Awarding Feature
* Carousel profile page
* Recommended friends page
* Customized alerts 
* Reactions to posts
* User accessibility settings
* Profile customization with likes/awards
* Light Mode (I will be making the app in a Dark mode by default)
* Reporting users
* Sharing profiles with link/social media
* Sharing posts with link/social media
* Private accounts 


### 2. Screen Archetypes

* Login
   * Login page
* Register screen
* Profile
   * Profile/stats page
* Settings page
    * Settings
* Profile Settings page
* Home screen
* Friends adding screen
* Post details screen for comments
* Search for images screen 

### 3. Navigation

**Flow Navigation** (Screen to Screen)

* Login
   * Home
* Registration
   * Home
* Home
    * Image search/game
    * Post details screen
    * Friends
* Profile
    * Friends
    * Previous Piccys detail pages
    * Stats
    * Settings
* Settings 
    * User/Profile settings

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="YOUR_WIREFRAME_IMAGE_URL" width=600>

### [BONUS] Digital Wireframes & Mockups
https://www.figma.com/file/VxeEJ2MzsmHVj8qaYgGofa/Piccy?node-id=2%3A2
### [BONUS] Interactive Prototype
https://www.figma.com/file/VxeEJ2MzsmHVj8qaYgGofa/Piccy?node-id=2%3A2

## Schema 
### Models
 * Users
     * Usernames
     * Names
     * Password
     * Email - for updating password
     * Phone Number - for making sure there is only 1 account per person
     * Date of Birth - for making sure the user is old enough to view content that may be on the app
     * Friends List
     * Bio
  * Posts
     * Caption
     * Image
     * Comments array
     * Ratings array
  * Chat 
     * Users
     * Messages
### Networking
- Network Requests
  - Login/Register
      - Will request for user information or post user information
  - Home
      - Will request posts by your friends and maybe a profile picture for a profile button
      - Comments or ratings post to parse
  - Settings and profile
      - Will request the current users information
      - Settings will post user information as well
  - Friends page
      - Will request friend array
      - Will post new friend array if a friend is added
  - Post details page 
      - Will request details about a post 
      - Potentially posting comments or post to Parse
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
