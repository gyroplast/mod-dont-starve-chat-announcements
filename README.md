Chat Announcements
==================

Unofficial mod for **Don't Starve Together** to announce monster and player deaths on a server and/or Discord.

Table of Contents
-----------------

- [Chat Announcements](#chat-announcements)
  - [Table of Contents](#table-of-contents)
  - [Installation and Setup](#installation-and-setup)
    - [Connecting to Discord](#connecting-to-discord)
      - [Get the Webhook URL](#get-the-webhook-url)
      - [Set Webhook URL in Server Files (recommended)](#set-webhook-url-in-server-files-recommended)
      - [Set Webhook URL with Console Command](#set-webhook-url-with-console-command)
  - [Roadmap](#roadmap)
  - [Acknowledgements](#acknowledgements)
    - [Graphics](#graphics)
    - [Source Code](#source-code)
  - [Changelog](#changelog)
    - [Version 1.0.0 (2021-09-06)](#version-100-2021-09-06)

Installation and Setup
----------------------

Please follow any generic installation instructions on how to install a mod on your dedicated or
client-hosted server, this mod works exactly the same as any other mod in that regard. If you want
to announce anything to Discord, you will have to further setup a Discord connection as described below.


### Connecting to Discord

Get the desired webhook URL from the Discord Integrations channel configuration.

**EITHER**

[Set Webhook URL in Server Files (recommended)](#set-webhook-url-in-server-files-recommended)

**OR**

[Set Webhook URL with Console Command](#set-webhook-url-with-console-command)

Configure the mod to your liking with the in-game mod configuration, (re-)start the server, enjoy.

You may use the **Remote** console command ```CATest()``` at any time to send a test message to all correctly configured channels and do a server announcement, independent of mod configuration settings.

Check your shard's ```server_log.txt``` for any error messages in case of trouble. 

You'll only have to do this setup once, and whenever your webhook URL changes.


#### Get the Webhook URL

To send any messages to a Discord server's channel, you will have to create a *Webhook* first in Discord.
Once setup, you'll get an URL looking similar to
https://discord.com/api/webhooks/123456789012345678ooLaiceili8oht-7oosho4mas3wai9eview_og4ira2ookea0the_1fooVie6cheogh1.
This is what you want.

In a Discord server, manage a channel's webhooks by clicking the *Edit Channel* cog icon for the 
Discord channel you want to announce to, select *Integrations*, and then the *Webhooks* option.
You can then either create a new webhook there, or edit an existing one, and *Copy Webhook URL* to the clipboard.

**WARNING:**
    Be aware that a webhook URL allows *anyone* to post messages to
    the channel the webhook was created for, and many other shenanigans,
    so **consider this URL as secret as you would a password**, and
    generally **DO NOT SHARE THIS URL** with anyone.
    Also be advised that the URL will be printed to the server's logfile
    and remain there if you use the in-game console variant of setting
    the webhook URL instead of placing files directly into the server directories.

Currently, each shard needs its own Discord webhook URL to be configured individually.
This allows you to use different webhooks for each shard, if you prefer,
to announce to different channels, or use a different bot picture.
Unfortunately, you'll have to set the webhook URL for each shard, usually at least one
Overworld and one Caves shard, to enable Discord announcements originating from
that shard.

There are two ways to set the Webhook URL, either by placing text files in the
server's directory, or by executing in-game console commands. Both variants are
described below, and I would recommend using the file method over the console method,
as it is, in fact, quicker and less error-prone to do, especially as you'll need to enter
the caves just to set the URL on that shard or, heaven forbid, enter every shard if
you're running more than just two linked shards!


#### Set Webhook URL in Server Files (recommended)

Create a text file named ```discord_webhook_url.txt``` containing exactly this line:

```
KLEI     1 <YOUR WEBHOOK URL>
```

That is exactly five (5) spaces between ```KLEI``` and ```1```, and one (1) space after the ```1```, with only a single line total in the file.
For example:

```
KLEI     1 https://discord.com/api/webhooks/123456789012345678ooLaiceili8oht-7oosho4mas3wai9eview_og4ira2ookea0the_1fooVie6cheogh1
```

Place this file in all server shard save directories for which you want announcements to go to that webhook, f. ex. typically:

- ```<SERVER_ROOT>/Cluster_1/Master/save/discord_webhook_url.txt```
- ```<SERVER_ROOT>/Cluster_1/Caves/save/discord_webhook_url.txt```

Your ```<SERVER_ROOT>``` depends on your platform and server setup, but if you're following some
guide to setup your server, I am sure you'll recognize this directory structure eventually and know
where to put these files.

#### Set Webhook URL with Console Command

Start your server with your server admin account. When in-game, open the **Remote** console, and run this command:

```
CASetDiscordURL("<YOUR WEBHOOK URL>")
```

For example:

```
CASetDiscordURL("https://discord.com/api/webhooks/123456789012345678ooLaiceili8oht-7oosho4mas3wai9eview_og4ira2ookea0the_1fooVie6cheogh1")
```

Ensure that to the left of the console input field you're reading ```Remote``` instead of ```Local```. Pressing the ```Ctrl``` key will switch between remote and local, and especially when you're using ```Ctrl-V``` to paste the webhook URL, you *will* switch from remote to local inadvertently. Toggle between remote and local console by pressing the ```Ctrl``` button.

Go with your character to every shard, i. e. enter the caves, and run the command again, possibly with a different webhook URL if you so desire.

Roadmap
-------

This is a list of changes and features that are planned to be implemented,
in no particular order.

- add new Wanda character image
- add announcements for spawning and despawning of monsters
- add announcements for player resurrections
- support full runtime configuration with server console
- ability to add custom images
- more customizable messages
- add localization support
- translate messages, docs and mod configuration
- port to single-player Don't Starve and its DLCs
- Matrix messaging support
- find robust alternative to letting Discord "host" the image files
- simplify installation across shards
- allow shard name instead of simple Cave/Overworld location
- other messenger/chat support

Acknowledgements
--------------

### Graphics

Character and monster icons/portraits were obtained and derived from the 
[Don't Starve Wiki](https://dontstarve.fandom.com/wiki/Don%27t_Starve_Wiki)
under the assumption that all used images are ultimately intellectual property of Klei Entertainment,
and as such permitted to be used in derivative works like this public, freely distributed game mod
according to the [Mod & Player Creation Policy](https://www.klei.com/mod-player-creation-policy).
Exact source references for the downloaded images are recorded in the [image sources](img/img_src.txt) file.

### Source Code

Please see the enclosed [license file](LICENSE),
applicable to the sources unless noted otherwise. Mod sources are hosted on
[GitHub](https://github.com/gyroplast/mod-dont-starve-chat-announcements).

This mod was heavily inspired by
[Discord Death Announcements](https://steamcommunity.com/sharedfiles/filedetails/?id=2202942881)
from [pixelatedInadequacy](https://steamcommunity.com/profiles/76561198119739765).
I practically started with that mod, shuffled bits around and refactored heavily,
added boss monster announcements, configuration options, and souped up the
Discord webhook handling and setup a notch in terms of error checking.

Changelog
---------

### Version 1.0.0 (2021-09-06)
  - first public release (*Gyroplast*)
