/*//////////////////////////////////////////////////////////////////////////////
// Name: 0i_constants
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Include script for handling all constants for the ai.
 These constants are static and can only be changed in the toolset.
 Changes to any constants will not take effect until the scripts are recompiled.
*///////////////////////////////////////////////////////////////////////////////

const string PHILOS_VERSION = "Philos' Enhancing Player System (PEPS) version 0.1";
// The following constants are designed to be changed to allow the AI to work
// differently based on what a developer wants.
//***************************  ADJUSTABLECONSTANTS  ***************************
// Should creatures summon familiars be used?
// These don't work very well unless you can change the familiar via NWNX.
const int AI_SUMMON_FAMILIARS = FALSE;
// Should creatures summon animal companions be used?
// These don't work very well unless you can change the companion via NWNX.
const int AI_SUMMON_COMPANIONS = FALSE;
// Should monsters use potions to prebuff before combat? Not working at the moment.
const int AI_BUFF_MONSTER_POTIONS = FALSE;
// The number of classes allowed for a character to take in the server/module.
const int AI_MAX_CLASSES_PER_CHARACTER = 3;
// Taunts cool down time before the AI attemps another Taunt.
const int AI_TAUNT_COOLDOWN = 3;
// Animal Empathy cool down time before the AI attemps another check.
const int AI_EMPATHY_COOLDOWN = 3;
// Change the Custom token number if it conflicts with your server.
const int AI_BASE_CUSTOM_TOKEN = 1000;
// Arcane Spell failure% or less than, for a caster to still try to cast a spell.
const int AI_ASF_WILL_USE = 15;
// Delay between Henchman casting Buff spells. Must be minimum of 0.1 seconds.
const float AI_HENCHMAN_BUFF_DELAY = 0.2;
//**************************  CONVERSATION CONSTANTS  **************************
// Player's can tell their associates to ignore enemy associates.
const int AI_IGNORE_ASSOCIATES_ON = TRUE;
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
const int AI_REMOVE_HENCHMAN_ON = FALSE;
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
// The moral DC is AI_MORAL_DC - the number of Allies. Default: 5
const int AI_WOUNDED_MORAL_DC = 5;
// Once a creature goes below AI_HEALTHY_BLOODY then it uses this moral DC. Default: 15
const int AI_BLOODY_MORAL_DC = 15;
//******************************* CORE CONSTANTS *******************************
// The following constants are core constants and changing any of these without
// understanding the whole system could cause unforseen results.
//                            CHANGE AT YOUR OWN RISK.

// Force the AI to overwrite all creature event scripts.
const int AI_OVERWRITE_EVENT_SCRIPTS = FALSE;
// Delay between Henchman casting Healing spells. Must be minimum of 0.1 seconds.
const float AI_HENCHMAN_HEALING_DELAY = 6.0;
// A variable that can be set on creatures to stop mobile animations.
const string AI_NO_ANIMATION = "AI_NO_ANIMATION";
// How many seconds in a combat round.
const int AI_COMBAT_ROUND_IN_SECONDS = 6;
// Used for actions that take x seconds but don't have an action constant.
const string AI_COMBAT_WAIT_IN_SECONDS = "AI_COMBAT_WAIT_IN_SECONDS";
// Constants used to define the difficulty of the battle for associates.
//    20+    : Impossible     - Cannot win.
// 17 to  19 : Overpowering   - Use all of our powers.
// 15 to  16 : Very Difficult - Use all of our power (Highest level spells).
// 11 to  14 : Challenging    - Use most of our power (Higher level powers).
//  8 to  10 : Moderate       - Use half of our power (Mid level powers and less).
//  5 to   7 : Easy           - Use our weaker powers (Lowest level powers).
//  2 to   4 : Effortless     - Don't waste spells and powers on this.
//  1 or less: Pointless      - We probably should ignore these dangers.
const int AI_COMBAT_IMPOSSIBLE = 21;
const int AI_COMBAT_OVERPOWERING = 17;
const int AI_COMBAT_VERY_DIFFICULT = 15;
const int AI_COMBAT_CHALLENGING = 11;
const int AI_COMBAT_MODERATE = 10;
const int AI_COMBAT_EASY = 7;
const int AI_COMBAT_EFFORTLESS = 4;
// Variables used to keep track of enemies in combat.
const string AI_ENEMY = "AI_ENEMY"; // The enemy objects.
const string AI_ENEMY_DISABLED = "AI_ENEMY_DISABLED"; // Int if they are disabled.
const string AI_ENEMY_PERCEIVED = "AI_ENEMY_PERCEIVED"; // TRUE if we have seen or heard them, FALSE if not.
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
const string AI_ALLY_PERCEIVED = "AI_ALLY_PERCEIVED"; // All allies are set to be seen and heard.
const string AI_ALLY_RANGE = "AI_ALLY_RANGE"; // The range from OBJECT_SELF.
const string AI_ALLY_COMBAT = "AI_ALLY_COMBAT"; // Combat rating: (BAB + AC - 10) / 2
const string AI_ALLY_MELEE = "AI_ALLY_MELEE"; // Enemies within 5 meters - Allies within 5 meters.
const string AI_ALLY_HEALTH = "AI_ALLY_HEALTH"; // % of hitpoints.
const string AI_ALLY_NUMBERS = "AI_ALLY_NUM"; // Number of allies in combat.
const string AI_ALLY_POWER = "AI_ALLY_POWER"; // (Level * Health %) / 100 added for each enemy to this.
// Variable name used to define the ai scripts being used by creatures.
const string AI_DEFAULT_SCRIPT = "AI_DEFAULT_SCRIPT";
const string AI_COMBAT_SCRIPT = "AI_COMBAT_SCRIPT";
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
// Constant used by monsters to reduce checks while searching for unseen targets.
const string AI_AM_I_SEARCHING = "AI_AM_I_SEARCHING";
// Used to keep track of oCreature attempting to hide.
const string AI_TRIED_TO_HIDE = "AI_TRIED_TO_HIDE";
// Constant used by creatures to keep track of invisible creatures.
const string AI_IS_INVISIBLE = "AI_IS_INVISIBLE";
// Constants used in combat to keep track of a creatures last action.
// 0+ is the last spell cast from the line number in Spells.2da.
const string sLastActionVarname = "AI_LAST_ACTION";
const int AI_LAST_ACTION_CAST_SPELL = -1;
const int AI_LAST_ACTION_NONE = -2;
const int AI_LAST_ACTION_MELEE_ATK = -3;
const int AI_LAST_ACTION_RANGED_ATK = -4;
const int AI_LAST_ACTION_USED_FEAT = -5;
const int AI_LAST_ACTION_USED_ITEM = -6;
const int AI_LAST_ACTION_USED_SKILL = -7;
const int AI_LAST_ACTION_MOVE = -8;
// Variable name used to keep track of Action Modes.
const string AI_CURRENT_ACTION_MODE = "AI_CURRENT_ACTION_MODE";
// Variable name used to keep a creatures attacked targets.
const string AI_ATTACKED_PHYSICAL = "AI_ATTACKED_PHYSICAL";
const string AI_ATTACKED_SPELL = "AI_ATTACKED_SPELL";
// Variable name used to keep track of a creatures normal polymorph form.
const string AI_NORMAL_FORM = "AI_NORMAL_FORM";
// Variable name used to keep track if a creature has been buffed yet.
const string AI_CASTER_BUFFS_SET = "AI_CASTER_BUFFS_SET";
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
// Database constants for Associate modes.
const string AI_MODE_DB_TABLE = "AI_MODE_DB_TABLE";
// Bitwise constants for Associate modes that are used with Get/SetAssociateMode().
const string sAIModeVarname = "ASSOCIATE_MODES";
const int AI_MODE_DISTANCE_CLOSE =      0x00000001; // Stays within AI_DISTANCE_CLOSE of master.
const int AI_MODE_DISTANCE_MEDIUM =     0x00000002; // Stays within AI_DISTANCE_MEDIUM of master.
const int AI_MODE_DISTANCE_LONG =       0x00000004; // Stays within AI_DISTANCE_LONG of master.
const int AI_MODE_SELF_HEALING_OFF =    0x00000008; // Creature will not use healing items or spells on self.
const int AI_MODE_PARTY_HEALING_OFF =   0x00000010; // Creature will not use healing items or spells on party.
const int AI_MODE_GHOST =               0x00000020; // Creature can move through other creatures.
//const int AI_MODE_ =                  0x00000040; // Not used.
//const int AI_MODE_ =                  0x00000080; // Not used.
const int AI_MODE_BASH_LOCKS =          0x00000100; // Will bash locks if cannot open door/placeable.
const int AI_MODE_AGGRESSIVE_SEARCH =   0x00000200; // Sets associate to continuous search mode.
const int AI_MODE_AGGRESSIVE_STEALTH =  0x00000400; // Sets associate to continuous stealth mode.
const int AI_MODE_PICK_LOCKS =          0x00000800; // Will pick locks if possible.
const int AI_MODE_DISARM_TRAPS =        0x00001000; // Will disarm traps.
const int AI_MODE_SCOUT_AHEAD =         0x00002000; // Will move ahead of master and scout.
const int AI_MODE_DEFEND_MASTER =       0x00004000; // Will attack enemies attacking our master.
const int AI_MODE_STAND_GROUND =        0x00008000; // Will stay in one place until new command.
const int AI_MODE_STOP_RANGED =         0x00010000; // Will not use ranged weapons.
const int AI_MODE_FOLLOW =              0x00020000; // Keeps associate following master ignoring combat.
const int AI_MODE_PICKUP_ITEMS =        0x00040000; // Will pickup up all items for master.
const int AI_MODE_COMMANDED =           0x00080000; // In Command mode then don't follow, search, etc.
//const int AI_MODE_ =                  0x00100000; // Not used.
const int AI_MODE_NO_STEALTH =          0x00200000; // Will not cast invisibilty or use stealth.
const int AI_MODE_DO_NOT_SPEAK =        0x00400000; // Tells the henchmen to be silent and not talk.
const int AI_MODE_CHECK_ATTACK =        0x00800000; // Will only engage in combats they think they can win.
const int AI_MODE_IGNORE_ASSOCIATES =   0x01000000; // Will ignore associates in combat.
//const int AI_MODE_ =                  0x02000000; // Not used.
//const int AI_MODE_ =                  0x04000000; // Not used.
//const int AI_MODE_ =                  0x08000000; // Not used.
//const int AI_MODE_ =                  0x10000000; // Not used.
//const int AI_MODE_ =                  0x20000000; // Not used.
//const int AI_MODE_ =                  0x40000000; // Not used.
//const int AI_MODE_ =                  0x80000000; // Not used.
// Bitwise constants for Associate magic modes that are used with Get/SetAssociateMagicMode().
const string sMagicModeVarname = "ASSOCIATE_MAGIC_MODES";
const int AI_MAGIC_BUFF_MASTER =         0x00000001; // Buffs master before other allies.
const int AI_MAGIC_NO_MAGIC =            0x00000002; // Will not use any magic (Spells, items, abilities).
const int AI_MAGIC_DEFENSIVE_CASTING =   0x00000004; // Will only cast defensive spells.
const int AI_MAGIC_OFFENSIVE_CASTING =   0x00000008; // Will only cast offensive spells.
const int AI_MAGIC_STOP_DISPEL =         0x00000010; // Will not cast dispel type spells.
const int AI_MAGIC_BUFF_AFTER_REST =     0x00000020; // Will buff the party after resting.
const int AI_MAGIC_NO_MAGIC_ITEMS =      0x00000040; // Will not use magic items in combat.
const int AI_MAGIC_LOW_MAGIC_USE =       0x00000080; // Will use spells sparingly in combat.
const int AI_MAGIC_NORMAL_MAGIC_USE =    0x00000100; // Will use spells more in combat.
const int AI_MAGIC_HEAVY_MAGIC_USE =     0x00000200; // Will use spells a lot in combat.
const int AI_MAGIC_CONSTANT_MAGIC_USE =  0x00000400; // Will use spells all the time until out in combat.
const int AI_MAGIC_NO_SPONTANEOUS_CURE = 0x00000800; // Caster will stop using spontaneous cure spells.
//const int AI_MAGIC_ =                  0x00001000; // Not used.
//const int AI_MAGIC_ =                  0x00002000; // Not used.
//const int AI_MAGIC_ =                  0x00004000; // Not used.
//const int AI_MAGIC_ =                  0x00008000; // Not used.
//const int AI_MAGIC_ =                  0x00010000; // Not used.
//const int AI_MAGIC_ =                  0x00020000; // Not used.
//const int AI_MAGIC_ =                  0x00040000; // Not used.
//const int AI_MAGIC_ =                  0x00080000; // Not used.
//const int AI_MAGIC_ =                  0x00100000; // Not used.
//const int AI_MAGIC_ =                  0x00200000; // Not used.
//const int AI_MAGIC_ =                  0x00400000; // Not used.
//const int AI_MAGIC_ =                  0x00800000; // Not used.
//const int AI_MAGIC_ =                  0x01000000; // Not used.
//const int AI_MAGIC_ =                  0x02000000; // Not used.
//const int AI_MAGIC_ =                  0x04000000; // Not used.
//const int AI_MAGIC_ =                  0x08000000; // Not used.
//const int AI_MAGIC_ =                  0x10000000; // Not used.
//const int AI_MAGIC_ =                  0x20000000; // Not used.
//const int AI_MAGIC_ =                  0x40000000; // Not used.
//const int AI_MAGIC_ =                  0x80000000; // Not used.
// Bitwise menu constants for Widget buttons that are used with Get/SetAssociateWidgetButtons().
const string sWidgetButtonsVarname = "ASSOCIATE_WIDGET_BUTTONS";
const int BTN_WIDGET_OFF     = 0x00000001; // Removes the widget from the screen, For PC it removes all associates.
const int BTN_WIDGET_LOCK    = 0x00000002; // Locks the widget to the current coordinates.
const int BTN_CMD_GUARD      = 0x00000004; // Command associates to Guard Me. PC widget only.
const int BTN_CMD_FOLLOW     = 0x00000008; // Command associates to Follow. PC widget only.
const int BTN_CMD_HOLD       = 0x00000010; // Command associates to Stand Ground. PC widget only.
const int BTN_CMD_ATTACK     = 0x00000020; // Command associates to Attack Nearest. PC widget only.
const int BTN_BUFF_REST      = 0x00000040; // Buffs with long duration spells after resting. Associate widget only.
const int BTN_BUFF_SHORT     = 0x00000080; // Buffs with short duration spells.
const int BTN_BUFF_LONG      = 0x00000100; // Buffs with long duration spells.
const int BTN_BUFF_ALL       = 0x00000200; // Buffs with all spells.
const int BTN_CMD_ACTION     = 0x00000400; // Command associate to do an action.
const int BTN_CMD_GHOST_MODE = 0x00000800; // Toggle's associates ghost mode.
const int BTN_CMD_AI_SCRIPT  = 0x00001000; // Toggle's special tactics ai scripts.
const int BTN_CMD_PLACE_TRAP = 0x00002000; // A trapper may place traps.
// Bitwise menu constants for Associate AI buttons that are used with Get/SetAssociateAIButtons().
const string sAIButtonsVarname = "ASSOCIATE_AI_BUTTONS";
const int BTN_AI_FOR_PC             = 0x00000001; // PC use AI. PC widget only.
const int BTN_AI_USE_RANGED         = 0x00000002; // AI uses ranged attacks.
const int BTN_AI_USE_SEARCH         = 0x00000004; // AI uses Search.
const int BTN_AI_USE_STEALTH        = 0x00000008; // AI uses Stealth.
const int BTN_AI_REMOVE_TRAPS       = 0x00000010; // AI seeks out and removes traps.
const int BTN_AI_PICK_LOCKS         = 0x00000020; // AI will attempt to pick locks.
const int BTN_AI_MAGIC_USE_PLUS     = 0x00000040; // Increase chance to use magic in battle.
const int BTN_AI_MAGIC_USE_MINUS    = 0x00000080; // Decrease chance to use magic in battle.
const int BTN_AI_NO_MAGIC_USE       = 0x00000100; // Will not use magic in battle.
const int BTN_AI_ALL_MAGIC_USE      = 0x00000200; // Will use all types of magic in battle.
const int BTN_AI_DEF_MAGIC_USE      = 0x00000400; // Will use Defensive spells only in battle.
const int BTN_AI_OFF_MAGIC_USE      = 0x00000800; // Will use Offensive spells only in battle.
const int BTN_AI_LOOT               = 0x00001000; // Auto picking up loot on/off.
const int BTN_AI_FOLLOW_TARGET      = 0x00002000; // Selects a target to follow.
const int BTN_AI_HEAL_OUT_PLUS      = 0x00004000; // Increase minimum hp required before ai heals out of combat.
const int BTN_AI_HEAL_OUT_MINUS     = 0x00008000; // Decrease minimum hp required before ai heals out of combat.
const int BTN_AI_HEAL_IN_PLUS       = 0x00010000; // Increase minimum hp required before ai heals in combat.
const int BTN_AI_HEAL_IN_MINUS      = 0x00020000; // Decrease minimum hp required before ai heals in combat.
const int BTN_AI_STOP_SELF_HEALING  = 0x00040000; // Stops AI from using any healing on self.
const int BTN_AI_STOP_PARTY_HEALING = 0x00080000; // Stops AI from using any healing on party.
const int BTN_AI_LOOT_RANGE_PLUS    = 0x00100000; // Increase range where we will check for loot.
const int BTN_AI_LOOT_RANGE_MINUS   = 0x00200000; // Decrease range where we will check for loot.
const int BTN_AI_UNLOCK_RANGE_PLUS  = 0x00400000; // Increase range where we will check for locks.
const int BTN_AI_UNLOCK_RANGE_MINUS = 0x00800000; // Decrease range where we will check for locks.
const int BTN_AI_TRAPS_RANGE_PLUS   = 0x01000000; // Increase range where we will check for traps.
const int BTN_AI_TRAPS_RANGE_MINUS  = 0x02000000; // Decrease range where we will check for traps.
const int BTN_AI_BASH_LOCKS         = 0x04000000; // AI will attempt to bash any locks they can't get past.
const int BTN_AI_REDUCE_SPEECH      = 0x08000000; // Reduce the associates speaking.
const int BTN_AI_FOLLOW_PLUS        = 0x10000000; // Increase distance the associate will follow.
const int BTN_AI_FOLLOW_MINUS       = 0x20000000; // Decrease distance the associate will follow.
// Bitwise menu constants for a second Associate AI buttons that are used with Get/SetAssociateAIButtons().
const string sAIButtons2Varname = "ASSOCIATE_AI_BUTTONS_2";
const int BTN2_AI_NO_SPONTANEOUS     = 0x00000001; // Not used.
//const int BTN2_AI_                 = 0x00000002; // Not used.
//const int BTN2_AI_                 = 0x00000004; // Not used.
//const int BTN2_AI_                 = 0x00000008; // Not used.
//const int BTN2_AI_                 = 0x00000010; // Not used.
//const int BTN2_AI_                 = 0x00000020; // Not used.
//const int BTN2_AI_                 = 0x00000040; // Not used.
//const int BTN2_AI_                 = 0x00000080; // Not used.
//const int BTN2_AI_                 = 0x00000100; // Not used.
//const int BTN2_AI_                 = 0x00000200; // Not used.
//const int BTN2_AI_                 = 0x00000400; // Not used.
//const int BTN2_AI_                 = 0x00000800; // Not used.
//const int BTN2_AI_                 = 0x00001000; // Not used.
//const int BTN2_AI_                 = 0x00002000; // Not used.
//const int BTN2_AI_                 = 0x00004000; // Not used.
//const int BTN2_AI_                 = 0x00008000; // Not used.
//const int BTN2_AI_                 = 0x00010000; // Not used.
//const int BTN2_AI_                 = 0x00020000; // Not used.
//const int BTN2_AI_                 = 0x00040000; // Not used.
//const int BTN2_AI_                 = 0x00080000; // Not used.
//const int BTN2_AI_                 = 0x00100000; // Not used.
//const int BTN2_AI_                 = 0x00200000; // Not used.
//const int BTN2_AI_                 = 0x00400000; // Not used.
//const int BTN2_AI_                 = 0x00800000; // Not used.
//const int BTN2_AI_                 = 0x01000000; // Not used.
//const int BTN2_AI_                 = 0x02000000; // Not used.
//const int BTN2_AI_                 = 0x04000000; // Not used.
//const int BTN2_AI_                 = 0x08000000; // Not used.
//const int BTN2_AI_                 = 0x10000000; // Not used.
//const int BTN2_AI_                 = 0x20000000; // Not used.
// Bitwise constants for Associate loot options that are used with Get/SetAssociateLootMode().
const string sLootFilterVarname = "ASSOCIATE_LOOT_MODES";
const int AI_LOOT_PLOT              = 0x00000001;
const int AI_LOOT_WEAPONS           = 0x00000002;
const int AI_LOOT_ARMOR             = 0x00000004;
const int AI_LOOT_SHIELDS           = 0x00000008;
const int AI_LOOT_HEADGEAR          = 0x00000010;
const int AI_LOOT_BELTS             = 0x00000020;
const int AI_LOOT_BOOTS             = 0x00000040;
const int AI_LOOT_CLOAKS            = 0x00000080;
const int AI_LOOT_GLOVES            = 0x00000100;
const int AI_LOOT_JEWELRY           = 0x00000200;
const int AI_LOOT_POTIONS           = 0x00000400;
const int AI_LOOT_SCROLLS           = 0x00000800;
const int AI_LOOT_WANDS_RODS_STAVES = 0x00001000;
const int AI_LOOT_GEMS              = 0x00002000;
const int AI_LOOT_MISC              = 0x00004000;
const int AI_LOOT_ARROWS            = 0x00008000;
const int AI_LOOT_BOLTS             = 0x00010000;
const int AI_LOOT_BULLETS           = 0x00020000;
// Default value for all loot filters to be on.
const int AI_LOOT_ALL_ON = 262143;
// Variable to keep track of who is in ghost mode.
const string sGhostModeVarname = "AI_GHOST_MODE_ON";
// Variables for gold piece value to pickup items.
const string AI_MIN_GOLD_ = "AI_MIN_GOLD_";
// Variable used to limit the spamming of NUI buttons.
const string AI_DELAY_NUI_USE = "AI_DELAY_NUI_USE";
// Variable for maximum weight to pickup from looting.
const string AI_MAX_LOOT_WEIGHT = "AI_MAX_LOOT_WEIGHT";
// Variable to change the difficulty so a player can adjust spell usage.
const string AI_DIFFICULTY_ADJUSTMENT = "AI_DIFFICULTY_ADJUSTMENT";
// Variable to change the Healing % limit for out of combat.
const string AI_HEAL_OUT_OF_COMBAT_LIMIT = "AI_HEAL_OUT_OF_COMBAT_LIMIT";
// Variable to change the Healing % limit for in combat.
const string AI_HEAL_IN_COMBAT_LIMIT = "AI_HEAL_IN_COMBAT_LIMIT";
// Variable to change the looting range.
const string AI_LOOT_CHECK_RANGE = "AI_LOOT_CHECK_RANGE";
// Variable to change the lock checking range.
const string AI_LOCK_CHECK_RANGE = "AI_LOCK_CHECK_RANGE";
// Variable to change the trap checking range.
const string AI_TRAP_CHECK_RANGE = "AI_TRAP_CHECK_RANGE";
// Variable to change the range an associate follows the pc.
const string AI_FOLLOW_RANGE = "AI_FOLLOW_RANGE";
// Variable that holds the target for an associate to follow.
const string AI_FOLLOW_TARGET = "AI_FOLLOW_TARGET";
// The number of Buff Groups
const int AI_BUFF_GROUPS = -17;
// Variable name used to keep track if we have set our talents.
const string AI_TALENTS_SET = "AI_TALENTS_SET";
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
// Variable name of json talent immunity.
const string AI_TALENT_IMMUNITY = "AI_TALENT_IMMUNITY";
// Variables that clips checking talent categories a creature does not have.
// Significantly reduces search times.
const string AI_NO_TALENTS = "AI_NO_TALENTS_";
// Backward compatability constants.
const int X2_EVENT_CONCENTRATION_BROKEN = 12400;
// Variable that saves any module target event script so we can pass it along.
const string AI_MODULE_TARGET_EVENT = "AI_MODULE_TARGET_EVENT";
// Variable used on the player to define the targeting action in the OnPlayerTarget event script.
const string AI_TARGET_MODE = "AI_TARGET_MODE";
// Variable used on the player to define which associate triggered the OnPlayer Target.
const string AI_TARGET_ASSOCIATE = "AI_TARGET_ASSOCIATE";
// Bitwise constants for immune damage item properties that is used with Get/SetItemProperty().
const string sIPImmuneVarname = "AI_IP_IMMUNE";
// Bitwise constants for resisted damage item properties that is used with Get/SetItemProperty().
const string sIPResistVarname = "AI_IP_RESIST";
// Variable name for the Int constant for reduced damage item property set to the bonus of the weapon required.
const string sIPReducedVarname = "AI_IP_REDUCED";
// Variable name for the Int (Bool) constant for the haste item property.
const string sIPHasHasteVarname = "AI_IP_HAS_HASTE";
//***************************** AI RULES CONSTANTS *****************************
// Variable name set to a creatures full name to set debugging on.
const string AI_RULE_DEBUG_CREATURE = "AI_RULE_DEBUG_CREATURE";
// Moral checks on or off.
const string AI_RULE_MORAL_CHECKS = "AI_RULE_MORAL_CHECKS";
// Allows monsters to prebuff before combat starts.
const string AI_RULE_BUFF_MONSTERS = "AI_RULE_BUFF_MONSTERS";
// Allows monsters cast summons spells when prebuffing.
const string AI_RULE_PRESUMMON = "AI_RULE_PRESUMMON";
// Allow the AI move during combat base on the situation and action taking.
const string AI_RULE_ADVANCED_MOVEMENT = "AI_RULE_ADVANCED_MOVEMENT";
const int AI_ADVANCED_COMBAT_MOVEMENT = TRUE;
// Follow Item Level Restrictions for monsters/associates.
// Usually off in Single player and on in Multi player.
const string AI_RULE_ILR = "AI_RULE_ILR";
// Allow the AI to use Use Magic Device.
const string AI_RULE_ALLOW_UMD = "AI_RULE_ALLOW_UMD";
// Allow the AI to use healing kits.
const string AI_RULE_HEALERSKITS = "AI_RULE_HEALERSKITS";
// Summoned associates are permanent and don't disappear when the caster dies.
const string AI_RULE_PERM_ASSOC = "AI_RULE_PERM_ASSOC";
// Monster AI's chance to attack the weakest target instead of the nearest.
const string AI_RULE_AI_DIFFICULTY = "AI_RULE_AI_DIFFICULTY";
// Variable that can change the distance creatures will come and attack after
// hearing a shout from an ally that sees or hears an enemy.
// Or when searching for an invisible, heard enemy.
// 10.0 short, 20.0 Medium, 35.0 long, 35.0 player.
const string AI_RULE_PERCEPTION_DISTANCE = "AI_RULE_PERCEPTION_DISTANCE";

/*/ Special behavior constants from x0_i0_behavior
const int NW_FLAG_BEHAVIOR_SPECIAL       = 0x00000001;
//Will always attack regardless of faction
const int NW_FLAG_BEHAVIOR_CARNIVORE     = 0x00000002;
//Will only attack if approached
const int NW_FLAG_BEHAVIOR_OMNIVORE      = 0x00000004;
//Will never attack.  Will alway flee.
const int NW_FLAG_BEHAVIOR_HERBIVORE     = 0x00000008;
// This is the name of the local variable that holds the spawn-in conditions
const string sSpawnCondVarname = "NW_GENERIC_MASTER";
// The available spawn-in conditions from x0_i0_spawncond
const int NW_FLAG_ESCAPE_RETURN               = 0x00000020; //Failed
const int NW_FLAG_ESCAPE_LEAVE                = 0x00000040;
const int NW_FLAG_TELEPORT_RETURN             = 0x00000080; //Failed
const int NW_FLAG_TELEPORT_LEAVE              = 0x00000100;
const int NW_FLAG_END_COMBAT_ROUND_EVENT      = 0x00004000;
const int NW_FLAG_ON_DIALOGUE_EVENT           = 0x00008000;
const int NW_FLAG_AMBIENT_ANIMATIONS          = 0x00080000;
const int NW_FLAG_HEARTBEAT_EVENT             = 0x00100000;
const int NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS = 0x00200000;
const int NW_FLAG_DAY_NIGHT_POSTING           = 0x00400000;
const int NW_FLAG_AMBIENT_ANIMATIONS_AVIAN    = 0x00800000;
const string sWalkwayVarname = "NW_WALK_CONDITION";
// If set, the creature's waypoints have been initialized.
const int NW_WALK_FLAG_INITIALIZED                 = 0x00000001;
// If set, the creature will walk its waypoints constantly,
// moving on in each OnHeartbeat event. Otherwise,
// it will walk to the next only when triggered by an
// OnPerception event.
const int NW_WALK_FLAG_CONSTANT                    = 0x00000002;
// Set when the creature is walking day waypoints.
const int NW_WALK_FLAG_IS_DAY                      = 0x00000004;
// Set when the creature is walking back
const int NW_WALK_FLAG_BACKWARDS                   = 0x00000008;

