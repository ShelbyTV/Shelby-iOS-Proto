# Shelby.tv iOS App

## General Code Structure

### XCode Hierarchy
- Shelby
  - App - app initialization and ShelbyWindow (UIWindow subclass)
  - API - code for talking to Shelby backend API server
  - iPad - iPad-specific subclasses of major pieces (where if checks don't make sense)
  - iPhone - iPhone-specific subclasses of major pieces (where if checks don't make sense)
  - Core Data - Core Data model files, with some JSON-loading helper methods included
  - Video - main backend in-memory data object - processes Core Data broadcasts and creates Videos.
  - Supporting Files - other miscellaneous files
  - Utility - various helper objects, including Shelby stats helpers
  - ViewControllers - main frontend business logic / user interaction logic
  - Views - mostly concerned with UI / presentation
    - Auxiliary - small helper views for gradients, disabling clicks
    - VideoGuide - view subclasses for each of the 4 main video table options
    - VideoPlayer - everything to display a video and video controls
- Resources
  - NIBs
    - Common - only contains TouchPlay remote mode help cell NIB, common for iPad and iPhone
    - TV - control bar and title bar in both 720p and 1080p layouts for TouchPlay
    - iPad - iPad-specific versions of all UI screens (that don't require code manipulation)
    - iPhone - iPhone-specific versions of all UI screens (that don't require code manipulation)
  - Images
    - Refresh - images for pull down to refresh 
    - RemoteMode - images for TouchPlay remote mode
    - Common - stripes, common icons for timeline, favorites, watch later
    - Login - images for the login screen
    - Logo - variations on the Shelby logo for various places
    - Settings - user settings screen images
    - Sharing - sharing screen images
    - User - images for the little user status in upper right of main nav screen
    - VideoPlayerControls
      - TV - 720p and 1080p versions of TouchPlay video-playing-related images
      - iPhone - video player controls for iPhone
      - iPad - video player controls for iPad
      - Common - progress bar slider images, left/right arrows overlaid on videos
    - VideoTableCell - images displayed within video table cells
    - VideoTableControls - old images for previous version of tab bar (can probably be deleted)
- Libraries
  - EGOTableViewPullRefresh - Shelby.tv fork / submodule of pull to refresh. our changes are just UI-related
  - JSON-Framework - submodule for JSON parsing, unmodified
  - OAuth - Shelby.tv fork / submodule for OAuth protocol, slighty modified to deal with compiler warnings
  - Reachability - copied from Apple's example, detects when Internet, WiFi isn't working
  - UICustomSwitch - copy of code intended for settings screen. not used yet (can probably be deleted)

### (Intended) Logical Structure / Important Pieces

#### Navigation Controller

This is supposed to be the main ViewController that should handle most high-level logic, handle user button touches, etc.

In both iPhone and iPad, the NavigationController is in charge of what you see on the screen. It is never hidden, though other views may be overlaid on top of it.

On iPad, the Navigation Controller most of the time shows you the VideoGuide and the VideoPlayer. On iPhone, it shows you *either* the VideoGuide or VideoPlayer, since there's not enough space to show both at the same time.

#### API-related Objects

DataAPI and BroadcastAPI classes allow communication with Shelby backend servers. This is how we get and interact with Broadcasts (Videos) coming from the Shelby backend.

#### Video / Video Data

Broadcasts from Shelby backend are stored in CoreData as Broadcasts (with Sharer and Thumbnail images also stored for network / performance optimization). These are loaded from CoreData and into in-memory data structures known as Videos.

There are a lot of classes for dealing with Videos, organizing them for display in VideoTables, etc. This is the most complicated part of the app for sure.

This also includes the VideoContentURLGetter, which is the sketchiest part of the app. Lots of superlatives for Videos.

#### VideoPlayer

This is responsible for taking a video, showing it, displaying info about a video, and allowing a user to control the video.

In TouchPlay, VideoPlayer gets a little more complicated, with differents part of the UI on different UIScreens and some parts (video info UI) duplicated on both UIScreens.

#### VideoGuide

This contains the actual video table. There are currently 4 subclasses, one for each option: Timeline, Favorite, Watch Later, and Search.

#### Login

This gets overlaid on the NavigationController for user login.

#### Sharing

This is just overlaid on the NavigationController / VideoPlayer also. Sharing is only complicated because on iPhone, we don't have tons of screen space, so it's a multi-step dialog.

Also, we use a somewhat complicated class taken from a guy on github to do email address book lookups / completion.

#### Settings

This is a fairly simple screen that slides in and is overlaid on top of the VideoGuide portion of the screen.

### App Flow

#### App Startup
- App initialized, objects instantiated
- Session stats reporting started
- LoginController presented
- User types in Facebook / Twitter
  - OAuth dance performed with Shelby
  - User data, authentications, channel, etc. acquired. Old data model was User -> Channel -> Broadcasts
- Kick off initial Broadcast retrieval to be stored in CoreData
- Kick off timer to periodically poll for new Broadcasts
- When initial broadcasts are present in CoreData, callback starts process of creating Videos
  - De-dupes Videos, determines which Videos are playable, downloads thumbnail and sharer images for them
  - Updates video tables (somewhat throttled by a timer for performance) to match Video list
- Now mostly driven by user UI events

#### Video Selection
- User taps video
- First time, video gets sent to VideoContentURLGetter to get MP4 URL
  - VideoContentURLGetter loads video in invisible UIWebView and signs up for notifications
  - Gets a notification containing an AVPlayerItem that supports 'path' selector
  - Calls 'path' selector, gets MP4 path, terminates video loading
  - Notifies VideoPlayer that a new content URL is available for a video
- VideoPlayer receives notification, checks to see if video is correct, if so loads content URL and plays

#### Data Polling / New Videos Handling
- Polling Timer 1
  - contacts API for Broadcasts
  - Response received - store new Broadcasts in CoreData (also update existing Broadcasts if different, though this usually doesn't happen / doesn't notify app of changes or reflect changes in Video)
  - Video Data Poller goes through and schedules video playability checks for any new Videos
- Polling Timer 2
  - Checks to see if any new playable videos have been found
  - Examines any of the first new max-videos-for-device-RAM to see if the vids are either completely new or just new comments on existing videos
  - Sends out a notification of any new videos / comments that gets noticed / displayed by UI
- Pull to Refresh
  - calls same logic as initial load of broadcasts to populate Video arrays, dupes
  - here we'll probably also need to remove some older videos if we're beyond max-videos-for-device-RAM
  - the updates to video tables here have to both add new videos/comments and remove old ones; incremental table updates, not just data refresh...

## Major Version Changelog

### 1.6 - Early-Mid April 2012
- re-architected backend data layer
- in-app notifications of new videos and comments on existing videos
- re-vamped sharing UI
- re-vamped pull-to-refresh UI

### 1.5 - Early February 2012
- TouchPlay
- iPhone guide UI changed to match iPad / ability to expand comments in guide
- new guide tab bar for both iPhone and iPad
- local search added for both iPhone and iPad (search channel icon added for TouchPlay)
- Tumblr support added back in (including sharing)
- zoom transition added for iPhone guide <-> video
- loading time improvements (caching playable status)
- demo mode for beta builds

### 1.4 - Unreleased - January 2012
- CES build contain prototype TouchPlay and demo mode

### 1.3 - Mid December 2011
- new video controls
- new video info layout
- new login screens
- new sharing screens with tweet counter / email address book functionality
- fixed the prepending of "@" onto twitter usernames that was a bug in 1.2

### 1.2 - Mid November 2011
- lots of cleanup, stability improvements, small bug fixes
- ability to play Vimeo videos
- swipe player to change videos
- faster login / video table display / video loading
- limit videos stored / displayed based on device RAM; fixes power user problems
- support for in-app webviews for login without switching to Mobile Safari
- basic Airplay enabled
- settings UI for legal / service addition
- support for setting/unsetting watch later, auto unset of watch later at 75%
- time display fix for future times
- removed all UI references to Tumblr for now
- detect playable videos and only show those
- highlight currently playing video in guide
- incorporate crashlytics

### 1.1 - Mid-Late October 2011

- first released version
- video de-duplication / comment unrolling on iPad
- sharing, account addition
- youtube only

### 1.0 - Unreleased - Early October 2011

- initial upload to Apple to make sure we'd be accepted
- basic iPhone and iPad functionality
- lacking pieces of sharing, account addition, etc.