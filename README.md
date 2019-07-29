# The MUT ![MUT Logo](https://i.imgur.com/g6XHGto.png "The MUT Logo") <!-- omit in TOC -->

_The **unofficial**, all-in-one mass update tool designed to be the perfect companion to Jamf Admins_

- [A note on v5:](#a-note-on-v5)
- [Introduction:](#introduction)
- [What it is:](#what-it-is)
- [Steps for use:](#steps-for-use)
  - [Log in and verify credentials:](#log-in-and-verify-credentials)
  - [Download templates](#download-templates)
  - [Formatting your CSV](#formatting-your-csv)
      - [Object Updates](#object-updates)
        - [Single Attribute Updates](#single-attribute-updates)
        - [Multiple Attribute Updates](#multiple-attribute-updates)
        - [Updating Extension Attributes](#updating-extension-attributes)
        - [Clearing Existing Attribute Values](#clearing-existing-attribute-values)
      - [Static Group Updates](#static-group-updates)
      - [Prestage Scope Updates](#prestage-scope-updates)
  - [Preflight and Preview](#preflight-and-preview)
  - [Send your updates](#send-your-updates)
- [Top Tips](#top-tips)

## [A note on v5:](#v5)

Welcome to MUT v5. There are a LOT of changes to v5, and even if you are MUT Veteran we encourage you to read the ReadMe, and watch a video or two if you have any questions.

MUT v5 is **significantly** more powerful than v4, but with great power comes great responsibility. It is very important that you format your CSV properly, and do not modify the header row of the provided templates.

## [Introduction:](#introduction)

Please note that The MUT is designed, built, and maintained outside of Jamf. It is not affiliated with Jamf, it is not officially maintained by Jamf.

This app is a learning project for us to learn how to use Xcode and program in Swift, and while we will do our best to maintain it, we cannot guarantee its functionality.

## [What it is:](#what-it-is)

The MUT is a native macOS application written in Swift 5 which allows Jamf admins to make mass updates to attributes (such as username, asset tag, or extension attribute) of their devices and users in Jamf.

Admins can also make mass changes to static groups, and the scope of prestage enrollments via MUT.

## [Steps for use:](#steps-for-use)

### [Log in and verify credentials:](#log-in)

MUT v5 will perform checks on your credentials automatically when you log in. If it senses a problem with the credentials you provide, it will let you know what those problems are.

MUT v5 performs these checks by generating a token for the new JPAPI. Any user is able to generate a token for the JPAPI, so there is no longer a need for the "bypass authentication" checkbox to exist. This checkbox has been changed to an "allow insecure SSL" checkbox, but MUT will perform standard SSL checks per ATS by default.

### [Download templates](#download-templates)

When you first authenticate, you will be presented with a relatively simplistic screen, which will have a large button to download the CSV templates needed to use MUT v5.

Upon pressing the button, MUT will create a directory called "MUT Templates" inside your Downloads directory, and will place inside that directory all of the templates needed--as well as the new MUT.log.

### [Formatting your CSV](#format-csv)
##### [Object Updates](#objects)
In order to update information for an object (such as a computer or mobile device) in Jamf Pro, you will need to use the associated CSV template that MUT placed in ~/Downloads/MUT Templates/. For example, to update Computer objects, you will need to use the "ComputerTemplate.csv".

MUT performs verification checks against the header row of this CSV file, and it is very important that you do not modify the header row (such as deleting columns, or rearranging the columns) prior to uploading your CSV file. If you do, MUT will reject the file.
###### [Single Attribute Updates](#single-attribute)
One of the most common uses for MUT is to update single attributes, such as updating the username assigned to a set of devices, or populating the Asset Tag or Barcode for a device.

The most important thing to remember is that any cell left completely blank in your CSV will be ignored. Please note that a space is not the same as completely blank. There is a big difference between "" and " ".

If a field is going to be ignored in MUT, your preflight check will show the phrase "(unchanged)" in blue for that field.

If you wanted to update the Username on a set of devices, the CSV file would look like this (with more columns after the ellipsis.):

| Computer Serial | Display Name | Asset Tag | Barcode 1 | Barcode 2 | Username      | Real Name | ... |
| --------------- | ------------ | --------- | --------- | --------- | ------------- | --------- | --- |
| C1111111        |              |           |           |           | mike.levenick |           |     |
| C2222222        |              |           |           |           | ben.whitis    |           |     |

And MUT will display a screen such as the following when you run your pre-flight check:

![Single attribute update](https://i.imgur.com/57LgeXD.png)


###### [Multiple Attribute Updates](#multiple-attributes)
Perhaps the MOST requested feature for MUT has been the ability to update multiple attributes at once. This feature is now available in MUT v5.

To update multiple attributes for an object at once, simply populate all of those fields in the CSV file. When you run your pre-flight check, you will be presented with all of the information that will be updating (and any blank fields will still display as "(unchanged)"). 

If you wanted to update the Asset Tag, Barcodes, Username, as well as Real Name on a set of devices, the CSV file would look like this (with more columns after the ellipsis.):

| Computer Serial | Display Name | Asset Tag | Barcode 1  | Barcode 2  | Username      | Real Name     | ... |
| --------------- | ------------ | --------- | ---------- | ---------- | ------------- | ------------- | --- |
| C1111111        |              | MUT-111   | 0123456789 | 0123456789 | mike.levenick | Mike Levenick |     |
| C2222222        |              | MUT-222   | 1234567890 | 1234567890 | ben.whitis    | Ben Whitis    |     |

And MUT will display a screen such as the following when you run your pre-flight check:

![Multiple attribute update](https://i.imgur.com/5eZcX0C.png)

###### [Updating Extension Attributes](#extension-attributes)
MUT is also able to update Extension Attributes for a device or a user. In order to do this, you must first identify the Extension Attribute ID number. You can find this number in the URL while you are viewing an extension attribute in Jamf Pro's GUI under Settings (gear icon) > Computer Management > Extension Attributes > Click on the EA you want to update to bring it up.

For example, the EA ID of the displayed Extension Attribute here is "2".

![Extension Attribute ID 2](https://i.imgur.com/iO0Pyjs.png)

To update an Extension Attribute, simply add your own header for a new column **AFTER** all of the existing columns of your template, and put the string "EA_#" in the header, where # is the ID of the EA you would like to update.

For example, to update an Extension Attribute with the ID: "5", we would add a new column with header "EA_5", and then place the values for that EA in the column.

Your CSV would look something like this (Some columns have been removed simply to make it fit. Please DO NOT remove columns from your CSV):

| Computer Serial | Display Name | Asset Tag | Barcode 1  | ... | ... | Site (ID or Name) | EA_5      |
| --------------- | ------------ | --------- | ---------- | --- | --- | ----------------- | --------- |
| C1111111        |              | MUT-111   | 0123456789 |     |     |                   | New Value |
| C2222222        |              | MUT-222   | 1234567890 |     |     |                   | New Value |

And MUT will display a screen such as the following when you run your pre-flight check (note the new field added at the bottom with EA_5):

![Extension Attribute Updates](https://i.imgur.com/o3oz0AH.png)

###### [Clearing Existing Attribute Values](#clearing-attributes)
Another common workflow with MUT is to clear out existing attributes. This happens for example in situations where a group of devices are being redistributed to new users, or retired, and need the username and related information cleared off of them.

Because MUT ignores blank fields in your CSV now, a specific string must be used to tell MUT to clear values. This string is currently "CLEAR!" (with exclamation point, without quotes.) In the Preflight GUI, MUT will display the string "WILL BE CLEARED" in all red, to let you know that the field is being cleared.

If you wanted to clear user information from a device, your CSV would look something like this (with more columns after the ellipsis.):

| Computer Serial | Display Name | Asset Tag | Barcode 1  | Barcode 2  | Username | Real Name | ... |
| --------------- | ------------ | --------- | ---------- | ---------- | -------- | --------- | --- |
| C1111111        |              | MUT-111   | 0123456789 | 0123456789 | CLEAR!   | CLEAR!    |     |
| C2222222        |              | MUT-222   | 1234567890 | 1234567890 | CLEAR!   | CLEAR!    |     |

And MUT will display a screen such as the following when you run your pre-flight check:

![Clear attributes from computers](https://i.imgur.com/Kgw5jEY.png)

##### [Static Group Updates](#groups)
MUT v5 is able to update the contents of a Static Group (computers, mobile devices, or users). It is able to either add objects to a group, remove objects from a group, or replace the entire current contents of that group.

In order to do this, your CSV file should contain nothing but a single column of identifiers for the objects to be added, removed, or replaced in the scope of that group. This identifier can be either Serial Number or ID for computers and mobile devices, or Username or ID for users.

Your CSV file should look like this:

| Serial Numbers or Usernames |
| --- |
| C1111111 |
| C2222222 |
| C3333333 |
| C4444444 |
| C5555555 |

When you upload this CSV to MUT, you will be taken to a slightly different screen which contains dropdowns. These dropdowns are how you will select what action to take place. It also contains a box, where you must put the ID of the static group to be modified. This ID can be found in the URL while viewing the group to be modified.

For example, the Group ID for the following group is "3".

![Group ID](https://i.imgur.com/5iAawXe.png)

To add the devices in question to Computer Static Group 3, your MUT GUI would look like this:

![Group 3 Update](https://i.imgur.com/STg89Yu.png)

##### [Prestage Scope Updates](#prestages)
One of the new features of MUT v5 is the ability to modify the scope of prestages. This feature REQUIRES Jamf Pro v10.14+ in order to function properly.

In order to do this, your CSV file should contain nothing but a single column of identifiers for the objects to be added, removed, or replaced in the scope of that prestage. This identifier can be either Serial Number or ID for computers and mobile devices.

Your CSV file should look like this:

| Serial Numbers or Usernames |
| --- |
| C1111111 |
| C2222222 |
| C3333333 |
| C4444444 |
| C5555555 |

When you upload this CSV to MUT, you will be taken to a slightly different screen which contains dropdowns. These dropdowns are how you will select what action to take place. It also contains a box, where you must put the ID of the prestage to be modified. This ID can be found in the URL while viewing the prestage to be modified.

For example, the Prestage ID for the following group is "1".

![Prestage ID](https://i.imgur.com/B87eWPT.png)

To add the devices in question to Prestage 1, your MUT GUI would look like this:

![Prestage 1 Update](https://i.imgur.com/4pXMvrc.png)

### [Preflight and Preview](#preflight)
Veterans of MUT are likely used to needing to run a PreFlight Check prior to every update, and then reviewing the information prior to submitting.

PreFlight Checks in v5 for Object Attribute updates now happen as soon as you upload your CSV. If there is an issue with your CSV file, you will be alerted as soon as you attempt to upload it. MUT should also not let you run any updates if your CSV contains errors.

Preflight Checks in v5 for group and prestage scope updates will happen partly when you upload the CSV, but you must run a separate PreFlight Check once you have populated the dropdowns and identifier boxes. The Submit Updates button will not appear until you have populated those fields, and then run the PreFlight Check.

### [Send your updates](#send-your-updates)
Once you are confident in the updates to be submitted to your Jamf Pro server, you can hit the "Submit Updates" button.

Updates to groups and prestages now happen all in one upload. There is no longer an API call per device being added or removed, so the strain on your server should be significantly less.

Updates to Object Attributes will need to be run individually, and a progress bar should appear as soon as you hit Submit, which will give you insight into the updates being run.

Very little status/result information is displayed in the main GUI of MUT v5. You will now find a MUT.log in ~/Downloads/MUT Templates/MUT.log. This new log file contains much more verbose information about the status of your updates, and should help with troubleshooting significantly.

The log file looks a bit like this:

![MUT.log](https://i.imgur.com/nJruxUe.png)

## [Top Tips](#top-tips)

*   There is an option in the top Menu Bar under "Settings" to change the character which separates items on your CSV file to either a comma (,) or a semicolon (;). This is especially useful for international folks who delimit their CSV files by semicolon by default, or for folks who wish to include commas in their attribute values.
*   There is an option in the top Menu Bar under "Settings" to clear any stored values that you may have by default, including Delimiter, Username, and your server URL.