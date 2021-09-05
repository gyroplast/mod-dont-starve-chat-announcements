local function trim(s) return s:gsub("^%s*(.-)%s*$", "%1") end

-- custom field for description and in-game constants
_src_url = "https://github.com/gyroplast/mod-dont-starve-chat-announcements"

name = "Chat Announcements"
author = "Gyroplast"
version = "1.0.0"
forumthread = "/profile/631156-gyroplast/"
api_version = 10
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
icon_atlas = "modicon.xml"
icon = "modicon.tex"
all_clients_require_mod = false
server_filter_tags = {"chat announcements"}

description = trim [[
Version __VERSION__
Announce monster and player deaths on a server and/or Discord. Highly configurable.

Setup Discord Webhook once with CASetDiscordURL("<URL>") in remote console on each shard (i. e. all running overworlds and caves), use CATest() to test. 
Check your server logfile in case of problems, and refer to the source link below for detailed instructions, bug reports, and further development.

Sources: __SRC_URL__
]]:gsub("__VERSION__", version):gsub("__SRC_URL__", _src_url)

-- refer to AnnounceChannelEnum in lib/const.lua for config value meanings
configuration_options = {
    {
        name = "title_general_defaults",
        label = "General Defaults",
        hover = "",
        options = {{description = "", data = false}},
        default = false
    }, {
        name = "death_player",
        label = "Announce Player Deaths",
        hover = "Announce player deaths on the selected channels.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 4
    }, {
        name = "announce_death",
        label = "Announce Monster Death",
        hover = "Announce monster deaths, as a default, on the selected channels. Override below as needed.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 4
    }, {
        name = "include_day",
        label = "Append Day",
        hover = "Append current in-world day to all announcements.",
        options = {
            {description = "Disabled", data = false},
            {description = "Enabled", data = true}
        },
        default = true
    }, {
        name = "include_death_location",
        label = "Append Location",
        hover = "Append location of death (Caves or Overworld) to all announcements.",
        options = {
            {description = "Disabled", data = false},
            {description = "Enabled", data = true}
        },
        default = true
    }, {

        name = "title_death",
        label = "Death Announcements",
        hover = "",
        options = {{description = "", data = false}},
        default = false
    }, {
        name = "death_minotaur",
        label = "Death Ancient Guardian",
        hover = "Announce death of Ancient Guardian.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_antlion",
        label = "Death Antlion",
        hover = "Announce death of Antlion.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_bearger",
        label = "Death Bearger",
        hover = "Announce death of Bearger.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_beequeen",
        label = "Death Bee Queen",
        hover = "Announce death of Bee Queen.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_alterguardian",
        label = "Death Celestial Champion",
        hover = "Announce death of Celestial Champion.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_crabking",
        label = "Death Crab King",
        hover = "Announce death of Crab King.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_deerclops",
        label = "Death Deerclops",
        hover = "Announce death of Deerclops.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_dragonfly",
        label = "Death Dragonfly",
        hover = "Announce death of Dragonfly.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_spat",
        label = "Death Ewecus",
        hover = "Announce death of Ewecus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_klaus",
        label = "Death Klaus",
        hover = "Announce death of Klaus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_koalefant",
        label = "Death Koalefant",
        hover = "Announce death of winter/summer koalefant.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_krampus",
        label = "Death Krampus",
        hover = "Announce death of Krampus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_lordfruitfly",
        label = "Death Lord Fruit Fly",
        hover = "Announce death of the Lord of the Fruit Flies.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_walrus",
        label = "Death MacTusk",
        hover = "Announce death of MacTusk.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_malbatross",
        label = "Death Malbatross",
        hover = "Announce death of Malbatross.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_moose",
        label = "Death Moose Goose",
        hover = "Announce death of Moose Goose.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_shadowchesspieces",
        label = "Death Shadow Chess Pieces",
        hover = "Announce death of Shadow Rook, Bishop, and Knight.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_spiderqueen",
        label = "Death Spider Queen",
        hover = "Announce death of Spider Queen.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_stalker",
        label = "Death Stalker",
        hover = "Announce death of reanimated skeleton/stalker/ancient fuelweaver.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_toadstool",
        label = "Death Toadstool",
        hover = "Announce death of (Misery) Toadstool.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_treeguard",
        label = "Death Treeguard",
        hover = "Announce death of Treeguards and poison birchnut trees.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "death_warg",
        label = "Death Warg",
        hover = "Announce death of Warg.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }
--[[ @todo: implement monster spawn and despawn announcements
    {
        name = "announce_despawn",
        label = "Announce Despawn",
        hover = "Announce when monsters despawn and vanish instead of dieing.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 4
    }, {
        name = "announce_spawn",
        label = "Announce Spawn",
        hover = "Announce when monsters spawn.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 4
    }, {
        name = "title_spawning",
        label = "Spawn Announcements",
        hover = "",
        options = {{description = "", data = false}},
        default = false
    }, {
        name = "spawn_minotaur",
        label = "Spawn Ancient Guardian",
        hover = "Announce spawning of Ancient Guardian.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_antlion",
        label = "Spawn Antlion",
        hover = "Announce spawning of Antlion.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_bearger",
        label = "Spawn Bearger",
        hover = "Announce spawning of Bearger.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_beequeen",
        label = "Spawn Bee Queen",
        hover = "Announce spawning of Bee Queen.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_alterguardian",
        label = "Spawn Celestial Champion",
        hover = "Announce spawning of Celestial Champion.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_crabking",
        label = "Spawn Crab King",
        hover = "Announce spawning of Crab King.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_deerclops",
        label = "Spawn Deerclops",
        hover = "Announce spawning of Deerclops.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_dragonfly",
        label = "Spawn Dragonfly",
        hover = "Announce spawning of Dragonfly.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_spat",
        label = "Spawn Ewecus",
        hover = "Announce spawning of Ewecus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_klaus",
        label = "Spawn Klaus",
        hover = "Announce spawning of Klaus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_koalefant",
        label = "Spawn Koalefant",
        hover = "Announce spawning of winter/summer koalefant.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_krampus",
        label = "Spawn Krampus",
        hover = "Announce spawning of Krampus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_lordfruitfly",
        label = "Spawn Lord Fruit Fly",
        hover = "Announce spawning of the Lord of the Fruit Flies.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_walrus",
        label = "Spawn MacTusk",
        hover = "Announce spawning of MacTusk.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_malbatross",
        label = "Spawn Malbatross",
        hover = "Announce spawning of Malbatross.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_moose",
        label = "Spawn Moose Goose",
        hover = "Announce spawning of Moose Goose.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_shadowchesspieces",
        label = "Spawn Shadow Chess Pieces",
        hover = "Announce spawning of Shadow Rook, Bishop, and Knight.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_spiderqueen",
        label = "Spawn Spider Queen",
        hover = "Announce spawning of Spider Queen.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_stalker",
        label = "Spawn Stalker",
        hover = "Announce spawning of reanimated skeleton/stalker/ancient fuelweaver.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_toadstool",
        label = "Spawn Toadstool",
        hover = "Announce spawning of (Misery) Toadstool.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_treeguard",
        label = "Spawn Treeguard",
        hover = "Announce spawning of Treeguards and poison birchnut trees.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "spawn_warg",
        label = "Spawn Warg",
        hover = "Announce spawning of Warg.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "title_despawn",
        label = "Despawn Announcements",
        hover = "",
        options = {{description = "", data = false}},
        default = false
    }, {
        name = "despawn_minotaur",
        label = "Despawn Ancient Guardian",
        hover = "Announce despawn of Ancient Guardian.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_antlion",
        label = "Despawn Antlion",
        hover = "Announce despawn of Antlion.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_bearger",
        label = "Despawn Bearger",
        hover = "Announce despawn of Bearger.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_beequeen",
        label = "Despawn Bee Queen",
        hover = "Announce despawn of Bee Queen.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_alterguardian",
        label = "Despawn Celestial Champion",
        hover = "Announce despawn of Celestial Champion.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_crabking",
        label = "Despawn Crab King",
        hover = "Announce despawn of Crab King.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_deerclops",
        label = "Despawn Deerclops",
        hover = "Announce despawn of Deerclops.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_dragonfly",
        label = "Despawn Dragonfly",
        hover = "Announce despawn of Dragonfly.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_spat",
        label = "Despawn Ewecus",
        hover = "Announce despawn of Ewecus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_klaus",
        label = "Despawn Klaus",
        hover = "Announce despawn of Klaus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_koalefant",
        label = "Despawn Koalefant",
        hover = "Announce despawn of winter/summer koalefant.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_krampus",
        label = "Despawn Krampus",
        hover = "Announce despawn of Krampus.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_lordfruitfly",
        label = "Despawn Lord Fruit Fly",
        hover = "Announce despawn of the Lord of the Fruit Flies.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_walrus",
        label = "Despawn MacTusk",
        hover = "Announce despawn of MacTusk.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_malbatross",
        label = "Despawn Malbatross",
        hover = "Announce despawn of Malbatross.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_moose",
        label = "Despawn Moose Goose",
        hover = "Announce despawn of Moose Goose.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_shadowchesspieces",
        label = "Despawn Shadow Chess Pieces",
        hover = "Announce despawn of Shadow Rook, Bishop, and Knight.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_spiderqueen",
        label = "Despawn Spider Queen",
        hover = "Announce despawn of Spider Queen.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_stalker",
        label = "Despawn Stalker",
        hover = "Announce despawn of reanimated skeleton/stalker/ancient fuelweaver.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_toadstool",
        label = "Despawn Toadstool",
        hover = "Announce despawn of (Misery) Toadstool.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_treeguard",
        label = "Despawn Treeguard",
        hover = "Announce despawn of Treeguards and poison birchnut trees.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }, {
        name = "despawn_warg",
        label = "Despawn Warg",
        hover = "Announce despawn of Warg.",
        options = {
            {description = "Disabled", data = 1},
            {description = "Default", data = 2},
            {description = "Server Only", data = 4},
            {description = "Discord Only", data = 8},
            {description = "Discord & Server", data = 4 + 8}
        },
        default = 2
    }
]]
}