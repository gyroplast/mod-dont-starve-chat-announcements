-- useful constants
local M = {}

-- available log levels in increasing severity
M.LOGLEVEL = { TRACE = 1, DEBUG = 2, INFO = 3, WARN = 4, WARNING = 4, ERR = 5, ERROR = 5 }

-- set to default loglevel threshold
M.MOD_LOGLEVEL = M.LOGLEVEL.INFO

-- URI of source and documentation distribution
M.SRC_URL = modinfo._src_url

M.LONG_MODNAME = ModInfoname(modname)
M.PRETTY_MODNAME = GetModFancyName(modname)

M.AnnounceChannelEnum = {DISABLED = 1, DEFAULT = 2, SERVER = 4, DISCORD = 8}

M.AnnounceEventsEnum = {DEATH = "death", SPAWN = "spawn", VANISH = "despawn"}

M.DISCORD_WEBHOOK_URL_FILE = "discord_webhook_url.txt"

-- prefab IDs of mobs to announce
M.ANNOUNCE_MOBS = {
    "alterguardian_phase1", "alterguardian_phase2", "alterguardian_phase3",
    "antlion", "bearger", "beequeen", "crabking", "deciduoustree", "deerclops",
    "dragonfly", "klaus", "koalefant_summer", "koalefant_winter", "krampus",
    "leif", "leif_sparse", "lordfruitfly", "malbatross", "minotaur", "moose",
    "shadow_knight", "shadow_bishop", "shadow_rook", "spat", "spiderqueen",
    "stalker_atrium", "stalker_forest", "stalker", "toadstool_dark",
    "toadstool", "walrus", "warg"
}

M.ANNOUNCE_MOBS_TO_CONFIG_NAME_MAP = {
    alterguardian_phase1 = "alterguardian",
    alterguardian_phase2 = "alterguardian",
    alterguardian_phase3 = "alterguardian",
    deciduoustree = "treeguard",
    leif = "treeguard",
    leif_sparse = "treeguard",
    koalefant_summer = "koalefant",
    koalefant_winter = "koalefant",
    shadow_bishop = "shadowchesspieces",
    shadow_knight = "shadowchesspieces",
    shadow_rook = "shadowchesspieces",
    stalker_atrium = "stalker",
    stalker_forest = "stalker",
    toadstool_dark = "toadstool"
}

-- URLs to small images to use as an avatar in Discord messages
M.CHARACTER_ICON = {
    unknown = "https://media.discordapp.net/attachments/879978511203463179/881557033411829760/avatar_unknown.png",
    wagstaff = "https://media.discordapp.net/attachments/879978511203463179/881557043985678406/avatar_wagstaff.png",
    walani = "https://media.discordapp.net/attachments/879978511203463179/881557054827925504/avatar_walani.png",
    walter = "https://media.discordapp.net/attachments/879978511203463179/881557065846382662/avatar_walter.png",
    wanda = "https://media.discordapp.net/attachments/879978511203463179/886224281640529920/avatar_wanda.png",
    warly = "https://media.discordapp.net/attachments/879978511203463179/881557077582024754/avatar_warly.png",
    wathgrithr = "https://media.discordapp.net/attachments/879978511203463179/881557088176853022/avatar_wathgrithr.png",
    waxwell = "https://media.discordapp.net/attachments/879978511203463179/881557098960408606/avatar_waxwell.png",
    webber = "https://media.discordapp.net/attachments/879978511203463179/881557109706203201/avatar_webber.png",
    wendy = "https://media.discordapp.net/attachments/879978511203463179/881557120342958150/avatar_wendy.png",
    wes = "https://media.discordapp.net/attachments/879978511203463179/881557131239776256/avatar_wes.png",
    wheeler = "https://media.discordapp.net/attachments/879978511203463179/881557141620674600/avatar_wheeler.png",
    wickerbottom = "https://media.discordapp.net/attachments/879978511203463179/881557152366485514/avatar_wickerbottom.png",
    wilba = "https://media.discordapp.net/attachments/879978511203463179/881557163191992340/avatar_wilba.png",
    wilbur = "https://media.discordapp.net/attachments/879978511203463179/881557173648375838/avatar_wilbur.png",
    willow = "https://media.discordapp.net/attachments/879978511203463179/881557184717140039/avatar_willow.png",
    wilson = "https://media.discordapp.net/attachments/879978511203463179/881557195773317180/avatar_wilson.png",
    winona = "https://media.discordapp.net/attachments/879978511203463179/881557206032597012/avatar_winona.png",
    wolfgang = "https://media.discordapp.net/attachments/879978511203463179/881557216518348840/avatar_wolfgang.png",
    woodie = "https://media.discordapp.net/attachments/879978511203463179/881557227910090863/avatar_woodie.png",
    woodlegs = "https://media.discordapp.net/attachments/879978511203463179/881557238584573962/avatar_woodlegs.png",
    wormwood = "https://media.discordapp.net/attachments/879978511203463179/881557249187790858/avatar_wormwood.png",
    wortox = "https://media.discordapp.net/attachments/879978511203463179/881557259073753168/avatar_wortox.png",
    wurt = "https://media.discordapp.net/attachments/879978511203463179/881557270050242560/avatar_wurt.png",
    wx78 = "https://media.discordapp.net/attachments/879978511203463179/881557280200462336/avatar_wx78.png",

    alterguardian_phase1 = "https://media.discordapp.net/attachments/879961726852927500/879970183001825290/icon_alterguardian_phase1.png",
    alterguardian_phase2 = "https://media.discordapp.net/attachments/879961726852927500/879970185241587732/icon_alterguardian_phase2.png",
    alterguardian_phase3 = "https://media.discordapp.net/attachments/879961726852927500/879970187854639114/icon_alterguardian_phase3.png",
    antlion = "https://media.discordapp.net/attachments/879961726852927500/879970189289074738/icon_antlion.png",
    bearger = "https://media.discordapp.net/attachments/879961726852927500/879970191793078282/icon_bearger.png",
    beequeen = "https://media.discordapp.net/attachments/879961726852927500/879970193974128650/icon_beequeen.png",
    crabking = "https://media.discordapp.net/attachments/879961726852927500/879970196448747520/icon_crabking.png",
    deciduoustree = "https://media.discordapp.net/attachments/879978511203463179/881558978205745232/icon_deciduoustree.png",
    deerclops = "https://media.discordapp.net/attachments/879961726852927500/879970198394896424/icon_deerclops.png",
    dragonfly = "https://media.discordapp.net/attachments/879961726852927500/879970200034869288/icon_dragonfly.png",
    klaus = "https://media.discordapp.net/attachments/879961726852927500/879970202459177000/icon_klaus.png",
    koalefant_summer = "https://media.discordapp.net/attachments/879961726852927500/879970204187258890/icon_koalefant_summer.png",
    koalefant_winter = "https://media.discordapp.net/attachments/879961726852927500/879970206007570492/icon_koalefant_winter.png",
    krampus = "https://media.discordapp.net/attachments/879961726852927500/879970207668510731/icon_krampus.png",
    leif = "https://media.discordapp.net/attachments/879961726852927500/879970209107161098/icon_leif.png",
    leif_sparse = "https://media.discordapp.net/attachments/879961726852927500/879970211166584912/icon_leif_sparse.png",
    lordfruitfly = "https://media.discordapp.net/attachments/879961726852927500/879970212391305216/icon_lordfruitfly.png",
    malbatross = "https://media.discordapp.net/attachments/879961726852927500/879970214681387038/icon_malbatross.png",
    minotaur = "https://media.discordapp.net/attachments/879961726852927500/879970216606568448/icon_minotaur.png",
    moose = "https://media.discordapp.net/attachments/879961726852927500/879970218754056212/icon_moose.png",
    shadow_bishop_level1 = "https://media.discordapp.net/attachments/879961726852927500/879970220834443284/icon_shadow_bishop_level1.png",
    shadow_bishop_level2 = "https://media.discordapp.net/attachments/879961726852927500/879970222788972544/icon_shadow_bishop_level2.png",
    shadow_bishop_level3 = "https://media.discordapp.net/attachments/879961726852927500/879970224911298630/icon_shadow_bishop_level3.png",
    shadow_knight_level1 = "https://media.discordapp.net/attachments/879961726852927500/879970227096530944/icon_shadow_knight_level1.png",
    shadow_knight_level2 = "https://media.discordapp.net/attachments/879961726852927500/879970229285945434/icon_shadow_knight_level2.png",
    shadow_knight_level3 = "https://media.discordapp.net/attachments/879961726852927500/879970230858821712/icon_shadow_knight_level3.png",
    shadow_rook_level1 = "https://media.discordapp.net/attachments/879961726852927500/879970233060823071/icon_shadow_rook_level1.png",
    shadow_rook_level2 = "https://media.discordapp.net/attachments/879961726852927500/879970235359326228/icon_shadow_rook_level2.png",
    shadow_rook_level3 = "https://media.discordapp.net/attachments/879961726852927500/879970236852486145/icon_shadow_rook_level3.png",
    spat = "https://media.discordapp.net/attachments/879961726852927500/879970238706356314/icon_spat.png",
    spiderqueen = "https://media.discordapp.net/attachments/879961726852927500/879970240786731018/icon_spiderqueen.png",
    stalker_atrium = "https://media.discordapp.net/attachments/879961726852927500/879971594435457044/icon_stalker_atrium.png",
    stalker_forest = "https://media.discordapp.net/attachments/879961726852927500/879971595957977088/icon_stalker_forest.png",
    stalker = "https://media.discordapp.net/attachments/879961726852927500/879971597476311080/icon_stalker.png",
    toadstool_dark = "https://media.discordapp.net/attachments/879961726852927500/879971825864572958/icon_toadstool_dark.png",
    toadstool = "https://media.discordapp.net/attachments/879961726852927500/879971827861061672/icon_toadstool.png",
    walrus = "https://media.discordapp.net/attachments/879961726852927500/879971854171914260/icon_walrus.png",
    warg = "https://media.discordapp.net/attachments/879978511203463179/881558989983350794/icon_warg.png"
}

return M
