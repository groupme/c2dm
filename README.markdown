# C2DM - Google Cloud to Device Messaging Service

c2dm sends push notifications to Android devices via Google [c2dm](http://code.google.com/android/c2dm/index.html).

## Installation

    $ gem install c2dm
    
## Requirements

An Android device running 2.2 or newer, its registration token, and a Google account registered for c2dm.

## Configuration

First you will need to authorize with google to get your ClientLogin auth token.

Use the credentials for the app you've registered with Google.

    C2DM.authorize("pat@gmail.com", "password")
    
This sets `auth_token` for future requests.

You can also use cURL to get the AUTH= parameter:

    # curl -X POST https://www.google.com/accounts/ClientLogin -d Email=<email> -d Passwd=<password> -d accountType=HOSTED_OR_GOOGLE -d service=ac2dm

We suggest you store the token and set it in your config files:

    C2DM.auth_token = "YOUR_AUTH_TOKEN"

You can also set it in your environment:

    ENV["C2DM_AUTH_TOKEN"] = "YOUR_AUTH_TOKEN"

## Send a notification

Send a single notification:

    C2DM.send_notification({
      :registration_id => "...",
      :message => "Hi!",
      :extra_data => 42,
      :collapse_key => "some-collapse-key"
    })
    
The only required key is `:registration_id`. You may also pass 
`:collapse_key`, but it's optional. 

All other keys will be sent as `"data.<key>"`. This is the payload of your notification.


## Sending Multiple

You can also send multiple notifications at once.

    notifications = [
      {
        :registration_id => "...", 
        :message => "Hi!",
        :extra_data => 42
      },
      {
        :registration_id => "...", 
        :message => "Bye!",
        :extra_data => "BOOM",
        :collapse_key => "some-collapse-key"
      },
      ...
    ]
    
    C2DM.send_notifications(notifications)

## TODO

* Send multiple notifications concurrently using Typhoeus::Hyrda

## Copyrights

* Copyright (c) 2010 Amro Mousa, (c) 2011 Brandon Keene. See LICENSE.txt for details.