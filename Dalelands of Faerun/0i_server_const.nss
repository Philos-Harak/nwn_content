  //////////////////////////////////////////////////////////////////////////////
/*//////////////////////////////////////////////////////////////////////////////
// Name: 0i_constants
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Include script for handling all constants for the server.
 Many of these can be changed to adjust the servers settings.
 Information on how to adjust the server is as follows.
 These constants are static and can only be changed in the toolset.
 Changes to any constants will not take effect until the scripts are recompiled.
*/
//**************************** MODULE CONSTANTS *****************************
// Used for _debugging scripts, turn off when server is live!
// This spams messages to the first player on the server.
const int DEBUG_MODE = FALSE;
// Send all debug to the first PC.
const int DEBUG_FIRST_PC = TRUE;
// The number of real minutes that makeup a game hour in game. See module properties.
const int MINUTES_IN_ONE_GAME_HOUR = 10;
// Default 60.0f: (1 minute) In Seconds. Used on temporary delays.
const float MINUTE_DELAY = 60.0f;
// This is used on small time delays like Doors closing etc.
const float FIVE_MINUTE_DELAY = 300.0f;
// This is used on long time delays like respawning creatures.
const float THIRTY_MINUTE_DELAY = 1800.0f;
// Anything within touching distance (2.25f).
const float TOUCH_DISTANCE = 2.25f;
// Same as the short range of a spell (8.0f).
const float SHORT_DISTANCE = 8.0f;
// Same as the medium range of a spell (20.0f).
const float MEDIUM_DISTANCE = 20.0f;
// Same as the long range of a spell (40.0f).
const float LONG_DISTANCE = 40.0f;
// This defines the minimum area for the module. Usually based on the starting character level.
const int MIN_AREA_LEVEL = 1;
// This defines the maximum area for the module. Default is 20.
const int MAX_AREA_LEVEL = 20;
// This is the maximum number of players allowed on the server. Used in loops when checking players.
const int MAX_NUM_OF_PLAYERS = 20;
// Starting Year of the module for calculating time changes.
const int STARTING_YEAR = 1372;
// Temp Chest for fixing items. Used as a temp holder while changing items.
// This chest is in Cynosure.
const string TEMP_CHEST = "TEMP_CHEST";
// The maximum times it will try to reroll on a 2da with minimum levels.
const int MAX_REROLLS = 5;
// The maximum number of classes a character can take.
const int MAX_NUMBER_OF_CLASSES = 8;
// The maximum number of henchmen a player can have in the party.
const int MAX_NUMBER_OF_HENCHMEN = 3;
// The total number of henchmen a player can have in the database.
const int TOTAL_NUMBER_OF_HENCHMEN = 10;
// The maximum number of henchman a the server will allow a player to have.
// These "henchman" don't mean they are henchman, some are summons, dominated, etc.
const int SERVER_MAX_HENCHMAN = 30;
//**************************** CHEAT TESTING ****************************
// Total ability scores. Divide by 6 to get the average ability score.
// This does not count magic items.
const int MAX_ABILITIES_1_to_7 = 96;  // Avg = 16
const int MAX_ABILITIES_8_to_15 = 108;  // Avg = 18
const int MAX_ABILITIES_16_Up = 120;  // Avg = 20
// Total saving throw numbers. Divide by 3 to get the average save.
// This counts the base save only.
const int MAX_SAVES_1_to_7 = 45;  // Avg < 15
const int MAX_SAVES_8_to_15 = 60;  // Avg < 20
const int MAX_SAVES_16_Up = 90;  // Avg < 30

//**************************** WAYPOINTS ****************************
// Where to send illegal or disruptive characters.
const string WP_LIMBO = "WP_Limbo";
// Default waypoint for respawning players.
const string WP_DEFAULT_RESPAWN = "WP_Default_Respawn";
// Where to send an administrator's player to Cynosure.
const string WP_CYNOSURE = "WP_Cynosure";
// This is where a starting player will begin the game.
const string WP_START_LOCATION = "WP_Start_Location";
// Temporary creature spawn.
const string WP_CREATURE_SPAWN = "WP_Creature_Spawn";

//**************************** DATABASE CONSTANTS ****************************
const string SERVER_DATABASE = "ServerDatabase";
const string SERVER_TABLE = "ServerTable";
const string PLAYER_TABLE = "PlayerTable";
const string DM_TABLE = "DMTable";
const string CHARACTER_TABLE = "CharacterTable";
const string OBJECT_TABLE = "ObjectTable";
const string QUEST_TABLE = "QuestTable";
const string PIN_TABLE = "PinTable";
const string DMPIN_TABLE = "DMPinTable";
const string AREA_TABLE = "AreaTable";
const string ADVENTURE_TABLE = "AdventureTable";
const string ADV_OBJ_TABLE = "AdvObjTable";
// Default 1: Sets the starting characters level. Only used when building the database.
const int STARTING_CHARACTER_LEVEL = 1;
// Default 0%: Sets the starting experience slider. Only used when building the database.
// Adds or subtracts in % values. Ranage is -100% to +100%
const int STARTING_EXPERIENCE_SLIDER = 0;
// Default 0%: Sets the starting treasure slider. Only used when building the database.
// Adds or subtracts in % values. Range is -100% to +100%.
const int STARTING_TREASURE_SLIDER = 0;
// Default 3%: Sets the starting chance of finding a random Villain on an encounter.
// Range is from 0% to 100%.
const int STARTING_VILLAIN_CHANCE = 3;
// Default 1%: Sets the starting chance of finding a unique item on a treasure drop.
// Range is from 0% to 100%.
const int STARTING_UNIQUE_CHANCE = 1;
// Default 20: Sets the number of items that can be saved to the db per character.
const int MAX_PERSISTANT_ITEMS = 20;
// Duration in minutes before a characters data should be saved.
// Used to reduce time spent saving information per game hour (i.e 5 minutes per hour).
const int SAVE_CHARACTERS_DURATION = 2;

//**************************** RESTING CONSTANTS ****************************
// Tells the server to restrict rest to certain areas and time 1 true, 0 false.
const int RESTRICT_REST = 1;
// The number of hitpoint to heal a character per character level when resting.
const int HEAL_HP_PER_LEVEL = 1;
// The rest wait period in game minutes per character level. Resets to this value on a server reset.
// Based of REST_WAIT_PER_LEVEL = 1 & REST_LEVELS_TO_DIVIDE_BY = 4
// 1-3(1 min) 3-7(2 min) 8-11(3 min) 12-15(4 min) 16-19(5 min) 20-23(6 min)
// 24-27(7 min) 28-31(8 min) 32-35(9 min) 36-39(10 min) 40(11 min)
const int REST_WAIT_PER_LEVEL = 1;
// The number to divide the character levels by to calculate wait period.
const int REST_LEVELS_TO_DIVIDE_BY = 4;
// The formula is as follows: (Character Levels / LEVELS_TO_DIVIDE_BY) * REST_WAIT_PER_LEVEL
// Variable to define that a character is clicking on a Placable to rest.
const string USING_PLACEABLE_TO_REST = "USING_PLACEABLE_TO_REST";

//**************************** HITPOINT CONSTANTS ****************************
// The Base DC for bleeding Fortitude DC.
// Add one per hit point below zero to get the actual DC.
const int BLEED_DC = 16;
// Maximum hitpoints constant for use with SetHitPoints function.
const int MAX_HITPOINTS = 1000;

// *************************** EXPERIENCE CONSTANTS *************************
// The radius from the kill Players may get xp.
const float XP_PARTY_RADIUS = 50.0f;
// The minimum xp a player may gain per kill.
const float XP_MIN = 1.0f;
// Formula ((CR - Killer Level + ADJUSTMENT_XP) / ADJUSTMENT_XP) * BASE_XP
//                    lvl diff                    x = 35  30  25  20  15  10
// CR = 6 / Killer = 1  [-5] ((6  - 1 + 7) / 7) * x = 60  51  42  34  25  17 Impossible
// CR = 5 / Killer = 1  [-4] ((5  - 1 + 7) / 7) * x = 55  47  39  31  23  15 Overpowering
// CR = 4 / Killer = 1  [-3] ((4  - 1 + 7) / 7) * x = 50  42  35  28  21  14 Overpowering
// CR = 3 / Killer = 1  [-2] ((3  - 1 + 7) / 7) * x = 45  38  32  25  19  12 Very Difficult
// CR = 2 / Killer = 1  [-1] ((2  - 1 + 7) / 7) * x = 40  34  28  22  17  11 Very Difficult
// CR = 1 / Killer = 1  [0]  ((1  - 1 + 7) / 7) * x = 35  30  25  20  15  10 Challenging
// CR = 1 / Killer = 2  [1]  ((1  - 2 + 7) / 7) * x = 30  25  21  17  12  8  Challenging
// CR = 1 / Killer = 3  [2]  ((1  - 3 + 7) / 7) * x = 25  21  17  14  10  7  Moderate
// CR = 1 / Killer = 4 *[3]* ((1  - 4 + 7) / 7) * x = 20  17  14  11  8   5  Moderate
// CR = 1 / Killer = 5  [4]  ((1  - 5 + 7) / 7) * x = 15  12  10  8   6   4  Easy
// CR = 1 / Killer = 6  [5]  ((1  - 6 + 7) / 7) * x = 5   8   7   5   4   2  Easy
// The experience a character gets for killing a challenging monster (Same level creature).
const float BASE_XP = 25.0f;
// The multiplier for creatures CR.
const float BASE_XP_MULTIPLIER = 5.0f;
// Adjustement
const float ADJUSTMENT_XP = 7.0f;
// Number used to multiply the XP per power the villain has.
const int VILLAIN_XP_MULTIPLIER = 2;

// Effect Racial experience from a moderate encounter *[3]* Formula: XP * (ERL / ECL)
//                    ERL 1                     ERL 2                     ERL 3
// Lvl = 1:  20 * (1 - 1 / 2)  = 10xp 20 * (1 - 2 / 3)   = 6xp  20 * (1 - 3 / 4)    = 5xp
// Lvl = 2:  20 * (1 - 1 / 3)  = 13xp 20 * (1 - 2 / 4)   = 10xp 20 * (1 - 3 / 5)    = 8xp
// Lvl = 3:  20 * (1 - 1 / 4)  = 15xp 20 * (1 - 2 / 5)   = 12xp 20 * (1 - 3 / 6)    = 10xp
// Lvl = 4:  20 * (1 - 1 / 5)  = 16xp 20 * (1 - 2 / 6)   = 13xp 20 * (1 - 3 / 7)    = 11xp
// Lvl = 5:  20 * (1 - 1 / 6)  = 16xp 20 * (1 - 2 / 7)   = 14xp 20 * (1 - 3 / 8)    = 12xp
// Lvl = 10: 20 * (1 - 1 / 11) = 18xp 20 * (1 - 2 / 12)  = 16xp 20 * (1 - 3 / 13)   = 15xp
// Lvl = 15: 20 * (1 - 1 / 16) = 18xp 20 * (1 - 2 / 17)  = 17xp 20 * (1 - 3 / 18)   = 16xp
// Lvl = 20: 20 * (1 - 1 / 21) = 19xp 20 * (1 - 2 / 22)  = 18xp 20 * (1 - 3 / 23)   = 17xp
// The base XP for disarming a trap. Formula = BASE_DISARM_TRAP_XP + TRAP DISARM DC.
const float BASE_DISARM_TRAP_XP = 0.0f;
// BASE_DISARM_TRAP_XP = 0.0f; 1st (20 - 29) 5th (24 - 33) 10th (30 - 39) 20th (40 - 49).
// The base XP for unlocking a door.Formula = BASE_UNLOCK_XP + LOCK DC.
const float BASE_UNLOCK_XP = -5.0f;
// BASE_UNLOCK_XP = -5.0f; 1st (15 - 24) 5th (19 - 28) 10th (25 - 34) 20th (35 - 44).

// *************************** ENCOUNTER CONSTANTS *************************
// The default number of creatures that can spawn for an encounter area.
const int SPAWN_DEFAULT = 4;
// Default chance an encounter waypoint will spawn an extra creature.
const int EXTRA_CREATURE_CHANCE = 25;

// *************************** DUNGEON MASTER CONSTANTS *********************
// These are used to hold all of the DM's targets so they can be manipulated.
// Target type is used to define what some windows target type is set to for 
// example inventory can be placeables or creatures.
const string DM_TARGET_TYPE = "0_TARGET_TYPE";
// Var target type is used just for checking variables.
const string DM_VAR_TARGET_TYPE = "0_VAR_TARGET_TYPE";
const string DM_TARGET_CREATURE = "0_DM_TARGET_CREATURE";
const string DM_TARGET_ITEM = "0_DM_TARGET_ITEM";
const string DM_TARGET_PLACEABLE = "0_DM_TARGET_PLACEABLE";
const string DM_TARGET_TILE = "0_DM_TARGET_TILE";
const string DM_TARGET_AREA = "0_DM_TARGET_AREA";
const string DM_TARGET_TRIGGER = "0_DM_TARGET_TRIGGER";
const string DM_TARGET_LOCATION = "0_DM_TARGET_LOCATION";
// *************************** MAGIC ITEM CONSTANTS *************************
// The file that randomizes the type of magic item to be found.
const string BASE_MAGIC_ITEM_2DA_FILE = "base_mi_table";
// The file that randomizes the type of mundane items to be found.
const string BASE_MUNDANE_ITEM_2DA_FILE = "base_mu_table";
// This is the master properties 2da file.
const string PROPERTY_LIST_2DA_FILE = "property_table";
// This is the Crafting properties 2da file.
const string CRAFTING_2DA_FILE = "crafting_table";
// Any items <= to this value will automatically be identified.
const int ID_MIN_GP_VALUE = 15;

// *************************** QUEST CONSTANTS *************************
// Sets the base chance of getting a new quest NPC for a player onenterarea.
const int NPC_QUEST_CHANCE = 20;
const int NPC_TAVERN_QUEST_CHANCE = 40;
// The maximum quests a player can be on at one time.
const int MAX_QUESTS = 10;
// Max xp per quest.
const int MAX_QUEST_XP = 999999;
const int STORY_QUESTS = 0;
const int SIDE_QUESTS = 1;
const int LOCATION_QUESTS = 2;
const int TREASURE_QUESTS = 3;
const int DM_QUESTS = 4;

// *************************** CRAFTING CONSTANTS *************************
// DC required to craft a Master Work item.
const int ITEM_QUALITY_MASTER_WORK = 25;
// DC required to craft a Exquite item.
const int ITEM_QUALITY_EXQUISITE = 30;
// DC required to craft a Legendary item.
const int ITEM_QUALITY_LEGENDARY = 35;
// DC required to craft a Relic item.
const int ITEM_QUALITY_RELIC = 40;
// DC required to craft a Artifact item.
const int ITEM_QUALITY_ARTIFACT = 45;

// *************************** BODY MODIFICATION CONSTANTS *************************
int WINGMAX = 230;  //-- Max wingmodel.2da line.
int TAILMAX = 500;  //-- Max tailmodel.2da line.
// This is PC Model heads.
int HFHEADMAX = 137;  //-- human female
int HMHEADMAX = 127;  //-- human male
int AFHEADMAX = 23;  //-- halfling female
int AMHEADMAX = 29;  //-- halfling male
int EFHEADMAX = 102;  //-- elf female
int EMHEADMAX = 43;  //-- elf male
int GFHEADMAX = 10;  //-- gnome female
int GMHEADMAX = 14;  //-- gnome male
int DFHEADMAX = 18;  //-- dwarf female
int DMHEADMAX = 21;  //-- dwarf male
int OFHEADMAX = 15;  //-- halforc female
int OMHEADMAX = 22;  //-- halforc male

// *************************** SEARCH CONSTANT **********************
const int BASE_SEARCH_DC = 10;  // Formula = BASE_SEARCH_DC + Area Level + d10().
// BASE_SEARCH_DC = 10; 1st (12-21), 5th (16-25), 10th (21-30, 20th (31-40)
const int PASSIVE_SEARCH_PENALTY = -10;  // This is the penalty on search checks when not in search mode.

// *************************** LOCKED OBJECT CONSTANTS **********************
// BASE_CHANCE_OF_LOCK + (Area Level / LOCK_CHANCE_LVL_DIVISOR).
const int BASE_CHANCE_OF_LOCK = 10;
const int LOCK_CHANCE_LVL_DIVISOR = 2;
// Simple Lock: 20, Average Lock: 25, Good Lock: 30, Amazing Lock: 40.
// Formula [Take 20] = LOCK_BASE_DC + d(LOCK_BASE_DIE) + Area Level.
const int LOCK_BASE_DC = 18;
const int LOCK_DIE = 10;
// LOCK_BASE_DC = 10; 1st (20-[24]-29) 5th (25-29]-33) 10th (30-[34]-39) 20th (40-[44]-49).
// Formula [NO take 20] = BASE_BASH_DC + d(BASE_BASE_DIE) + Area Level.
const int BASH_BASE_DC = 10;
const int BASH_DIE = 10;
// BASE_BASH_DC = 10; 1st (12-[16]-21), 5th (16-[20]-25), 10th (21-[25]-30, 20th (31-[35]-40)

// ******************************** TRAP CONSTANTS ***************************
// Random chance is BASE_CHANCE_OF_TRAP + (Area_Level / TRAP_CHANCE_LVL_DIVISOR).
const int BASE_CHANCE_OF_TRAP = 10;
const int TRAP_CHANCE_LVL_DIVISOR = 2;
// Simple Trap: 10, Ticky Trap: 15, Difficult Trap: 20, Wicked Trap: 25.
// Formula [No Take 20] = TRAP_DISARM_BASE_DC + d(TRAP_DISARM_DIE) + Area Level.
const int TRAP_DISARM_BASE_DC = 10;
const int TRAP_DISARM_DIE = 10;
// TRAP_DISARM_BASE_DC = 10; 1st (12-[16]-21), 5th (16-[20]-25), 10th (21-[25]-30, 20th (31-[35]-40)
// Formula [No Take 20] = TRAP_DETECT_BASE_DC + d(TRAP_DETECT_DIE) + Area Level.
const int TRAP_DETECT_BASE_DC = 10;
const int TRAP_DETECT_DIE = 10;
// TRAP_DETECT_BASE_DC = 10; 1st (12-[16]-21), 5th (16-[20]-25), 10th (21-[25]-30, 20th (31-[35]-40)
const int MINOR_TRAP_DAMAGE_CHANCE = 30;  // This is the chance to roll for a minor trap. See 0i_traps.
const int AVERAGE_TRAP_DAMAGE_CHANCE = 90;  // This is the chance to roll for a average trap. See 0i_traps.
const int STRONG_TRAP_DAMAGE_CHANCE = 99;  // This is the chance to roll for a strong trap. See 0i_traps.
const int DEADLY_TRAP_DAMAGE_CHANCE = 100;  // This is the chance to roll for a deadly trap. See 0i_traps.
// Trap damage
const int TRAP_LVL_DIVISOR = 1;  // Number to divide into the area level.
const int MINOR_TRAP_NUM_OF_DMG_DIE = 1;  // This is the number of dice to roll for a minor trap. See 0i_traps.
const int MINOR_TRAP_DAMAGE_DIE = 2;  // This is the die to roll for a minor trap. See 0i_traps.
// 1d2 1st (1-2) 5th (5-10) 10th (10-20) 20th (20-40).
const int AVERAGE_TRAP_NUM_OF_DMG_DIE = 1;  // This is the number of dice to roll for a average trap. See 0i_traps.
const int AVERAGE_TRAP_DAMAGE_DIE = 4;  // This is the die to roll for a average trap. See 0i_traps.
// 1d4 1st (1-4) 5th (5-20) 10th (10-40) 20th (20-80).
const int STRONG_TRAP_NUM_OF_DMG_DIE = 1;  // This is the number of dice to roll for a strong trap. See 0i_traps.
const int STRONG_TRAP_DAMAGE_DIE = 6;  // This is the die to roll for a strong trap. See 0i_traps.
// 1d6 1st (1-6) 5th (5-30) 10th (10-60) 20th (20-120).
const int DEADLY_TRAP_NUM_OF_DMG_DIE = 1;  // This is the number of dice to roll for a deadly trap. See 0i_traps.
const int DEADLY_TRAP_DAMAGE_DIE = 8;  // This is the die to roll for a deadly trap. See 0i_traps.
// 1d8 1st (1-8) 5th (5-40) 10th (10-80) 20th (20-160).
// Formula = TRAP_BASE_SAVE + d(TRAP_SAVE_DIE) + Area Level.
const int TRAP_BASE_SAVE = 10;
const int TRAP_SAVE_DIE = 4;
// TRAP_BASE_SAVE = 10; 1st (12 - 15) 5th (16 - 19) 10th (21 - 24) 20th (31 - 34).
// Default 30.0f : This is the radius for any area of effect traps.
const float TRAP_RADIUS = 30.0f;
// Trap Types are used to define special traps to the function TriggerTrap.
const int TRAP_TYPE_GAS = 5000;
const int TRAP_TYPE_TANGLE = 5001;

// ******************************** PORTAL CONSTANTS ************************
// Used on an area to keep players from using Rods of Recall, teleport, and
// Leomunds secure shelter!
const string NO_PORTALING = "NO_PORTALING";

/******************************** HOUSING CONSTANTS ***********************
const int UPKEEP_WAIT_STRING = 3;  // This is the wait period The players will see such as 3 months instead of 30000 months.
const int UPKEEP_WAIT_PERIOD = 30000;  // This is the wait period betweek upkeep costs. 1000000 is one year, 10000 is one month, 100 is one day, 1 is one hour.
const string UPKEEP_WAIT_TEXT = "months";  // This is to use with the time. Put year if using years, month if using a month etc.
const int HOUSE_TYPE_COTTAGE = 1;
const int HOUSE_TYPE_HOUSE = 2;
const int HOUSE_TYPE_MANSION = 3;
const int HOUSE_TYPE_TOWER = 4;
const int HOUSE_TYPE_KEEP = 5;
const string HOUSE_LOC_SOUTH_WARD = "WP_SOUTH_WARD";
const string HOUSE_LOC_SEA_WARD = "WP_SEA_WARD";
const int COTTAGE_BASE_COST = 1000;  // The a simple home.
const int HOUSE_BASE_COST = 10000;  // The a basic home.
const int MANSION_BASE_COST = 30000;  // The a very nice home.
const int TOWER_BASE_COST = 30000;  // A wizards home.
const int KEEP_BASE_COST = 70000;  // A stronghold for warriors.
const int COTTAGE_COMPONENT_COST = 100;  // The a simple homes.
const int HOUSE_COMPONENT_COST = 1000;  // The a basic home.
const int MANSION_COMPONENT_COST = 3000;  // The a very nice home.
const int TOWER_COMPONENT_COST = 3000;  // A wizards home.
const int KEEP_COMPONENT_COST = 7000;  // A stronghold for warriors.
const int MAX_NUM_OF_HOMES = 9;  // This is the maximum number of homes the game will create before it stops. Used to preserve memory.
*/
//**************************** MERCHANT CONSTANTS ***************************
// A magic shop will start with MIN_MERCHANT_ITEMS + d(MIN_MERCHANT_ITEMS).
// The maximum number of shop items will be MIN_MERCHANT_ITEMS x 2.
const int MIN_MERCHANT_ITEMS = 20;
// This is the minimum cost of an item the merchants will keep in gold.
const int MIN_MERCHANT_ITEM_PRICE = 10;
// Number of hours before the shops will get new shipments.
const int NEW_SHIPMENT_DELAY = 24;

// *************** Associates **********************************
// The variable name used on an associate to define the type of associate.
const string PC_ASSOCIATE_TYPE = "0_PCAssociate";
// New Associate type NPC. They are used in quests and are not real henchman.
const int ASSOCIATE_TYPE_NPC = 6;

// ****************************** ITEM CONSTANTS ****************************
const int CHANCE_BREAK_AMULET = 1;  // Chance of a amulet breaking in a bashed chest.
const int CHANCE_BREAK_ARMOR = 1;  // Chance of a armor breaking in a bashed chest.
const int CHANCE_BREAK_BELT = 1;  // Chance of a belt breaking in a bashed chest.
const int CHANCE_BREAK_BOOTS = 1;  // Chance of a boots breaking in a bashed chest.
const int CHANCE_BREAK_BRACER = 1;  // Chance of a bracer breaking in a bashed chest.
const int CHANCE_BREAK_CLOAK = 1;  // Chance of a cloak breaking in a bashed chest.
const int CHANCE_BREAK_GLOVES = 1;  // Chance of a gloves breaking in a bashed chest.
const int CHANCE_BREAK_HELMET = 1;  // Chance of a helmet breaking in a bashed chest.
const int CHANCE_BREAK_ROD = 1;  // Chance of a rod breaking in a bashed chest.
const int CHANCE_BREAK_STAFF = 1;  // Chance of a staff breaking in a bashed chest.
const int CHANCE_BREAK_WAND = 1;  // Chance of a wand breaking in a bashed chest.
const int CHANCE_BREAK_MISC = 1;  // Chance of a misc breaking in a bashed chest.
const int CHANCE_BREAK_WEAPON = 1;  // Chance of a weapon breaking in a bashed chest.
const int CHANCE_BREAK_POTION = 50;  // Chance of a potion breaking in a bashed chest.
const int CHANCE_BREAK_SCROLL = 1;  // Chance of a scroll breaking in a bashed chest.
const int CHANCE_BREAK_RING = 1;  // Chance of a ring breaking in a bashed chest.
const int CHANCE_BREAK_GRENADE = 1;  // Chance of a grenade item breaking in a bashed chest.

const int BASE_ITEM_OPEN_FACE_HELMET = 23;
const int BASE_ITEM_SMALL_CONTAINER = 68;
const int BASE_ITEM_SMALL_STACKING_ITEM = 30;
const int BASE_ITEM_HOLY_SYMBOLS = 43;

// ************************* SKILL CONSTANTS *******************
const int SKILL_ATHLETICS = 3;
const int SKILL_KNOWLEDGE = 7;
const int SKILL_SLEIGHT_OF_HAND = 13;
const int SKILL_ACROBATICS = 21;
const int SKILL_CRAFTING = 23;
const int SKILL_SURVIVAL = 25;
const int SKILL_DECIPHER_SCRIPT = 26;
const int SKILL_SPEAK_LANGUAGES = 27;

// This is the threshold that defines if an item is common or uncommon, based on gp value.
const int APPRAISE_COMMON_ITEM_VALUE = 1000;
// The base DC when attempting to stabilize a fallen PC add 1 per HP below zero.
const int HEAL_STABILIZE_DC = 16;
// The base DC when attempting to cure poison HEAL_POISON_DIE.
const int HEAL_POISON_DC = 17;
const int HEAL_POISON_DIE = 6;
// The base DC when attempting to cure disease HEAL_DISEASE_DIE.
const int HEAL_DISEASE_DC = 22;
const int HEAL_DISEASE_DIE = 6;
// This is the chance they will either steal gold or an item when using Sleight of Hand.
const int CHANCE_TO_STEAL_GOLD = 75;
// The maximum gold that can be stolen at one time.
const int MAX_GOLD_TO_STEAL = 20;
// The minimum gold that can be stolen at one time.
const int MIN_GOLD_TO_STEAL = 5;
// The maximum weight of an item that can be stolen in tenth pounds, example 9 is .9 pounds.
const int MAX_WEIGHT_OF_ITEM = 9;

// ************************* FEAT CONSTANTS *******************
// GENERAL FEATS
const int FEAT_2_HAND_WEAPON_STYLE = 1370;  // Any 2 handed weapon gains +2 dmg.
const int FEAT_GREATER_2_HAND_WEAPON_STYLE = 1371;  // Any 2 handed weapon gains +4 dmg.
const int FEAT_SWORD_SHIELD_STYLE = 1501;  // +2 AC vs piercing and slashing weapons.
const int FEAT_IMPROVED_SWORD_SHIELD_STYLE = 1502;  // +4 AC vs piercing and slashing weapons.
const int FEAT_1_HAND_WEAPON_STYLE = 1549;  // +4 Parry and +2 AC vs piercing weapons.
const int FEAT_GREATER_1_HAND_WEAPON_STYLE = 1550;  // +6 Parry and +4 AC vs piercing weapons.
const int FEAT_EMPOWER_TURNING = 1562;  //  -2 on turning check, +2d6 on turning damage.
const int FEAT_HEIGHTEN_TURNING = 1563;  // Turning check gains + Caster Level and Turning damage - half caster level.
const int FEAT_AUGMENT_SUMMONING = 1305;  // Summoned creatures gain +4 enhancement bonus to Strength and Constitution.
const int FEAT_ESCHEW_MATERIALS = 1306;  // Ignore material components that are not consumed.
const int FEAT_WIDEN_SPELL_METAMAGIC = 1307;  // Increase the area of effect of spells by 100%.
const int FEAT_PRACTICED_SPELLCASTER_BARD = 1569;
const int FEAT_PRACTICED_SPELLCASTER_CLERIC = 1570;
const int FEAT_PRACTICED_SPELLCASTER_DRUID = 1571;
const int FEAT_PRACTICED_SPELLCASTER_SORCERER = 1572;
const int FEAT_PRACTICED_SPELLCASTER_WIZARD = 1573;
const int FEAT_PRACTICED_SPELLCASTER_ASSASSIN = 1574;
const int FEAT_PRACTICED_SPELLCASTER_FAVORED_SOUL = 1575;
const int FEAT_PRACTICED_SPELLCASTER_WARMAGE = 1576;
// RACE FEATS
const int FEAT_RACIAL_TYPE_DWARF = 1235;
const int FEAT_RACIAL_TYPE_ELF = 1236;
const int FEAT_RACIAL_TYPE_OUTSIDER = 1240;
const int FEAT_RACIAL_TYPE_GNOME = 1237;
const int FEAT_RACIAL_TYPE_GOBLINOID = 1241;
const int FEAT_RACIAL_TYPE_HALFLING = 1238;
const int FEAT_RACIAL_TYPE_HUMAN = 1234;
const int FEAT_RACIAL_TYPE_ORC = 1239;
const int FEAT_RACIAL_TYPE_REPTILIAN = 1242;

const int FEAT_RACIAL_DWARF_DUERGAR = 1209;
const int FEAT_RACIAL_DWARF_GOLD = 1208;
const int FEAT_RACIAL_DWARF_SHIELD = 1207;
const int FEAT_RACIAL_ELF_DROW = 1213;
const int FEAT_RACIAL_ELF_MOON = 1210;
const int FEAT_RACIAL_ELF_STAR = 1241;
const int FEAT_RACIAL_ELF_SUN = 1211;
const int FEAT_RACIAL_ELF_WOOD = 1212;
const int FEAT_RACIAL_GNOME_FOREST = 1215;
const int FEAT_RACIAL_GNOME_ROCK = 1214;
const int FEAT_RACIAL_GNOME_SVIRFNEBLIN = 1216;
const int FEAT_RACIAL_GOBLIN = 1220;
const int FEAT_RACIAL_HALFLING_LIGHTFOOT = 1217;
const int FEAT_RACIAL_HALFLING_STRONGHEART = 1218;
const int FEAT_RACIAL_HALFLING_GHOSTWISE = 1219;
const int FEAT_RACIAL_HALF_ORC = 1221;
const int FEAT_RACIAL_HUMAN = 1200;
const int FEAT_RACIAL_HUMAN_DAMARAN = 1201;
const int FEAT_RACIAL_HUMAN_ILLUSKAN = 1202;
const int FEAT_RACIAL_HUMAN_RASHEMI = 1203;
const int FEAT_RACIAL_HUMAN_MULAN = 1204;
const int FEAT_RACIAL_HUMAN_TETHYRIAN = 1205;
const int FEAT_RACIAL_HUMAN_CHONDATHAN = 1206;
const int FEAT_RACIAL_KOBOLD = 1245;
const int FEAT_RACIAL_ORC_MOUNTAIN = 1222;
const int FEAT_RACIAL_ORC_GRAY = 1223;

// SKILL FEATS
const int FEAT_SKILL_AFFINITY_APPRAISE = 1249;  // +2 to Appraise
const int FEAT_SKILL_AFFINITY_CRAFTING = 1248;  // +2 to Crafting
const int FEAT_SKILL_AFFINITY_HIDE = 1251;  // +2 to Hide
const int FEAT_SKILL_AFFINITY_PERSUASION = 1250;  // +2 to Persuade
const int FEAT_SKILL_MASTERY_HIDE = 1285;  // +4 to Hide
const int FEAT_SKILL_MASTERY_MOVESILENT = 1252;  // +4 to Move Silently
const int FEAT_SKILL_AFFINITY_ATHLETICS = 1286;  // +2 to Athletics
const int FEAT_DILIGENT = 1294;  // +2 Appraise & Decipher Script.
const int FEAT_INVESTIGATOR = 1295;  // +2 Knowledge & Search.
const int FEAT_MAGICAL_APTITUDE = 1296;  // +2 Spellcraft & Use Magic Device.
const int FEAT_NEGOTIATOR = 1297;  // +2 Persuade & Taunt.
const int FEAT_NIMBLE_FINGERS = 1298;  // +2 Disable Device & Open Locks.
const int FEAT_SELF_SUFFICIENT = 1299;  // +2 Heal & Survival.

// RACIAL FEATS
const int FEAT_ABERRATIONS_TRAINING = 1253;  // +1 attack vs aberrations.
const int FEAT_DUERGAR_IMMUNITIES = 1284;  // Immune to Illusion, paryalzation, poison.
const int FEAT_RACIAL_SPELL_RESISTANCE = 1269;  // Gain Spell Resistance 12 + 2 per 2 levels after 1 (stops at 20th).
const int FEAT_DODGE_MASTERY = 1272;  // Gain +4 Dodge
const int FEAT_DEFENSIVE_MASTERY = 1273;  // Gain +2 to all saves.
const int FEAT_TELEPATHY = 1287;  // RP only feat.
const int FEAT_AASIMAR_RESISTANCE = 1274;  // Gain Acid, Cold, and Electric resistance 5.
const int FEAT_TIEFLING_RESISTANCE = 1275;  // Gain Cold, Fire, and Electric resistance 5.
const int FEAT_AIR_AFFINITY = 1256;  // Gain +1 save vs Electricty per 5 levels.
const int FEAT_EARTH_AFFINITY = 1257;  // Gain +1 save vs Acid per 5 levels.
const int FEAT_FIRE_AFFINITY = 1258;  // Gain +1 save vs Fire per 5 levels.
const int FEAT_WATER_AFFINITY = 1259;  // Gain +1 save vs Cold per 5 levels.
const int FEAT_LIGHTNING_RESISTANCE_10 = 1288;  // Lightning reistance of 10.
const int FEAT_ACID_RESISTANCE_10 = 1289;  // Acid reistance of 10.
const int FEAT_FIRE_RESISTANCE_10 = 1290;  // Fire reistance of 10.
const int FEAT_COLD_RESISTANCE_10 = 1291;  // Cold reistance of 10.
const int FEAT_DUERGAR_SPELL_ABILITIES = 1292;  // Can cast Enlarge Person and Invisiblity 1/day.
const int FEAT_CAST_ENLARGE_PERSON_1_DAY = 1276;
const int FEAT_CAST_INVISIBILITY_1_DAY = 1277;
const int FEAT_SVIRFNEBLIN_SPELL_ABILITIES = 1293;  // Can cast Blindness/Deafness and Blur 1/day.
const int FEAT_CAST_BLIND_DEAF_1_DAY = 1278;
const int FEAT_CAST_BLUR_1_DAY = 1279;

// CLASS FEATS
// *************************** Barbarian *********************************
const int FEAT_DEATHLESS_RAGE = 1372;  // While in a rage they cannot go below 20 hp.
const int FEAT_GREATER_RAGE = 329;  // Rage bonus is increased.
// *************************** Orc Warlord *********************************
const int FEAT_PARTY_RAGE = 1373;  // Put all allies within 30' in a rage.
const int FEAT_FEARLESS_RAGE = 1382;  // While in a rage they are immune to fear.
const int FEAT_DOMINATE_ORC_RADIUS = 1381;  // Dominate orcs in a 10' radius.
// ***************************** Artificer *************************************
const int FEAT_MASTER_CRAFTSMAN = 1263;  // +3 Crafting skill at 1, 5, 9.
const int FEAT_GRAND_CRAFTMANSHIP = 1264;  // Reduce crafting/enchanting cost at 2, 7.
const int FEAT_TUNE_DEVICES = 1265;  // +5 Use magic device skill at 3, 8.
const int FEAT_EXTEND_ENCHANTMENTS = 1266;  // Extend enchantments on weapons and armor.
const int FEAT_PURGE_MAGIC = 1267;  // Remove properties from a magic item.
const int FEAT_POWERFUL_IMBUE = 1268;  // Gain +1 max propery when enchanting an item.
// **************************** Swashbuckler ***********************************
const int FEAT_INSIGHTFUL_STRIKE = 1302;  // Gain damage on melee attacks equal to your intelligence.
const int FEAT_SKILL_AFFINITY_ACROBATICS = 1300;  // Gain +2 to Acrobatics.
const int FEAT_SKILL_MASTERY_ACROBATICS = 1401;  // Gain +4 to Acrobatics.
// *************************** Dragon Disciple *********************************
const int FEAT_BLACK_DRAGON_BLOOD = 1356;
const int FEAT_BLUE_DRAGON_BLOOD = 1357;
const int FEAT_GREEN_DRAGON_BLOOD = 1358;
const int FEAT_RED_DRAGON_BLOOD = 1359;
const int FEAT_WHITE_DRAGON_BLOOD = 1360;
const int FEAT_BRASS_DRAGON_BLOOD = 1361;
const int FEAT_BRONZE_DRAGON_BLOOD = 1362;
const int FEAT_COPPER_DRAGON_BLOOD = 1363;
const int FEAT_GOLD_DRAGON_BLOOD = 1364;
const int FEAT_SILVER_DRAGON_BLOOD = 1365;
const int FEAT_DRAGON_IMMUNE_ELEMENT = 1366;
// ************************** Bard / Warmage ***********************************
const int FEAT_ARMORED_MAGE_LIGHT = 1524;  // -25% Arcane spell failure.
const int FEAT_ARMORED_MAGE_MEDIUM = 1525;  // -35% Arcane spell failure.
// MAGIC FEATS
const int FEAT_CRAFT_ARMS_AND_ARMOR = 1280;
const int FEAT_CRAFT_RODS_STAVES = 1281;
const int FEAT_CRAFT_WONDROUS = 1282;
const int FEAT_CRAFT_AMULETS_RINGS = 1283;

// OTHER FEATS
const int FEAT_FLY = 1368;

// ************************* CLASS CONSTANTS *******************
const int CLASS_TYPE_ARTIFICER = 42;
const int CLASS_TYPE_SWASHBUCKLER = 43;
const int CLASS_TYPE_ORC_WARLORD = 44;
const int CLASS_TYPE_PALADIN2 = 45;
const int CLASS_TYPE_RANGER2 = 46;
const int CLASS_TYPE_FAVORED_SOUL = 47;
const int CLASS_TYPE_WARMAGE = 48;
const int CLASS_TYPE_MYSTIC_THEURGE = 49;

// ************* MATERIAL COMPONENTS AND FOCUSES **********
const string COMPONENT_POUCH = "0_comp_pouch";
const string CLERIC_HOLY_SYMBOL = "holy_symbol";
const string DRUID_HOLY_SYMBOL = "holly_mistletoe";

// ************************* SPELL CONSTANTS *******************
const int STOP_SPELL = -1;
// SUB_SCHOOL
const int SUBSCHOOL_CALLING = 1;
const int SUBSCHOOL_CREATION = 2;
const int SUBSCHOOL_HEALING = 3;
const int SUBSCHOOL_SUMMONING = 4;
const int SUBSCHOOL_TELEPORTATION = 5;
const int SUBSCHOOL_SCRYING = 6;
const int SUBSCHOOL_CHARM = 7;
const int SUBSCHOOL_COMPULSION = 8;
const int SUBSCHOOL_FIGMENT = 9;
const int SUBSCHOOL_GLAMER = 10;
const int SUBSCHOOL_PATTERN = 11;
const int SUBSCHOOL_PHANTASM = 12;
const int SUBSCHOOL_SHADOW = 13;
// DESCRIPTION
const int DESC_ACID = 1;
const int DESC_AIR = 2;
const int DESC_CHAOTIC = 4;
const int DESC_COLD = 8;
const int DESC_DARKNESS = 16;
const int DESC_DEATH = 32;
const int DESC_EARTH = 64;
const int DESC_ELECTRICITY = 128;
const int DESC_EVIL = 256;
const int DESC_FEAR = 512;
const int DESC_FIRE = 1024;
const int DESC_FORCE = 2048;
const int DESC_GOOD = 4096;
const int DESC_LANGUAGE = 8192;
const int DESC_LAWFUL = 16384;
const int DESC_LIGHT = 32768;
const int DESC_MIND = 65536;
const int DESC_SONIC = 131072;
const int DESC_WATER = 262144;
// DURATION TYPE
const int DURATION_TYPE_CONCENTRATION = 3;
const int DURATION_TYPE_ROUNDS = 4;
const int DURATION_TYPE_MINUTES = 5;
const int DURATION_TYPE_TURNS = 6;
const int DURATION_TYPE_HOURS = 7;
// TARGET TYPE
const int TARGET_TYPE_ALL = 0;
const int TARGET_TYPE_ENEMIES = 1;
const int TARGET_TYPE_ALLIES = 2;
const int TARGET_TYPE_ALL_BUT_CASTER = 3;
const int SHAPE_RANGE_TARGET = 5;
const int SHAPE_TOUCH_TARGET = 6;
const int SHAPE_PERSONAL = 7;
// SPELLS 2DA
const int SPELL_FEAT_CAST_LIGHT = 850;
const int SPELL_FEAT_CAST_DARKNESS = 851;
const int SPELL_FEAT_CAST_ENLARGE_PERSON = 852;
const int SPELL_FEAT_CAST_INVISIBILITY = 853;
const int SPELL_FEAT_CAST_BLIND_DEAF = 854;
const int SPELL_FEAT_CAST_BLUR = 855;
const int SPELL_FEAT_DD_ACID_LINE = 856;
const int SPELL_FEAT_DD_LIGHTNING_LINE = 857;
const int SPELL_FEAT_DD_ACID_CONE = 858;
const int SPELL_FEAT_DD_FIRE_CONE = 859;
const int SPELL_FEAT_DD_COLD_CONE = 860;
const int SPELL_FEAT_DD_FIRE_LINE = 861;
// const int SPELL_LANGUAGE (ABYSSAL 862 TO THIEVES' CANT 887)
const int SPELL_QUEST_DIFFICULTY = 888;
const int SPELL_QUEST_GIVE = 889;
const int SPELL_QUEST_REMOVE = 890;
const int SPELL_BLUR = 900;
const int SPELL_FEAT_PURGE_MAGIC = 901;
const int SPELL_ENLARGE_PERSON = 902;
const int SPELL_FLY_UNLIMITED_USES = 903;
const int SPELL_FEAT_PARTY_RAGE = 904;
const int SPELL_FEAT_DOMINATE_ORC = 905;
const int SPELL_ARCANE_BLAST = 906;
const int SPELL_FEAT_ACIDIC_RAY = 907;
const int SPELL_FEAT_ELECTRIC_RAY = 908;
const int SPELL_FEAT_FIRE_RAY = 909;
const int SPELL_FEAT_COLD_RAY = 910;
const int SPELL_FEAT_ACID_RAY = 911;
const int SPELL_FEAT_ELECTRIC_BLAST = 912;
const int SPELL_FEAT_FIRE_BLAST = 913;
const int SPELL_FEAT_COLD_BLAST = 914;
const int SPELL_FEAT_ACID_BLAST = 915;
const int SPELL_FEAT_ELEMENTAL_TRANSFERANCE = 916;
const int SPELL_CHAOS_BLAST = 917;
const int SPELL_CORUPTING_RAY = 918;
const int SPELL_HELFIRE = 919;
const int SPELL_FEAT_HOLY_SACRIFICE = 920;
const int SPELL_FLY = 921;
const int SPELL_ITEM_IOUN_STONE_YELLOW = 922;
const int SPELL_ITEM_IOUN_STONE_RED = 923;
const int SPELL_ITEM_IOUN_STONE_BLUE = 924;
const int SPELL_ITEM_IOUN_STONE_GREEN = 925;
const int SPELL_ITEM_IOUN_STONE_WHITE = 926;
const int SPELL_FEAT_LUMINESCENCE = 927;
const int SPELL_FEAT_SCATTER_SHOT = 928;
const int SPELL_FEAT_ARCANE_SONG = 929;
const int SPELL_FEAT_DIVINE_SONG = 930;
const int SPELL_FEAT_ROGUE_SONG = 931;
const int SPELL_FEAT_WARRIOR_SONG = 932;
const int SPELL_DETECT_SECRET_DOORS = 933;
const int SPELL_FIND_THE_PATH = 934;
const int SPELL_LEOMUNDS_SECURE_SHELTER = 935;
const int SPELL_IMPRISONMENT = 936;
const int SPELL_WORD_OF_CHAOS = 937;
const int SPELL_WORD_OF_EVIL = 938;
const int SPELL_WORD_OF_GOOD = 939;
const int SPELL_WORD_OF_LAW = 940;
const int SPELL_CHAOS_HAMMER = 941;
const int SPELL_FREEDOM = 942;
const int SPELL_INSANITY = 943;
const int SPELL_ANIMATE_ROPE = 944;
const int SPELL_MINOR_CREATION = 945;
const int SPELL_FANTASTIC_MACHINE = 946;
const int SPELL_GREATER_FANTASTIC_MACHINE = 947;
const int SPELL_MAJOR_CREATION = 948;
const int SPELL_DARKBOLT = 949;
const int SPELL_ARMOR_OF_DARKNESS = 950;
const int SPELL_SUMMON_SWARM = 951;
const int SPELL_SPIDERSKIN = 952;
const int SPELL_SPIDERFORM = 953;
const int SPELL_SNARE = 954;
const int SPELL_LIVEOAK = 955;
const int SPELL_HEROES_FEAST = 956;
const int SPELL_IMBUE_WITH_SPELL_ABILITY = 957;
const int SPELL_ISA_BLESS = 958;
const int SPELL_ISA_CURE_LIGHT_WOUNDS = 959;
const int SPELL_ISA_CURE_MODERATE_WOUNDS = 960;
const int SPELL_PRISMATIC_SPHERE = 961;
const int SPELL_GREATER_MAGE_ARMOR = 962;
const int SPELL_DOMAIN_PWR_CHAOS = 963;
const int SPELL_DOMAIN_PWR_CHARM = 964;
const int SPELL_DOMAIN_PWR_DARKNESS = 965;
const int SPELL_DOMAIN_PWR_DESTRUCTION = 966;
const int SPELL_DOMAIN_PWR_DROW = 967;
const int SPELL_DOMAIN_PWR_ELF = 968;
const int SPELL_DOMAIN_PWR_FAMILY = 969;
const int SPELL_TRUE_RESURRECTION = 970;
const int SPELL_FEAT_SUDDEN_EMPOWER = 971;
const int SPELL_FEAT_SUDDEN_WIDEN = 972;
const int SPELL_FEAT_SUDDEN_MAXIMIZE = 973;
const int SPELL_FEAT_SUDDEN_EXTEND = 974;
const int SPELL_DEEP_SLUMBER = 975;
const int SPELL_TELEPORT = 976;
const int SPELL_GREATER_TELEPORT = 977;
const int SPELL_FEAT_DETECT_GOOD = 978;
const int SPELL_FEAT_UNHOLY_SACRIFICE = 979;
const int SPELL_FEAT_WIDEN_METAMAGIC = 980;
const int SPELL_FEAT_BLOOD_COMPONENT = 981;
const int SPELL_FEAT_BLOOD_MAGIC = 982;
