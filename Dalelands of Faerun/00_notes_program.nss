/*

Game notes:

Encounters:
Bosses CR is equal to the encounter CR.
Encounters are equal to 4 creatures being 3 CR less than the encounter.
Thus using between 1 and 5 creatures per encounter.
5 CR 1 creatures are a CR 5 encounter.
4 CR 2 creatures are a CR 5 encounter.
3 CR 3 creatures are a CR 5 encounter.
2 CR 4 creatures are a CR 5 encounter.
1 CR 5 creature is a CR 5 encounter.


New definitions:

Fear effects do not make creatures flee, but instead give penalties on
      attack rolls, saving throws, skill checks, and ability checks.
Shaken: -2 penalty.
Frightened: -4 penalty & paralyzed for 1-3 rounds.
Panicked: -6 penalty & paralyzed for 1-6 rounds.

Coding notes:

***** Naming Conventions
0*_ - The main designation for Server scripts start with a 0.

0e_ - Event scripts.
0i_ - Include scripts.
0c_ - Conversation scripts.
0s_ - Spell scripts
0t_ - trap scripts

// ***** All event run scripts are linked via the tag. of the area, item, placeable, or creature.
         i.e. ae_TAGOFAREA.

ae_ - Area Enter scripts. They are run from the event 0e_areaenter.
ax_ - Area eXit scripts. They are run from the event 0e_areaexit.
aq_ - Item aquire scripts. They are run from the event 0e_aquireitem.
ac_ - Item activation scripts. They are run from the event 0e_activateitem.
eq_ - Item equip scripts. They are run from the event 0e_playerequip.
ue_ - Item unequip scripts. They are run from the event 0e_playerunequip.
ua_ - Item unaquire scripts. They are run from the event 0e_unaquireitem.
oh_ - Item OnHit scripts. They are run when an item has the OnHit Generic Spell property.
cd_ - Creature death scripts. They are run when a creature dies in the event 0e_cr_death.
cs_ - Creature spawn scripts. They are run when a creature spawns in the event 0e_cr_spawn.
pd_ - Placeable death scripts. They are run when a placeable is destroyed in the event 0e_pl_death.
ps_ - Placeable spawn scripts. They are run when a placeable is spawned in the event 0e_pl_spawn.

***** MODULE VARIABLES **********
0_Error (Module/String)- Holds the last error that occured.

***** AREA Variables *****
0_Clean_Wait_Period (Area/Int) - Can be used to clean an area faster than
    normal.
0_PopulateOFF (Area/Int) - Used by DM's to turn spawning off while they run events.
0_LootOFF (Area/Int) - Used by DM's to turn loot off while they run an event.
0_XPOFF (Area/Int) - Used by DM's to turn XP off while they run an event.
0_CleanOFF (Area/Int) - Used by DM's to turn cleaning of areas off for events.
0_NoSpells (Area/Int) - Used by DM's to turn magic on/off for the current area.

***** AREA Information points **********
ip_area_level
    Defines many objects difficulty within an area. I.E. Traps, locks, treasure, etc.
    This will be a minimum level and a maximum level cap.
    If not set in an area the area defaults to Min:1 and Max:5.
    0_Min_Level (Waypoint/Int) - Minimum level a character will be calculated as.
    0_Max_Level (Waypoint/Int) - Maximum level a character will be calculated as.
ip_encounter
    An encounter will spawn here based upon the ip_area_level variables.
ip_no_rest
    If placed in an area then the only rest allowed is with placeables.
    No waypoint sets the area to allow resting everywhere.
WP_NoReturning
    If placed in an area stops any character from being returned with the rod of returning.
WP_NoSpells
    If placed in an area will stop any spells from working in the area. Dead magic zone.

***** CHARACTER VARIABLES **********
0_NoResetSinceLastLogin (Character/Int) - Holds whether the server has been reset
    since the players last login.
    Note: Player variables reset on server resets thus removing the variable
    to show that the server was reset.
0_CharacterLoggedIn (Character/Int) - Tells if the character has been logged in
    or not. Used in the 0e_areaenter event to load character information on log in.
0_Death_Location (Character/String) - The location of where the player died.
0_Kills (Character/Int) - The number of kills a player has had since the
    characters last saved.
0_Current_HP (Character/Int) - Used for resting, holds the characters
    current hitpoints while resting.
0_Raise (Character/Int) - Used to define if they can be brought back to life with
    a spell. Defined as 1 Raise dead, 2 Resurrection, 3 True Resurrection.


****** OBJECT VARIABLES **********

****** PLACEABLE/DOOR VARIABLES ************
--- State info
0_NoClose (Door/Int) - Makes a door stay open after resetting an area.

--- Lock info ---
0_LockChance (Door,Container, or Spawner/Int) - Sets the objects chance to be
    locked. -1 sets the door to never be locked. See 0i_spawn for more.
0_UnlockDC (Door,Container, or Spawner/Int) - Sets the DC to unlock an object.
    See 0i_spawn for more.
0_BashDC (Door,Container, or Spawner/Int) - Sets the DC to bash through an
    object that is locked. See 0e_bash for more.

--- Trap info ---
0_TrapChance (Door,Container, or Spawner/Int ) - Sets the objects chance to be
    trapped. -1 sets the door to never be locked. See 0i_spawn for more.
0_TrapDetectDC (Door,Container, or Spawner/Int) - Sets the DC to detect a trap
    on an object. See 0i_spawn for more.
0_TrapDisarmDC (Door,Container, or Spawner/Int) - Sets the DC to disarm a trap
    on an object. See 0i_spawn for more.

--- Treasure info ---
0_Multiplier (Object/Int) - The object will recieve multiple of any treasure found
    equal to the value of 0_Multiplier. -1 Will give no treasure. 0 = 1 multiple as default.
0_BonusGold (Object/Int) - Object will get a bonus amount of gold
    equal to the value of 0_BonusGold.
0_BonusMagicItems (Object/Int) - Object will get a bonus number of magic items
    equal to the value of 0_BonusMagicItems.
0_TreasureBonus (Object/Int) - Object will add this number to the level used to
    roll for treasure.
0_Generated_NPC (Creature/Int) - If set to TRUE then the NPC was generated.

--- Item data ---
0_Creator (Item/String) - Sets the name of the object/creature that created this
    item in the game.
0_Binded (Item/String) - Sets the name of the players character who first got this item.

****** CRAFTING VARIABLES ************
0_Craft_DC (Item/Int) - Sets the DC to craft the object of this mold.
0_Craft_Skill (Item/Int) - Sets what skill is rolled to craft this mold.
0_Craft_ResRef (Item/Int) - Sets the resref on the mold of the item to be crafted.
    There should be 4 types of the item (ResRef1 to ResRef4).
0_Craft_Metal (Item/Int) - Sets how many metal ingots are needed. They are Iron,
    Adamantine, Mithral, Cold Iron, Alchemical Silver.
0_Craft_Cloth (Item/Int) - Sets how many cloth bolts are needed.
0_Craft_Wood (Item/Int) - Sets how many wood planks are needed.
0_Craft_Leather (Item/Int) - Sets how many leather hides are needed.
0_Craft_Shop (Shop/Int) - Tells the on aquire script to repopulate a mold in a shop if the shop is set to 1 with this variable.
                           Used to bypass variables not saving on items in shops.

****** Journal Notes ************
To work with the persistancy system all journal tags must use the following naming convention.
0_Journal_## where ## is the number of the quest. i.e. the first quest in the
    system is 01, the second is 02, etc.

********** Token map **********
Module Tool
 430 Target Name
 431 Area Spawning
 432 Area Treasure
 433 Area Give XP
 434 Area Cleaning
 435 Area Level
 436 Area Anti-magic zone
 437 Area resting
 438 Area Encounters
 440 Starting Character Level
 441 Treasure Slider
 442 XP Slider
 443 Weather settings
 450 -458 Area save slots
 460 Strength
 461 Dexterity
 462 Constitution
 463 Intelligence
 464 Wisdom
 465 Charisma
 470 1st Class and level
 471 2nd Class and level
 472 3rd Class and level
 473 Targets faction
 474 Class selection
 475 Faction selection


Players Handbook
 1101
 1102
 1103
 1104
 1105
 1106
 1107
 1108
 1109
 1110 Deity
 1111 Age

Character Creation (0c_char_create)
 1150 Deity

Henchman Conversations
 8000
*/

void main()
{

}
