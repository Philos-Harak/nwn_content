/*//////////////////////////////////////////////////////////////////////////////
// Name: 0i_constants
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Include script for handling all constants for the ai.
 These constants are static and can only be changed in the toolset.
 Changes to any constants will not take effect until the scripts are recompiled.
*///////////////////////////////////////////////////////////////////////////////

// The following constants are designed to be changed to allow the AI to work
// differently based on what a developer wants.
//***************************  ADJUSTABLE CONSTANTS  ***************************
// The number of classes allowed for a character to take in the server/module.
const int AI_MAX_CLASSES_PER_CHARACTER = 3;
// Should moral checks be used.
const int AI_USE_MORAL = FALSE;
// Change the Custom token number if it conflicts with your server.
const int AI_BASE_CUSTOM_TOKEN = 1000;
// The DC monsters make to decide if they cast the best talent vs random talent.
const int AI_INTELLIGENCE_DC = 12;
// Arcane Spell failure% or less that a caster must have to still try to cast a spell.
const int AI_ASF_WILL_USE = 15;
// Should summon familiars be used?
const int AI_SUMMON_FAMILIARS = FALSE;
// Should animal companions be used?
const int AI_SUMMON_COMPANIONS = FALSE;
// Summons, familiars, and companions are permanent and don't disappear when the caster dies.
const int AI_PERMANENT_ASSOCIATES = FALSE;
// Should all monsters prebuff before combat?
const int AI_BUFF_MONSTER_CASTERS = TRUE;
// Should monsters cast summons spells when prebuffing?
const int AI_PREBUFF_SUMMONS = TRUE;
// Should monsters use potions to prebuff before combat?
const int AI_BUFF_MONSTER_POTIONS = TRUE;
// Should the AI allow the use of Use Magic Device?
const int AI_ALLOW_USE_MAGIC_DEVICE = TRUE;
// After combat the combat heartbeat script will run for AI_AFTER_COMBAT_WRAP_IN_ROUNDS.
// Allows monsters to heal and use cure spells after combat.
const int AI_AFTER_COMBAT_WRAP_IN_ROUNDS = 5;
// Delay between Henchman casting Buff spells.
const float AI_HENCHMAN_BUFF_DELAY = 0.0;
// Variable to change the difficulty so a player can adjust spell usage.
const string AI_DIFFICULTY_ADJUSTMENT = "AI_DIFFICULTY_ADJUSTMENT";
// Variable that can be change the distance for looting checks.
const float AI_LOOT_DISTANCE = 20.0f;
//**************************  CONVERSATION CONSTANTS  **************************
// Player's can tell their associates to ignore enemy associates.
const int AI_IGNORE_ASSOCIATES_ON = TRUE;
// Player's can tell their associates to loot the enemy for them.
const int AI_LOOTING = TRUE;
// Associates with a Taunt skill higher than their level can be told to taunt.
const int AI_TAUNTING_ON = TRUE;
// Associates that cast spells can be told to use counterspell.
const int AI_COUNTERSPELLING_ON = TRUE;
// Associates with lore skill higher than the master can identify items.
const int AI_IDENTIFY_ON = TRUE;
// Associates can be called upon to scout ahead for monsters.
const int AI_SCOUT_AHEAD_ON = TRUE;
// A player can open a henchmen's inventory.
const int AI_OPEN_INVENTORY = TRUE;
// Allows players to have associates pickup loot.
const int AI_PICKUP_LOOT = TRUE;
// Allows players to remove a henchman.
const int AI_REMOVE_HENCHMAN_ON = TRUE;
// The distances associates will stay away from the player.
const float AI_DISTANCE_CLOSE = 0.5;
const float AI_DISTANCE_MEDIUM = 2.5;
const float AI_DISTANCE_LONG = 4.5;
//*****************************  Health Constants  *****************************
// % of health for when a creature is considered wounded.
const int AI_HEALTH_WOUNDED = 50;
// % of health when creature is considered badly wounded.
const int AI_HEALTH_BLOODY = 25;
//*****************************  MORAL CONSTANTS  ******************************
// Moral checks are only made once a creature is below AI_HEALTH_WOUNDED.
// The moral DC is AI_MORAL_DC - the number of Allies.
const int AI_MORAL_DC = 5;
// Once a creature goes below AI_HEALTHY_BLOODY then the moral DC increases by AI_MORAL_INC_DC
const int AI_MORAL_INC_DC = 10;
//******************************* CORE CONSTANTS *******************************
// The following constants are core constants and changing any of these without
// understanding the whole system could cause unforseen results.
//                            CHANGE AT YOUR OWN RISK.

// A variable that can be set on creatures to stop mobile animations.
const string AI_NO_ANIMATION = "AI_NO_ANIMATION";
// How many seconds in a combat round.
const int AI_COMBAT_ROUND_IN_SECONDS = 6;
// Used for actions that take x seconds but don't have an action constant.
const string AI_COMBAT_WAIT_IN_SECONDS = "AI_COMBAT_WAIT_IN_SECONDS";
// Constants used to define the difficulty of the battle for associates.
const int AI_COMBAT_IMPOSSIBLE = 31;
const int AI_COMBAT_DEADLY = 26;
const int AI_COMBAT_HARD = 21;
const int AI_COMBAT_DIFFICULT = 16;
const int AI_COMBAT_EASY = 11;
const int AI_COMBAT_SIMPLE = 6;
const int AI_COMBAT_EFFORTLESS = 1;
// Variables used to keep track of enemies in combat.
const string AI_ENEMY = "AI_ENEMY"; // The enemy objects.
const string AI_ENEMY_DISABLED = "AI_ENEMY_DISABLED"; // Int if they are disabled.
const string AI_ENEMY_SEEN = "AI_ENEMY_SEEN"; // TRUE if we have seen them, FALSE if not.
const string AI_ENEMY_RANGE = "AI_ENEMY_RANGE"; // The range from OBJECT_SELF.
const string AI_ENEMY_COMBAT = "AI_ENEMY_COMBAT"; // Combat rating: (BAB + AC - 10) / 2
const string AI_ENEMY_MELEE = "AI_ENEMY_MELEE"; // Enemies within 5 meters - Allies within 5 meters.
const string AI_ENEMY_HEALTH = "AI_ENEMY_HEALTH"; // % of hitpoints.
const string AI_ENEMY_NUMBERS = "AI_ENEMY_NUM"; // Number of enemies in combat.
const string AI_ENEMY_POWER = "AI_ENEMY_POWER"; // (Level * Health %) / 100 added for each enemy to this.
const string AI_ENEMY_NEAREST = "AI_ENEMY_NEAREST"; // Nearest enemy to OBJECT_SELF.
// Variables used to keep track of allies in combat.
const string AI_ALLY = "AI_ALLY"; // All friendly creatures
const string AI_ALLY_DISABLED = "AI_ALLY_DISABLED"; // Int if they are disabled.
const string AI_ALLY_SEEN = "AI_ALLY_SEEN"; // All allies are set to be seen.
const string AI_ALLY_RANGE = "AI_ALLY_RANGE"; // The range from OBJECT_SELF.
const string AI_ALLY_COMBAT = "AI_ALLY_COMBAT"; // Combat rating: (BAB + AC - 10) / 2
const string AI_ALLY_MELEE = "AI_ALLY_MELEE"; // Enemies within 5 meters - Allies within 5 meters.
const string AI_ALLY_HEALTH = "AI_ALLY_HEALTH"; // % of hitpoints.
const string AI_ALLY_NUMBERS = "AI_ALLY_NUM"; // Number of allies in combat.
const string AI_ALLY_POWER = "AI_ALLY_POWER"; // (Level * Health %) / 100 added for each enemy to this.
// Variable name used to define the ai scripts being used by creatures.
const string AI_DEFAULT_SCRIPT = "AI_DEFAULT_SCRIPT";
const string AI_COMBAT_SCRIPT = "AI_COMBAT_SCRIPT";
// Battle scripts.
// When combat starts these scripts are put on the creature and when combat is
// over the original scripts are swapped back.
// Heartbeat scripts (1).
const string AI_EVENT_SCRIPT_1 = "AI_EVENT_SCRIPT_1";
const string AI_MONSTER_BATTLE_SCRIPT_1 = "0e_c2_battle_1";
const string AI_ASSOCIATE_BATTLE_SCRIPT_1 = "0e_ch_battle_1";
// Perception[NOTICE] scripts (2).
const string AI_EVENT_SCRIPT_2 = "AI_EVENT_SCRIPT_2";
const string AI_MONSTER_BATTLE_SCRIPT_2 = "0e_c2_battle_2";
const string AI_ASSOCIATE_BATTLE_SCRIPT_2 = "0e_ch_battle_2";
// Dialogue scripts (4).
const string AI_EVENT_SCRIPT_4 = "AI_EVENT_SCRIPT_4";
const string AI_MONSTER_BATTLE_SCRIPT_4 = "0e_c2_battle_4";
const string AI_ASSOCIATE_BATTLE_SCRIPT_4 = "0e_ch_battle_4";
// Constants used in a creatures listening patterns.
const string AI_I_SEE_AN_ENEMY = "AI_I_SEE_AN_ENEMY";
const string AI_I_HEARD_AN_ENEMY = "AI_I_HEARD_AN_ENEMY";
const string AI_ATKED_BY_WEAPON = "AI_ATK_BY_WEAPON";
const string AI_ATKED_BY_SPELL = "AI_ATK_BY_SPELL";
const string AI_I_AM_WOUNDED = "AI_I_AM_WOUNDED";
const string AI_I_AM_DEAD = "AI_I_AM_DEAD";
const int AI_ALLY_SEES_AN_ENEMY = 1;
const int AI_ALLY_HEARD_AN_ENEMY = 2;
const int AI_ALLY_ATKED_BY_WEAPON = 3;
const int AI_ALLY_ATKED_BY_SPELL = 4;
const int AI_ALLY_IS_WOUNDED = 5;
const int AI_ALLY_IS_DEAD = 6;
const string AI_MY_TARGET = "AI_MY_TARGET";
// Constants used in combat to keep track of a creatures last action.
const string AI_AM_I_SEARCHING = "AI_AM_I_SEARCHING";
// 0+ is the last spell cast from the line number in Spells.2da.
const string sLastActionVarname = "AI_LAST_ACTION";
const int AI_LAST_ACTION_CAST_SPELL = 0;
const int AI_LAST_ACTION_NONE = -1;
const int AI_LAST_ACTION_MELEE_ATK = -2;
const int AI_LAST_ACTION_RANGED_ATK = -3;
const int AI_LAST_ACTION_USED_FEAT = -4;
const int AI_LAST_ACTION_USED_ITEM = -5;
const int AI_LAST_ACTION_USED_SKILL = -6;
// Variable name used to keep track of Action Modes.
const string AI_CURRENT_ACTION_MODE = "AI_CURRENT_ACTION_MODE";
// Variable name used to keep a creatures attacked targets.
const string AI_ATTACKED_PHYSICAL = "AI_ATTACKED_PHYSICAL";
const string AI_ATTACKED_SPELL = "AI_ATTACKED_SPELL";
// Variable name used to keep track of a creatures normal polymorph form.
const string AI_NORMAL_FORM = "AI_NORMAL_FORM";
// Variable name used to keep track if a caster has already prebuffed.
const string AI_CASTER_USED_BUFFS = "AI_CASTER_USED_BUFFS";
// Variable name used to keep track of rounds in a custom ai script.
const string AI_ROUND = "AI_ROUND";
// Combat Ranges
const float AI_RANGE_MELEE = 5.0f; // Anyone within this is considered to be in melee.
const float AI_RANGE_CLOSE = 8.0f; // For anything requiring to be within 30'.
const float AI_RANGE_LONG = 15.0f; // Mainly used for distance ranged attacks.
const float AI_RANGE_PERCEPTION = 35.0f; // This is the distance for perception in battle.
const float AI_RANGE_BATTLEFIELD = 40.0f; // This is the size of the battlefield area.
// Spell ranges.
const float AI_SHORT_DISTANCE = 8.0f;
const float AI_MEDIUM_DISTANCE = 20.0f;
const float AI_LONG_DISTANCE = 40.0f;
// When computer checks if a creature should cast a specific spell at a target.
// Computer makes a spell check vs the targets saving throw.
// Spell check roll for the caster is
// [Innate spell Level + Random (AI_SPELL_CHECK_DIE) + AI_SPELL_CHECK_BONUS]
// If the spell gives a save for half (i.e. FireBall) and the target does not have
// Evasion then they get an additional bonus of AI_SPELL_CHECK_NO_EVASION_BONUS.
const int AI_SPELL_CHECK_DIE = 6;
const int AI_SPELL_CHECK_BONUS = 3;
const int AI_SPELL_CHECK_NO_EVASION_BONUS = 10;
// When the computer checks if a creature should use defensive casting it looks
// at the spell level + AI_DEFENSIVE_CASTING_DC vs casters concentration
// and feat bonuses (i.e. COMBAT_CASTING) + Random (AI_DEFENSIVE_CASTING_ROLL).
const int AI_DEFENSIVE_CASTING_DC = 19; // 19 will allow them to use it at 50% effectiveness.
const int AI_DEFENSIVE_CASTING_DIE = 10;
// When the computer checks to see if it should cast in melee combat it looks
// at CASTING_IN_MELEE_DC + SpellLevel + (Num of creatures in melee * GetHitDice (NearestEnemy));
// vs the casters concentration + Random (AI_CASTING_IN_MELEE_ROLL).
const int AI_CASTING_IN_MELEE_DC = 10;
const int AI_CASTING_IN_MELEE_ROLL = 10;
// For getting a specific class the following constants were added to flesh out
// the CLASS_TYPE_*
const int AI_CLASS_TYPE_CASTER = -1;
const int AI_CLASS_TYPE_DIVINE = -2;
const int AI_CLASS_TYPE_ARCANE = -3;
const int AI_CLASS_TYPE_WARRIOR = -4;
// For getting a specific race the following constants were added to flesh out
// the RACIAL_TYPE_*
const int AI_RACIAL_TYPE_ANIMAL_BEAST = -1;
const int AI_RACIAL_TYPE_HUMANOID = -2;
// Bitwise constants for negative conditions we might want to try to cure
const int AI_CONDITION_POISON         = 0x00000001;
const int AI_CONDITION_DISEASE        = 0x00000002;
const int AI_CONDITION_BLINDDEAF      = 0x00000004;
const int AI_CONDITION_ATK_DECREASE   = 0x00000008;
const int AI_CONDITION_DMG_DECREASE   = 0x00000010;
const int AI_CONDITION_DMG_I_DECREASE = 0x00000020;
const int AI_CONDITION_SKILL_DECREASE = 0x00000040;
const int AI_CONDITION_SAVE_DECREASE  = 0x00000080;
const int AI_CONDITION_SR_DECREASE    = 0x00000100;
const int AI_CONDITION_AC_DECREASE    = 0x00000200;
const int AI_CONDITION_SLOW           = 0x00000400;
const int AI_CONDITION_ABILITY_DRAIN  = 0x00000800;
const int AI_CONDITION_LEVEL_DRAIN    = 0x00001000;
const int AI_CONDITION_CHARMED        = 0x00002000;
const int AI_CONDITION_DAZED          = 0x00004000;
const int AI_CONDITION_STUNNED        = 0x00008000;
const int AI_CONDITION_FRIGHTENED     = 0x00010000;
const int AI_CONDITION_CONFUSED       = 0x00020000;
const int AI_CONDITION_CURSE          = 0x00040000;
const int AI_CONDITION_PARALYZE       = 0x00080000;
const int AI_CONDITION_DOMINATED      = 0x00100000;
// Database constants.
const string AI_DATABASE_TABLE = "AI_DATABASE_TABLE";
// Bitwise constants for Associate modes that are used with Get/SetAssociateMode().
const string sAssociateModeVarname = "ASSOCIATE_MODES";
const int AI_MODE_DISTANCE_CLOSE =      0x00000001; // Stays within AI_DISTANCE_CLOSE of master.
const int AI_MODE_DISTANCE_MEDIUM =     0x00000002; // Stays within AI_DISTANCE_MEDIUM of master.
const int AI_MODE_DISTANCE_LONG =       0x00000004; // Stays within AI_DISTANCE_LONG of master.
const int AI_MODE_HEAL_AT_75 =          0x00000008; // Heals master when at 75% hitpoints
const int AI_MODE_HEAL_AT_50 =          0x00000010; // Heals master when at 50% hitpoints
const int AI_MODE_HEAL_AT_25 =          0x00000020; // Heals master when at 25% hitpoints
const int AI_MODE_BUFF_MASTER =         0x00000040; // Buffs master before other allies.
const int AI_MODE_AGGRESSIVE_SEARCH =   0x00000080; // Sets associate to continuous search mode.
const int AI_MODE_AGGRESSIVE_STEALTH =  0x00000100; // Sets associate to continuous stealth mode (Not using).
const int AI_MODE_OPEN_LOCKS =          0x00000200; // Will pick locks, or bash them.
const int AI_MODE_DISARM_TRAPS =        0x00000400; // Will disarm traps.
const int AI_MODE_SCOUT_AHEAD =         0x00000800; // Will move ahead of master and scout.
const int AI_MODE_DEFEND_MASTER =       0x00001000; // Will attack enemies attacking our master.
const int AI_MODE_STAND_GROUND =        0x00002000; // Will stay in one place until new command.
const int AI_MODE_STOP_RANGED =         0x00004000; // Will not use ranged weapons.
const int AI_MODE_FOLLOW =              0x00008000; // Keeps associate following master ignoring combat.
const int AI_MODE_PICKUP_ITEMS =        0x00010000; // Will pickup up all items for master.
const int AI_MODE_PICKUP_GEMS_ITEMS =   0x00020000; // Will pickup gold, gems, and magic items for master.
const int AI_MODE_PICKUP_MAGIC_ITEMS =  0x00040000; // Will pickup only gold and magic items for master.
const int AI_MODE_NO_STEALTH =          0x00080000; // Will not cast invisibilty or use stealth.
const int AI_MODE_NO_MAGIC =            0x00100000; // Will not use any magic (Spells, items, abilities).
const int AI_MODE_DEFENSIVE_CASTING =   0x00200000; // Will only cast defensive spells.
const int AI_MODE_OFFENSIVE_CASTING =   0x00400000; // Will only cast offensive spells.
const int AI_MODE_STOP_DISPEL =         0x00800000; // Will not cast dispel type spells.
const int AI_MODE_DO_NOT_SPEAK =        0x01000000; // Tells the henchmen to be silent and not talk.
const int AI_MODE_CHECK_ATTACK =        0x02000000; // Will only engage in combats they think they can win.
const int AI_MODE_BUFF_AFTER_REST =     0x04000000; // Will buff the party after resting.
const int AI_MODE_TAUNTING =            0x08000000; // Will use the Taunt skill.
const int AI_MODE_COUNTERSPELL =        0x10000000; // Will attempt to counter spell.
const int AI_MODE_IGNORE_ASSOCIATES =   0x20000000; // Will ignore associates in combat.
const int AI_MODE_NO_MAGIC_ITEMS =      0x40000000; // Will not use magic items in combat.
//const int AI_MODE_ =                  0x80000000; // Not used.
// The number of Buff Groups
const int AI_BUFF_GROUPS = 17;
// Variable name used to keep track if we have set our talents.
const string sTalentsSetVarname = "AI_TALENTS_SET";
// New talent categories
const string AI_TALENT_ENHANCEMENT        = "E";
const string AI_TALENT_PROTECTION         = "P";
const string AI_TALENT_SUMMON             = "S";
const string AI_TALENT_HEALING            = "H";
const string AI_TALENT_CURE               = "C";
const string AI_TALENT_INDISCRIMINANT_AOE = "I";
const string AI_TALENT_DISCRIMINANT_AOE   = "D";
const string AI_TALENT_RANGED             = "R";
const string AI_TALENT_TOUCH              = "T";
// Talent types.
const int AI_TALENT_TYPE_SPELL = 1;
const int AI_TALENT_TYPE_SP_ABILITY = 2;
const int AI_TALENT_TYPE_FEAT = 3;
const int AI_TALENT_TYPE_ITEM = 4;
// Variables that clip checking talent categories a creature does not have.
// Significantly reduces search times.
const string AI_NO_TALENTS = "AI_NO_TALENTS_";
// Backward compatability constants.
const int X2_EVENT_CONCENTRATION_BROKEN = 12400;

