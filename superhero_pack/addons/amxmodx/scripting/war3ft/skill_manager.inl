SM_Init()
{
	// Set up the Skill Owners
	g_SkillOwner[SKILL_VAMPIRICAURA			]	= RACE_UNDEAD;
	g_SkillOwner[SKILL_UNHOLYAURA			]	= RACE_UNDEAD;
	g_SkillOwner[SKILL_LEVITATION			]	= RACE_UNDEAD;
	g_SkillOwner[ULTIMATE_SUICIDE			]	= RACE_UNDEAD;

	g_SkillOwner[SKILL_INVISIBILITY			]	= RACE_HUMAN;
	g_SkillOwner[SKILL_DEVOTION				]	= RACE_HUMAN;
	g_SkillOwner[SKILL_BASH					]	= RACE_HUMAN;
	g_SkillOwner[ULTIMATE_BLINK				]	= RACE_HUMAN;

	g_SkillOwner[SKILL_CRITICALSTRIKE		]	= RACE_ORC;
	g_SkillOwner[SKILL_CRITICALGRENADE		]	= RACE_ORC;
	g_SkillOwner[SKILL_REINCARNATION		]	= RACE_ORC;
	g_SkillOwner[ULTIMATE_CHAINLIGHTNING	]	= RACE_ORC;

	g_SkillOwner[SKILL_EVASION				]	= RACE_ELF;
	g_SkillOwner[SKILL_THORNS				]	= RACE_ELF;
	g_SkillOwner[SKILL_TRUESHOT				]	= RACE_ELF;
	g_SkillOwner[ULTIMATE_ENTANGLE			]	= RACE_ELF;

	g_SkillOwner[SKILL_PHOENIX				]	= RACE_BLOOD;
	g_SkillOwner[SKILL_BANISH				]	= RACE_BLOOD;
	g_SkillOwner[SKILL_SIPHONMANA			]	= RACE_BLOOD;
	g_SkillOwner[ULTIMATE_IMMOLATE			]	= RACE_BLOOD;
	g_SkillOwner[PASS_RESISTANTSKIN			]	= RACE_BLOOD;

	g_SkillOwner[SKILL_HEALINGWAVE			]	= RACE_SHADOW;
	g_SkillOwner[SKILL_HEX					]	= RACE_SHADOW;
	g_SkillOwner[SKILL_SERPENTWARD			]	= RACE_SHADOW;
	g_SkillOwner[ULTIMATE_BIGBADVOODOO		]	= RACE_SHADOW;
	g_SkillOwner[PASS_UNSTABLECONCOCTION	]	= RACE_SHADOW;

	g_SkillOwner[SKILL_FANOFKNIVES			]	= RACE_WARDEN;
	g_SkillOwner[SKILL_BLINK				]	= RACE_WARDEN;
	g_SkillOwner[SKILL_SHADOWSTRIKE			]	= RACE_WARDEN;
	g_SkillOwner[ULTIMATE_VENGEANCE			]	= RACE_WARDEN;
	g_SkillOwner[PASS_HARDENEDSKIN			]	= RACE_WARDEN;

	g_SkillOwner[SKILL_IMPALE				]	= RACE_CRYPT;
	g_SkillOwner[SKILL_SPIKEDCARAPACE		]	= RACE_CRYPT;
	g_SkillOwner[SKILL_CARRIONBEETLES		]	= RACE_CRYPT;
	g_SkillOwner[ULTIMATE_LOCUSTSWARM		]	= RACE_CRYPT;
	g_SkillOwner[PASS_ORB					]	= RACE_CRYPT;
	
	g_SkillOwner[SKILL_GIFTOFNAARU]           = RACE_DRAENEI;

	
	// Set up the skill types
	g_SkillType[SKILL_VAMPIRICAURA			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_UNHOLYAURA			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_LEVITATION			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_SUICIDE			]	= SKILL_TYPE_ULTIMATE;

	g_SkillType[SKILL_INVISIBILITY			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_DEVOTION				]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BASH					]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_BLINK				]	= SKILL_TYPE_ULTIMATE;

	g_SkillType[SKILL_CRITICALSTRIKE		]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CRITICALGRENADE		]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_REINCARNATION			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_CHAINLIGHTNING		]	= SKILL_TYPE_ULTIMATE;

	g_SkillType[SKILL_EVASION				]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_THORNS				]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TRUESHOT				]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_ENTANGLE			]	= SKILL_TYPE_ULTIMATE;

	g_SkillType[SKILL_PHOENIX				]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BANISH				]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SIPHONMANA			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_IMMOLATE			]	= SKILL_TYPE_ULTIMATE;
	g_SkillType[PASS_RESISTANTSKIN			]	= SKILL_TYPE_PASSIVE;

	g_SkillType[SKILL_HEALINGWAVE			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HEX					]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SERPENTWARD			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_BIGBADVOODOO		]	= SKILL_TYPE_ULTIMATE;
	g_SkillType[PASS_UNSTABLECONCOCTION		]	= SKILL_TYPE_PASSIVE;

	g_SkillType[SKILL_FANOFKNIVES			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BLINK					]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SHADOWSTRIKE			]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_VENGEANCE			]	= SKILL_TYPE_ULTIMATE;
	g_SkillType[PASS_HARDENEDSKIN			]	= SKILL_TYPE_PASSIVE;

	g_SkillType[SKILL_IMPALE				]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SPIKEDCARAPACE		]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CARRIONBEETLES		]	= SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_LOCUSTSWARM		]	= SKILL_TYPE_ULTIMATE;
	g_SkillType[PASS_ORB					]	= SKILL_TYPE_PASSIVE;

	g_SkillType[SKILL_GIFTOFNAARU]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_VINDICATORSHIELD]        = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HOLYSMITE]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_LIGHTWRATH]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_DARKFLIGHT]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SAVAGEREND]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BLOODHUNT]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_WORGENFRENZY]         = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_ROCKETBARRAGE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TIMEISMONEY]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_EXPLOSIVETRAP]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_BIGBOOM]              = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_WARSTOMP]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ENDURANCEAURA]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_EARTHSHOCK]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_REINCARNATION]        = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_DETONATE]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HARVESTENERGY]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_FADE]                    = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_SPIRITOFTHEFOREST]    = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_BERSERKING]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_REGENERATION]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_VOODOOHEX]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_TROLLRAGE]            = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_DRUNKENHAZE]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BREATHOFFIRE]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ROLL]                    = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_STORMEARTHANDFIRE]    = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FELFLAME]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_DEMONICLEAP]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SHADOWCLEAVE]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_METAMORPHOSIS]        = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_HIBERNATE]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_MIGHTYROAR]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TOTEMSLAM]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_BEARFORM]             = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_ENGINEERINGMASTERY]      = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ESCAPEARTIST]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_GADGETRY]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_MECHANICALGENIUS]     = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FROSTNOVA]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_FORKEDLIGHTNING]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ENSNARE]                 = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_WAVE]            = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_TWOHEADEDSTRIKE]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_OGRESTRENGTH]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CRUSHINGBLOW]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_OGREMAGI]             = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_MURLOCRUSH]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_AQUATICESCAPE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SLIPPERYSKIN]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_CALLOFTHEDEEP]        = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_STAMPEDE]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TRAMPLE]                 = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HARPOONTOOSS]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_CENTAURCHARGE]        = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_CORRUPTION]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CURSEOFWEAKNESS]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SHADOWSTEP]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_DARKRITUAL]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_TITANSGRIP]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_EARTHSHAKER]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_COSMICBEAM]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_WRATHOFTHETITANS]     = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_HOLYNOVA]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_LIGHTOFDAWN]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_PURIFY]                  = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_BLESSINGOFTHENAARU]   = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_STONEFORM]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_GUNMASTERY]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_EXPLORERSBOUNTY]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_AVATAR]               = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_TOUCHOFTHEGRAVE]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_WILLOFTHEFORSAKEN]       = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BLIGHTSPRAY]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_PLAGUEOFUNDEATH]      = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_STONESKIN]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_GROUNDSLAM]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HARDENEDRESOLVE]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_LIVINGSTONE]          = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_HYPERCHARGE]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_COMBATANALYSIS]          = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_EMERGENCYREPAIRS]        = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_MECHAOVERDRIVE]       = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_ARCANEBLAST]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_MANASHIELD]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ANCIENTKNOWLEDGE]        = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_ARCANEASCENDANCY]     = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FISHINGNET]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ICEARMOR]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TUSKSTRIKE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_CALLOFTHETIDES]       = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_RUNICEMPOWERMENT]        = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_DRAGONSROAR]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BATTLEHARDENED]          = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_VRYKULSWRATH]         = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_GIANTSSTOMP]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_MOUNTAINSTRENGTH]        = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BOULDERTHROW]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_COLOSSALSMASH]        = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_BAGOFTRICKS]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SCAVENGERSCUNNING]       = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_DUSTCLOUD]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_NOMADICSPIRIT]        = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_LIGHTNINGLASH]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_STONEGUARD]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SPIRITLINK]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_TITANSWILL]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_ROOTSTRIKE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_NATURESEMBRACE]          = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BARKSKIN]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_ANCIENTAWAKENING]     = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FELRESISTANCE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CHAINHEAL]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_DARKSTRIKE]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_FERALSPIRIT]          = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_NATURESWRATH]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_FORESTSGRACE]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HEALINGTOUCH]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_WRATHOFTHEWILDS]      = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FIREBRAND]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_WILDCHARGE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_BURNINGRAGE]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_INFERNOCHARGE]        = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_BLADEDDANCE]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_AMBERPRISON]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_QUICKSTRIKE]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_SWARMSFURY]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_POISONSPIT]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CLAWFRENZY]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CAMOUFLAGE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_PRIMALRAGE]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_DIMENSIONALSHIFT]        = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_MANADRAIN]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ARCANECLOAK]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_NETHERSTORM]          = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_PETRIFY]                 = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_EARTHQUAKE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ROCKARMOR]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_STONETITAN]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_WATERJET]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HEALINGRAIN]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TIDALSURGE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_WATERSPOUT]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_BANANATOSS]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_AGILITYBOOST]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_FRENZIEDDANCE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_PRIMALHOWL]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_DARKTALON]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SOLARBEAM]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CURSEOFSETHE]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_SHADOWNOVA]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_SPOREBUST]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_REGROWTH]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_FUNGUSSHIELD]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_SPOREEXPLOSION]       = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_RAZORQUILLS]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CHARGE]                  = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_EARTHSPIKE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_STAMPEDE]             = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_DRAGONSBREATH]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_WINGBUFFET]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TAILSWIPE]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_DRAGONFURY]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_VICIOUSBITE]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_GNOLLHOWL]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SCAVENGERSINSTINCT]      = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_PACKLEADER]           = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_SCREECH]                 = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TALONSTRIKE]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_WINDGUST]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_TEMPEST]              = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_CANDLESASH]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TUNNELING]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SCURRY]                  = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_CAVEIN]               = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_SANDBLAST]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_OBSIDIANSKIN]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_DUSTSTORM]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_GUARDIANOFTHESANDS]   = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FIERCESLASH]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HUNTERSMARK]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_PACKTACTICS]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_WOLVARSWRATH]         = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_SEAMIST]                 = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_GHOSTLYSTRIKE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_UNDYINGWILL]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_WRATHOFTHEKVALDIR]    = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_SCARABSWARM]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SANDSTORM]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_GUARDIANSSHIELD]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_ANUBISATHREBIRTH]     = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FROSTBREATH]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SLAM]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_MASSIVECHARGE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_GLACIALCRUSH]         = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_LUCKYDO]                 = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_PACKMENTALITY]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_NIMBLEFINGERS]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_GRUMMLEFORTUNE]       = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_SHELLSHIELD]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TIDALWAVE]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_WISDOMOFTHEAGES]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_TORTOISEGUARDIAN]     = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_LIGHTNINGCOIL]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_VENOMSPIT]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CONSTRICT]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_SERPENTSRAGE]         = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_PSYCHICSCREAM]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SANDTRAP]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HIVEMIND]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_SWARMCALL]            = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_VOIDBOLT]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SHADOWSHIELD]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SIPHONLIFE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_VOIDERUPTION]         = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FELCLEAVE]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_DEMONICROAR]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HELLFIRE]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_FELSTORM]             = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_TOXICSPRAY]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_AQUATICDASH]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SLIPPERYESCAPE]          = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_GILBLINFRENZY]        = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_NATURESCHARM]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ENTANGLINGROOTS]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HEALINGWATERS]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_FORESTSBLESSING]      = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FLAMEBURST]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_WATERSPIKE]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_QUAKE]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_ELEMENTALOVERLOAD]    = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_FIRELASH]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_MOLTENARMOR]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_INFERNOCHARGE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_LAVABURST]            = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_MINDFLAY]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SHADOWEMBRACE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_CORRUPTINGTOUCH]         = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_VOIDCONSUMPTION]      = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_BATTLEROAR]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_ICESHIELD]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_SPIRITBOND]              = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_TAUNKASRESOLVE]       = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_MOONFIRE]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_STARFALL]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_NATURESTOUCH]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_WRATHOFELUNE]         = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_SEABLAST]                = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_FREEDOMCALL]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_TIDALSTRIKE]             = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_UNSHACKLEDSFURY]      = SKILL_TYPE_ULTIMATE;
	
	g_SkillType[SKILL_WATERWHIP]               = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_HEALINGTIDES]            = SKILL_TYPE_TRAINABLE;
	g_SkillType[SKILL_DEEPSEASTRIKE]           = SKILL_TYPE_TRAINABLE;
	g_SkillType[ULTIMATE_TIDALWAVE]            = SKILL_TYPE_ULTIMATE;























	// Set up the skill order
	g_SkillOrder[SKILL_VAMPIRICAURA			]	= SKILL_POS_1;
	g_SkillOrder[SKILL_UNHOLYAURA			]	= SKILL_POS_2;
	g_SkillOrder[SKILL_LEVITATION			]	= SKILL_POS_3;
	g_SkillOrder[ULTIMATE_SUICIDE			]	= SKILL_POS_4;

	g_SkillOrder[SKILL_INVISIBILITY			]	= SKILL_POS_1;
	g_SkillOrder[SKILL_DEVOTION				]	= SKILL_POS_2;
	g_SkillOrder[SKILL_BASH					]	= SKILL_POS_3;
	g_SkillOrder[ULTIMATE_BLINK				]	= SKILL_POS_4;

	g_SkillOrder[SKILL_CRITICALSTRIKE		]	= SKILL_POS_1;
	g_SkillOrder[SKILL_CRITICALGRENADE		]	= SKILL_POS_2;
	g_SkillOrder[SKILL_REINCARNATION		]	= SKILL_POS_3;
	g_SkillOrder[ULTIMATE_CHAINLIGHTNING	]	= SKILL_POS_4;

	g_SkillOrder[SKILL_EVASION				]	= SKILL_POS_1;
	g_SkillOrder[SKILL_THORNS				]	= SKILL_POS_2;
	g_SkillOrder[SKILL_TRUESHOT				]	= SKILL_POS_3;
	g_SkillOrder[ULTIMATE_ENTANGLE			]	= SKILL_POS_4;

	g_SkillOrder[SKILL_PHOENIX				]	= SKILL_POS_1;
	g_SkillOrder[SKILL_BANISH				]	= SKILL_POS_2;
	g_SkillOrder[SKILL_SIPHONMANA			]	= SKILL_POS_3;
	g_SkillOrder[ULTIMATE_IMMOLATE			]	= SKILL_POS_4;
	g_SkillOrder[PASS_RESISTANTSKIN			]	= SKILL_POS_NONE;

	g_SkillOrder[SKILL_HEALINGWAVE			]	= SKILL_POS_1;
	g_SkillOrder[SKILL_HEX					]	= SKILL_POS_2;
	g_SkillOrder[SKILL_SERPENTWARD			]	= SKILL_POS_3;
	g_SkillOrder[ULTIMATE_BIGBADVOODOO		]	= SKILL_POS_4;
	g_SkillOrder[PASS_UNSTABLECONCOCTION	]	= SKILL_POS_NONE;

	g_SkillOrder[SKILL_FANOFKNIVES			]	= SKILL_POS_1;
	g_SkillOrder[SKILL_BLINK				]	= SKILL_POS_2;
	g_SkillOrder[SKILL_SHADOWSTRIKE			]	= SKILL_POS_3;
	g_SkillOrder[ULTIMATE_VENGEANCE			]	= SKILL_POS_4;
	g_SkillOrder[PASS_HARDENEDSKIN			]	= SKILL_POS_NONE;

	g_SkillOrder[SKILL_IMPALE				]	= SKILL_POS_1;
	g_SkillOrder[SKILL_SPIKEDCARAPACE		]	= SKILL_POS_2;
	g_SkillOrder[SKILL_CARRIONBEETLES		]	= SKILL_POS_3;
	g_SkillOrder[ULTIMATE_LOCUSTSWARM		]	= SKILL_POS_4;
	g_SkillOrder[PASS_ORB					]	= SKILL_POS_NONE;
	
	g_SkillOrder[SKILL_GIFTOFNAARU]            = SKILL_POS_1;
	g_SkillOrder[SKILL_VINDICATORSHIELD]       = SKILL_POS_2;
	g_SkillOrder[SKILL_HOLYSMITE]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_LIGHTWRATH]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_DARKFLIGHT]             = SKILL_POS_1;
	g_SkillOrder[SKILL_SAVAGEREND]             = SKILL_POS_2;
	g_SkillOrder[SKILL_BLOODHUNT]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_WORGENFRENZY]        = SKILL_POS_4;
	
	g_SkillOrder[SKILL_ROCKETBARRAGE]          = SKILL_POS_1;
	g_SkillOrder[SKILL_TIMEISMONEY]            = SKILL_POS_2;
	g_SkillOrder[SKILL_EXPLOSIVETRAP]          = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_BIGBOOM]             = SKILL_POS_4;
	
	g_SkillOrder[SKILL_WARSTOMP]               = SKILL_POS_1;
	g_SkillOrder[SKILL_ENDURANCEAURA]          = SKILL_POS_2;
	g_SkillOrder[SKILL_EARTHSHOCK]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_REINCARNATION]       = SKILL_POS_4;
	
	g_SkillOrder[SKILL_DETONATE]               = SKILL_POS_1;
	g_SkillOrder[SKILL_HARVESTENERGY]          = SKILL_POS_2;
	g_SkillOrder[SKILL_FADE]                   = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_SPIRITOFTHEFOREST]   = SKILL_POS_4;
	
	g_SkillOrder[SKILL_BERSERKING]             = SKILL_POS_1;
	g_SkillOrder[SKILL_REGENERATION]           = SKILL_POS_2;
	g_SkillOrder[SKILL_VOODOOHEX]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_TROLLRAGE]           = SKILL_POS_4;
	
	g_SkillOrder[SKILL_DRUNKENHAZE]            = SKILL_POS_1;
	g_SkillOrder[SKILL_BREATHOFFIRE]           = SKILL_POS_2;
	g_SkillOrder[SKILL_ROLL]                   = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_STORMEARTHANDFIRE]   = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FELFLAME]               = SKILL_POS_1;
	g_SkillOrder[SKILL_DEMONICLEAP]            = SKILL_POS_2;
	g_SkillOrder[SKILL_SHADOWCLEAVE]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_METAMORPHOSIS]       = SKILL_POS_4;
	
	g_SkillOrder[SKILL_HIBERNATE]              = SKILL_POS_1;
	g_SkillOrder[SKILL_MIGHTYROAR]             = SKILL_POS_2;
	g_SkillOrder[SKILL_TOTEMSLAM]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_BEARFORM]            = SKILL_POS_4;
	
	g_SkillOrder[SKILL_ENGINEERINGMASTERY]     = SKILL_POS_1;
	g_SkillOrder[SKILL_ESCAPEARTIST]           = SKILL_POS_2;
	g_SkillOrder[SKILL_GADGETRY]               = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_MECHANICALGENIUS]    = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FROSTNOVA]              = SKILL_POS_1;
	g_SkillOrder[SKILL_FORKEDLIGHTNING]        = SKILL_POS_2;
	g_SkillOrder[SKILL_ENSNARE]                = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_WAVE]           = SKILL_POS_4;
	
	g_SkillOrder[SKILL_TWOHEADEDSTRIKE]        = SKILL_POS_1;
	g_SkillOrder[SKILL_OGRESTRENGTH]           = SKILL_POS_2;
	g_SkillOrder[SKILL_CRUSHINGBLOW]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_OGREMAGI]            = SKILL_POS_4;
	
	g_SkillOrder[SKILL_MURLOCRUSH]             = SKILL_POS_1;
	g_SkillOrder[SKILL_AQUATICESCAPE]          = SKILL_POS_2;
	g_SkillOrder[SKILL_SLIPPERYSKIN]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_CALLOFTHEDEEP]       = SKILL_POS_4;
	
	g_SkillOrder[SKILL_STAMPEDE]               = SKILL_POS_1;
	g_SkillOrder[SKILL_TRAMPLE]                = SKILL_POS_2;
	g_SkillOrder[SKILL_HARPOONTOOSS]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_CENTAURCHARGE]       = SKILL_POS_4;
	
	g_SkillOrder[SKILL_CORRUPTION]             = SKILL_POS_1;
	g_SkillOrder[SKILL_CURSEOFWEAKNESS]        = SKILL_POS_2;
	g_SkillOrder[SKILL_SHADOWSTEP]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_DARKRITUAL]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_TITANSGRIP]             = SKILL_POS_1;
	g_SkillOrder[SKILL_EARTHSHAKER]            = SKILL_POS_2;
	g_SkillOrder[SKILL_COSMICBEAM]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_WRATHOFTHETITANS]    = SKILL_POS_4;
	
	g_SkillOrder[SKILL_HOLYNOVA]               = SKILL_POS_1;
	g_SkillOrder[SKILL_LIGHTOFDAWN]            = SKILL_POS_2;
	g_SkillOrder[SKILL_PURIFY]                 = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_BLESSINGOFTHENAARU]  = SKILL_POS_4;
	
	g_SkillOrder[SKILL_STONEFORM]              = SKILL_POS_1;
	g_SkillOrder[SKILL_GUNMASTERY]             = SKILL_POS_2;
	g_SkillOrder[SKILL_EXPLORERSBOUNTY]        = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_AVATAR]              = SKILL_POS_4;
	
	g_SkillOrder[SKILL_TOUCHOFTHEGRAVE]        = SKILL_POS_1;
	g_SkillOrder[SKILL_WILLOFTHEFORSAKEN]      = SKILL_POS_2;
	g_SkillOrder[SKILL_BLIGHTSPRAY]            = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_PLAGUEOFUNDEATH]     = SKILL_POS_4;
	
	g_SkillOrder[SKILL_STONESKIN]              = SKILL_POS_1;
	g_SkillOrder[SKILL_GROUNDSLAM]             = SKILL_POS_2;
	g_SkillOrder[SKILL_HARDENEDRESOLVE]        = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_LIVINGSTONE]         = SKILL_POS_4;
	
	g_SkillOrder[SKILL_HYPERCHARGE]            = SKILL_POS_1;
	g_SkillOrder[SKILL_COMBATANALYSIS]         = SKILL_POS_2;
	g_SkillOrder[SKILL_EMERGENCYREPAIRS]       = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_MECHAOVERDRIVE]      = SKILL_POS_4;
	
	g_SkillOrder[SKILL_ARCANEBLAST]            = SKILL_POS_1;
	g_SkillOrder[SKILL_MANASHIELD]             = SKILL_POS_2;
	g_SkillOrder[SKILL_ANCIENTKNOWLEDGE]       = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_ARCANEASCENDANCY]    = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FISHINGNET]             = SKILL_POS_1;
	g_SkillOrder[SKILL_ICEARMOR]               = SKILL_POS_2;
	g_SkillOrder[SKILL_TUSKSTRIKE]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_CALLOFTHETIDES]      = SKILL_POS_4;
	
	g_SkillOrder[SKILL_RUNICEMPOWERMENT]       = SKILL_POS_1;
	g_SkillOrder[SKILL_DRAGONSROAR]            = SKILL_POS_2;
	g_SkillOrder[SKILL_BATTLEHARDENED]         = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_VRYKULSWRATH]        = SKILL_POS_4;
	
	g_SkillOrder[SKILL_GIANTSSTOMP]            = SKILL_POS_1;
	g_SkillOrder[SKILL_MOUNTAINSTRENGTH]       = SKILL_POS_2;
	g_SkillOrder[SKILL_BOULDERTHROW]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_COLOSSALSMASH]       = SKILL_POS_4;
	
	g_SkillOrder[SKILL_BAGOFTRICKS]            = SKILL_POS_1;
	g_SkillOrder[SKILL_SCAVENGERSCUNNING]      = SKILL_POS_2;
	g_SkillOrder[SKILL_DUSTCLOUD]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_NOMADICSPIRIT]       = SKILL_POS_4;
	
	g_SkillOrder[SKILL_LIGHTNINGLASH]          = SKILL_POS_1;
	g_SkillOrder[SKILL_STONEGUARD]             = SKILL_POS_2;
	g_SkillOrder[SKILL_SPIRITLINK]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_TITANSWILL]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_ROOTSTRIKE]             = SKILL_POS_1;
	g_SkillOrder[SKILL_NATURESEMBRACE]         = SKILL_POS_2;
	g_SkillOrder[SKILL_BARKSKIN]               = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_ANCIENTAWAKENING]    = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FELRESISTANCE]          = SKILL_POS_1;
	g_SkillOrder[SKILL_CHAINHEAL]              = SKILL_POS_2;
	g_SkillOrder[SKILL_DARKSTRIKE]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_FERALSPIRIT]         = SKILL_POS_4;
	
	g_SkillOrder[SKILL_NATURESWRATH]           = SKILL_POS_1;
	g_SkillOrder[SKILL_FORESTSGRACE]           = SKILL_POS_2;
	g_SkillOrder[SKILL_HEALINGTOUCH]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_WRATHOFTHEWILDS]     = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FIREBRAND]              = SKILL_POS_1;
	g_SkillOrder[SKILL_WILDCHARGE]             = SKILL_POS_2;
	g_SkillOrder[SKILL_BURNINGRAGE]            = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_INFERNOCHARGE]       = SKILL_POS_4;
	
	g_SkillOrder[SKILL_BLADEDDANCE]            = SKILL_POS_1;
	g_SkillOrder[SKILL_AMBERPRISON]            = SKILL_POS_2;
	g_SkillOrder[SKILL_QUICKSTRIKE]            = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_SWARMSFURY]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_POISONSPIT]             = SKILL_POS_1;
	g_SkillOrder[SKILL_CLAWFRENZY]             = SKILL_POS_2;
	g_SkillOrder[SKILL_CAMOUFLAGE]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_PRIMALRAGE]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_DIMENSIONALSHIFT]       = SKILL_POS_1;
	g_SkillOrder[SKILL_MANADRAIN]              = SKILL_POS_2;
	g_SkillOrder[SKILL_ARCANECLOAK]            = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_NETHERSTORM]         = SKILL_POS_4;
	
	g_SkillOrder[SKILL_PETRIFY]                = SKILL_POS_1;
	g_SkillOrder[SKILL_EARTHQUAKE]             = SKILL_POS_2;
	g_SkillOrder[SKILL_ROCKARMOR]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_STONETITAN]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_WATERJET]               = SKILL_POS_1;
	g_SkillOrder[SKILL_HEALINGRAIN]            = SKILL_POS_2;
	g_SkillOrder[SKILL_TIDALSURGE]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_WATERSPOUT]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_BANANATOSS]             = SKILL_POS_1;
	g_SkillOrder[SKILL_AGILITYBOOST]           = SKILL_POS_2;
	g_SkillOrder[SKILL_FRENZIEDDANCE]          = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_PRIMALHOWL]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_DARKTALON]              = SKILL_POS_1;
	g_SkillOrder[SKILL_SOLARBEAM]              = SKILL_POS_2;
	g_SkillOrder[SKILL_CURSEOFSETHE]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_SHADOWNOVA]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_SPOREBUST]              = SKILL_POS_1;
	g_SkillOrder[SKILL_REGROWTH]               = SKILL_POS_2;
	g_SkillOrder[SKILL_FUNGUSSHIELD]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_SPOREEXPLOSION]      = SKILL_POS_4;
	
	g_SkillOrder[SKILL_RAZORQUILLS]            = SKILL_POS_1;
	g_SkillOrder[SKILL_CHARGE]                 = SKILL_POS_2;
	g_SkillOrder[SKILL_EARTHSPIKE]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_STAMPEDE]            = SKILL_POS_4;
	
	g_SkillOrder[SKILL_DRAGONSBREATH]          = SKILL_POS_1;
	g_SkillOrder[SKILL_WINGBUFFET]             = SKILL_POS_2;
	g_SkillOrder[SKILL_TAILSWIPE]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_DRAGONFURY]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_VICIOUSBITE]            = SKILL_POS_1;
	g_SkillOrder[SKILL_GNOLLHOWL]              = SKILL_POS_2;
	g_SkillOrder[SKILL_SCAVENGERSINSTINCT]     = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_PACKLEADER]          = SKILL_POS_4;
	
	g_SkillOrder[SKILL_SCREECH]                = SKILL_POS_1;
	g_SkillOrder[SKILL_TALONSTRIKE]            = SKILL_POS_2;
	g_SkillOrder[SKILL_WINDGUST]               = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_TEMPEST]             = SKILL_POS_4;
	
	g_SkillOrder[SKILL_CANDLESASH]             = SKILL_POS_1;
	g_SkillOrder[SKILL_TUNNELING]              = SKILL_POS_2;
	g_SkillOrder[SKILL_SCURRY]                 = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_CAVEIN]              = SKILL_POS_4;
	
	g_SkillOrder[SKILL_SANDBLAST]              = SKILL_POS_1;
	g_SkillOrder[SKILL_OBSIDIANSKIN]           = SKILL_POS_2;
	g_SkillOrder[SKILL_DUSTSTORM]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_GUARDIANOFTHESANDS]  = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FIERCESLASH]            = SKILL_POS_1;
	g_SkillOrder[SKILL_HUNTERSMARK]            = SKILL_POS_2;
	g_SkillOrder[SKILL_PACKTACTICS]            = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_WOLVARSWRATH]        = SKILL_POS_4;
	
	g_SkillOrder[SKILL_SEAMIST]                = SKILL_POS_1;
	g_SkillOrder[SKILL_GHOSTLYSTRIKE]          = SKILL_POS_2;
	g_SkillOrder[SKILL_UNDYINGWILL]            = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_WRATHOFTHEKVALDIR]   = SKILL_POS_4;
	
	g_SkillOrder[SKILL_SCARABSWARM]            = SKILL_POS_1;
	g_SkillOrder[SKILL_SANDSTORM]              = SKILL_POS_2;
	g_SkillOrder[SKILL_GUARDIANSSHIELD]        = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_ANUBISATHREBIRTH]    = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FROSTBREATH]            = SKILL_POS_1;
	g_SkillOrder[SKILL_SLAM]             		= SKILL_POS_2;
	g_SkillOrder[SKILL_MASSIVECHARGE]          = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_GLACIALCRUSH]        = SKILL_POS_4;
	
	g_SkillOrder[SKILL_LUCKYDO]                = SKILL_POS_1;
	g_SkillOrder[SKILL_PACKMENTALITY]          = SKILL_POS_2;
	g_SkillOrder[SKILL_NIMBLEFINGERS]          = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_GRUMMLEFORTUNE]      = SKILL_POS_4;
	
	g_SkillOrder[SKILL_SHELLSHIELD]            = SKILL_POS_1;
	g_SkillOrder[SKILL_TIDALWAVE]              = SKILL_POS_2;
	g_SkillOrder[SKILL_WISDOMOFTHEAGES]        = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_TORTOISEGUARDIAN]    = SKILL_POS_4;
	
	g_SkillOrder[SKILL_LIGHTNINGCOIL]          = SKILL_POS_1;
	g_SkillOrder[SKILL_VENOMSPIT]              = SKILL_POS_2;
	g_SkillOrder[SKILL_CONSTRICT]              = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_SERPENTSRAGE]        = SKILL_POS_4;
	
	g_SkillOrder[SKILL_PSYCHICSCREAM]          = SKILL_POS_1;
	g_SkillOrder[SKILL_SANDTRAP]               = SKILL_POS_2;
	g_SkillOrder[SKILL_HIVEMIND]               = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_SWARMCALL]           = SKILL_POS_4;
	
	g_SkillOrder[SKILL_VOIDBOLT]               = SKILL_POS_1;
	g_SkillOrder[SKILL_SHADOWSHIELD]           = SKILL_POS_2;
	g_SkillOrder[SKILL_SIPHONLIFE]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_VOIDERUPTION]        = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FELCLEAVE]              = SKILL_POS_1;
	g_SkillOrder[SKILL_DEMONICROAR]            = SKILL_POS_2;
	g_SkillOrder[SKILL_HELLFIRE]               = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_FELSTORM]            = SKILL_POS_4;
	
	g_SkillOrder[SKILL_TOXICSPRAY]             = SKILL_POS_1;
	g_SkillOrder[SKILL_AQUATICDASH]            = SKILL_POS_2;
	g_SkillOrder[SKILL_SLIPPERYESCAPE]         = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_GILBLINFRENZY]       = SKILL_POS_4;
	
	g_SkillOrder[SKILL_NATURESCHARM]           = SKILL_POS_1;
	g_SkillOrder[SKILL_ENTANGLINGROOTS]        = SKILL_POS_2;
	g_SkillOrder[SKILL_HEALINGWATERS]          = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_FORESTSBLESSING]     = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FLAMEBURST]             = SKILL_POS_1;
	g_SkillOrder[SKILL_WATERSPIKE]               = SKILL_POS_2;
	g_SkillOrder[SKILL_QUAKE]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_ELEMENTALOVERLOAD]   = SKILL_POS_4;
	
	g_SkillOrder[SKILL_FIRELASH]               = SKILL_POS_1;
	g_SkillOrder[SKILL_MOLTENARMOR]            = SKILL_POS_2;
	g_SkillOrder[SKILL_INFERNOCHARGE]          = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_LAVABURST]           = SKILL_POS_4;
	
	g_SkillOrder[SKILL_MINDFLAY]               = SKILL_POS_1;
	g_SkillOrder[SKILL_SHADOWEMBRACE]          = SKILL_POS_2;
	g_SkillOrder[SKILL_CORRUPTINGTOUCH]        = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_VOIDCONSUMPTION]     = SKILL_POS_4;
	
	g_SkillOrder[SKILL_BATTLEROAR]             = SKILL_POS_1;
	g_SkillOrder[SKILL_ICESHIELD]              = SKILL_POS_2;
	g_SkillOrder[SKILL_SPIRITBOND]             = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_TAUNKASRESOLVE]      = SKILL_POS_4;
	
	g_SkillOrder[SKILL_MOONFIRE]               = SKILL_POS_1;
	g_SkillOrder[SKILL_STARFALL]               = SKILL_POS_2;
	g_SkillOrder[SKILL_NATURESTOUCH]           = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_WRATHOFELUNE]        = SKILL_POS_4;
	
	g_SkillOrder[SKILL_SEABLAST]               = SKILL_POS_1;
	g_SkillOrder[SKILL_FREEDOMCALL]            = SKILL_POS_2;
	g_SkillOrder[SKILL_TIDALSTRIKE]            = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_UNSHACKLEDSFURY]     = SKILL_POS_4;
	
	g_SkillOrder[SKILL_WATERWHIP]              = SKILL_POS_1;
	g_SkillOrder[SKILL_HEALINGTIDES]           = SKILL_POS_2;
	g_SkillOrder[SKILL_DEEPSEASTRIKE]          = SKILL_POS_3;
	g_SkillOrder[ULTIMATE_TIDALWAVE]           = SKILL_POS_4;
	
		
		
		
		
		
		
	
}

/***** NEW SKILL SET UP BELOW!! *****/

SM_SetPlayerRace( id, iRace )
{
	static i;

	// Set up the chameleon skills
	if ( iRace == RACE_CHAMELEON )
	{
		g_bPlayerSkills[id][g_ChamSkills[0]] = true;
		g_bPlayerSkills[id][g_ChamSkills[1]] = true;
		g_bPlayerSkills[id][g_ChamSkills[2]] = true;
		g_bPlayerSkills[id][g_ChamSkills[3]] = true;
		g_bPlayerSkills[id][g_ChamSkills[4]] = true;
	}

	else
	{
		// Loop through all possible skills to find all valid skills for this race
		for ( i = 0; i < MAX_SKILLS; i++ )
		{

			// Valid skill found, assign it to this player
			if ( g_SkillOwner[i] == iRace )
			{
				g_bPlayerSkills[id][i] = true;
			}
		}
	}
}

// Function will reset all of the user's skill levels
SM_ResetSkillLevels( id )
{
	static i;

	for ( i = 0; i < MAX_SKILLS; i++ )
	{
		g_PlayerSkillLevel[id][i] = 0;
	}
}

// Function will reset what skills the user has
SM_ResetSkills( id )
{
	static i;

	for ( i = 0; i < MAX_SKILLS; i++ )
	{
		g_bPlayerSkills[id][i] = false;
	}
}

// Function will return the skill ID number based on the position (i.e. used after a skill is selected)
SM_GetSkillByPos( id, iPos )
{
	static i, j;
	j = 0;

	new iUserSkills[MAX_SKILLS] = {-1, ...};

	// Sort by trainable first
	for ( i = 0; i < MAX_SKILLS; i++ )
	{
		if ( g_bPlayerSkills[id][i] && g_SkillType[i] == SKILL_TYPE_TRAINABLE )
		{
			iUserSkills[j++] = i;
		}
	}

	// Then sort by ultimates
	for ( i = 0; i < MAX_SKILLS; i++ )
	{
		if ( g_bPlayerSkills[id][i] && g_SkillType[i] == SKILL_TYPE_ULTIMATE )
		{
			iUserSkills[j++] = i;
		}
	}

	// Then sort by passive
	for ( i = 0; i < MAX_SKILLS; i++ )
	{
		if ( g_bPlayerSkills[id][i] && g_SkillType[i] == SKILL_TYPE_PASSIVE )
		{
			iUserSkills[j++] = i;
		}
	}

	// Now lets return the position

	if ( iUserSkills[iPos] != -1 )
	{
		return iUserSkills[iPos];
	}

	return -1;
}

// Returns the user's level for a certain skill
SM_GetSkillLevel( id, skill_id, debug_id = -1 )
{
	if ( !SM_IsValidSkill( skill_id ) )
	{
		WC3_Log( false, "[0] Invalid skill: %d [%d]", skill_id, debug_id );

		log_error( AMX_ERR_NATIVE, "[0] Invalid skill: %d [%d]", skill_id, debug_id );

		return 0;
	}

	// User doesn't have this skill
	if ( !g_bPlayerSkills[id][skill_id] )
	{
		return -1;
	}

	// If it's a passive skill, we'll just return the player's current level
	if ( g_SkillType[skill_id] == SKILL_TYPE_PASSIVE )
	{
		return p_data[id][P_LEVEL];
	}

	return g_PlayerSkillLevel[id][skill_id];
}

// Set the user's skill level for a given skill
SM_SetSkillLevel( id, skill_id, iLevel, iDebugID )
{
	if ( !SM_IsValidSkill( skill_id ) )
	{
		WC3_Log( false, "[1] Invalid skill: %d (%d)", skill_id, iDebugID );

		log_error( AMX_ERR_NATIVE, "[1] Invalid skill: %d (%d)", skill_id, iDebugID );

		return;
	}

	// User doesn't have this skill
	if ( !g_bPlayerSkills[id][skill_id] )
	{
		return;
	}
	
	// We shouldn't be setting a passive skill's level!
	if ( g_SkillType[skill_id] == SKILL_TYPE_PASSIVE )
	{
		WC3_Log( false, "Setting a passive skill's level %d to %d (%d)", skill_id, iLevel, iDebugID );

		log_error( AMX_ERR_NATIVE, "Setting a passive skill's level %d to %d (%d)", skill_id, iLevel, iDebugID );

		return;
	}

	// Technically we shouldn't have a skill level EVER greater than 3 right?
	if ( iLevel > MAX_SKILL_LEVEL )
	{
		WC3_Log( false, "Setting skill %d to %d wtf?? (%d)", skill_id, iLevel, iDebugID );

		log_error( AMX_ERR_NATIVE, "Setting skill %d to %d wtf?? (%d)", skill_id, iLevel, iDebugID );

		return;
	}
	
	//static iLastSkillLevel;
	//iLastSkillLevel = g_PlayerSkillLevel[id][skill_id];

	// Set our new skill value
	g_PlayerSkillLevel[id][skill_id] = iLevel;

	// This will configure the skill (make any changes that should be necessary)
	//SM_SkillSet( id, skill_id, iLastSkillLevel, iLevel );
	SM_SkillSet( id, skill_id );

	return;
}


// Checks to see if a skill ID is valid
bool:SM_IsValidSkill( skill_id )
{
	if ( skill_id >= 0 && skill_id < MAX_SKILLS )
	{
		return true;
	}

	return false;
}

// Function will get a random skill for the user's current skills (great for bots)
SM_GetRandomSkill( id )
{

	// Make sure a skill is available
	if ( !SM_SkillAvailable( id ) )
	{
		return -1;
	}

	static iRandomSkill;
	

	// Initial condition selected
	iRandomSkill = random_num( 0, MAX_SKILLS - 1 );

	while ( !g_bPlayerSkills[id][iRandomSkill] )
	{
		iRandomSkill = random_num( 0, MAX_SKILLS - 1 );
	}

	return iRandomSkill;
}

SM_GetRandomSkillByType( id, type )
{

	// Make sure a skill is available
	if ( !SM_SkillAvailable( id ) )
	{
		return -1;
	}

	static iRandomSkill;
	

	// Initial condition selected
	iRandomSkill = random_num( 0, MAX_SKILLS - 1 );

	while ( !g_bPlayerSkills[id][iRandomSkill] || g_SkillType[iRandomSkill] != type )
	{
		iRandomSkill = random_num( 0, MAX_SKILLS - 1 );
	}

	return iRandomSkill;
}


bool:SM_SkillAvailable( id )
{
	static i;

	for ( i = 0; i < MAX_SKILLS; i++ )
	{
		if ( g_bPlayerSkills[id][i] )
		{
			return true;
		}
	}

	return false;
}

// Function will simply return the skill type
SM_GetSkillType( skill_id )
{
	if ( !SM_IsValidSkill( skill_id ) )
	{
		WC3_Log( false, "[2] Invalid skill: %d", skill_id );

		log_error( AMX_ERR_NATIVE, "[2] Invalid skill: %d", skill_id );

		return 0;
	}

	return g_SkillType[skill_id];
}

SM_TotalSkillPointsUsed( id )
{
	static i, iTotal;
	iTotal = 0;

	for ( i = 0; i < MAX_SKILLS; i++ )
	{
		if ( g_SkillType[i] == SKILL_TYPE_TRAINABLE || g_SkillType[i] == SKILL_TYPE_ULTIMATE )
		{
			if ( g_bPlayerSkills[id][i] )
			{
				iTotal += g_PlayerSkillLevel[id][i];
			}
		}
	}

	return iTotal;
}

// Function will return a skill of a certain type
SM_GetSkillOfType( id, type, iStart = 0 )
{
	static i;

	for ( i = iStart; i < MAX_SKILLS; i++ )
	{
		if ( g_bPlayerSkills[id][i] && g_SkillType[i] == type )
		{
			return i;
		}
	}

	return -1;
}

bool:SM_IsValidRace( iRace )
{
	if ( 1 <= iRace <= get_pcvar_num( CVAR_wc3_races ) )
	{
		return true;
	}

	return false;
}

// Prints debug info on a player to the console...
SM_DebugPrint( id )
{
	static iSkillID;
	new szSkillName[32];


	// **** Trainable ****
	WC3_Log( true, "=== Trainable ===" );
	
	iSkillID = SM_GetSkillOfType( id, SKILL_TYPE_TRAINABLE );
	while ( iSkillID != -1 )
	{
		LANG_GetSkillName( iSkillID, LANG_SERVER, szSkillName, 31, 5 );

		WC3_Log( true, "[%d] %s", iSkillID, szSkillName );

		iSkillID = SM_GetSkillOfType( id, SKILL_TYPE_TRAINABLE, iSkillID + 1 );
	}

	// **** Ultimates ****
	WC3_Log( true, "=== Ultimates ===" );
	
	iSkillID = SM_GetSkillOfType( id, SKILL_TYPE_ULTIMATE );
	while ( iSkillID != -1 )
	{
		LANG_GetSkillName( iSkillID, LANG_SERVER, szSkillName, 31, 6 );

		WC3_Log( true, "[%d] %s", iSkillID, szSkillName );

		iSkillID = SM_GetSkillOfType( id, SKILL_TYPE_ULTIMATE, iSkillID + 1 );
	}

	// **** Passive ****
	WC3_Log( true, "=== Passive ===" );
	
	iSkillID = SM_GetSkillOfType( id, SKILL_TYPE_PASSIVE );
	while ( iSkillID != -1 )
	{
		LANG_GetSkillName( iSkillID, LANG_SERVER, szSkillName, 31, 7 );

		WC3_Log( true, "[%d] %s", iSkillID, szSkillName );

		iSkillID = SM_GetSkillOfType( id, SKILL_TYPE_PASSIVE, iSkillID + 1 );
	}
}

// After we know which skill to give the user - we call this function to give it to them!
SM_SetSkill( id, iSkillID )
{
	if ( !SM_IsValidSkill( iSkillID ) )
	{
		WC3_Log( false, "[40] Invalid skill: %d", iSkillID );

		log_error( AMX_ERR_NATIVE, "[40] Invalid skill: %d", iSkillID );

		return;
	}

	// Get the user's current skill level
	new iCurrentLevel = SM_GetSkillLevel( id, iSkillID, 10 );

	if ( iCurrentLevel + 1 > MAX_SKILL_LEVEL )
	{
		WC3_Log( true, "Attempted to increase skill %d to %d", iSkillID, iCurrentLevel + 1 );

		return;
	}

	// Add one to their level!
	SM_SetSkillLevel( id, iSkillID, iCurrentLevel + 1, 6 );

	// User selected an ultimate + global cooldown is done
	if ( SM_GetSkillType( iSkillID ) == SKILL_TYPE_ULTIMATE )
	{
		ULT_IconHandler( id );
	}

	return;
}

// Given a player id - will simply give them a random skill point! - it will always give an ult @ level 6
// returns false if no point was given
SM_GiveRandomSkillPoint( id )
{
	// Then there is nothing to give!
	if ( SM_TotalSkillPointsUsed( id ) >= p_data[id][P_LEVEL] )
	{
		return false;
	}

	// Give them their ultimate if we can
	if ( p_data[id][P_LEVEL] >= MIN_ULT_LEVEL )
	{
		new iUltSkill = SM_GetRandomSkillByType( id, SKILL_TYPE_ULTIMATE );
		
		if ( iUltSkill != -1 && SM_GetSkillLevel( id, iUltSkill, 11 ) == 0 )
		{
			// Set up the skill...
			SM_SetSkill( id, iUltSkill );

			//client_print( id, print_chat, "[DEBUG] Ultimate given: %d", iUltSkill );

			return true;
		}
	}
	
	new iRandomSkill = SM_GetRandomSkillByType( id, SKILL_TYPE_TRAINABLE );
	new iSkillLevel = SM_GetSkillLevel( id, iRandomSkill, 12 );

	// Sweetest conditional statement ever
	while ( iSkillLevel + 1 > MAX_SKILL_LEVEL || p_data[id][P_LEVEL] <= 2 * iSkillLevel )
	{
		//server_print( "[%d:%d] %d >= %d || %d <= %d", iRandomSkill, iSkillLevel, iSkillLevel + 1, MAX_SKILL_LEVEL, p_data[id][P_LEVEL], 2 * iSkillLevel );

		iRandomSkill = SM_GetRandomSkillByType( id, SKILL_TYPE_TRAINABLE );
		iSkillLevel = SM_GetSkillLevel( id, iRandomSkill, 13 );
	}
			
	// Set up the skill...
	SM_SetSkill( id, iRandomSkill );

	//client_print( id, print_chat, "[DEBUG] (%d) Trainable given - from %d to %d", iRandomSkill, iSkillLevel, iSkillLevel + 1 );

	return true;
}

// After a user's skill has changed - the skill is configured here!
//SM_SkillSet( id, iSkillID, iPreviousSkillLevel = 0, iNewSkillLevel = 0 )
SM_SkillSet( id, iSkillID )
{
	switch( iSkillID )
	{
		case SKILL_UNHOLYAURA:				// Undead's Unholy Aura
		{
			SHARED_SetSpeed( id );
		}

		case SKILL_LEVITATION:				// Undead's Levitation
		{
			SHARED_SetGravity( id );
		}

		case SKILL_INVISIBILITY:			// Human's Invisibility
		{
			SHARED_INVIS_Set( id );
		}

		case SKILL_DEVOTION:				// Human's Devotion Aura
		{
			HU_DevotionAura( id );
		}

		case SKILL_PHOENIX:					// Blood Mage's Phoenix
		{
			BM_PhoenixCheck( id );
		}

		case SKILL_HEALINGWAVE:				// Shadow Hunter's Healing Wave
		{
			SH_HealingWave( id )
		}

		case SKILL_SERPENTWARD:				// Shadow Hunter's Serpent Ward
		{
			SH_SerpentWard( id );
		}

		case SKILL_BLINK:					// Warden's Blink
		{
			WA_Blink( id );
		}
	}

	return;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
