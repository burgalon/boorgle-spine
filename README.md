# Boorgle
Boorgle is a way to be sure that the details of your contacts are always up to date.
Simply because each contact can update his own phone number, mail and address.
Now there is no need to send mass emails notifying your friends of new number or calling to ask the address when sending flowers. Your contacts and friends will always have your number and full details that you have provided.
Boorgle pushes all the updates to your GMail account so your native device address book is synched.

## This source
Boorgle mobile app is built with [Spine](http://spinejs.com/) - a Coffeescript MVC framework.
The app can be served as a mobile web app by pushing to a [Heroku](http://www.heroku.com/) server running [NodeJS](http://nodejs.org/).
Alternatively, that app can be wrapped with [Cordova](http://docs.phonegap.com/en/2.2.0/index.html) (formely known as Phonegap) to create native iOS iTunes applications or Android Google play.

The Phonegap wrappers are also available as opensource here:
* iOS - https://github.com/burgalon/boorgle-cordova-ios - [Download from iTunes](https://itunes.apple.com/us/app/boorgle/id579190662?ls=1&mt=8)
* Android - https://github.com/burgalon/boorgle-cordova-android - [Download from Google Play](http://play.google.com/store/apps/details?id=com.boorgle.app)

## Notable code
Here are some of the features which you might find helpful to re-use:
* [OAuth authentication](https://github.com/burgalon/boorgle-spine/blob/master/app/authorization.coffee) (see note below) and error handling
* Model hooks and RESTful API
* iOS look and feel
* Custom URL schemes for launching the app from external browser
* [Pubsub](https://github.com/burgalon/boorgle-spine/blob/master/app/controllers/user_edit.coffee#L169) for pushing data to clients
* Support Android 2.2/3 [overflow scroll](https://github.com/burgalon/boorgle-spine/blob/master/app/controllers/base_panel.coffee#L6) using [Overthrow](http://filamentgroup.com/lab/overthrow)

## Dependencies
* NodeJS
* SpineJS
* NPM
* Corodova (Phonegap)

## Installation
    git clone git@github.com:burgalon/boorgle-spine.git
    cd boorgle-spine
    npm install

## Running
    hem server

## Opensource
The app has been opensourced under MIT license

## Historical note
Boorgle contains some historical commits to suit it to [Trigger.io](https://trigger.io/) platform which enables creating native apps in the cloud.
The last code commit which supports Trigger.io is available under the tag 'triggerio-before-phonegap'
