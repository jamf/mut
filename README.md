# The MUT ![MUT Logo](https://imgur.com/hGAg9Ry.png "The MUT Logo") <!-- omit in TOC -->

_The **unofficial**, all-in-one mass update tool designed to be the perfect companion to Jamf Admins_

- [A note on v6:](#a-note-on-mut-and-v6)
- [Introduction:](#introduction)
- [What it is:](#what-it-is)
- [Steps for use:](#steps-for-use)
  - [Log in and verify credentials:](#log-in-and-verify-credentials)
  - [Download templates](#download-templates)
  - [Formatting your CSV](#formatting-your-csv)
      - [Object Updates](#object-updates)
        - [Single Attribute Updates](#single-attribute-updates)
        - [Multiple Attribute Updates](#multiple-attribute-updates)
        - [Enforcing Mobile Device Names](#enforcing-mobile-device-names)
        - [Updating Extension Attributes](#updating-extension-attributes)
        - [Clearing Existing Attribute Values](#clearing-existing-attribute-values)
      - [Static Group Updates](#static-group-updates)
      - [Prestage Scope Updates](#prestage-scope-updates)
      - [Classic Mode Group/Prestage Updates](#classic-mode-groupprestage-updates)
  - [Preflight and Preview](#preflight-and-preview)
  - [Send your updates](#send-your-updates)
- [Top Tips](#top-tips)

## [A note on MUT and v6:](#a-note-on-mut-and-v6)

Welcome to MUT v6. If you're familiar with MUT v5, and MUT Classic, MUT v6 will probably feel very familiar to you. If this is your first time here, I recommend you read the ReadMe in its entirety. 

**MUT is an incredibly powerful tool, and with great power comes great ability-to-break-things. Always, ALWAYS run a small test update on just a couple devices to make sure your updates are working as intended, and your scoping does not break due to the updates.**

## [Introduction:](#introduction)

Please note that The MUT is designed, built, and maintained outside of Jamf. It is not affiliated with Jamf, it is not officially maintained by Jamf. All of MUT was written on unpaid time, and any updates that are made to it are done in what little free time we have between work, school, kids, and hobbies.

This app is a learning project for us to learn how to use Xcode and program in Swift, and while we will do our best to maintain it, we cannot guarantee its functionality. If you find an issue, report it on the Issues page, and we will do our best to rectify the situation. 

## [What it is:](#what-it-is)

The MUT is a native macOS application written in Swift, which allows Jamf admins to make mass updates to attributes (such as username, asset tag, or extension attribute) of their devices and users in Jamf.

Admins can also make mass changes to static groups, and the scope of prestage enrollments via MUT.

![The MUT Main Screen](https://imgur.com/vY00wLc.png "The MUT Main Screen")

## [Steps for use:](#steps-for-use)

### [Log in and verify credentials:](#log-in)

MUT will perform checks on your credentials automatically when you log in. If it senses a problem with the credentials you provide, it will let you know what those problems are.

MUT performs these checks by generating a token for the new JPAPI. Any user is able to generate a token for the JPAPI, so there is no longer a need for the "bypass authentication" checkbox to exist. This checkbox has been changed to an "allow insecure SSL" checkbox. You can use this checkbox if you'd like to allow insecure SSL, but MUT will perform standard SSL checks per ATS by default.

### [Download templates](#download-templates)

When you first authenticate, you will be presented with a relatively simplistic screen, which will have a large button to download the CSV templates needed to use MUT. Note that these templates tend to change with MUT upgrades, in order to allow new features, so it is recommended that you re-download these templates after updates.

Upon pressing the Download CSV Templates button, MUT will ask you where you'd like to save the MUT Templates.zip. The MUT.log is no longer located in the Templates directory, and can now be found under the Settings menu at the top of the page.

![The MUT CSV Download Prompt](https://imgur.com/hOfgE3O.png "The MUT CSV Download Prompt")

### [Formatting your CSV](#format-csv)
##### [Object Updates](#objects)
In order to update information for an object (such as a computer or mobile device) in Jamf Pro, you will need to use the associated CSV template that MUT saved where you specified. For example, to update Computer objects, you will need to use the "ComputerTemplate.csv".

MUT performs verification checks against the header row of this CSV file, and it is very important that you do not modify the header row (such as deleting columns, or rearranging the columns) prior to uploading your CSV file. If you do, MUT will reject the file.

###### [Single Attribute Updates](#single-attribute)
One common use for MUT is to update single attributes, such as updating the username assigned to a set of devices, or populating the Asset Tag or Barcode for a device.

The most important thing to remember is that any cell left completely blank in your CSV will be ignored. Please note that a space is not the same as completely blank. There is a big difference between "" and " ".

If a field is going to be ignored in MUT, your preflight check will show the phrase "(unchanged)" in blue for that field.

If you wanted to update the Username on a set of devices, the CSV file would look like this (with more columns after the ellipsis.):

| Computer Serial | Display Name | Asset Tag | Barcode 1 | Barcode 2 | Username      | Real Name | ... |
| --------------- | ------------ | --------- | --------- | --------- | ------------- | --------- | --- |
| C13371337        |              |           |  1337   |           |  |           |     |

And MUT will display a screen such as the following when you run your pre-flight check:

![Single Attribute Updates](https://imgur.com/Qw4cHH4.png "Single Attribute Updates")


###### [Multiple Attribute Updates](#multiple-attributes)
Perhaps the MOST requested feature for MUT has been the ability to update multiple attributes at once. This feature is now available in MUT.

To update multiple attributes for an object at once, simply populate all of those fields in the CSV file. When you run your pre-flight check, you will be presented with all of the information that will be updating (and any blank fields will still display as "(unchanged)"). 

If you wanted to update the Asset Tag, Barcodes, Username, as well as Real Name on a set of devices, the CSV file would look like this (with more columns after the ellipsis.):

| Computer Serial | Display Name | Asset Tag | Barcode 1  | Barcode 2  | Username      | Real Name     | ... |
| --------------- | ------------ | --------- | ---------- | ---------- | ------------- | ------------- | --- |
| C1111111        |              | MUT-111   | 0123456789 | 0123456789 | mike.levenick | Mike Levenick |     |
| C2222222        |              | MUT-222   | 1234567890 | 1234567890 | ben.whitis    | Ben Whitis    |     |

And MUT will display a screen such as the following when you run your pre-flight check:

![Multiple Attribute Updates](https://imgur.com/EWdFvjp.png "Multiple Attribute Updates")

###### [Enforcing Mobile Device Names](#enforcing-mobile-device-names)
As of Jamf Pro 10.33, there is an endpoint which allows for the Enforce Name checkbox to be checked or unchecked via the Jamf Pro API.

MUT v6 can leverage this endpoint, and can allow you to either enforce or unenforce the name of your Mobile Device. There is a new "Enforce Name" field in the Mobile Devices template, and this field accepts a boolean value of TRUE or FALSE. 

These updates can be done on their own, or in combination with any other updates. To set a mobile device name and enforce that name, as well as update the Asset Tag, Barcode, and Username, your CSV would look something like this:

| Computer Serial | Display Name | Enforce Name | Asset Tag | Barcode 1  | Barcode 2  | Username      | ... |
| --------------- | ------------ | --------- | ---------- | ---------- | ------------- | ------------- | --- |
| C1111111        | Mikes iPhone | TRUE   | MUT-111 | 0123456789 |  | mike.levenick |     |
| C2222222        |Mikes iPad | TRUE   | MUT-222 | 1234567890 |  | ben.whitis    |     |

###### [Updating Extension Attributes](#extension-attributes)
MUT is also able to update Extension Attributes for a device or a user. In order to do this, you must first identify the Extension Attribute ID number. You can find this number in the URL while you are viewing an extension attribute in Jamf Pro's GUI under Settings (gear icon) > Computer Management > Extension Attributes > Click on the EA you want to update to bring it up.

For example, the EA ID of the displayed Extension Attribute here is "2".

![Extension Attribute ID 2](https://i.imgur.com/iO0Pyjs.png)

To update an Extension Attribute, simply add your own header for a new column **AFTER** all of the existing columns of your template, and put the string "EA_#" in the header, where # is the ID of the EA you would like to update.

For example, to update an Extension Attribute with the ID: "2", we would add a new column with header "EA_2", and then place the values for that EA in the column.

Your CSV would look something like this (Some columns have been removed simply to make it fit. Please DO NOT remove columns from your CSV):

| Computer Serial | Display Name | Asset Tag | Barcode 1  | ... | ... | Site (ID or Name) | EA_2      |
| --------------- | ------------ | --------- | ---------- | --- | --- | ----------------- | --------- |
| C1111111        |              | MUT-111   | 0123456789 |     |     |                   | New Value |
| C2222222        |              | MUT-222   | 1234567890 |     |     |                   | New Value |

And MUT will display a screen such as the following when you run your pre-flight check. Note the new field added at the bottom with EA_2. Also note that you will need to scroll down in the right hand window in order to see all of the fields that MUT can update now. There are quite a few!:

![Extension Attribute Updates](https://imgur.com/GhB7y0G.png "Extension Attribute Updates")

###### [Clearing Existing Attribute Values](#clearing-attributes)
Another common workflow with MUT is to clear out existing attributes. This happens for example in situations where a group of devices are being redistributed to new users, or retired, and need the username and related information cleared off of them.

Because MUT ignores blank fields in your CSV now, a specific string must be used to tell MUT to clear values. This string is currently "CLEAR!" (with exclamation point, without quotes.) In the Preflight GUI, MUT will display the string "WILL BE CLEARED" in all red, to let you know that the field is being cleared.

If you wanted to clear user information from a device, your CSV would look something like this (with more columns after the ellipsis.):

| Computer Serial | Display Name | Asset Tag | Barcode 1  | Barcode 2  | Username | Real Name | ... |
| --------------- | ------------ | --------- | ---------- | ---------- | -------- | --------- | --- |
| C1111111        |              | MUT-111   | 0123456789 | 0123456789 | CLEAR!   | CLEAR!    |     |
| C2222222        |              | MUT-222   | 1234567890 | 1234567890 | CLEAR!   | CLEAR!    |     |

And MUT will display a screen such as the following when you run your pre-flight check (I went a little bit overboard with clearing values for this screenshot...):

![Clear Attribute Values](https://imgur.com/lrCSwp6.png "Clear Attribute Values")

##### [Static Group Updates](#groups)
MUT v6 is able to update the contents of a Static Group (computers, mobile devices, or users). It is able to either add objects to a group, remove objects from a group, or replace the entire current contents of that group.

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

But let's pretend our group number was 1337; to add the devices in question to Computer Static Group 1337, your MUT GUI would look like this:

![Static Group Update](https://imgur.com/BsDX0IH.png "Static Group Update")

##### [Prestage Scope Updates](#prestages)
One of the new features of MUT v6 is the ability to modify the scope of prestages. This feature REQUIRES Jamf Pro v10.14+ in order to function properly.

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

![Prestage 1 Update](https://imgur.com/6Q5RP1d.png "Prestage 1 Update")

##### [Classic Mode Group/Prestage Updates](#classic-mode-groupprestage-updates)
The MUT v5 used a new method to update groups and prestages. This new method was far more efficient, but required the CSV to be perfect. Any lines with devices that were already in scope, or no longer in the environment would cause the entire update run to fail. Because of this, MUT Classic was made available, which updated group or prestage line-by-line, just as MUT v4 did.

These line-by-line submissions are far less efficient, and take significantly longer, but if there is a bad line in the CSV, MUT will simply skip over it and move on.

Now, in MUT v6, you get the best of both worlds. MUT v6 will initially attempt the new, more efficient update method, but on the off chance that it fails, you will be presented with the option to attempt a "Classic Mode" update.

![Classic mode prompt](https://imgur.com/7YF7Mtr.png "Classic mode prompt")

It is important to note that incorrect lines will still fail with this Classic Mode, but those lines will be reported in the MUT.log for later review, and any other lines will still go through successfully.

It is important to note that Classic Mode is not compatible with "Replace" update attempts via MUT, as the entire Group or Prestage would simply be replaced with the last working line of the CSV. 

![Classic mode cannot do replace](https://imgur.com/3TbREuN.png "Classic mode cannot do replace")

### [Preflight and Preview](#preflight)
Veterans of MUT are likely used to needing to run a PreFlight Check prior to every update, and then reviewing the information prior to submitting.

PreFlight Checks in v6 for Object Attribute updates now happen as soon as you upload your CSV. If there is an issue with your CSV file, you will be alerted as soon as you attempt to upload it. MUT should also not let you run any updates if your CSV contains errors.

Preflight Checks in v6 for group and prestage scope updates will happen partly when you upload the CSV, but you must run a separate PreFlight Check once you have populated the dropdowns and identifier boxes. The Submit Updates button will not appear until you have populated those fields, and then run the PreFlight Check.

### [Send your updates](#send-your-updates)
It is STRONGLY recommended that you do a small, test update of just a couple devices before making mass updates with MUT--especially if you are new to the tool.

Once you are confident in the updates to be submitted to your Jamf Pro server, you can hit the "Submit Updates" button.

Very little status/result information is displayed in the main GUI of MUT. You will now find a MUT.log by heading to the Settings menu at the top of your screen. This new log file contains much more verbose information about the status of your updates, and should help with troubleshooting significantly.

The log file looks a bit like this:

![MUT.log](https://i.imgur.com/nJruxUe.png)

## [Top Tips](#top-tips)

* There is an option in the top Menu Bar under "Settings" to change the character which separates items on your CSV file to either a comma (,) or a semicolon (;). This is especially useful for international folks who delimit their CSV files by semicolon by default, or for folks who wish to include commas in their attribute values.
* There is an option in the top Menu Bar under "Settings" to clear any stored values that you may have by default, including Delimiter, Username, and your server URL.
* MUT attempts to determine if you are using Usernames or User IDs for user updates, by checking if Column A contains Integers--but on the chance that your usernames are integers (which happens most often if an Employee ID or Student ID is also the Username) MUT can get confused. If this is the case in your environment, select "My Usernames are Ints" from the settings menu
