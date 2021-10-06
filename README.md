Chat Announcements
==================

Unofficial mod for **Don't Starve Together** to announce monster and player deaths on a server and/or Discord.

Table of Contents
-----------------

- [Chat Announcements](#chat-announcements)
  - [Table of Contents](#table-of-contents)
  - [Installation and Setup](#installation-and-setup)
    - [Mod Installation using the Steam Workshop](#mod-installation-using-the-steam-workshop)
      - [Edit dedicated_server_mods_setup.lua in mods directory](#edit-dedicated_server_mods_setuplua-in-mods-directory)
      - [Edit modoverrides.lua in server/shard directory](#edit-modoverrideslua-in-servershard-directory)
    - [Mod Installation Without Steam Workshop](#mod-installation-without-steam-workshop)
    - [Connecting to Discord](#connecting-to-discord)
      - [Drop-In Replacement of Discord Death Announcements](#drop-in-replacement-of-discord-death-announcements)
      - [Get a Discord Webhook URL](#get-a-discord-webhook-url)
      - [Set Webhook URL as Configuration Option](#set-webhook-url-as-configuration-option)
      - [Set Webhook URL in Server Files](#set-webhook-url-in-server-files)
      - [Set Webhook URL with Console Command](#set-webhook-url-with-console-command)
  - [Roadmap](#roadmap)
  - [Acknowledgements](#acknowledgements)
    - [Graphics](#graphics)
    - [Source Code](#source-code)
  - [Changelog](#changelog)
    - [Version 1.2.1 (2021-10-06)](#version-121-2021-10-06)
    - [Version 1.2.0 (2021-09-28)](#version-120-2021-09-28)
    - [Version 1.1.1 (2021-09-16)](#version-111-2021-09-16)
    - [Version 1.1.0 (2021-09-11)](#version-110-2021-09-11)
    - [Version 1.0.0 (2021-09-06)](#version-100-2021-09-06)

Installation and Setup
----------------------

Please follow any generic installation instructions on how to install a mod on your dedicated or client-hosted server, this mod works exactly the same as any other mod in that regard. If you want to announce anything to Discord, you will have to further setup a Discord connection as described below.

### Mod Installation using the Steam Workshop

#### Edit dedicated_server_mods_setup.lua in mods directory

Add this snippet to the file `<dedicated_server_install>/mods/dedicated_server_mods_setup.lua` to automatically let the server download the mod from the Steam Workshop on boot. This does not activate the mod, yet.

```lua
-- Chat Announcements by Gyroplast
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2594707725
ServerModSetup("2594707725")
```

#### Edit modoverrides.lua in server/shard directory

Add configuration options and enable the mod in the server's `modoverrides.lua` file. Please note that this file is server specific! As Overworld and Caves are technically two independent servers, you will generally want to modify this file in at least two locations, most of the time identically, unless you want differing configuration for any mod from Caves to Overworld.

Below is a commented, comprehensive default configuration for this mod that can be copied into the file directly to configure the Steam Workshop installation of the mod.

```lua
  -- Chat Announcements by Gyroplast
  -- https://steamcommunity.com/sharedfiles/filedetails/?id=2594707725
  ["workshop-2594707725"]={
    configuration_options={
      -- Discord Webhook URL to use if no URL was set manually by this mod or
      -- Discord Death Announcements. Delete `discord_webhook_url.txt` and
      -- `Discord_Webhook_URL.txt` file(s) in the `save` subdirectory to
      -- use this configuration option and re-create the URL file.
      discord_webhook_url="https://discord.com/api/webhooks/1234/LEqwufkGXdT",

      -- Default Settings
      -- All announce channel selection options are set to a numeric value.
      -- If the value is 1, the announcement will be disabled.
      -- If the value is 2, the Default Setting will be used.
      -- If the value is 4, the announcement will be a server broadcast.
      -- If the value is 8, the announcement will be sent to Discord.
      -- The values can be added to announce on multiple channels, f. ex.:
      -- If the value is 12, the announcement will be broadcast on the
      -- server (4) AND sent to Discord (8), since 12 = 4 + 8. 
      announce_death=4, -- where to announce boss monster death, default setting
      death_player=4,   -- where to announce player death, default setting
      include_day=true, -- append in-world day/time/cycle to announcements
      include_death_location=true, -- append location of death to announcements
      log_level="INFO", -- server log level: TRACE, DEBUG, INFO, WARN, ERROR

      -- overrides for monster death announcements
      death_alterguardian=2,     -- Celestial Champion, all phases
      death_antlion=2,           -- Antlion
      death_bearger=2,           -- Bearger
      death_beequeen=2,          -- Bee Queen
      death_crabking=2,          -- Crab King
      death_deerclops=2,         -- Deerclops
      death_dragonfly=2,         -- Dragonfly
      death_klaus=2,             -- Klaus
      death_koalefant=2,         -- Summer/Winter Koalefant
      death_krampus=2,           -- Krampus
      death_lordfruitfly=2,      -- Lord of the Fruit Flies
      death_malbatross=2,        -- Malbatross
      death_minotaur=2,          -- Ancient Guardian
      death_moose=2,             -- Moose/Goose
      death_shadowchesspieces=2, -- all shadow chesspieces (rook, bishop, knight)
      death_spat=2,              -- Ewecus
      death_spiderqueen=2,       -- Spider Queen
      death_stalker=2,           -- Ancient Fuelweaver, Atrium/Forest Stalker
      death_toadstool=2,         -- Toadstool, Misery Toadstool
      death_treeguard=2,         -- Treeguard variants
      death_walrus=2,            -- MacTusk
      death_warg=2               -- Warg
    },
    enabled=true
  }
```

### Mod Installation Without Steam Workshop

If you prefer to install the mod without using the Steam Workshop, download the release you want as an archive, and extract it into the `mods` directory in the dedicated server installation directory, where the `dedicated_server_mods_setup.lua` file resides. After extraction, you should have a new directory for the mod in the `mods` directory, named `Chat_Announcements-<version>`, similar to this:

```
.../
    Don't Starve Together Dedicated Server/
        mods/
            Chat_Announcements-1.2.1/
                client/
                lib/
                LICENSE
                modicon.tex
                modicon.xml
                modinfo.lua
                modmain.lua
                README.md
            INSTALLING_MODS.txt
            MAKING_MODS.txt
            dedicated_server_mods_setup.lua
            modsettings.lua
```

Take note of the *exact* name of the mod directory, `Chat_Announcements-1.2.1` in this example. The mod configuration must refer to this exact, case-sensitive directory name. The actual directory name is not important, but it must be consistent with the `modoverrides.lua` entry for the mod, otherwise the server will not be able to associate the configuration with the mod, and the mod will stay disabled entirely.

To achieve the required consistency, you may now either just rename the mod directory to `workshop-2594707725`, and edit the `modoverrides.lua` files exactly as described in the [Steam Workshop Installation above](#edit-modoverrideslua-in-servershard-directory), 

**OR**

replace the `workshop-2594707725` reference in the `modoverrides.lua` file with the exact, case-sensitive name of the mod, i. e. `Chat_Announcements-1.2.1` in this case, like this:

```lua
  -- Chat Announcements by Gyroplast
  -- https://steamcommunity.com/sharedfiles/filedetails/?id=2594707725
  ["Chat_Announcements-1.2.1"]={
    configuration_options={
      [""]="",
      ...
```

**Do not edit the `dedicated_server_mods_setup.lua` file to include the `ServerModSetup("2594707725")` line.**

The `ServerModSetup`'s *only job* is to download the mod files from the Steam Workshop, which is unnecessary after downloading, extracting, and placing the mod files manually.
In fact, if you renamed the directory to `workshop-2594707725`, leaving the `ServerModSetup` line active would overwrite the manually installed mod with the Steam Workshop version on server start, so ensure there is no `ServerModSetup("2594707725")` line in the `dedicated_server_mods_setup.lua` file, or leave the mod directory name as-is.

### Connecting to Discord

After installation and configuration, follow these steps to connect a DST server to a Discord channel with a Discord webhook.

#### Drop-In Replacement of Discord Death Announcements

If you plan on replacing the [Discord Death Announcements (ID 2202942881)](https://steamcommunity.com/sharedfiles/filedetails/?id=2202942881) mod, and already have a working configuration on your server, you are done after installing and configuring the mod. You do not need to set the `discord_webhook_url` configuration option in the `modoverrides.lua` files.
This mod will automatically detect and use the existing configuration, and, although untested, there should be no harm in running both mods at the same time if you want to "test the waters". Of course you'd receive announcements twice on Discord in that case, as both mods are fully running and doing their thing independently.

Either way, you're done. Try it out!

#### Get a Discord Webhook URL

To send any messages to a Discord server's channel, you will have to create a *Webhook* first in Discord. Once setup, you'll copy an URL into your clipboard looking similar to
https://discord.com/api/webhooks/123456789012345678/ooLaiceili8oht-7oosho4mas3wai9eview_og4ira2ookea0the_1fooVie6cheogh1.
This is what you need.

In a Discord server, you manage a channel's webhooks by clicking the `Edit Channel` cog icon for the Discord channel you want to announce to, select `Integrations`, and then the `Webhooks` option.
You can then either create a new webhook there, or edit an existing one, and *Copy Webhook URL* to the clipboard.

**WARNING:**
    Be aware that a webhook URL allows *anyone* to post messages to
    the channel the webhook was created for, and many other shenanigans,
    so **consider this URL as secret as you would a password**, and
    generally **DO NOT SHARE THIS URL** with anyone.
    Also be advised that the URL will be printed to the server's logfile
    and remain there if you use the in-game console or configuration file
    variants of setting the webhook URL instead of placing files directly
    into the server directories. The TRACE log level also prints the
    webhook URL to the server log file occassionally.

Currently, each server/shard needs its own Discord webhook URL to be configured individually, but you may re-use one webhook for multiple servers.
This allows you to use different webhooks for each server, if you want to announce to different channels or use a different bot picture for specific servers.

There are three ways to set a webhook URL on a server, either by setting the `discord_webhook_url` option in the `modoverrides.lua` file (recommended), placing text files into the server's directory, or by executing an in-game remote console command as an admin. All variants are described below, and I would recommend using the `modoverrides.lua` configuration, as it is, in fact, quicker and less error-prone to do than the other options, and you have to edit this file during setup, anyway, to enable the mod.

#### Set Webhook URL as Configuration Option

Edit the `modoverrides.lua` for the server and add/set the configuration option named `discord_webhook_url` to the webhook URL, like this:

```lua
  -- Chat Announcements by Gyroplast
  -- https://steamcommunity.com/sharedfiles/filedetails/?id=2594707725
  ["workshop-2594707725"]={
    configuration_options={
      [""]="",
      -- Discord Webhook URL to use if no URL was set manually by this mod or
      -- Discord Death Announcements. Delete `discord_webhook_url.txt` and
      -- `Discord_Webhook_URL.txt` file(s) in the `save` subdirectory to
      -- use this configuration option and re-create the URL file.
      discord_webhook_url="https://discord.com/api/webhooks/123456789012345678/ooLaiceili8oht-7oosho4mas3wai9eview_og4ira2ookea0the_1fooVie6cheogh1",

      -- Default Settings
      ...
```

Please note that the configuration setting has the lowest priority of all options, and will *not* overwrite an URL set by any other method, unless the saved files are deleted as described in the file comment. Using the configuration option is ideal when setting up a new server, where no Discord webhook has been configured, yet.

#### Set Webhook URL in Server Files

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

Directly editing this file usually isn't a good option, as you'll have an easier time just deleting this file and setting the configuration option instead to the webhook URL you want. Consider this comprehesive reference if you really need to understand how the mod is working internally.
It is the **only option**, however, if you want to prevent the webhook URL to be printed to the server logs, ever. To ensure no webhook URL is printed to the logs, you must also:

- NOT use the `TRACE` log level. Anything else is fine.
- remove/comment out the `discord_webhook_url` configuration option in all `modoverrides.lua` files, or set it to an empty string: `""`.

#### Set Webhook URL with Console Command

You may, at any time, use console commands in-game as an admin to check the server's configuration, send test announcements, or explicitly set a webhook URL for the current server you're on. 

Login to the server with an admin account. When in-game, open the **Remote** console with the tilde key `~`, and run this command:

```
CASetDiscordURL("<YOUR WEBHOOK URL>")
```

For example:

```
CASetDiscordURL("https://discord.com/api/webhooks/123456789012345678ooLaiceili8oht-7oosho4mas3wai9eview_og4ira2ookea0the_1fooVie6cheogh1")
```

Ensure that to the left of the console input field you're reading ```Remote``` instead of ```Local```. Pressing the ```Ctrl``` key will switch between remote and local, and especially when you're using ```Ctrl-V``` to paste the webhook URL, you *will* switch from remote to local inadvertently. 

Go with your character to every shard, i. e. enter the Caves, and run the command again, possibly with a different webhook URL if you so desire.

You can check the current configuration with the command `CAStatus()`, which will also tell you the name of the Discord webhook installed on the current shard, like this:

```
Current Configuration Status
Append Day is ENABLED  --  Append Location is DISABLED
Discord is configured on this shard, using webhook `Death Announcements`.
```

You can force a test announcement on all possible channels, i. e. server broadcast and Discord, if a webhook is configured, with the command `CATest()`.

As an in-game reminder how to set the Discord Webhook URL with a command, you may run `CAHelp()` for short instructions.

Internally, the console command `CASetDiscordURL(<URL>)` simply writes the supplied URL into the server file `discord_webhook_url.txt` after comprehensive validity checks, meaning there is effectively no difference between using the console command or directly editing the file on the server, except for the chance for mistakes and how "involved" it is to migrate to other shards as opposed to just editing a different file.

Roadmap
-------

This is a list of changes and features that are planned to be implemented,
in no particular order.

- [X] add new Wanda character image
- [ ] add announcements for spawning and despawning of monsters
- [ ] add announcements for player resurrections
- [ ] support full runtime configuration with server console
- [ ] ability to add custom images
- [ ] more customizable messages
- [ ] add localization support
- [ ] translate messages, docs and mod configuration
- [ ] port to single-player Don't Starve and its DLCs
- [ ] Matrix messaging support
- [ ] find robust alternative to letting Discord "host" the image files
- [X] simplify installation across shards
- [ ] allow shard name instead of simple Cave/Overworld location
- [ ] other messenger/chat support
- [ ] comprehensive unit tests


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

### Version 1.2.1 (2021-10-06)
  **Bugfixes**
  - server crash when run with Prefab Counter 1.0.1    
    Fixes [#12](https://github.com/gyroplast/mod-dont-starve-chat-announcements/issues/12).

  **Other Changes**
  - remove Discord Webhook URL from mod config screen
  - unset forumthread in modinfo to go to Workshop page

### Version 1.2.0 (2021-09-28)
  **Bugfixes**
  - display correct player icon in CATest() Discord message

  **New Features**
  - support for `discord_webhook_url` configuration option
  - drop-in compatibility with `Discord Death Announcements` mod
  - console commands print output to in-game chat / broadcast
  - big logging overhaul, with configurable log level support

**Other Changes**
  - huge refactoring into a separate DiscordClient module
  - comprehensive server-side logging available with TRACE
  - new mod icon with border and blue gradient background
  - code cleanup across the board

### Version 1.1.1 (2021-09-16)
  **Bugfixes**
  - fix missing mob death announcements

    Several mob deaths were mistakenly not announced at all:
    - Celestial Champion
    - all three treeguard variants
    - Summer and Winter Koalefant
    - all shadow chesspieces
    - both stalker variants
    - Misery Toadstool

    This is now fixed by mapping the lookup for the announcement configuration to the correct prefab names.
    Thanks go to CampbellSoupBoy for reporting!

    Fixes [#2](https://github.com/gyroplast/mod-dont-starve-chat-announcements/issues/2).
  - fix package script to prevent symlink loops

  **Other Changes**
  - change MOD_DEBUG bool to LOGLEVEL implementation, add TRACE
  - handle non-string inputs with trim() and starts_with()

### Version 1.1.0 (2021-09-11)
  **New Features**
  - add Steam Workshop ID to mod description
  - use last attacker in 5 secs in player death announcement
    
    Player deaths are credited to most recent attacker within the last 5
    seconds, even if dying by fire, cold, over-aging, etc.
    This is particularly useful for Wanda characters, who usually always die
    to "passage of time", unless such a logic is implemented. Now Wandas can
    also enjoy public announcements of dying to a cactus.
  - add Wanda avatar image 

### Version 1.0.0 (2021-09-06)
  - first public release
