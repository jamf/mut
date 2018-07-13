<div id="readme" class="readme blob instapaper_body">
    <article class="markdown-body entry-content" itemprop="text"><h1><a id="user-content-the-mut----" class="anchor" aria-hidden="true" href="#the-mut----"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>The MUT    <a target="_blank" href="https://camo.githubusercontent.com/fc8094bb245db3aed908c5383b3f1efc28b5471c/687474703a2f2f6d2d6c65762e636f6d2f696d672f36342e706e67"><img src="https://camo.githubusercontent.com/fc8094bb245db3aed908c5383b3f1efc28b5471c/687474703a2f2f6d2d6c65762e636f6d2f696d672f36342e706e67" alt="MUT Logo" title="The MUT Logo" data-canonical-src="http://m-lev.com/img/64.png" style="max-width:100%;"></a></h1>
<p><em>The <strong>unofficial</strong>, all-in-one mass update tool designed to be the perfect companion to Jamf Admins</em></p>
<ul>
<li><a href="#introduction">Introduction</a></li>
<li><a href="#what-it-is">What it is</a></li>
<li><a href="#steps-for-use">Steps For use</a>
<ul>
<li><a href="#format-your-csv">Format your CSV</a>
<ul>
<li><a href="#examples-of-good-csv">Examples of GOOD CSV</a></li>
<li><a href="#examples-of-bad-csv">Examples of BAD CSV</a></li>
</ul>
</li>
<li><a href="#verify-your-credentials">Verify your credentials</a></li>
<li><a href="#prepare-for-your-updates">Prepare for your updates</a></li>
<li><a href="#send-your-updates">Send your updates</a></li>
</ul>
</li>
<li><a href="#top-tips">Top tips</a></li>
<li><a href="#advanced-workflows">Advanced workflows</a>
<ul>
<li><a href="#create-multiple-users-en-masse">Create multiple users en masse</a></li>
<li><a href="#remove-users-from-devices-en-masse">Remove users from devices en masse</a></li>
</ul>
</li>
</ul>
<h2><a id="user-content-introduction" class="anchor" aria-hidden="true" href="#introduction"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Introduction:</h2>
<p>Please note that The MUT is designed, built, and maintained outside of Jamf. It is not affiliated with Jamf, it is not officially maintained by Jamf.</p>
<p>This app is a learning project for me to learn how to use Xcode and program in Swift, and while I will do my best to maintain it, I cannot guarantee its functionality.</p>
<p><strong>If you are having trouble with your CSV not parsing properly, and you are exporting your CSV from Excel, try using "Windows Comma Separated (.csv)".</strong> Windows Comma Separated uses a slightly different linebreak character, which can sometimes play nicer with the CSV parsing functions in The MUT.</p>
<h2><a id="user-content-what-it-is" class="anchor" aria-hidden="true" href="#what-it-is"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>What it is:</h2>
<p>The MUT is a native macOS application written in Swift 3 which allows Jamf admins to make mass updates to attributes (such as username, asset tag, or extension attribute) of their devices and users in Jamf.</p>
<p>Admins can enter the URL for their Jamf server (whether cloud hosted or on-premise), a username and password for The MUT to use, select the device type, attribute type, and unique identifier type from dropdowns, and browse to their CSV file. A pre-flight check will give a preview of the actions to be taken, and then the admin can submit their updates.</p>
<h2><a id="user-content-steps-for-use" class="anchor" aria-hidden="true" href="#steps-for-use"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Steps for use:</h2>
<h3><a id="user-content-format-your-csv" class="anchor" aria-hidden="true" href="#format-your-csv"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Format your CSV</h3>
<ol>
<li>Fill out Column A with the unique identifiers to be used (serial numbers or Jamf ID numbers)</li>
<li>Fill out Column B with the values for the attributes to be updated</li>
<li>Headers are optional. If you include them, The MUT will throw a 404 on line 1, but it will ignore this error and continue updating the rest of the rows</li>
<li>If you are looking to strip values off of devices (such as removing the username from all of your iPads) you can include a header row so that The MUT knows the column exists, and then leave the rest of Column B blank. This will strip set the value for that attribute to null</li>
</ol>
<h3><a id="user-content-examples-of-good-csv" class="anchor" aria-hidden="true" href="#examples-of-good-csv"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Examples of GOOD CSV</h3>
<h4><a id="user-content-good-csv-with-headers" class="anchor" aria-hidden="true" href="#good-csv-with-headers"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Good CSV With Headers</h4>
<table>
<thead>
<tr>
<th>Serial</th>
<th>Username</th>
</tr>
</thead>
<tbody>
<tr>
<td>C111111</td>
<td>mike.levenick</td>
</tr>
<tr>
<td>C222222</td>
<td>john.smith</td>
</tr>
<tr>
<td>C333333</td>
<td>jane.smith</td>
</tr></tbody></table>
<h4><a id="user-content-good-csv-without-headers" class="anchor" aria-hidden="true" href="#good-csv-without-headers"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Good CSV Without Headers</h4>
<table>
<thead>
<tr>
<th>C111111</th>
<th>mike.levenick</th>
</tr>
</thead>
<tbody>
<tr>
<td>C222222</td>
<td>john.smith</td>
</tr>
<tr>
<td>C333333</td>
<td>jane.smith</td>
</tr></tbody></table>
<h4><a id="user-content-good-csv-for-removing-usernames" class="anchor" aria-hidden="true" href="#good-csv-for-removing-usernames"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Good CSV for Removing Usernames</h4>
<table>
<thead>
<tr>
<th>Serial</th>
<th>Username</th>
</tr>
</thead>
<tbody>
<tr>
<td>C111111</td>
<td></td>
</tr>
<tr>
<td>C222222</td>
<td></td>
</tr>
<tr>
<td>C333333</td>
<td></td>
</tr></tbody></table>
<h3><a id="user-content-examples-of-bad-csv" class="anchor" aria-hidden="true" href="#examples-of-bad-csv"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Examples of BAD CSV</h3>
<h4><a id="user-content-no-header--no-column-b-mut-will-not-see-column-b-at-all" class="anchor" aria-hidden="true" href="#no-header--no-column-b-mut-will-not-see-column-b-at-all"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>No Header &amp;&amp; No Column B (MUT will not "see" Column B at all)</h4>
<table>
<thead>
<tr>
<th>C111111</th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td>C222222</td>
<td></td>
</tr>
<tr>
<td>C333333</td>
<td></td>
</tr></tbody></table>
<h4><a id="user-content-commas-in-attribute-values-mut-will-believe-column-b-ends-prematurely" class="anchor" aria-hidden="true" href="#commas-in-attribute-values-mut-will-believe-column-b-ends-prematurely"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Commas in Attribute Values (MUT will believe Column B ends prematurely)</h4>
<table>
<thead>
<tr>
<th>Serial</th>
<th>Building</th>
</tr>
</thead>
<tbody>
<tr>
<td>C111111</td>
<td>Eau Claire, WI</td>
</tr>
<tr>
<td>C222222</td>
<td>Minneapolis, MN</td>
</tr>
<tr>
<td>C333333</td>
<td>New York, NY</td>
</tr></tbody></table>
<blockquote>
<p>It is now possible to change the delimiter MUT uses to a semi-colon under the Settings menu at the top of the page. Use this feature if you must include commas in attribute values.</p>
</blockquote>
<h3><a id="user-content-verify-your-credentials" class="anchor" aria-hidden="true" href="#verify-your-credentials"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Verify your credentials</h3>
<ol>
<li>Select the radio button for Jamf Cloud hosted or on-premise Jamf server</li>
<li>Fill out your instance name if Jamf Cloud hosted, or your full URL if on-premise</li>
<li>Enter a username and password to use for the updates you wish to run</li>
</ol>
<blockquote>
<p>The MUT does a read of your Activation Code via the API to verify the credentials. If you wish to give The MUT's user minimal permissions, it must include at least Update privileges for the attribute you wish to update, as well as Read privileges on the Activation Code.</p>
</blockquote>
<ol start="4">
<li>Select whether or not you'd like to save the username for your next run (it is saved by default). <strong>The MUT will never store your password.</strong></li>
<li>Hit the "Verify Credentials" button (or simply press Enter) to verify the credentials you've entered</li>
<li>A message will be displayed to let you know whether or not your credentials are correct</li>
</ol>
<h3><a id="user-content-prepare-for-your-updates" class="anchor" aria-hidden="true" href="#prepare-for-your-updates"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Prepare for your updates</h3>
<ol>
<li>Select the Device Type, Unique Identifier, and Attribute from the dropdowns</li>
<li>If you're updating an Extension Attribute, enter the Extension Attribute ID number in the box (you can find the EA ID in the URL while viewing the EA in Jamf)</li>
<li>Browse for your CSV File</li>
<li>Hit the "Pre-Flight Check" button</li>
<li>Review the information in the display paying particularly close attention to whether or not The MUT sees the correct number of lines in your CSV, and that your device type/attribute are correct. Once you make a run and the attributes get updated, there is no "undo" button</li>
</ol>
<h3><a id="user-content-send-your-updates" class="anchor" aria-hidden="true" href="#send-your-updates"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Send your updates</h3>
<ol>
<li>Hit the "Submit" button to send the updates to Jamf</li>
<li>Messages will be displayed in either green or red, depending on the success of the run</li>
<li>In case of a failure, the HTTP code of the failure will display. The MUT may also try to provide some advice on why you received that error</li>
</ol>
<h2><a id="user-content-top-tips" class="anchor" aria-hidden="true" href="#top-tips"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Top Tips</h2>
<ul>
<li>There is an option in the top Menu Bar under "Settings" to change the character which separates items on your CSV file to either a comma (,) or a semi-colon (;). This is especially useful for international folks who delimit their CSV files by semi-colon by default, or for folks who wish to include commas in their attribute values.</li>
<li>There is an option in the top Menu Bar under "Settings" to enable advanced debugging. This will display the full HTML code of the API response, and is especially useful in situations where you are getting a 409 - Conflict error and want to see what the issue may be.</li>
<li>There is an option in the top Menu Bar under "Settings" to clear any stored values that you may have by default, including Delimiter, Username, and your server URL.</li>
<li>There is an option in the top Menu Bar under "File" to save the contents of the logging box. This is especially useful in combination with advanced debugging when trying to figure out why some devices are not updating properly.</li>
</ul>
<h2><a id="user-content-advanced-workflows" class="anchor" aria-hidden="true" href="#advanced-workflows"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Advanced Workflows</h2>
<h3><a id="user-content-create-multiple-users-en-masse" class="anchor" aria-hidden="true" href="#create-multiple-users-en-masse"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Create multiple users en masse</h3>
<p>Your Jamf server will create users on demand. This means that if you attempt to assign a device to a user that does not exist, the username will be created. <strong>It is important to note that the usernames will be created and populated with whatever user/location information currently exists for that device, such as Full Name, Phone Number, etc.</strong></p>
<ol>
<li>If you already know which devices will go to which users, simply fill out your CSV as normal, and the usernames will be created as they are assigned</li>
<li>If you simply wish to create all the usernames without having them assigned to the same user, fill out Column A of your CSV with the same device serial over and over. This can be any device, but it is recommended that you use some sort of "test device" or Jamf Admin's device to limit unintended behavior for end-users</li>
<li>Fill out Column B with all of the usernames that you wish to create. Your CSV Should look something like:</li>
</ol>
<table>
<thead>
<tr>
<th>Serial</th>
<th>username</th>
</tr>
</thead>
<tbody>
<tr>
<td>C1111111</td>
<td>mike.levenick</td>
</tr>
<tr>
<td>C1111111</td>
<td>bill.smith</td>
</tr>
<tr>
<td>C1111111</td>
<td>jane.smith</td>
</tr>
<tr>
<td>C1111111</td>
<td>ronnie.smith</td>
</tr>
<tr>
<td>C1111111</td>
<td></td>
</tr></tbody></table>
<p>The update run will create the usernames mike.levenick, bill.smith, jane.smith, and ronnie.smith, and then at the end of the run the device will be unassigned from any user. Alternatively, the last line can be the correct username to associate that device (such as the admin's username if you're using an admin's device).</p>
<h3><a id="user-content-remove-users-from-devices-en-masse" class="anchor" aria-hidden="true" href="#remove-users-from-devices-en-masse"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Remove users from devices en masse</h3>
<p>If you leave Column B blank, The MUT can wipe out the values for whatever attribute you're updating. This is especially useful when unassigning users from devices. However, The MUT needs to "see" Column B before it will let you do a run. Headers are sufficient to help MUT see the column, so a CSV formatted similar to the following will remove the usernames from devices C111111, C222222, and C333333.</p>
<table>
<thead>
<tr>
<th>Serial</th>
<th>Username</th>
</tr>
</thead>
<tbody>
<tr>
<td>C111111</td>
<td></td>
</tr>
<tr>
<td>C222222</td>
<td></td>
</tr>
<tr>
<td>C333333</td>
<td></td>
</tr></tbody></table>
</article>
  </div>

  </div>

  <button type="button" data-facebox="#jump-to-line" data-facebox-class="linejump" data-hotkey="l" class="d-none">Jump to Line</button>
  <div id="jump-to-line" style="display:none">
    <!-- '"` --><!-- </textarea></xmp> --></option></form><form class="js-jump-to-line-form" action="" accept-charset="UTF-8" method="get"><input name="utf8" type="hidden" value="&#x2713;" />
      <input class="form-control linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" aria-label="Jump to line" autofocus>
      <button type="submit" class="btn">Go</button>
</form>  </div>


  </div>
  <div class="modal-backdrop js-touch-events"></div>
</div>

    </div>
  </div>

  </div>

      
<div class="footer container-lg px-3" role="contentinfo">
  <div class="position-relative d-flex flex-justify-between pt-6 pb-2 mt-6 f6 text-gray border-top border-gray-light ">
    <ul class="list-style-none d-flex flex-wrap ">
      <li class="mr-3">&copy; 2018 <span title="0.30850s from unicorn-1437287646-dh9fl">GitHub</span>, Inc.</li>
        <li class="mr-3"><a data-ga-click="Footer, go to terms, text:terms" href="https://github.com/site/terms">Terms</a></li>
        <li class="mr-3"><a data-ga-click="Footer, go to privacy, text:privacy" href="https://github.com/site/privacy">Privacy</a></li>
        <li class="mr-3"><a href="https://help.github.com/articles/github-security/" data-ga-click="Footer, go to security, text:security">Security</a></li>
        <li class="mr-3"><a href="https://status.github.com/" data-ga-click="Footer, go to status, text:status">Status</a></li>
        <li><a data-ga-click="Footer, go to help, text:help" href="https://help.github.com">Help</a></li>
    </ul>

    <a aria-label="Homepage" title="GitHub" class="footer-octicon" href="https://github.com">
      <svg height="24" class="octicon octicon-mark-github" viewBox="0 0 16 16" version="1.1" width="24" aria-hidden="true"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>
</a>
   <ul class="list-style-none d-flex flex-wrap ">
        <li class="mr-3"><a data-ga-click="Footer, go to contact, text:contact" href="https://github.com/contact">Contact GitHub</a></li>
      <li class="mr-3"><a href="https://developer.github.com" data-ga-click="Footer, go to api, text:api">API</a></li>
      <li class="mr-3"><a href="https://training.github.com" data-ga-click="Footer, go to training, text:training">Training</a></li>
      <li class="mr-3"><a href="https://shop.github.com" data-ga-click="Footer, go to shop, text:shop">Shop</a></li>
        <li class="mr-3"><a href="https://blog.github.com" data-ga-click="Footer, go to blog, text:blog">Blog</a></li>
        <li><a data-ga-click="Footer, go to about, text:about" href="https://github.com/about">About</a></li>

    </ul>
  </div>
  <div class="d-flex flex-justify-center pb-6">
    <span class="f6 text-gray-light"></span>
  </div>
</div>



  <div id="ajax-error-message" class="ajax-error-message flash flash-error">
    <svg class="octicon octicon-alert" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M8.893 1.5c-.183-.31-.52-.5-.887-.5s-.703.19-.886.5L.138 13.499a.98.98 0 0 0 0 1.001c.193.31.53.501.886.501h13.964c.367 0 .704-.19.877-.5a1.03 1.03 0 0 0 .01-1.002L8.893 1.5zm.133 11.497H6.987v-2.003h2.039v2.003zm0-3.004H6.987V5.987h2.039v4.006z"/></svg>
    <button type="button" class="flash-close js-ajax-error-dismiss" aria-label="Dismiss error">
      <svg class="octicon octicon-x" viewBox="0 0 12 16" version="1.1" width="12" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.48 8l3.75 3.75-1.48 1.48L6 9.48l-3.75 3.75-1.48-1.48L4.52 8 .77 4.25l1.48-1.48L6 6.52l3.75-3.75 1.48 1.48L7.48 8z"/></svg>
    </button>
    You can’t perform that action at this time.
  </div>


    
    <script crossorigin="anonymous" integrity="sha512-HtXMaArrY9G3PeC0Ak9gvytVs8jgGWgF72UwiHRvPUaF/ru8bw6gGq2qxSli8smS4OcZUo+6sXKV9ilIsIW/cw==" type="application/javascript" src="https://assets-cdn.github.com/assets/frameworks-c3c14c4cae6d3342206a30a4f9851d53.js"></script>
    
    <script crossorigin="anonymous" async="async" integrity="sha512-nRc6PFf8BVI7wfX8/X56tAKay2YA4qqW+weVHnPvfg6BUaMOacqY8BrBsGlRaGsJ+zOlqieKwESq+afIvVv0xg==" type="application/javascript" src="https://assets-cdn.github.com/assets/github-0cf9f7e086e0c91c4b50d4fdbfde46c5.js"></script>
    
    
    
  <div class="js-stale-session-flash stale-session-flash flash flash-warn flash-banner d-none">
    <svg class="octicon octicon-alert" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M8.893 1.5c-.183-.31-.52-.5-.887-.5s-.703.19-.886.5L.138 13.499a.98.98 0 0 0 0 1.001c.193.31.53.501.886.501h13.964c.367 0 .704-.19.877-.5a1.03 1.03 0 0 0 .01-1.002L8.893 1.5zm.133 11.497H6.987v-2.003h2.039v2.003zm0-3.004H6.987V5.987h2.039v4.006z"/></svg>
    <span class="signed-in-tab-flash">You signed in with another tab or window. <a href="">Reload</a> to refresh your session.</span>
    <span class="signed-out-tab-flash">You signed out in another tab or window. <a href="">Reload</a> to refresh your session.</span>
  </div>
  <div class="facebox" id="facebox" style="display:none;">
  <div class="facebox-popup">
    <div class="facebox-content" role="dialog" aria-labelledby="facebox-header" aria-describedby="facebox-description">
    </div>
    <button type="button" class="facebox-close js-facebox-close" aria-label="Close modal">
      <svg class="octicon octicon-x" viewBox="0 0 12 16" version="1.1" width="12" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.48 8l3.75 3.75-1.48 1.48L6 9.48l-3.75 3.75-1.48-1.48L4.52 8 .77 4.25l1.48-1.48L6 6.52l3.75-3.75 1.48 1.48L7.48 8z"/></svg>
    </button>
  </div>
</div>

  <div class="Popover js-hovercard-content position-absolute" style="display: none; outline: none;" tabindex="0">
  <div class="Popover-message Popover-message--bottom-left Popover-message--large Box box-shadow-large" style="width:360px;">
  </div>
</div>

<div id="hovercard-aria-description" class="sr-only">
  Press h to open a hovercard with more details.
</div>


  </body>
</html>

