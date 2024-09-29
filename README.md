# Ambulert

## Inspiration
An estimated 6,500 ambulance-related accidents occur annually. Thats 6,500 accidents too many. Traffic slows down the rescue process and could potentially make the difference between life and death. To reduce the possibility of further accidents happening, it would be better if users were better alerted to the ambulance's precense within their vicinity

## What it does
Notifies civilians in the proxmimity of an ambulance during an emergency. Does this by taking location of civilian and the location of the ambulance which gets registered when there is an ambulance.

## How we built it
App will use geolocation of user device and ambulance device to evaluate proximity Pushes persistent notification to users within 1.0km of an ambulance to steer clear until ambulance is out of range

## Project Components
Flutter (Front-end) UI: indicates whether or no there’s an ambulance nearby Send push notification in the background if there’s an incoming ambulance (user-side) Flask (Back-end) Set up API to compare user’s location with the ambulance Ambulance side takes location of vehicle and makes post request

## Accomplishments that we're proud of
Our application can successfully request the location of the phone and the notification system works properly

## What we learned
- How to send push notifications
- Receive Location from devices
- Basics of a mobile app

## What's next for Ambulert
- Adding a more sophisticated GUI with more features

## Made With
- Azure
- Dart
- Flask
- Flutter
- Python
- Vincenty
