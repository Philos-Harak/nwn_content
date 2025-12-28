/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_spells
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for base spells.

 Variables on creaters that affect spells.
 int   0_SpellCasterLvlMod - Adjust the casters level for the cast spell.
 int   0_SpellDCMod - Adjust the casters spell DC.
 int   0_SpellDmgMod - Adjust a spells total damage.
 int   0_SpellDurationMod - Adjust the duration of a spell.
 float 0_SpellWidthMod - Adjust the area effect by times the number.

Touch range  = 7'   (1/2 tile)  2.25m
Short range  = 25'  (1 tile)    8m
Medium range = 65'  (2 tiles)  20m
Long range   = 130' (4 tiles)  40m
Feat to Meters: feet * 0.3048  (130' * 0.3048 = 39.624 meters)
* To allow a spell to do its effect in the enchant_table.2da set the "Cast_On_Item"
  column to 1.


 Ideas to make work in all/most spells.
X Components for spells.
X Repeat Spell - A repeated spell is automatically cast again at
the beginning of your next turn in the round.
* Chain Spell - You can chain any spell that specifies a single
target and has a range greater than touch. The chained
spell affects that target (the primary target) normally, then
arcs to a number of secondary targets equal to your caster
level.
* Sculpt Spell - You can modify an area spell by changing the
area’s shape. The new area must be chosen from the following
list: cylinder (10-foot radius, 30 feet high), 40-foot
cone, four 10-foot cubes, or a ball (20-foot-radius spread).
* Split Ray - You can split spells that specify a single target
and make a ranged touch attack.
* Widen  Spell - You can alter a (cylinder(line)'s length, Spell Cone's length,
cube's 1/2 side or sphere's radius) shape to increase it's size.

Summons array (Also make sure any summons have "0_Summon_ID" set to the spellID used!)
0 - Henchmen info see 0i_henchmen
1 - 9 Summon Monster I - IV
10 Create Undead
11 Create Greater Undead
12 Lesser Planar portal
13 Planar portal
14 Greater Planar portal
15 Gate
16 Minor Creation

Polymorph Array Slots
0 - none
1 - Polymorph Self
2 - Spiderform

Teleport Array Slots
1 - 10 Selection options in teleport menu.
11 - 20 Name of the location saved.
21 - Teleport selected appear location.
22 - Respawn appear location.

tlk
Spell descriptions...

Notes:
Shadow spells - need done & reworked.
Planar/Gate spells - need rework.
AOE spells - need reworked.
Storm of Vengence - needs to be reworked to closer to the book version.
Black Blade of Disaster - needs to be reworked as its too close to mordenkainen's sword.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_win_layout_pc"
#include "0i_effects"
#include "0i_crafting"
#include "nwnx_consts"
// Used for AOE Behavior of NPC. To see how to remove enemy area of effects.
const int X2_SPELL_AOEBEHAVIOR_FLEE = 0;
const int X2_SPELL_AOEBEHAVIOR_IGNORE = 1;
const int X2_SPELL_AOEBEHAVIOR_GUST = 2;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_L = SPELL_LESSER_DISPEL;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_N = SPELL_DISPEL_MAGIC;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_G = SPELL_GREATER_DISPELLING;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_M = SPELL_MORDENKAINENS_DISJUNCTION;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_C = 727;

struct stSpell Spell;

// Will adjust the spells variables to allow for customization of all spells.
// stSpell Spell - the structure variable the spell will use.
// Must be setup in the spell before calling this fuction.
struct stSpell SetSpell(struct stSpell Spell);

// Calculate the duration for the spell.
// Returns the value in Spell.fDuration.
// bItemEnchantment - the spell being cast enchants items (Extend Enchantments feat).
struct stSpell GetDuration(struct stSpell Spell, int bItemEnchantment = FALSE);

// Roll dice for either damage or modifiers.
// Returns the value in Spell.iResult
// Spell is the spell struct.
struct stSpell GetModifier(struct stSpell Spell);

// Get the level of the spell being cast based on casting class.
// Spell is the spell structure.
int GetSpellLevel(struct stSpell Spell);

// Get the spells school from Spells.2da
// Returns SPELL_SCHOOL_*
// iSpellID the ID of the spell you want to know the school for.
int GetSpellSchool(int iSpellID);

// Get the Difficulty challenge for the spell to use in saves.
// stSpell is the spell struct.
struct stSpell GetSaveDC(struct stSpell Spell);

// Check for a Savingthrow and Spell Resistance by using Spell struct variable.
// Does full save check for 1/2 damage and negation.
// Returns the following values in Spell.iSaveResult.
// Returns FALSE (0) if a target fails its resistance check and save attempt.
// Returns on Resist: 1 - Resisted, 2 - Magic Immunity, 3 - Spell absorption.
// Returns on Save: 4 - Save Negates, 2 - Target is immune to the save type.
// stSpell is the spell struct.
struct stSpell ResistAndSave(struct stSpell Spell);

// Checks all classes to get total caster level
// for the last spell cast and special abilities.
// stSpell is the spell struct
// Returns the Spell variable.
struct stSpell GetCasterTotalLevel(struct stSpell Spell);

int GetCasterLevelByClass(object oCreature, int nClass);

// Returns the highest level class for oCaster that is not nClassToIgnore.
int GetHighestArcaneCasterClass(object oCaster, int nClassToIgnore = 0);
// Checks to see if the target of the spell is valid.
// Some abilities remove targets as valid.
// oTarget is the target of the spell.
// iTargetType what type of targets are we trying to hit.
// oCaster is the caster of the spell.
int GetIsSpellTargetValid(object oTarget, int iTargetType, object oCaster);

// Gets a target for a beam spell.
// Checks for area spells, personal spells, and single target spells.
// Cones and Cylinders will give the closest targets in order.
// Checks for and only returns valid targets based on Spell.iTargetType.
// Returns the object to Spell.oAreaTarget.
// Spell is the spell's variables.
struct stSpell GetSpellBeamTarget(struct stSpell Spell);

// Gets a target for a spell.
// Checks for area spells, personal spells, and single target spells.
// Checks for and only returns valid targets based on Spell.iTargetType.
// Returns the object to Spell.oAreaTarget.
// Spell is the spell's variables.
struct stSpell GetSpellTarget(struct stSpell Spell);

// Runs after every spell.
void CleanUpSpell(struct stSpell Spell);

// Checks for Sudden Feats and adjusts for them.
struct stSpell CheckForSuddenFeats(struct stSpell Spell);

// Will setup a spell to fire again on the next round.
// Spell is the spell's variables.
void FireSpellAgain(struct stSpell Spell);

// Unsummon monsters based on spell cast.
void AdjustCurrentSummonedCreatures(object oCaster, int iSpellID);

// Mark just summoned creatures, use is the summon spell.
void MarkSummonedCreatures(object oCaster, int nSpellID);

// Cast an Arcane Blast.
// Spell is the original spells variables.
void CastArcaneBlast(struct stSpell Spell);

// Will do all cure type effects for living and undead creatures.
// Spell is the spell structure.
// iVFX_ImpDmg is the vfx for doing damage to undead.
// iVFX_ImpHeal is the vfx for healing a creature.
void CureSpell(struct stSpell Spell, int iVFX_ImpDmg, int iVFX_ImpHeal);

// Will do all inflict type effects for living and undead creatures.
// Spell is the spell structure.
// iVFX_ImpDmg is the vfx for doing damage to undead.
// iVFX_ImpHeal is the vfx for healing a creature.
void InflictSpell(struct stSpell Spell, int iVFX_ImpDmg, int iVFX_ImpHeal);

// Fires a volley of missiles around the area of the object selected.
// Spell is the spells data from the original spell.
// iNumOfMissles is the number of missles to fire.
// iMIRV is the vfx_imp_* defaults to VFX_IMP_MIRV
// bOneHit tells the script to only do one missle per enemy maximum.
// bOneTarget tells the script to put all missles into one target.
void MissileStorm(struct stSpell Spell, int iNumOfMissiles, int iMIRV = VFX_IMP_MIRV, int bOneHit = FALSE, int bOneTarget = FALSE);

// Removes mental spell effects from target and protects against new effects.
// Spell is the spells data from the original spell.
void ApplyMindBlank(struct stSpell Spell);

// Changes a spells damage type and some graphical effect based on damage type.
// Returns the spells structure.
// Spell is the spell struct for the spell.
// iDamageType is the damage type base on DAMAGE_TYPE_*
struct stSpell ChangeDamageType(struct stSpell Spell, int iDamageType);

// Wild magic!
// Will change a variety of effects for a spell when cast at random!
struct stSpell WildMagic(struct stSpell Spell);

// See vfx_persistent.2da for line number of the area of effect.
void SetAreaOfEffectSpellVariables(int iAreaOfEffectID, struct stSpell Spell);

// See vfx_persistent.2da for line number of the area of effect.
struct stSpell GetAreaOfEffectSpellVariables(int iAreaOfEffectID, struct stSpell Spell);

// Gets if character knows a spell.
int GetKnownSpell(object oPC, int nSpell);

// Returns if the creature can be summoned by this character.
// object oPC the player to check for summons.
// int nRow - The row of the change_spell.2da to check if they can be summoned.
int CanSummonCreature(object oPC, int nRow);

// * returns true if the creature has flesh
int IsImmuneToPetrification(object oCreature);

// Do I have any effect on me that came from a mind affecting spell?
int DoIHaveAMindAffectingSpellOnMe(object oTarget);

// True if this spell is a cure spell.
int IsCureTouchSpell(int nSpell);

// True if this spell is an Inflict spell.
int IsInflictTouchSpell(int nSpell);

int IsMindAffectingSpell(int iSpell);

// If the passed in spell is an area of effect spell.
int IsAreaOfEffectSpell(int nSpell);

// A different approach for timing spells that has the positive side
// effects of making the spell dispellable as well.
// I am using the VFX applied by the spell to track the remaining duration
// instead of adding the remaining runtime on the stack
//
// This function returns FALSE if a delayed Spell effect from nSpell_ID has
// expired. Used in nw_s0_acidarrow.
int GetDelayedSpellEffectsExpired(int nSpell_ID, object oTarget, object oCaster);

// Attempts a dispel on one target, with all safety checks put in.
void DispelMagicEffect(object oTarget, int nCasterLevel, effect eVis, effect eImpac, int bAll = TRUE, int bBreachSpells = FALSE);

void DoSpellBreach(object oTarget, int nTotal, int nSR, int nSpellId = -1);

// Handle Dispelling Area of Effects
// Since NWN does not give the required information to do proper dispelling
// on AoEs, we do some simulated stuff here:
// - Base chance to dispel is 25, 50, 75 or 100% depending on the spell
// - Chance is modified positive by the caster level and ability scores.
// - Chance is modified negative by the highest spellcasting class level of the
//   AoE creator and the releavant ability score.
void DispelAoEEffect(object oTargetAoE, object oCaster, int nCasterLevel);

// Removes temporary hit points so that they will not stack.
void RemoveTempHitPoints ();

// Saves spells to autobuff for a caster.
void SaveSpellToAutoBuff(struct stSpell Spell);

// Will check and make sure the spell is memorized.
// nSpell is the spell to find.
// nClass that cast the spell.
// nLevel the level of the spell.
// nMetamagic is if it has metamagic on it.
// nDomain is if it is a domain spell.
int GetSpellReady(object oCaster, int nSpell, int nClass, int nLevel, int nMetamagic, int nDomain);

// Returns the range from the spells.2da (Column Range) for nSpell.
// S = 8.0f, M = 20.0f, L = 40.0f, T = 5.0f, else = 0.1f;
float GetSpellRange(int nSpell);

// Returns TRUE if the target has a disabling spell cast from oCaster.
// FALSE if not.
int TargetHasDispelableEffect(object oTarget, object oCaster = OBJECT_SELF);

// Returns TRUE if persistant Area Of Effect spell will overlap an already
// existing AOE Spell of the same. FALSE if not.
// lTargetLocation is the location the new AOE spell will target.
// nAOESpellVFX is the AOE_* for the vfx_persistant.2da list.
int AOESpellOverlaps(location lTargetLocation, int nAOESpellVFX);

// Returns the Total controlled Hit Dice for oCaster based on classes and abilities.
int GetTotalUndeadControlledHitDice(object oCaster);
// Returns TRUE if oCaster takes control of the undead oCreature.
// This will check and add the creature to the Hit Dice total oCaster can control.
// A creature can only control a number of HitDice equal to thier class level.
// sSpellTag is the ability to change: "ANIMATE_DEAD" and "TURNED_UNDEAD"
// nTotalHD is the Total Hit Dice oCaster can control.
int IncreaseUndeadControlledHitDice(object oCaster, object oCreature, string sSpellTag, int nTotalHD);

// Reduced the number of Hit Dice oCaster has control of based on oCreatures
// Hit Dice for the ability of sSpellTag.
// sSpellTag is the ability to change: "ANIMATE_DEAD" and "TURNED_UNDEAD"
// nTotalHD is the Total Hit Dice oCaster can control.
void DecreaseUndeadControlledHitDice(object oCaster, object oCreature, string sSpellTag);

// Will adjust the spells variables to allow for customization of all spells.
// Also checks to see if the spell can be cast or needs to be stopped.
// stSpell Spell - the structure variable the spell will use.
// Must be setup in the spell before calling this fuction.
struct stSpell SetSpell (struct stSpell Spell)
{
    // ***********************************************************
    // *********** Setup Basic Spell Structure *******************
    // ***********************************************************
    // Check to see if the spell is firing a second time.
    /*if (GetLocalInt (OBJECT_SELF, "0_Fired_Spell_Again"))
    {
        // If so then get the spells variables from the caster.
        Spell.oCaster = OBJECT_SELF;
        Spell.iClass = GetLocalInt (OBJECT_SELF, "0_Spell_Class");
        Spell.iSpellID = GetLocalInt (OBJECT_SELF, "0_Spell_ID");
        Spell.oTarget = GetLocalObject (OBJECT_SELF, "0_Spell_oTarget");
        Spell.lTarget = GetLocalLocation (OBJECT_SELF, "0_Spell_lTarget");
        Spell.iMetaMagic = GetLocalInt (OBJECT_SELF, "0_Spell_MetaMagic");
        DeleteLocalInt (OBJECT_SELF, "0_Fired_Spell_Again");
    }
    // If not then get the variables the normal way.
    else
    { */
        Spell.oCaster = OBJECT_SELF;
        // Some spells define the class.
        // **** NOTICE! If this is not a spell defined for a class in the spells.2da it will return 255! ****
        if (Spell.iClass == 0) Spell.iClass = GetLastSpellCastClass();
        Spell.iSpellID = GetSpellId ();
        Spell.oTarget = GetSpellTargetObject();
        Spell.lTarget = GetSpellTargetLocation ();
        Spell.iMetaMagic = GetMetaMagicFeat ();
        Spell = CheckForSuddenFeats (Spell);
        // This will make a spell cast twice!
        // Any use of this ability must be done within this else grouping.
        // if (GetLocalInt (OBJECT_SELF, "0_Fired_Spell_Again") == 0) DelayCommand (5.0, FireSpellAgain (Spell));
    //}
    //Debug ("0i_spells", "309", GetName (OBJECT_SELF) + " is casting: " + Get2DAString ("Spells", "Label", Spell.iSpellID));
    // *********************************************************************
    // *********************** Cast by an Item *****************************
    // *********************************************************************
    object oItem = GetSpellCastItem ();
    // Check to see if the spell was cast by an item.
    if (GetIsObjectValid (oItem))
    {
        // Check to see if the item has a caster level.
        int iItemLevel = GetLocalInt (oItem, "0_Caster_Level");
        // Use the set caster level.
        if (iItemLevel > 0) Spell.iCasterLevel = iItemLevel;
        // Use the power level of the item i.e. minimum level to equip. if not.
        else Spell.iCasterLevel = NWNX_Item_GetMinEquipLevel (oItem);
        // Must be at least 1st level.
        if (Spell.iCasterLevel < 0) Spell.iCasterLevel = 1;
    }
    // *********************************************************************
    // ************************ Caster Level *******************************
    // *********************************************************************
    // Get the level of the caster using all classes that can use the spell.
    else Spell = GetCasterTotalLevel (Spell);
    // *********************************************************************
    // ************************ Feat Changes ****************************
    // *********************************************************************
    // Check for Elemental Transferance - Change the energy of an elemental spell.
    if (GetLocalInt (Spell.oCaster, "0_Elem_Transferance"))
    {
        // Check to see if the spell has an elemental descriptor.
        if (Spell.iDescriptor == DESC_ACID || Spell.iDescriptor == DESC_COLD ||
            Spell.iDescriptor == DESC_ELECTRICITY || Spell.iDescriptor == DESC_FIRE)
        {
            // Check for spell transferance feat.
            if (GetHasFeat (1338, Spell.oCaster))
            {
                Spell.iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
                Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
            }
            if (GetHasFeat (1392, Spell.oCaster))
            {
                Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
                Spell.iDamageType = DAMAGE_TYPE_FIRE;
            }
            if (GetHasFeat (1397, Spell.oCaster))
            {
                Spell.iSaveType = SAVING_THROW_TYPE_COLD;
                Spell.iDamageType = DAMAGE_TYPE_COLD;
            }
            if (GetHasFeat (1402, Spell.oCaster))
            {
                Spell.iSaveType = SAVING_THROW_TYPE_ACID;
                Spell.iDamageType = DAMAGE_TYPE_ACID;
            }
        }
    }
    // *************************************************************************
    // ****************** Check for area spell changes *************************
    // *************************************************************************
    // Get the area as these fuctions use the area to save the variables.
    object oArea = GetArea (Spell.oCaster);
    // Check for Wild magic zone.
    if (GetLocalInt (oArea, "0_Spell_State") == 2) Spell = WildMagic (Spell);
    // Check for dead magic zone, or Anti-magic effect on caster (Beholder).
    else if (GetLocalInt (oArea, "0_Spell_State") == 1 || GetLocalInt (Spell.oCaster, "0_Anti_Magic"))
    {
        // Send message.
        if (GetIsObjectValid (oItem))
        {
            SendMessages ("Your item does not work! Magic seems absent here.", COLOR_RED, Spell.oCaster);
        }
        else SendMessages ("Your spell fizzles! Magic seems absent here.", COLOR_RED, Spell.oCaster);
        // Stop the spell.
        Spell.iSpellID = STOP_SPELL;
        return Spell;
    }
    // Check for Altered magic zone.
    else if (GetLocalInt (oArea, "0_Spell_State") == 3)
    {
        int iValue;
        // Set Caster Level.
        iValue = GetLocalInt (oArea, "0_Caster_Level");
        if (iValue > 0) Spell.iCasterLevel = iValue;
        // Set Damage / Modifier dice.
        iValue = GetLocalInt (oArea, "0_Spell_Mod_Dice");
        if (iValue > 0) Spell.iModNumOfDice = iValue;
        // Set Damage / Modifier die.
        iValue = GetLocalInt (oArea, "0_Spell_Mod_Die");
        if (iValue > 0) Spell.iModifierDie = iValue;
        // Set Damage / Modifier dice per level.
        iValue = GetLocalInt (oArea, "0_Spell_Mod_Dice_Per_Lvl");
        if (iValue > 0) Spell.iModDicePerLvl = iValue;
        // Set Damage / Modifier.
        iValue = GetLocalInt (oArea, "0_Spell_Mod");
        if (iValue > 0) Spell.iModifier = iValue;
        // Set Damage / Modifier per level.
        iValue = GetLocalInt (oArea, "0_Spell_Mod_Per_Lvl");
        if (iValue > 0) Spell.iModPerLvl = iValue;
        // Check for damage type.
        iValue = GetLocalInt (oArea, "0_Spell_Dmg_Type");
        if (iValue > 0 && Spell.iDamageType > 0) Spell = ChangeDamageType (Spell, iValue);
        // Check for Spell area shape.
        if (GetLocalInt (oArea, "0_Spell.Area_Shape_Changed"))
        {
            Spell.iLineOfSight = TRUE;
            Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
            Spell.iAreaShape = GetLocalInt (oArea, "0_Spell_Area_Shape");
        }
        // Check for Spell area size.
        float fValue = GetLocalFloat (oArea, "0_Spell_Area_Size");
        if (fValue > 0.0f) Spell.fAreaSize = fValue;
    }
    else if(GetLocalInt(oArea, NO_PORTALING))
    {
        // 935 Leomunds Secure Shelter, 976 Teleport, 977 Greater Teleport.
        if(Spell.iSpellID == 935 || Spell.iSpellID == 976 || Spell.iSpellID == 977)
        {
            if(GetIsCharacter(Spell.oCaster))
            {
                SendMessages ("The spell cannot connect to another plane. This location is removed from the Astral plane!", COLOR_RED, Spell.oCaster);
            }
            Spell.iSpellID = STOP_SPELL;
            return Spell;
        }
    }
    // Check for widening special effects.
    if (GetLocalFloat (Spell.oCaster, "0_SpellWidthMod") > 0.0f) Spell.fAreaSize *= GetLocalFloat (Spell.oCaster, "0_SpellWidthMod");
    // ***************************************************
    // ******************* RAGE **************************
    // ***************************************************
    // Check for 0_Cannot_Cast.
    // Used to lock spells for Barbarian rage, Tensors Transformation, etc.
    if (GetLocalInt (Spell.oCaster, "0_Cannot_Cast"))
    {
        // Make sure this is a magical effect.
        if (Spell.iSubType == SUBTYPE_MAGICAL)
        {
            // The spell was cast from an item.
            if (GetIsObjectValid (oItem))
            {
                int iBaseType = GetBaseItemType (oItem);
                // Check for scrolls.
                if (iBaseType == BASE_ITEM_BLANK_SCROLL || iBaseType == BASE_ITEM_ENCHANTED_SCROLL ||
                    iBaseType == BASE_ITEM_SCROLL || iBaseType == BASE_ITEM_SPELLSCROLL)
                {
                    SendMessages ("Your mind is clouded and you cannot use scrolls.", COLOR_RED, OBJECT_SELF);
                    Spell.iSpellID = STOP_SPELL;
                    return Spell;
                }
                // Check for wands.
                if (iBaseType == BASE_ITEM_BLANK_WAND || iBaseType == BASE_ITEM_ENCHANTED_WAND ||
                    iBaseType == BASE_ITEM_MAGICWAND)
                {
                    // Send message.
                    SendMessages ("Your mind is clouded and you cannot use wands.", COLOR_RED, OBJECT_SELF);
                    Spell.iSpellID = STOP_SPELL;
                    return Spell;
                }
                // Check for Staves.
                if (iBaseType == BASE_ITEM_MAGICSTAFF)
                {
                    // Send message.
                    SendMessages ("Your mind is clouded and you cannot use staves.", COLOR_RED, OBJECT_SELF);
                    Spell.iSpellID = STOP_SPELL;
                    return Spell;
                }
                // Check for Staves.
                if (iBaseType == BASE_ITEM_MAGICROD)
                {
                    // Send message.
                    SendMessages ("Your mind is clouded and you cannot use rods.", COLOR_RED, OBJECT_SELF);
                    Spell.iSpellID = STOP_SPELL;
                    return Spell;
                }
            }
            // Then this magical effect was cast by the barbian making it a spell.
            else
            {
                // Send message.
                SendMessages ("Your mind is clouded and you cannot use spells.", COLOR_RED, OBJECT_SELF);
                Spell.iSpellID = STOP_SPELL;
                return Spell;
            }
        }
    }
    // *************************************************************************
    // ****************************** A Cast Spell *****************************
    // *************************************************************************
    // The spell was not cast from an item and its subtype is magical then its a spell.
    if (!GetIsObjectValid (oItem) && Spell.iSubType == SUBTYPE_MAGICAL)
    {
        // *********************************************************************
        // *************** Check to see if we are saving a Buff ****************
        // *********************************************************************
        //if (GetLocalInt (Spell.oCaster, "0_SAVE_BUFF_SPELL")) SaveSpellToAutoBuff (Spell);
        // *********************************************************************
        // ************************* Arcane Blast ******************************
        // *********************************************************************
        if (GetLocalInt (Spell.oCaster, "0_Arcane_Blast"))
        {
            // Make sure the target is an enemy and valid.
            if (GetIsSpellTargetValid (Spell.oTarget, TARGET_TYPE_ENEMIES, Spell.oCaster)) CastArcaneBlast (Spell);
            // Stop the original spell.
            Spell.iSpellID = STOP_SPELL;
            return Spell;
        }
        // *********************************************************************
        // *********** 20% spell failure if deaf and divine ********************
        // *********************************************************************
        // This is a core fix where arcane only gets a 20% failure if deaf so lets do it for divine as well.
        if (GetHasEffect (EFFECT_TYPE_DEAF, Spell.oCaster))
        {
            // Must be a non arcane i.e. a divine spell.
            if (Get2DAString ("classes", "Arcane", Spell.iClass) != "1")
            {
                // Is the spell verbal.
                string sVS = Get2DAString ("spells", "VS", Spell.iSpellID);
                if (sVS == "vs" || sVS == "v" && d100() < 20)
                {
                   Spell.iSpellID = STOP_SPELL;
                   return Spell;
                }
            }
        }
        // *********************************************************************
        // ************* Components / Divine Focus / Enhancing *****************
        // *********************************************************************
        // Components are only for PC's.
        object oMaster = GetMaster(Spell.oCaster);
        if(GetIsCharacter(Spell.oCaster) || GetIsCharacter(oMaster))
        {
            if(Spell.sArcaneComponent != "")
            {
                // Check to see if the caster is using an arcane spell.
                if (Spell.iClass == CLASS_TYPE_BARD || Spell.iClass == CLASS_TYPE_SORCERER ||
                    Spell.iClass == CLASS_TYPE_WIZARD || Spell.iClass == 48/*War Mage*/)
                {
                    // Check to see if the caster has the component.
                    object oComponent = GetCreatureHasItem (Spell.oCaster, Spell.sArcaneComponent);
                    // Has the component.
                    if (GetIsObjectValid (oComponent))
                    {
                        // Do we remove the component?
                        if (Spell.iCompAmount != 0 && GetTag (oComponent) != COMPONENT_POUCH)
                        {
                            int iAmount;
                            if (Spell.iCompAmount < 1) iAmount = 1;
                            else
                            {
                                iAmount = Spell.iCompAmount / (GetGoldPieceValue (oComponent) / GetItemStackSize(oComponent));
                                if (iAmount < 1) iAmount = 1;
                            }
                            if (!RemoveItemStack (Spell.oCaster, Spell.sArcaneComponent, iAmount))
                            {
                                // Send message.
                                if(oMaster != OBJECT_INVALID)
                                {
                                    SendMessages(GetName(Spell.oCaster) + " does not have the required components to cast this spell.", COLOR_RED, oMaster);
                                }
                                else SendMessages ("You do not have the required components to cast this spell.", COLOR_RED, OBJECT_SELF);
                                Spell.iSpellID = STOP_SPELL;
                                return Spell;
                            }
                        }
                    }
                    // Does not have the component.
                    else
                    {
                        // Send message.
                        if(oMaster != OBJECT_INVALID)
                        {
                            SendMessages(GetName(Spell.oCaster) + " does not have the required component to cast this spell.", COLOR_RED, oMaster);
                        }
                        else SendMessages("You not have the required component to cast this spell.", COLOR_RED, OBJECT_SELF);
                        Spell.iSpellID = STOP_SPELL;
                        return Spell;
                    }
                }
            }
            if (Spell.sDivineComponent != "")
            {
                // Check to see if the caster is using a divine spell.
                if (Spell.iClass == CLASS_TYPE_CLERIC || Spell.iClass == CLASS_TYPE_DRUID ||
                    Spell.iClass == 47/*Favored Soul*/)
                {
                    // Check to see if the caster has the component.
                    object oComponent = GetCreatureHasItem (Spell.oCaster, Spell.sDivineComponent);
                    // Has the component.
                    if (GetIsObjectValid (oComponent))
                    {
                        // Do we remove the component?
                        if (Spell.iCompAmount != 0 && GetTag (oComponent) != COMPONENT_POUCH)
                        {
                            int iAmount;
                            if (Spell.iCompAmount < 1) iAmount = 1;
                            else
                            {
                                iAmount = Spell.iCompAmount / (GetGoldPieceValue (oComponent) / GetItemStackSize(oComponent));
                                if (iAmount < 1) iAmount = 1;
                            }
                            if (!RemoveItemStack (Spell.oCaster, Spell.sDivineComponent, iAmount))
                            {
                                // Send message.
                                if(oMaster != OBJECT_INVALID)
                                {
                                    SendMessages (GetName(Spell.oCaster) + " does not have the required components to cast this spell.", COLOR_RED, oMaster);
                                }
                                else SendMessages ("You do not have the required components to cast this spell.", COLOR_RED, OBJECT_SELF);
                                Spell.iSpellID = STOP_SPELL;
                                return Spell;
                            }
                        }
                    }
                    // Does not have the component.
                    else
                    {
                        // Send message.
                        if(oMaster != OBJECT_INVALID)
                        {
                            SendMessages(GetName(Spell.oCaster) + " does not have the required component to cast this spell.", COLOR_RED, oMaster);
                        }
                        else SendMessages("You not have the required component to cast this spell.", COLOR_RED, OBJECT_SELF);
                        Spell.iSpellID = STOP_SPELL;
                        return Spell;
                    }
                }
            }
            if (Spell.iDivineFocus)
            {
                // Check to see if the caster is using a divine spell from Cleric or Favored Soul.
                if (Spell.iClass == CLASS_TYPE_CLERIC || Spell.iClass == 47/*Favored Soul*/)
                {
                    // Check to see if the caster has a holy symbol.
                    object oItem = GetCreatureHasItem (Spell.oCaster, CLERIC_HOLY_SYMBOL);
                    // Does not have the Divine Focus.
                    if (!GetIsObjectValid (oItem))
                    {
                        if(oMaster != OBJECT_INVALID)
                        {
                            SendMessages(GetName(Spell.oCaster) + " does not have a holy symbol to cast this spell!", COLOR_RED, oMaster);
                        }
                        else SendMessages ("You do not have a holy symbol to cast this spell!", COLOR_RED, OBJECT_SELF);
                        Spell.iSpellID = STOP_SPELL;
                        return Spell;
                    }
                }
                else
                {
                    // Check Druids for holly or mistletoe.
                    if (Spell.iClass == CLASS_TYPE_DRUID)
                    {
                        // Check to see if the caster has holly or mistltoe.
                        object oItem = GetCreatureHasItem (Spell.oCaster, DRUID_HOLY_SYMBOL);
                        // Does not have the Divine Focus.
                        if (!GetIsObjectValid (oItem))
                        {
                            if(oMaster != OBJECT_INVALID)
                            {
                                SendMessages(GetName(Spell.oCaster) + " does not have a Holly or Mistletoe to cast this spell!", COLOR_RED, oMaster);
                            }
                            else SendMessages ("You do not have a Holly or Mistletoe to cast this spell!", COLOR_RED, OBJECT_SELF);
                            Spell.iSpellID = STOP_SPELL;
                            return Spell;
                        }
                    }
                }
            }
            // Make sure we are not using enhancing components while crafting.
            string sTargetTag = GetTag (Spell.oTarget);
            if (Spell.sEnhancingComp != "" && GetLocalInt (Spell.oCaster, "0_Use_Enhancing_Component") &&
                sTargetTag != "0_craft_item" && sTargetTag != "enchant_box" && sTargetTag != "bag" &&
                sTargetTag != "0_comp_pouch")
            {
                // Check to see if the caster has the component.
                object oItem = GetCreatureHasItem (Spell.oCaster, Spell.sEnhancingComp);
                // Get the number of enhancing components needed. We assume each is 25gp worth.
                // The spell should have set how much gp worth is needed. Defaults to 25gp or 1.
                int iAmount = Spell.iCompAmount / 25;
                if (iAmount < 1) iAmount = 1;
                int iStack = GetItemStackSize (oItem);
                // Has the component.
                if (GetIsObjectValid (oItem) && iStack >= iAmount)
                {
                    // Remove the component?
                    if (iStack - 1 > iAmount) SetItemStackSize (oItem, iStack - iAmount);
                    else DestroyObject (oItem);
                    // Has the enhancing component and we have consumed it.
                    // Return back "TRUE".
                    Spell.sEnhancingComp = "TRUE";
                    // Tell the caster they are enhancing the spell!
                    string sSpellName = GetStringByStrRef (StringToInt (Get2DAString ("Spells", "Name", Spell.iSpellID)));
                    SendMessages (sSpellName + " has been enhanced!", COLOR_GREEN, Spell.oCaster);
                }
                // Does not have the component, return back "FALSE".
                else Spell.sEnhancingComp = "FALSE";
            }
        }
    }
    // ***************************************************
    // ************** Cast on an item ********************
    // ***************************************************
    // Check to see if the spell works on items.
    if (GetObjectType (Spell.oTarget) == OBJECT_TYPE_ITEM)
    {
        // *********************************************************************
        // ************************ Enchanting Items ***************************
        // *********************************************************************
        // Check to see if we are crafting a disposable item (Scroll, Potion, Wand).
        // Use else if so we don't craft items with items!
        string sTargetTag = GetTag (Spell.oTarget);
        if (sTargetTag == "0_craft_item")
        {
            if (!GetIsObjectValid (oItem))
            {
                CraftDisposableItem (Spell);
                // Stop the spell.
                Spell.iSpellID = STOP_SPELL;
                return Spell;
            }
            else SendMessages ("You cannot use item spells to create disposable items.", COLOR_RED, Spell.oCaster);
        }
        // Check to see if we are enchanting an item in an enchanting box.
        if (sTargetTag == "enchant_box")
        {
            CraftPermanentItem (Spell);
            // Stop the spell.
            Spell.iSpellID = STOP_SPELL;
            return Spell;
        }
        else if (sTargetTag == "bag" || sTargetTag == "0_comp_pouch")
        {
            CraftPermanentItem (Spell, Spell.oTarget);
            // Stop the spell.
            Spell.iSpellID = STOP_SPELL;
            return Spell;
        }
        // To allow a spell to do its effect in the enchant_table.2da set
        // the "Cast_On_Item" column to 1.
        if (!StringToInt (Get2DAString ("enchant_table", "Cast_On_Item", Spell.iSpellID)))
        {
            // Stop the spell.
            Spell.iSpellID = STOP_SPELL;
            return Spell;
        }
    }
    // *********************************************************************
    // ************************ Spell Immunities ***************************
    // *********************************************************************
    // Checks to see if the target is immune to specific effects.
    // We need to add immunity for Celestial bloodline V for Petrification.
    // We need to add immunity for Draconic bloodline V for Sleep.

    // *********************************************************************
    // ************************ MetaMagic Setup ****************************
    // *********************************************************************

    // *********************************************************************
    // ************************ Area Conversion ****************************
    // *********************************************************************
    // Since Dnd uses feet and NWN uses meters lets convert Spell.fAreaSize from feet to meters.
    Spell.fAreaSize = Spell.fAreaSize * 0.3048f;
    return Spell;
}

// Roll the duration for the spell.
// Returns the value in Spell.fDuration.
// Spell is the spell struct.
// bItemEnchantment - the spell being cast enchants items (Extend Enchantments feat).
struct stSpell GetDuration (struct stSpell Spell, int bItemEnchantment = FALSE)
{
    int iRoll, iCount, iNumOfDice, iDuration;
    // Check iDuration to see if we need to create one.
    if (Spell.iDuration > 0)
    {
        // If no Duration per level then just use the straight Duration.
        if (Spell.iDurPerLvl == 0) iDuration = Spell.iDuration;
        // If there is a duration per level then set it up.
        else
        {
            // Get the bonus per level. i.e. 5 / 1 = 5th. or +1 per level.
            iDuration = Spell.iCasterLevel / Spell.iDurPerLvl;
            // Check the maximum duration the spell can have.
            if (Spell.iMaxDuration > 0 && Spell.iMaxDuration < iDuration) iDuration = Spell.iMaxDuration;
            // Take the duration and multiply it by the duration per level.
            iDuration = Spell.iDuration * iDuration;
        }
        // cannot divide it below 1.
        if (iDuration < 1) iDuration = 1;
    }
    else iDuration = 0;
    // Roll the dice if there is some.
    if (Spell.iDurNumOfDice > 0)
    {
        // If no duration dice per level then just set the dice to the dice number.
        if (Spell.iDurDicePerLvl == 0) iNumOfDice = Spell.iDurNumOfDice;
        // if there is a duration dice per level then set it up.
        else
        {
            // Get the bonus per level of dice. i.e. 5/2 = 2. or +1 per 2 levels.
            iNumOfDice = Spell.iCasterLevel / Spell.iDurDicePerLvl;
            // Check the maximum duration dice the spell can have.
            if (Spell.iMaxDurNumOfDice > 0 && Spell.iMaxDurNumOfDice < iNumOfDice) iNumOfDice = Spell.iMaxDurNumOfDice;
            // Take the duration dice number and multiply it by the duration dice per level.
            iNumOfDice = Spell.iDurNumOfDice * iNumOfDice;
        }
        // cannot divide it below 1.
        if (iNumOfDice < 1) iNumOfDice = 1;
        for (iCount = iNumOfDice; iCount > 0; iCount --)
        {
            iRoll += Random (Spell.iDurationDie) + 1;
        }
    }
    else iRoll = 0;
    /*string sDebug;
    if (iNumOfDice > 0)
    {
        sDebug = IntToString (iNumOfDice) + "d" + IntToString (Spell.iDurationDie);
        if (iDuration > 0) sDebug = sDebug + "+" + IntToString (iDuration);
    }
    else sDebug = IntToString (iDuration); */
    // Now add the Dice to the straight duration.
    iDuration = iRoll + iDuration;
    //Debug ("0i_spells", "514", "Duration: " + sDebug + " = " + IntToString (iDuration));
    // Extend the duration.
    if (Spell.iMetaMagic == METAMAGIC_EXTEND) iDuration = iDuration * 2;
    // If casting class Sorcerer, has Extend MetaMagic feat, has Bloodline III feat, then extend duration spells automatically.
    else if (Spell.iClass == CLASS_TYPE_SORCERER && GetHasFeat (FEAT_EXTEND_SPELL, Spell.oCaster) &&
             GetHasFeat (1322, Spell.oCaster))
    {
        iDuration = iDuration * 2;
    }
    else if (bItemEnchantment && GetHasFeat (1266/*Extend Enchantments*/, Spell.oCaster)) iDuration = iDuration * 2;
    // Return the duration in seconds (float).
    iDuration = iDuration + GetLocalInt (Spell.oCaster, "0_SpellDurationMod");
    if (Spell.iDurationType == DURATION_TYPE_ROUNDS)
    {
        // Set the Duration type to temporary for NWN.
        Spell.iDurationType = DURATION_TYPE_TEMPORARY;
        // Now calculate duration in rounds.
        Spell.fDuration = RoundsToSeconds (iDuration);
    }
    else if (Spell.iDurationType == DURATION_TYPE_MINUTES)
    {
        // Set the Duration type to temporary for NWN.
        Spell.iDurationType = DURATION_TYPE_TEMPORARY;
        // Now calculate duration in rounds.
        Spell.fDuration = TurnsToSeconds (iDuration);
    }
    else if (Spell.iDurationType == DURATION_TYPE_TURNS)
    {
        // Set the Duration type to temporary for NWN.
        Spell.iDurationType = DURATION_TYPE_TEMPORARY;
        // Now calculate duration in rounds.
        Spell.fDuration =  TurnsToSeconds (iDuration * 10);
    }
    else if (Spell.iDurationType == DURATION_TYPE_HOURS)
    {
        // Set the Duration type to temporary for NWN.
        Spell.iDurationType = DURATION_TYPE_TEMPORARY;
        // Now calculate duration in rounds.
        Spell.fDuration = HoursToSeconds (iDuration);
    }
    //Debug ("0i_spells", "665", "Duration in seconds: " + FloatToString (Spell.fDuration));
    return Spell;
}

// Roll dice for either damage or modifiers.
// Returns the value in Spell.iResult.
// Spell is the spell struct.
struct stSpell GetModifier (struct stSpell Spell)
{
    int iRoll, iCount, iNumOfDice, iModifier, iBonusMod;
    // If we have a number of dice then get the roll.
    if (Spell.iModNumOfDice > 0)
    {
        // if ModPerLvl = 0 then we only apply the dice once!
        if (Spell.iModDicePerLvl == 0) iNumOfDice = Spell.iModNumOfDice;
        // Check to see how many dice we need to roll.
        else
        {
            iNumOfDice = (Spell.iCasterLevel + Spell.iModDicePerLvl - 1) / Spell.iModDicePerLvl;
            // Check the maximum modifier dice the spell can have.
            if (Spell.iMaxModNumOfDice > 0 && Spell.iMaxModNumOfDice < iNumOfDice) iNumOfDice = Spell.iMaxModNumOfDice;
        }
        // Minimum dice is 1.
        if (iNumOfDice < 1) iNumOfDice = 1;
        // Since we have dice lets check for Elemental Bloodline II damage increase.
        // Elemental spells gain +1 per die.
        if (GetHasFeat (1336, Spell.oCaster) && Spell.iDamageType == DAMAGE_TYPE_ELECTRICAL) iBonusMod = iNumOfDice;
        else if (GetHasFeat (1390, Spell.oCaster) && Spell.iDamageType == DAMAGE_TYPE_FIRE) iBonusMod = iNumOfDice;
        else if (GetHasFeat (1395, Spell.oCaster) && Spell.iDamageType == DAMAGE_TYPE_COLD) iBonusMod = iNumOfDice;
        else if (GetHasFeat (1400, Spell.oCaster) && Spell.iDamageType == DAMAGE_TYPE_ACID) iBonusMod = iNumOfDice;
        // If Maximized then just calculate the maximum roll.
        if (Spell.iMetaMagic == METAMAGIC_MAXIMIZE) iRoll = Spell.iModifierDie * iNumOfDice;
        // Roll the dice for the modifier.
        else
        {
            for (iCount = iNumOfDice; iCount > 0; iCount --)
            {
                iRoll += Random (Spell.iModifierDie) + 1;
            }
        }
    }
    else iRoll = 0;
    // Now check to see if we need to add a modifier.
    if (Spell.iModifier > 0)
    {
        // If iModPerLevel is 0 then apply the modifier once.
        if (Spell.iModPerLvl == 0) iModifier = Spell.iModifier;
        else
        {
            iModifier = (Spell.iCasterLevel) / Spell.iModPerLvl;
            // Check the maximum modifier the spell can have.
            if (Spell.iMaxModifier > 0 && Spell.iMaxModifier < iModifier) iModifier = Spell.iMaxModifier;
            // Take the modifier and multiply it by the modifier per level.
            iModifier = Spell.iModifier * iModifier;
        }
        // cannot divide it below 1.
        if (iModifier < 1) iModifier = 1;
    }
    else iModifier = 0;
    // Now add the modifier and roll together.
    Spell.iResult = iRoll + iModifier + iBonusMod;
    string sDebug = "Spell: " + IntToString (Spell.iSpellID) + " " +
                    "Caster Level: " + IntToString (Spell.iCasterLevel) + " ";
    if (iNumOfDice > 0)
    {
        sDebug += IntToString (iNumOfDice) + "d" + IntToString (Spell.iModifierDie);
        if (iModifier > 0) sDebug = sDebug + " + " + IntToString (iModifier) + " (+ " + IntToString (iBonusMod) + ")";
    }
    else sDebug += IntToString (iModifier);
    //Debug ("0i_spells", "905", sDebug + " = " + IntToString (Spell.iResult));
    // Empower the result only if the result uses dice.
    // Check for Empower feat on spell.
    if (Spell.iMetaMagic == METAMAGIC_EMPOWER && Spell.iModNumOfDice > 0)
    {
        Spell.iResult = Spell.iResult + (Spell.iResult / 2);
    }
    // If casting class Sorcerer, has Empower MetaMagic feat, has Bloodline V feat, then empower spells automatically.
    else if (Spell.iClass == CLASS_TYPE_SORCERER && GetHasFeat (FEAT_EMPOWER_SPELL, Spell.oCaster) &&
             GetHasFeat (1324, Spell.oCaster) && Spell.iModNumOfDice > 0) Spell.iResult = Spell.iResult + (Spell.iResult / 2);
    if (GetHasFeat (1522/*FEAT_WARMAGE_EDGE*/, Spell.oCaster) && Spell.iClass == CLASS_TYPE_WARMAGE)
    {
        Spell.iResult += GetAbilityModifier (ABILITY_INTELLIGENCE, Spell.oCaster);
    }
    if (GetHasFeat (1523/*FEAT_EXTRA_EDGE*/, Spell.oCaster) && Spell.iClass == CLASS_TYPE_WARMAGE)
    {
        Spell.iResult += 1 + (Spell.iCasterLevel / 4);
    }
    // Add additional spell damage from effects using variable: 0_SpellDmgMod.
    Spell.iResult += GetLocalInt (Spell.oCaster, "0_SpellDmgMod");
    //Debug ("0i_spells", "929", "Spell adjusted result: " + IntToString (Spell.iResult));
    return Spell;
}

// Get the level of the spell being cast based on casting class.
// Spell is the spell structure.
int GetSpellLevel (struct stSpell Spell)
{
    string sColumn;
    // Get the casting class.
    sColumn = Get2DAString ("classes", "SpellTableColumn", Spell.iClass);
    // If wizard or Sorcerer we need to change the column label to Wiz_Sorc.
    if (sColumn == "") sColumn = "Innate";
    // Use spell.2da to get level based on class casting.
    int iSpellLevel = StringToInt (Get2DAString ("Spells", sColumn, Spell.iSpellID));
    // Check spells level if it is 0 then get the innate level instead incase its a feat only spell.
    if (iSpellLevel == 0) StringToInt (Get2DAString ("Spells", "Innate", Spell.iSpellID));
    //Debug ("0i_spells", "954", "Spell Level: " + IntToString (iSpellLevel) + " (Class: " + sColumn + ")");
    return iSpellLevel;
}

// Get the spells school from Spells.2da
// Returns SPELL_SCHOOL_*
// iSpellID the ID of the spell you want to know the school for.
int GetSpellSchool (int iSpellID)
{
    string sSchool = Get2DAString ("Spells", "School", iSpellID);
    if (sSchool == "A") return SPELL_SCHOOL_ABJURATION;
    else if (sSchool == "C") return SPELL_SCHOOL_CONJURATION;
    else if (sSchool == "D") return SPELL_SCHOOL_DIVINATION;
    else if (sSchool == "E") return SPELL_SCHOOL_ENCHANTMENT;
    else if (sSchool == "V") return SPELL_SCHOOL_EVOCATION;
    else if (sSchool == "I") return SPELL_SCHOOL_ILLUSION;
    else if (sSchool == "N") return SPELL_SCHOOL_NECROMANCY;
    else if (sSchool == "T") return SPELL_SCHOOL_TRANSMUTATION;
    return 0;
}

// Get the Difficulty challenge for the spell to use in saves.
// stSpell is the spell struct.
struct stSpell GetSaveDC (struct stSpell Spell)
{
    int iModifier, iSchool;
    string sAbility;
    // Check to see if there is already a DC.
    if (Spell.iSaveDC != 0) iModifier = Spell.iSaveDC;
    // If not then create it based on 10 + Caster ability modifier + Spells level.
    else
    {
        // Check for Placeable (trap). Use caster level / 2 for +0 to +10.
        if (GetObjectType (Spell.oCaster) == OBJECT_TYPE_PLACEABLE)
        {
            iModifier = iModifier + GetLocalInt (Spell.oCaster, "0_CasterLevel") / 2;
        }
        else
        {
            // Get the primary ability for the class from the classes.2da
            sAbility = Get2DAString ("classes", "PrimaryAbil", Spell.iClass);
            // Get the casters ability modifier.
            if (sAbility == "INT") iModifier = GetAbilityModifier (ABILITY_INTELLIGENCE, Spell.oCaster);
            else if (sAbility == "WIS") iModifier = GetAbilityModifier (ABILITY_WISDOM, Spell.oCaster);
            else if (sAbility == "CHA") iModifier = GetAbilityModifier (ABILITY_CHARISMA, Spell.oCaster);
        }
        iModifier = iModifier + 10 + GetSpellLevel (Spell);
    }
    // Check caster for bonus spell DC effects.
    iModifier = iModifier + GetLocalInt (Spell.oCaster, "0_SpellDCMod");
    // Check feats for bonus to spell DC.
    // Spell focus feats.
    iSchool = GetSpellSchool (Spell.iSpellID);
    if (GetHasFeat (FEAT_SPELL_FOCUS_ABJURATION) && iSchool == SPELL_SCHOOL_ABJURATION) iModifier = iModifier +2;
    else if (GetHasFeat (FEAT_SPELL_FOCUS_CONJURATION) && iSchool == SPELL_SCHOOL_CONJURATION) iModifier = iModifier +2;
    else if (GetHasFeat (FEAT_SPELL_FOCUS_DIVINATION) && iSchool == SPELL_SCHOOL_DIVINATION) iModifier = iModifier +2;
    else if (GetHasFeat (FEAT_SPELL_FOCUS_ENCHANTMENT) && iSchool == SPELL_SCHOOL_ENCHANTMENT) iModifier = iModifier +2;
    else if (GetHasFeat (FEAT_SPELL_FOCUS_EVOCATION) && iSchool == SPELL_SCHOOL_EVOCATION) iModifier = iModifier +2;
    else if (GetHasFeat (FEAT_SPELL_FOCUS_ILLUSION) && iSchool == SPELL_SCHOOL_ILLUSION) iModifier = iModifier +2;
    else if (GetHasFeat (FEAT_SPELL_FOCUS_NECROMANCY) && iSchool == SPELL_SCHOOL_NECROMANCY) iModifier = iModifier +2;
    else if (GetHasFeat (FEAT_SPELL_FOCUS_TRANSMUTATION) && iSchool == SPELL_SCHOOL_TRANSMUTATION) iModifier = iModifier +2;
    // Greater spell focus feats.
    if (GetHasFeat (FEAT_GREATER_SPELL_FOCUS_ABJURATION) && iSchool == SPELL_SCHOOL_ABJURATION) iModifier = iModifier +4;
    else if (GetHasFeat (FEAT_GREATER_SPELL_FOCUS_CONJURATION) && iSchool == SPELL_SCHOOL_CONJURATION) iModifier = iModifier +4;
    else if (GetHasFeat (FEAT_GREATER_SPELL_FOCUS_DIVINATION) && iSchool == SPELL_SCHOOL_DIVINATION) iModifier = iModifier +4;
    else if (GetHasFeat (FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT) && iSchool == SPELL_SCHOOL_ENCHANTMENT) iModifier = iModifier +4;
    else if (GetHasFeat (FEAT_GREATER_SPELL_FOCUS_EVOCATION) && iSchool == SPELL_SCHOOL_EVOCATION) iModifier = iModifier +4;
    else if (GetHasFeat (FEAT_GREATER_SPELL_FOCUS_ILLUSION) && iSchool == SPELL_SCHOOL_ILLUSION) iModifier = iModifier +4;
    else if (GetHasFeat (FEAT_GREATER_SPELL_FOCUS_NECROMANCY) && iSchool == SPELL_SCHOOL_NECROMANCY) iModifier = iModifier +4;
    else if (GetHasFeat (FEAT_GREATER_SPELL_FOCUS_TRANSMUTATION) && iSchool == SPELL_SCHOOL_TRANSMUTATION) iModifier = iModifier +4;
    // Epic spell focus feats.
    if (GetHasFeat (FEAT_EPIC_SPELL_FOCUS_ABJURATION) && iSchool == SPELL_SCHOOL_ABJURATION) iModifier = iModifier +6;
    else if (GetHasFeat (FEAT_EPIC_SPELL_FOCUS_CONJURATION) && iSchool == SPELL_SCHOOL_CONJURATION) iModifier = iModifier +6;
    else if (GetHasFeat (FEAT_EPIC_SPELL_FOCUS_DIVINATION) && iSchool == SPELL_SCHOOL_DIVINATION) iModifier = iModifier +6;
    else if (GetHasFeat (FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT) && iSchool == SPELL_SCHOOL_ENCHANTMENT) iModifier = iModifier +6;
    else if (GetHasFeat (FEAT_EPIC_SPELL_FOCUS_EVOCATION) && iSchool == SPELL_SCHOOL_EVOCATION) iModifier = iModifier +6;
    else if (GetHasFeat (FEAT_EPIC_SPELL_FOCUS_ILLUSION) && iSchool == SPELL_SCHOOL_ILLUSION) iModifier = iModifier +6;
    else if (GetHasFeat (FEAT_EPIC_SPELL_FOCUS_NECROMANCY) && iSchool == SPELL_SCHOOL_NECROMANCY) iModifier = iModifier +6;
    else if (GetHasFeat (FEAT_EPIC_SPELL_FOCUS_TRANSMUTATION) && iSchool == SPELL_SCHOOL_TRANSMUTATION) iModifier = iModifier +6;
    // Return the DC for the spell.
    Spell.iSaveDC = iModifier;
    //Debug ("0i_spells", "832", "Save DC: " + IntToString (Spell.iSaveDC));
    return Spell;
}

// Makes a specific save and gives an effect based on the save check.
int SavingThrowWithEffects (int nSavingThrow, object oTarget, int nDC, int nSaveType = SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0)
{
    if (nDC < 1) nDC = 1;
    else if (nDC > 255) nDC = 255;
    effect eVis;
    int bValid = FALSE;
    int nSpellID;
    if (nSavingThrow == SAVING_THROW_FORT)
    {
        bValid = FortitudeSave (oTarget, nDC, nSaveType, oSaveVersus);
        if (bValid) eVis = EffectVisualEffect (VFX_IMP_FORTITUDE_SAVING_THROW_USE);
    }
    else if (nSavingThrow == SAVING_THROW_REFLEX)
    {
        bValid = ReflexSave (oTarget, nDC, nSaveType, oSaveVersus);
        if (bValid) eVis = EffectVisualEffect (VFX_IMP_REFLEX_SAVE_THROW_USE);
    }
    else if (nSavingThrow == SAVING_THROW_WILL)
    {
        bValid = WillSave(oTarget, nDC, nSaveType, oSaveVersus);
        if (bValid) eVis = EffectVisualEffect (VFX_IMP_WILL_SAVING_THROW_USE);
    }
    nSpellID = GetSpellId();
    // 0 = FAILED SAVE
    if (bValid == 0)
    {
        if ((nSaveType == SAVING_THROW_TYPE_DEATH ||
             nSpellID == SPELL_WEIRD ||
             nSpellID == SPELL_FINGER_OF_DEATH) &&
             nSpellID != SPELL_HORRID_WILTING)
        {
            eVis = EffectVisualEffect (VFX_IMP_DEATH);
            DelayCommand (fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
    }
    // 1 = SAVE SUCCESSFUL, 2 = IMMUNE TO WHAT WAS BEING SAVED AGAINST
    if (bValid == 2)
    {
        eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
        DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, oTarget));
            /*
            If the spell is save immune then the link must be applied in order to get the true immunity
            to be resisted.  That is the reason for returing false and not true.  True blocks the
            application of effects.
            */
            bValid = FALSE;
    }
    return bValid;
}

int ResistSpellWithEffects (object oCaster, object oTarget, float fDelay = 0.0)
{
    if (fDelay > 0.5)
    {
        fDelay = fDelay - 0.1;
    }
    int nResist = ResistSpell (oCaster, oTarget);
    effect eSR = EffectVisualEffect (VFX_IMP_MAGIC_RESISTANCE_USE);
    effect eGlobe = EffectVisualEffect (VFX_IMP_GLOBE_USE);
    effect eMantle = EffectVisualEffect (VFX_IMP_SPELL_MANTLE_USE);
    if(nResist == 1) //Spell Resistance
    {
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eSR, oTarget));
    }
    else if(nResist == 2) //Globe
    {
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eGlobe, oTarget));
    }
    else if(nResist == 3) //Spell Mantle
    {
        if (fDelay > 0.5)
        {
            fDelay = fDelay - 0.1;
        }
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMantle, oTarget));
    }
    return nResist;
}

// Check for a Savingthrow and Spell Resistance by using Spell struct variable.
// Does full save check for 1/2 damage and negation.
// Returns the following values in Spell.iSaveResult.
// Returns FALSE (0) if a target fails its resistance check and save attempt.
// Returns on Resist: 1 - Resisted, 2 - Magic Immunity, 3 - Spell absorption.
// Returns on Save: 4 - Save Negates/Half, 2 - Target is immune to the save type.
// stSpell is the spell struct.
struct stSpell ResistAndSave (struct stSpell Spell)
{
    //Debug ("0i_spells", "919", "(" + GetName (Spell.oAreaTarget) + ") Start Result: " + IntToString (Spell.iResult));
    // Is the spell stopped by SpellResistance?
    if (Spell.iSpellResistance)
    {
        // Make a Resistance check 0 Failed, 1 Resisted, 2 Immune, 3 Spell absorption.
        Spell.iSaveResult = ResistSpellWithEffects (Spell.oCaster, Spell.oAreaTarget, Spell.fDelay);
        // Check Sorcerer Arcane bloodline II to see if we need to reroll this Resistance check.
        if (Spell.iClass == CLASS_TYPE_SORCERER && GetHasFeat (1321, Spell.oCaster) && Spell.iSaveResult > 0)
        {
            Spell.iSaveResult = ResistSpellWithEffects (Spell.oCaster, Spell.oAreaTarget, Spell.fDelay);
        }
        // If the spell does not affect them then return the result.
        if (Spell.iSaveResult > 0)
        {
            // Reduce all modifiers to 0.
            Spell.iResult = 0;
            return Spell;
        }
    }
    // Does the creature get a save?
    if (Spell.iSave > 0)
    {
        // Get the save DC.
        if (Spell.iSaveDC == 0) Spell = GetSaveDC (Spell);
        // *****************************************************************************
        // ********************** Saving Throw Adjustments Start ***********************
        // *****************************************************************************
        // To give additional save bonus we will hack by adjusting the DC!
        // Shadow Mastery (1510): +2 save vs Illusion (shadow) spells.
        if (Spell.iSubSchool == 13 && GetHasFeat (1510, Spell.oAreaTarget)) Spell.iSaveDC = Spell.iSaveDC - 2;
        // *****************************************************************************
        // ********************** Saving Throw Adjustments End   ***********************
        // *****************************************************************************
        // Make a save 0 Failed, 1 Succeeded, 2 Immune.
        Spell.iSaveResult = SavingThrowWithEffects (Spell.iSave, Spell.oAreaTarget, Spell.iSaveDC, Spell.iSaveType, Spell.oCaster, Spell.fDelay);
        // Adjust a successfull save to a value of 4.
        if (Spell.iSaveResult == 1) Spell.iSaveResult = 4;
        // Target is immune to the spell give message and show effects.
        if (Spell.iSaveResult == 2)
        {
            // Let everyone know the target was immune.
            DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature (84525, Spell.oAreaTarget, FALSE));
            // Show immunity in game.
            effect eSR = EffectVisualEffect (VFX_IMP_MAGIC_RESISTANCE_USE);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eSR, Spell.oAreaTarget));
            // Set any damage or modifier to 0.
            Spell.iResult = 0;
            return Spell;
        }
        // Check to see if we save to take half damage
        else if (Spell.iSaveHalf)
        {
            // Save successful.
            if (Spell.iSaveResult == 4)
            {
                if (Spell.iSave == SAVING_THROW_REFLEX)
                {
                    // If has Evasion or Improved Evasion remove the result.
                    if (GetHasFeat (FEAT_EVASION, Spell.oAreaTarget) || GetHasFeat (FEAT_IMPROVED_EVASION, Spell.oAreaTarget))
                    {
                        Spell.iResult = 0;
                    }
                    // No evasions then just half the result.
                    else Spell.iResult = Spell.iResult / 2;
                }
            }
            // If has Improved Evasion even on a failed reflex save half the result.
            else if (GetHasFeat(FEAT_IMPROVED_EVASION, Spell.oAreaTarget) &&
                     Spell.iSave == SAVING_THROW_REFLEX) Spell.iResult = Spell.iResult / 2;
        }
        // Save negates so remove a result.
        else if (Spell.iSaveResult == 4)  Spell.iResult = 0;
    }
    //Debug ("0i_spells", "992", "(" + GetName (Spell.oAreaTarget) + ") End Result: " + IntToString (Spell.iResult) + " Save Result: " + IntToString (Spell.iSaveResult));
    return Spell;
}

// Checks all classes to get total caster level
// for the last spell cast and special abilities.
// Spell.iClass must be setup with the casting class to get the level.
// stSpell is the spell struct
// Returns the Spell variable.
struct stSpell GetCasterTotalLevel(struct stSpell Spell)
{
    // Check for DM, and give them 40 levels.
    if(GetIsDungeonMaster(Spell.oCaster))
    {
        Spell.iCasterLevel = 40;
        // Lets put all targets to all for the DM since they have no friends or enemies!
        Spell.iTargetType = TARGET_TYPE_ALL;
        return Spell;
    }
    // If the caster is a Placeable then get the level from it.
    if(GetObjectType(Spell.oCaster) == OBJECT_TYPE_PLACEABLE)
    {
       // Placeable (traps) caster level is set and saved in 0e_trigtrapspell script.
       Spell.iCasterLevel = GetLocalInt(Spell.oCaster, "0_CasterLevel");
       return Spell;
    }
    // Get the levels of the class casting the spell.
    Spell.iCasterLevel = GetCasterLevelByClass(Spell.oCaster, Spell.iClass);
    Debug("0i_spells", "1255", "Name: " + GetName (Spell.oCaster) + " CasterLevel: " +
          IntToString (Spell.iCasterLevel) + " Caster Class: " + IntToString (Spell.iClass));
    // ********** SUBSCHOOL BONUS LEVEL CHECKS **********
    // Check for feat, Shadow mastery: Cast Illusion (Shadow) spells at +1 caster level.
    if(Spell.iSubSchool == SUBSCHOOL_SHADOW &&
       GetHasFeat (1510/*FEAT_SHADOW_MASTERY*/, Spell.oCaster)) Spell.iCasterLevel ++;
    if(Spell.iSubSchool == SUBSCHOOL_CREATION)
    {
        // Check if they are a player.
        if(GetIsCharacter (Spell.oCaster))
        {
            // Check to see if they have a set deity in the database.
            int nDeity = GetObjectDatabaseInt(Spell.oCaster, CHARACTER_TABLE, "deity");
            int bHasDomain = StringToInt(Get2DAString ("deities", "Craft_Domain", nDeity));
            if(bHasDomain && GetHasFeat(1554/*FEAT_CRAFT_DOMAIN*/, Spell.oCaster)) Spell.iCasterLevel ++;
        }
        // All NPC's have it if they have the domain.
        else if(GetHasFeat(1554/*FEAT_CRAFT_DOMAIN*/, Spell.oCaster)) Spell.iCasterLevel ++;
    }
    // ********** DESCRIPTOR BONUS LEVEL CHECKS **********
    if(Spell.iDescriptor == DESC_CHAOTIC)
    {
        if(GetDomain(Spell.oCaster, 1) == 2/*CHAOS_DOMAIN*/ ||
           GetDomain(Spell.oCaster, 2) == 2/*CHAOS_DOMAIN*/) Spell.iCasterLevel ++;
    }
    // ********** FEAT BONUS LEVEL CHECKS **********
    if(Spell.iClass == CLASS_TYPE_SORCERER)
    {
        // If has Arcane bloodline I feat & using metamagic feats then gain +1 caster level.
        if(GetHasFeat(1320, Spell.oCaster) && Spell.iMetaMagic > 0) Spell.iCasterLevel ++;
    }
    // ********** OTHER BONUS LEVEL CHECKS **********
    // Check for Caster Level effects on variable 0_SpellCasterLvlMod.
    Spell.iCasterLevel += GetLocalInt(Spell.oCaster, "0_SpellCasterLvlMod");
    //Debug ("0i_spells", "1214", "Caster Level: " + IntToString (Spell.iCasterLevel));
    return Spell;
}

int GetCasterLevelByClass(object oCreature, int nClass)
{
    int nCasterLevel;
    // Check for DM, and give them 40 levels.
    if(GetIsDungeonMaster(oCreature)) return 40;
    // Check for monster caster level set at monster level.
    else if(nClass == 255) return GetCasterLevel(oCreature);
    else
    {
        nCasterLevel = GetLevelByClass(nClass, oCreature);
        switch(nClass)
        {
            // Arcane classes.
            case CLASS_TYPE_BARD :
            case CLASS_TYPE_SORCERER :
            case CLASS_TYPE_WARMAGE :
            case CLASS_TYPE_WIZARD :
            {
                nCasterLevel += GetLevelByClass(CLASS_TYPE_ARTIFICER, oCreature);
                nCasterLevel += (GetLevelByClass(CLASS_TYPE_PALE_MASTER, oCreature) + 1) / 2;
                nCasterLevel += GetLevelByClass(CLASS_TYPE_MYSTIC_THEURGE, oCreature);
                break;
            }
            case CLASS_TYPE_CLERIC :
            case CLASS_TYPE_DRUID :
            case CLASS_TYPE_FAVORED_SOUL :
            {
                nCasterLevel += GetLevelByClass(CLASS_TYPE_MYSTIC_THEURGE, oCreature);
                break;
            }
            case CLASS_TYPE_PALE_MASTER :
            {
                nCasterLevel = (nCasterLevel + 1) / 2;
                nClass = GetHighestArcaneCasterClass(oCreature, CLASS_TYPE_PALE_MASTER);
                nCasterLevel += GetLevelByClass(nClass, oCreature);
            }
        }
    }
    return nCasterLevel;
}
int GetHighestArcaneCasterClass(object oCaster, int nClassToIgnore = 0)
{
    int nCounter, nClass, nCasterLevel, nHighestLevel, nHighestLevelClass;
    // Find the characters highest level base spellcasting class so we can add
    // it to the Palemasters casting levels.
    for (nCounter = 1; nCounter <= 8 ; nCounter++)
    {
        nClass = GetClassByPosition(nCounter, oCaster);
        if(nClass != nClassToIgnore && nClass != CLASS_TYPE_INVALID)
        {
            // Is an arcane spellcasting class and is not a prestige class.
            if(Get2DAString("classes", "Arcane", nClass) == "1" &&
               Get2DAString("classes", "PreReqTable", nClass) == "")
            {
                nCasterLevel = GetLevelByPosition(nCounter, oCaster);
                if(nCasterLevel > nHighestLevel)
                {
                    nHighestLevelClass = nClass;
                    nHighestLevel = nCasterLevel;
                }
            }
        }
    }
    return nHighestLevelClass;
}

// Checks to see if the target of the spell is valid.
// Some abilities remove targets as valid.
// oTarget is the target of the spell.
// iTargetType what type of targets are we trying to hit.
// oCaster is the caster of the spell.
int GetIsSpellTargetValid (object oTarget, int iTargetType, object oCaster)
{
    // Check to see if the target is dead.
    if (GetCurrentHitPoints (oTarget) < 1) return FALSE;
    // If we are hitting all target types then return TRUE.
    if (iTargetType == TARGET_TYPE_ALL) return TRUE;
    // If only allies check for ally.
    else if (iTargetType == TARGET_TYPE_ALLIES)
    {
        if (GetIsReactionTypeFriendly (oTarget ,oCaster) || GetFactionEqual (oTarget ,oCaster))  return TRUE;
    }
    // If only enemies check for enemy.
    else if (iTargetType == TARGET_TYPE_ENEMIES)
    {
        // We should never target the caster if the target types is enemies.
        if (oTarget == oCaster) return FALSE;
        if (GetIsEnemy (oTarget ,oCaster)) return TRUE;
    }
    // Used for effects centered on the caster that don't effect the caster.
    else if (iTargetType == TARGET_TYPE_ALL_BUT_CASTER)
    {
        if (oTarget == oCaster) return FALSE;
        return TRUE;
    }
    return FALSE;
}

// Gets the closest target in a spells area shape.
// To start with the closest target set Spell.iCounter to 1.
// After that do not set Spell.iCounter as it counts to the next target on each call.
// Spell is the spell being cast.
struct stSpell GetClosestTarget (struct stSpell Spell)
{
    int iFound = FALSE;
    object oClosest, oTarget;
    // Get the closest target to the caster. Then see if they are within the shape.
    oClosest = GetNearestObject (Spell.iObjectFilter, Spell.oCaster, Spell.iCounter);
    while (GetIsObjectValid (oClosest) && GetDistanceBetween (Spell.oCaster, oClosest) <= Spell.fAreaSize && !iFound)
    {
        // Check to see if the closest target is in the shape.
        oTarget = GetFirstObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter, GetPosition (Spell.oCaster));
        while (GetIsObjectValid(oTarget) && !iFound)
        {
            //Exclude the caster as a target && Closest = Target in shape.
            if (oTarget != Spell.oCaster && oClosest == oTarget)
            {
                // Save the target as the selected target.
                Spell.oAreaTarget = oTarget;
                // We have found the target so drop out.
                iFound = TRUE;
            }
            oTarget = GetNextObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter, GetPosition(Spell.oCaster));
        }
        Spell.iCounter ++;
        oClosest = GetNearestObject (Spell.iObjectFilter, Spell.oCaster, Spell.iCounter);
    }
    // If we have not found a new Target then set the target to OBJECT_INVALID.
    if (!iFound) Spell.oAreaTarget = OBJECT_INVALID;
    return Spell;
}

// Gets a target for a beam spell.
// Checks for area spells, personal spells, and single target spells.
// Cones and Cylinders will give the closest targets in order.
// Checks for and only returns valid targets based on Spell.iTargetType.
// Returns the object to Spell.oAreaTarget.
// Spell is the spell's variables.
struct stSpell GetSpellBeamTarget (struct stSpell Spell)
{
    // Check for area targets: 0)SHAPE_SPELLCYLINDER 1)SHAPE_CONE 2)SHAPE_CUBE 3)SHAPE_SPELLCONE 4)SHAPE_SPHERE.
    if (Spell.iAreaShape < 5)
    {
        // If we have not gotten a target yet then set to the beams first target.
        if (!GetIsObjectValid (Spell.oAreaTarget))
        {
            // Remove any looking for object variables.
            DeleteLocalInt (Spell.oCaster, "0_Looking_For_Objects");
            // Set the caster as the oBeamEffector, the start location of the beam.
            Spell.oBeamEffector = Spell.oCaster;
            // if the shape is a cylider or cone then we need to get the closest target.
            if (Spell.iAreaShape == SHAPE_SPELLCYLINDER || Spell.iAreaShape == SHAPE_CONE ||
                Spell.iAreaShape == SHAPE_SPELLCONE)
            {
                // Set the counter so we can get the closest target to start with.
                Spell.iCounter = 1;
                // Now get the closest target.
                Spell = GetClosestTarget (Spell);
                // Remove Spell.oTarget since we don't use it in cylinders and cones.
                Spell.oTarget = OBJECT_INVALID;
            }
            // if we have a selected target then start with them.
            else if (GetIsObjectValid (Spell.oTarget))
            {
                Spell.oAreaTarget = Spell.oTarget;
                // Exit as this is the only time oAreaTarget can equal oTarget.
                return Spell;
            }
            // if there is not a first target then get the first one in the area of the spell.
            else
            {
                Spell.oAreaTarget = GetFirstObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter);
                // Set the cast as looking for objects now.
                SetLocalInt (Spell.oCaster, "0_Looking_For_Objects", TRUE);
            }
        }
        else
        {
            // We already have an oAreaTarget then set them as the new beam starting point.
            Spell.oBeamEffector = Spell.oAreaTarget;
            // if the shape is a cylider or cone then we need to get the closest target.
            if (Spell.iAreaShape == SHAPE_SPELLCYLINDER || Spell.iAreaShape == SHAPE_CONE ||
                Spell.iAreaShape == SHAPE_SPELLCONE)
            {
                // Now get the closest target.
                Spell = GetClosestTarget (Spell);
            }
            // Is the caster looking for objects now.
            else if (GetLocalInt (Spell.oCaster, "0_Looking_For_Objects"))
            {
                // get the next target in the shape.
                Spell.oAreaTarget = GetNextObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter);
            }
            else
            {
                Spell.oAreaTarget = GetFirstObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter);
                // Set the cast as looking for objects now.
                SetLocalInt (Spell.oCaster, "0_Looking_For_Objects", TRUE);
            }
        }
        // If object is valid, not a valid target for this spell, and has been hit by this spell then get the next target.
        while (GetIsObjectValid (Spell.oAreaTarget) && (!GetIsSpellTargetValid (Spell.oAreaTarget, Spell.iTargetType, Spell.oCaster) ||
               Spell.oAreaTarget == Spell.oTarget))
        {
            // if the shape is a cylider or cone then we need to get the closest target.
            if (Spell.iAreaShape == SHAPE_SPELLCYLINDER || Spell.iAreaShape == SHAPE_CONE ||
                Spell.iAreaShape == SHAPE_SPELLCONE)
            {
                // Now get the closest target.
                Spell = GetClosestTarget (Spell);
            }
            else Spell.oAreaTarget = GetNextObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter);
            //Debug ("spells", "889", "target: " + GetName (Spell.oAreaTarget));
        }
    }
    // If not an area target then its a single target or personal target.
    else
    {
        // There is already a target so we have passed throught once.
        // Now return OBJECT INVALID since we should only have one target.
        if (GetIsObjectValid (Spell.oAreaTarget)) Spell.oAreaTarget = OBJECT_INVALID;
        // Set oAreaTarget to oTarget for all TARGET SHAPES.
        else if (Spell.iAreaShape == SHAPE_RANGE_TARGET || Spell.iAreaShape == SHAPE_TOUCH_TARGET) Spell.oAreaTarget = Spell.oTarget;
        // Use the caster for SHAPE_PERSONAL targets.
        else Spell.oAreaTarget = Spell.oCaster;
    }
    // Delay each beam by 0.2f seconds.
    Spell.fDelay = Spell.fDelay + 0.2f;
    return Spell;
}

// Gets a target for a spell.
// Checks for area spells, personal spells, and single target spells.
// Checks for and only returns valid targets based on Spell.iTargetType.
// Returns the object to Spell.oAreaTarget.
// Spell is the spell's variables.
struct stSpell GetSpellTarget (struct stSpell Spell)
{
    // Check for area targets: 0)SHAPE_SPELLCYLINDER 1)SHAPE_CONE 2)SHAPE_CUBE 3)SHAPE_SPELLCONE 4)SHAPE_SPHERE.
    if (Spell.iAreaShape < 5)
    {
        // If there is no Spell.oAreaTarget then we need to get the first object in the shape.
        if (Spell.oAreaTarget == OBJECT_INVALID)
        {
            Spell.oAreaTarget = GetFirstObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter);
        }
        // Get the next target.
        else Spell.oAreaTarget = GetNextObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter);
        // If object is valid and it is not a valid target for this spell get the next target.
        while ((Spell.oAreaTarget != OBJECT_INVALID) && !GetIsSpellTargetValid (Spell.oAreaTarget, Spell.iTargetType, Spell.oCaster))
        {
            Spell.oAreaTarget = GetNextObjectInShape (Spell.iAreaShape, Spell.fAreaSize, Spell.lTarget, Spell.iLineOfSight, Spell.iObjectFilter);
        }
    }
    // If not an area target then its a single target or personal target.
    else
    {
        // There is already a target so we have passed throught once.
        // Now return OBJECT INVALID since we should only have one target.
        if (Spell.oAreaTarget != OBJECT_INVALID) Spell.oAreaTarget = OBJECT_INVALID;
        // Set oAreaTarget to oTarget for all TARGET SHAPES.
        else if (Spell.iAreaShape == SHAPE_RANGE_TARGET || Spell.iAreaShape == SHAPE_TOUCH_TARGET) Spell.oAreaTarget = Spell.oTarget;
        // Use the caster for SHAPE_PERSONAL targets.
        else Spell.oAreaTarget = Spell.oCaster;
    }
    // Get the delay for this target based on distance from center.
    Spell.fDelay = GetDistanceBetweenLocations (Spell.lTarget, GetLocation (Spell.oAreaTarget)) / 20;
    //Debug ("0i_spells", "1137", "GetSpellTarget pass:" + IntToString (Spell.iMetaMagic)  + " oCaster:" + GetName (Spell.oCaster) + " Targeting:" + GetName (Spell.oAreaTarget) +
    //       "area: " + IntToString (Spell.iAreaShape));
    //Spell.iMetaMagic = Spell.iMetaMagic + 1;
    return Spell;
}

// Runs at the end of every spell.
void CleanUpSpell (struct stSpell Spell)
{
}

// Checks for the Sudden Feats and adjusts.
struct stSpell CheckForSuddenFeats (struct stSpell Spell)
{
    // Check for Sudden Feats.
    if (GetLocalInt (Spell.oCaster, "0_SUDDEN_MAXIMIZE"))
    {
        DeleteLocalInt (Spell.oCaster, "0_SUDDEN_MAXIMIZE");
        Spell.iMetaMagic = METAMAGIC_MAXIMIZE;
    }
    else if (GetLocalInt (Spell.oCaster, "0_SUDDEN_WIDEN"))
    {
        DeleteLocalInt (Spell.oCaster, "0_SUDDEN_WIDEN");
        Spell.fAreaSize = Spell.fAreaSize * 2;
    }
    else if (GetLocalInt (Spell.oCaster, "0_SUDDEN_EMPOWER"))
    {
        DeleteLocalInt (Spell.oCaster, "0_SUDDEN_EMPOWER");
        Spell.iMetaMagic = METAMAGIC_EMPOWER;
    }
    else if (GetLocalInt (Spell.oCaster, "0_SUDDEN_EXTEND"))
    {
        DeleteLocalInt (Spell.oCaster, "0_SUDDEN_EXTEND");
        Spell.iMetaMagic = METAMAGIC_EXTEND;
    }
    return Spell;
}

//------------------------------------------------------------------------------
// GZ: 2003-Oct-15
// A different approach for timing these spells that has the positive side
// effects of making the spell dispellable as well.
// I am using the VFX applied by the spell to track the remaining duration
// instead of adding the remaining runtime on the stack
//
// This function returns FALSE if a delayed Spell effect from nSpell_ID has
// expired. See x2_s0_bigby4.nss for details
//------------------------------------------------------------------------------
int GetSpellEffectsExpired (int nSpell_ID, object oTarget, object oCaster)
{
    if (!GetHasSpellEffect (nSpell_ID,oTarget))
    {
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        return TRUE;
    }
    // If the caster is dead or no longer there, cancel the spell, as it is directed
    if( !GetIsObjectValid (oCaster))
    {
        RemoveEffectsFromSpell (oTarget, nSpell_ID);
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        return TRUE;
    }
    if (GetIsDead(oCaster))
    {
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        RemoveEffectsFromSpell (oTarget, nSpell_ID);
        return TRUE;
    }
    return FALSE;
}

// Will setup a spell to fire again on the next round.
// Spell is the spell's variables.
void FireSpellAgain (struct stSpell Spell)
{
    string sSpellScript;
    // Set all variables on the caster to fire the spell again.
    SetLocalInt (OBJECT_SELF, "0_Spell_Class", Spell.iClass);
    SetLocalInt (OBJECT_SELF, "0_Spell_ID", Spell.iSpellID);
    SetLocalObject (OBJECT_SELF, "0_Spell_oTarget", Spell.oTarget);
    SetLocalLocation (OBJECT_SELF, "0_Spell_lTarget", Spell.lTarget);
    SetLocalInt (OBJECT_SELF, "0_Spell_MetaMagic", Spell.iMetaMagic);
    // Set the variable to let the spell scripts know we are firing the spell again.
    // This setups the spell to get the proper variables such as target.
    SetLocalInt (OBJECT_SELF, "0_Fired_Spell_Again", TRUE);
    // Get the script to fire again.
    sSpellScript = Get2DAString ("spells", "ImpactScript", Spell.iSpellID);
    // Fire off the impact script again.
    ExecuteScript (sSpellScript, Spell.oCaster);
    // Delete the variable so the spell does not interfere with casting other spells.
    DeleteLocalInt (OBJECT_SELF, "0_Fired_Spell_Again");
}

// Unsummon monsters based on spell cast.
void AdjustCurrentSummonedCreatures (object oCaster, int nSpellID)
{
    int nCount = 1, nSpell;
    effect eVisual = EffectVisualEffect (VFX_IMP_UNSUMMON);
    object oSummons = GetAssociate (ASSOCIATE_TYPE_SUMMONED, oCaster, nCount);
    while (GetIsObjectValid (oSummons))
    {
        nSpell = GetLocalInt (oSummons, "0_Summon_ID");
        if (nSpell != nSpellID)
        {
            AssignCommand (oSummons, SetIsDestroyable (FALSE, FALSE, FALSE));
            AssignCommand (oSummons, DelayCommand (0.5, SetIsDestroyable (TRUE, FALSE, FALSE)));
        }
        else
        {
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, oSummons);
            DestroyObject (oSummons, 1.0f);
        }
        nCount ++;
        oSummons = GetAssociate (ASSOCIATE_TYPE_SUMMONED, oCaster, nCount);
    }
}

// Mark just summoned creatures, used in multi-summon spells.
void MarkSummonedCreatures(object oCaster, int nSpellID)
{
    int nIndex = 1, nSummonID;
    object oSummons = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCaster, nIndex);
    while(oSummons != OBJECT_INVALID)
    {
        nSummonID = GetLocalInt (oSummons, "0_Summon_ID");
        if(nSummonID == 0) SetLocalInt(oSummons, "0_Summon_ID", nSpellID);
        oSummons = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCaster, ++nIndex);
    }
}

// Cast an Arcane Blast.
// Spell is the original spells variables.
void CastArcaneBlast (struct stSpell Spell)
{
    // Change spell variables to Arcane Blast variables.
    Spell.iDescriptor = DESC_FORCE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    // Set target.
    Spell.oAreaTarget = Spell.oTarget;
    // Do Arcane Blast effect
    effect eDmg;
    effect eImpact = EffectVisualEffect (VFX_IMP_STUN);
    effect eImpact2 = EffectVisualEffect (VFX_IMP_BREACH);
    //Fire cast spell at event for the specified target
    SignalEvent (Spell.oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
    // Make resistance and save check.
    Spell = ResistAndSave (Spell);
    if (!Spell.iSaveResult)
    {
        int iSpellLevel = GetSpellLevel (Spell);
        //Roll damage d8 per level of the spell.
        Spell.iResult = d8 (iSpellLevel);
        //Set damage effect
        eDmg = EffectDamage(Spell.iResult, Spell.iDamageType);
        //Apply the VFX and damage effect
        ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oTarget);
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eImpact, Spell.oTarget);
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eImpact2, Spell.oTarget);
    }
}

// Will do all cure type effects for living and undead creatures.
// Spell is the spell structure.
// iVFX_ImpDmg is the vfx for doing damage to undead.
// iVFX_ImpHeal is the vfx for healing a creature.
void CureSpell (struct stSpell Spell, int iVFX_ImpDmg, int iVFX_ImpHeal)
{
    int iHit, bHasDomain = FALSE;
    effect eHeal, eDmg, eImpact;
    // Get the amount of healing or damage.
    Spell = GetModifier (Spell);
    // Check for Healing domain power.
    // Check to see players if they have a set deity in the database.
    if (GetIsCharacter (Spell.oCaster))
    {
        int nDeity = GetObjectDatabaseInt (Spell.oCaster, CHARACTER_TABLE, "deity");
        bHasDomain = StringToInt (Get2DAString ("deities", "Healing_Domain", nDeity));
    }
    // NPC's if have the domain are assumed to have a correct Diety.
    else bHasDomain = TRUE;
    if (GetHasFeat (FEAT_HEALING_DOMAIN_POWER) && bHasDomain) Spell.iResult = Spell.iResult + ((GetSpellLevel (Spell) + 1) * 2);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Check to see if they are undead.
        if (GetRacialType(Spell.oAreaTarget) == RACIAL_TYPE_UNDEAD ||
            GetClassByPosition(1, Spell.oAreaTarget) == CLASS_TYPE_UNDEAD)
        {
            // If the spell is a touch attack.
            if (Spell.iAreaShape == SHAPE_TOUCH_TARGET) iHit = TouchAttackMelee (Spell.oAreaTarget);
            // else its a ranged touch attack.
            else iHit = TouchAttackRanged (Spell.oAreaTarget);
            if (iHit)
            {
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                // If the target doesn't make a Resistance and Save check.
                Spell = ResistAndSave (Spell);
                if (!Spell.iSaveResult)
                {
                    eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                    //Apply the VFX impact and effects
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                    eImpact = EffectVisualEffect (iVFX_ImpDmg);
                    DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                }
            }
        }
        else
        {
            int nNPCHp = GetLocalInt (Spell.oAreaTarget, "0_Hitpoints");
            int nAssociateType = GetLocalInt (Spell.oAreaTarget, "0_PCAssociate");
            if ((nAssociateType == ASSOCIATE_TYPE_HENCHMAN || nAssociateType == ASSOCIATE_TYPE_NPC) &&
                nNPCHp < 1 && nNPCHp > -10 && GetIsDead(Spell.oAreaTarget))
            {
                nNPCHp = nNPCHp + Spell.iResult;
                SetLocalInt (Spell.oAreaTarget, "0_Hitpoints", nNPCHp);
                SendMessages (GetName (Spell.oAreaTarget) + " : " + "Healed " + IntToString (Spell.iResult) + " hit points.", COLOR_YELLOW, Spell.oCaster, FALSE, FALSE);
                //Apply heal effect and VFX impact
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eHeal, Spell.oAreaTarget));
                eImpact = EffectVisualEffect (iVFX_ImpHeal);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            }
            else
            {
                //Set the heal effect
                eHeal = EffectHeal (Spell.iResult);
                //Apply heal effect and VFX impact
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eHeal, Spell.oAreaTarget));
                eImpact = EffectVisualEffect (iVFX_ImpHeal);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
}

// Will do all inflict type effects for living and undead creatures.
// Spell is the spell structure.
// iVFX_ImpDmg is the vfx for doing damage to undead.
// iVFX_ImpHeal is the vfx for healing a creature.
void InflictSpell (struct stSpell Spell, int iVFX_ImpDmg, int iVFX_ImpHeal)
{
    int iHit;
    effect eHeal, eDmg, eImp;
    // Get the amount of healing or damage.
    Spell = GetModifier (Spell);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Check to see if they are dead.
        if (GetRacialType(Spell.oTarget) == RACIAL_TYPE_UNDEAD)
        {
            //Set the heal effect
            eHeal = EffectHeal (Spell.iResult);
            //Apply heal effect and VFX impact
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eHeal, Spell.oAreaTarget));
            eImp = EffectVisualEffect (iVFX_ImpHeal);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImp, Spell.oAreaTarget));
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        }
        // Now do effect to living creatures i.e. inflict wounds.
        else
        {
            // If the spell is a touch attack.
            if (Spell.iAreaShape == SHAPE_TOUCH_TARGET) iHit = TouchAttackMelee (Spell.oAreaTarget);
            // else its a ranged touch attack.
            else iHit = TouchAttackRanged (Spell.oAreaTarget);
            if (iHit)
            {
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                // If the target doesn't make a Resistance and Save check.
                Spell = ResistAndSave (Spell);
                if (!Spell.iSaveResult)
                {
                    // The harm spell cannot lower a creatures hitpoints below 1.
                    if (Spell.iSpellID == SPELL_HARM)
                    {
                        int nHitPoints = GetCurrentHitPoints (Spell.oAreaTarget);
                        if (Spell.iResult >= nHitPoints) Spell.iResult = nHitPoints - 1;
                    }
                    eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                    //Apply the VFX impact and effects
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                    eImp = EffectVisualEffect (iVFX_ImpDmg);
                    DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, Spell.oAreaTarget));
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
}

// Fires a volley of missiles around the area of the object selected.
// Spell is the spells data from the original spell.
// iTotalMissles is the total number of missles to fire.
// iMIRV is the vfx_imp_* defaults to VFX_IMP_MIRV
// bOneHit tells the script to only do one missle per enemy maximum.
// bOneTarget tells the script to put all missles into one target.
void MissileStorm (struct stSpell Spell, int nTotalMissiles, int nMIRV = VFX_IMP_MIRV, int bOneHit = FALSE, int bOneTarget = FALSE)
{
    effect eDmg;
    object oTarget = OBJECT_INVALID;
    int nCnt, nTargets = 0, nMissilesPerTarget, nRemainderMissiles, nExtraMissile;
    effect eMissile = EffectVisualEffect (nMIRV);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    float fDistance;
    float fDelay = 0.0;
    float fDelay2, fTime;
    // Get the number of targets in the area of effect before we send missles.
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        // You can only fire missiles on visible targets.
        // If the firing object is a placeable (such as a projectile trap),
        // we skip the line of sight check as placeables can't "see" things.
        if ((GetObjectType (Spell.oCaster) == OBJECT_TYPE_PLACEABLE ) ||
             GetObjectSeen (Spell.oAreaTarget, Spell.oCaster) ||
             GetIsDungeonMaster (Spell.oCaster)) nTargets ++;
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    // Exit if no enemies to hit
    if (nTargets == 0) return;
    // If more targets than missles setup the number of missles to fire per target.
    if (nTargets > nTotalMissiles)
    {
        // If we have more targets than missles reduce the number of targets.
        nTargets = nTotalMissiles;
        nMissilesPerTarget = 1;
        nRemainderMissiles = 0;
    }
    // If more missles than targets setup the number of missles to fire per target.
    else
    {
        // This spell only hits each target once.
        if (bOneHit == TRUE)
        {
            nMissilesPerTarget = 1;
            nRemainderMissiles = 0;
        }
        else
        {
            nMissilesPerTarget = nTotalMissiles / nTargets;
            nRemainderMissiles = nTotalMissiles - (nMissilesPerTarget * nTargets);
        }
    }
    // Reset the spells targets so we can cycle through and hit them.
    Spell.oAreaTarget = OBJECT_INVALID;
    // Get each target of the spell.
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        // Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Calculate appropriate distances from target.
        fDistance = GetDistanceBetween (Spell.oCaster, Spell.oAreaTarget);
        fDelay = fDistance / (3.0 * log(fDistance) + 2.0);
        nCnt = 0;
        //--------------------------------------------------------------
        // GZ: Moved SR check out of loop to have 1 check per target
        //     not one check per missile, which would rip spell mantels apart.
        //     We have a main per target loop then a missle loop to fix this.
        //--------------------------------------------------------------
        // Make resistance and save check per target.
        Spell = ResistAndSave (Spell);
        // Count each remainder missle.
        if (nRemainderMissiles > 0)
        {
            nExtraMissile = 1;
            nRemainderMissiles--;
        }
        else nExtraMissile = 0;
        if (!Spell.iSaveResult)
        {
            // Loop for each missle that should hit them.
            for (nCnt= 1; nCnt <= nMissilesPerTarget + nExtraMissile; nCnt++)
            {
                // Roll damage and set delays.
                Spell = GetModifier (Spell);
                fTime = fDelay;
                fDelay2 += 0.1;
                fTime += fDelay2;
                // Set damage effect
                eDmg = EffectDamage(Spell.iResult, Spell.iDamageType);
                // Apply the MIRV and damage effect
                DelayCommand (fTime, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eImpact, Spell.oAreaTarget));
                DelayCommand (fDelay2, ApplyEffectToObject (DURATION_TYPE_INSTANT, eMissile, Spell.oAreaTarget));
                DelayCommand (fTime, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                //Debug ("0i_spells", "1912", GetName (Spell.oAreaTarget) + ": Spell.iResult: " + IntToString (Spell.iResult));
            }
        }
        else
        {  // Apply a dummy visual effect that does no damage.
            for (nCnt= 1; nCnt <= nMissilesPerTarget + nExtraMissile; nCnt++)
            {
                ApplyEffectToObject (DURATION_TYPE_INSTANT, eMissile, Spell.oAreaTarget);
            }
        }
        // Reduce number of targets till we have hit them all.
        if (--nTargets < 1) return;
        // Get the spells target(s).
        if (!bOneTarget) Spell = GetSpellTarget (Spell);
    }
}

// Removes mental spell effects from target and protects against new effects.
// Spell is the spells data from the original spell.
void ApplyMindBlank (struct stSpell Spell)
{
    // Create visual effects.
    effect eImmunity = EffectImmunity (IMMUNITY_TYPE_MIND_SPELLS);
    effect eVisual = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects (eImmunity, eVisual);
    eLink = EffectLinkEffects (eLink, eDuration);
    effect eSearch = GetFirstEffect(Spell.oAreaTarget);
    int iValid;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Search through effects
        while (GetIsEffectValid (eSearch))
        {
            iValid = FALSE;
            //Check to see if the effect matches a particular type defined below
            if (GetEffectType(eSearch) == EFFECT_TYPE_DAZED) iValid = TRUE;
            else if (GetEffectType (eSearch) == EFFECT_TYPE_CHARMED) iValid = TRUE;
            else if (GetEffectType (eSearch) == EFFECT_TYPE_SLEEP) iValid = TRUE;
            else if (GetEffectType (eSearch) == EFFECT_TYPE_CONFUSED) iValid = TRUE;
            else if(GetEffectType(eSearch) == EFFECT_TYPE_STUNNED) iValid = TRUE;
            else if(GetEffectType(eSearch) == EFFECT_TYPE_DOMINATED) iValid = TRUE;
            // * Remove any feeblemind originating effects
            else if (GetEffectSpellId(eSearch) == SPELL_FEEBLEMIND) iValid = TRUE;
            else if (GetEffectSpellId(eSearch) == SPELL_BANE) iValid = TRUE;
            // Remove effect if the effect is a match
            if (iValid == TRUE) RemoveEffect (Spell.oAreaTarget, eSearch);
            eSearch = GetNextEffect (Spell.oAreaTarget);
        }
        // After effects are removed we apply the immunity to mind spells to the target
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
}

// Wrapper for petrification within the server.
// Scripts affected: flesh to stone, breath petrification, gaze petrification, touch petrification
// nFortSaveDC: pass in this number from the spell script
void ApplyPetrificationEffect(struct stSpell Spell)
{
    if(IsImmuneToPetrification(Spell.oAreaTarget)) return;
    effect ePetrify = EffectPetrify();
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eDuration, ePetrify);
    // If a PC then display Death panel.
    if(GetIsCharacter(Spell.oAreaTarget)) DelayCommand(2.75, PopUpDeathPanel(Spell.oAreaTarget));
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, Spell.oAreaTarget);
    // Associates must be uncommandable or they will follow you while stoned!
    if(GetAssociateType(Spell.oAreaTarget) == ASSOCIATE_TYPE_HENCHMAN)
    {
        SetCommandable(FALSE, Spell.oAreaTarget);
    }
    // April 2003: Clearing actions to kick them out of conversation when petrified
    ClearAllActions(TRUE, Spell.oAreaTarget);
}

void ApplyInsanityEffect (struct stSpell Spell)
{
    effect eImpact = EffectVisualEffect (VFX_IMP_HEAD_MIND);
    effect eInsanity = EffectConfused ();
    if (GetIsPC (Spell.oAreaTarget))
    {
        Spell.iDurationType = DURATION_TYPE_MINUTES;
        Spell.iDuration = 1;
        Spell.iDurPerLvl = 1;
        Spell = GetDuration (Spell);
    }
    else
    {
        Spell.iDurationType = DURATION_TYPE_PERMANENT;
        Spell.fDuration = 0.0f;
    }
    ApplyEffectToObject (Spell.iDurationType, eInsanity, Spell.oAreaTarget, Spell.fDuration);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
}

// Changes a spells damage type and some graphical effect based on damage type.
// Returns the spells structure.
// Spell is the spell struct for the spell.
// iDamageType is the damage type base on DAMAGE_TYPE_*
struct stSpell ChangeDamageType (struct stSpell Spell, int iDamageType)
{
    Spell.iDamageType = iDamageType;
    // Now change the impact graphic to match the damage type.
    if (iDamageType == DAMAGE_TYPE_ACID)
    {
        Spell.iImpact = VFX_IMP_ACID_S;
        Spell.iBeam = VFX_BEAM_DISINTEGRATE;
    }
    else if (iDamageType == DAMAGE_TYPE_BLUDGEONING)
    {
        Spell.iImpact = VFX_COM_BLOOD_LRG_RED;
        Spell.iBeam = VFX_BEAM_ODD;
    }
    else if (iDamageType == DAMAGE_TYPE_COLD)
    {
        Spell.iImpact = VFX_IMP_FROST_S;
        Spell.iBeam = VFX_BEAM_COLD;
    }
    else if (iDamageType == DAMAGE_TYPE_DIVINE)
    {
        Spell.iImpact = VFX_IMP_HEAD_HOLY;
        Spell.iBeam = VFX_BEAM_HOLY;
    }
    else if (iDamageType == DAMAGE_TYPE_ELECTRICAL)
    {
        Spell.iImpact = VFX_IMP_LIGHTNING_S;
        Spell.iBeam = VFX_BEAM_LIGHTNING;
    }
    else if (iDamageType == DAMAGE_TYPE_FIRE)
    {
        Spell.iImpact = VFX_IMP_FLAME_S;
        Spell.iBeam = VFX_BEAM_FIRE;
    }
    else if (iDamageType == DAMAGE_TYPE_MAGICAL)
    {
        Spell.iImpact = VFX_IMP_MAGBLUE;
        Spell.iBeam = VFX_BEAM_MIND;
    }
    else if (iDamageType == DAMAGE_TYPE_NEGATIVE)
    {
        Spell.iImpact = VFX_IMP_AURA_NEGATIVE_ENERGY;
        Spell.iBeam = VFX_BEAM_BLACK;
    }
    else if (iDamageType == DAMAGE_TYPE_PIERCING)
    {
        Spell.iImpact = VFX_COM_BLOOD_LRG_RED;
        Spell.iBeam = VFX_BEAM_ODD;
    }
    else if (iDamageType == DAMAGE_TYPE_POSITIVE)
    {
        Spell.iImpact = VFX_IMP_HEAD_COLD;
        Spell.iBeam = VFX_BEAM_COLD;
    }
    else if (iDamageType == DAMAGE_TYPE_SLASHING)
    {
        Spell.iImpact = VFX_COM_BLOOD_LRG_RED;
        Spell.iBeam = VFX_BEAM_ODD;
    }
    else if (iDamageType == DAMAGE_TYPE_SONIC)
    {
        Spell.iImpact = VFX_IMP_SONIC;
        Spell.iBeam = VFX_BEAM_ODD;
    }
    return Spell;
}

// Wild magic!
// Will change a variety of effects for a spell when cast at random!
struct stSpell WildMagic (struct stSpell Spell)
{
    // Send message.
    SendMessages ("This area seems unstable for magic!", COLOR_RED, Spell.oCaster);
    // Roll for random effect.
    int iRoll = d6();
    // Change damage type.
    if (iRoll == 1)
    {
        iRoll = d8();
        if (iRoll = 1) Spell.iDamageType = DAMAGE_TYPE_ACID;
        else if (iRoll = 2) Spell.iDamageType = DAMAGE_TYPE_COLD;
        else if (iRoll = 3) Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
        else if (iRoll = 4) Spell.iDamageType = DAMAGE_TYPE_FIRE;
        else if (iRoll = 5) Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
        else if (iRoll = 6) Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
        else if (iRoll = 7) Spell.iDamageType = DAMAGE_TYPE_POSITIVE;
        else if (iRoll = 8) Spell.iDamageType = DAMAGE_TYPE_SONIC;
        // Now change the impact graphic to match the damage type.
        Spell = ChangeDamageType (Spell, Spell.iDamageType);
    }
    // Change Area Effect.
    else if (iRoll == 2)
    {
        iRoll = d6();
        if (iRoll == 1) Spell.fAreaSize = 5.0f;
        else if (iRoll == 2) Spell.fAreaSize = 10.0f;
        else if (iRoll == 3) Spell.fAreaSize = 20.0f;
        else if (iRoll == 4) Spell.fAreaSize = 40.0f;
        else if (iRoll == 5) Spell.fAreaSize = 80.0f;
        else if (iRoll == 6) Spell.fAreaSize = 160.0f;
    }
    // Change caster level.
    else if (iRoll == 3)
    {
        iRoll = d20();
        Spell.iCasterLevel = iRoll;
    }
    // Change Target.
    else if (iRoll == 4)
    {
        object oTarget;
        int iRoll = d6();
        oTarget = GetNearestObject (OBJECT_TYPE_CREATURE, Spell.oTarget, iRoll);
        // If not a valid target or close enough then move in and check again.
        while (oTarget == OBJECT_INVALID || GetDistanceBetween (oTarget, Spell.oTarget) > 30.0f && iRoll > 0)
        {
            iRoll = iRoll - 1;
            oTarget = GetNearestObject (OBJECT_TYPE_CREATURE, Spell.oTarget, iRoll);
        }
        // if we found a new target then change the target!
        if (iRoll > 0) Spell.oTarget = oTarget;
        return Spell;
    }
    // Change Modifiers.
    else if (iRoll == 5)
    {
        int iRoll = d3();
        if (iRoll == 1) Spell.iModNumOfDice = d6();
        else if (iRoll == 2) Spell.iModifierDie = d12();
        else  Spell.iModifier = d10();
    }
    // Spell fails
    else
    {
        // Send message.
        SendMessages ("Your spell fizzles out!", COLOR_RED, Spell.oCaster);
        // Stop the spell.
        Spell.iSpellID = STOP_SPELL;
        return Spell;
    }
    return Spell;
}

object GetAssociateWithResRef (object oMaster, string sResRef)
{
    int iNumberOfAssociate;
    object oSummons = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, oMaster, iNumberOfAssociate);
    while (GetIsObjectValid (oSummons))
    {
        if (GetResRef (oSummons) == sResRef) return oSummons;
        oSummons = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, oMaster, ++iNumberOfAssociate);
    }
    return oSummons;
}

// See vfx_persistent.2da for line number of the area of effect.
void SetAreaOfEffectSpellVariables (int iAreaOfEffectID, struct stSpell Spell)
{
    string sTag = Get2DAString ("vfx_persistent", "LABEL", iAreaOfEffectID);
    object oAOE = GetObjectByTag (sTag);
    SetTag (oAOE, sTag + RemoveIllegalCharacters (GetName (Spell.oCaster)));
    SetLocalObject (oAOE, "Spell_Caster", Spell.oCaster);
    SetLocalInt (oAOE, "Spell_SaveDC", Spell.iSaveDC);
}

// See vfx_persistent.2da for line number of the area of effect.
struct stSpell GetAreaOfEffectSpellVariables (int iAreaOfEffectID, struct stSpell Spell)
{
    string sTag = Get2DAString ("vfx_persistent", "LABEL", iAreaOfEffectID);
    object oAOE = GetObjectByTag (sTag + RemoveIllegalCharacters (GetName (Spell.oCaster)));
    Spell.oCaster = GetLocalObject (oAOE, "Spell_Caster");
    Spell.iSaveDC = GetLocalInt (oAOE, "Spell_SaveDC");
    return Spell;
}

// Gets if character knows a spell.
int GetKnownSpell (object oCreature, int nSpell)
{
    int ic, nLevel, nIndex, nSpellCount, nClass;
    for (ic = 1; ic < 4; ic++)
    {
        nClass = GetClassByPosition (ic, oCreature);
        if (nClass == CLASS_TYPE_INVALID) return FALSE;
        for (nLevel = 1; nLevel < 10; nLevel++)
        {
            nSpellCount = GetKnownSpellCount (oCreature, nClass, nLevel);
            for (nIndex = 0; nIndex < nSpellCount; nIndex ++)
            {
                if (nSpell == GetKnownSpellId (oCreature, nClass, nLevel, nIndex)) return TRUE;
            }
        }
    }
    return FALSE;
}

// * returns true if the creature has flesh
int IsImmuneToPetrification (object oCreature)
{
    int nAppearance = GetAppearanceType (oCreature);
    switch (nAppearance)
    {
        case APPEARANCE_TYPE_BASILISK:
        case APPEARANCE_TYPE_COCKATRICE:
        case APPEARANCE_TYPE_MEDUSA:
        case APPEARANCE_TYPE_ALLIP:
        case APPEARANCE_TYPE_ELEMENTAL_AIR:
        case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_EARTH:
        case APPEARANCE_TYPE_ELEMENTAL_EARTH_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_FIRE:
        case APPEARANCE_TYPE_ELEMENTAL_FIRE_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_WATER:
        case APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER:
        case APPEARANCE_TYPE_GOLEM_STONE:
        case APPEARANCE_TYPE_GOLEM_IRON:
        case APPEARANCE_TYPE_GOLEM_CLAY:
        case APPEARANCE_TYPE_GOLEM_BONE:
        case APPEARANCE_TYPE_GORGON:
        case APPEARANCE_TYPE_HEURODIS_LICH:
        case APPEARANCE_TYPE_LANTERN_ARCHON:
        case APPEARANCE_TYPE_SHADOW:
        case APPEARANCE_TYPE_SHADOW_FIEND:
        case APPEARANCE_TYPE_SHIELD_GUARDIAN:
        case APPEARANCE_TYPE_SKELETAL_DEVOURER:
        case APPEARANCE_TYPE_SKELETON_CHIEFTAIN:
        case APPEARANCE_TYPE_SKELETON_COMMON:
        case APPEARANCE_TYPE_SKELETON_MAGE:
        case APPEARANCE_TYPE_SKELETON_PRIEST:
        case APPEARANCE_TYPE_SKELETON_WARRIOR:
        case APPEARANCE_TYPE_SKELETON_WARRIOR_1:
        case APPEARANCE_TYPE_SPECTRE:
        case APPEARANCE_TYPE_WILL_O_WISP:
        case APPEARANCE_TYPE_WRAITH:
        case APPEARANCE_TYPE_BAT_HORROR:
        case 405: // Dracolich:
        case 415: // Alhoon
        case 418: // shadow dragon
        case 420: // mithral golem
        case 421: // admantium golem
        case 430: // Demi Lich
        case 469: // animated chest
        case 474: // golems
        case 475: // golems
            return TRUE;
    }
    // Petrification immunity can also be granted as an item property.
    if (ResistSpell (OBJECT_SELF, oCreature) == 2 ) return TRUE;
    // Prevent people from petrifying DM, resulting in GUI even when effect is not successful.
    if (!GetPlotFlag (oCreature) && GetIsDungeonMaster (oCreature)) return TRUE;
    return FALSE;
}

// Do I have any effect on me that came from a mind affecting spell?
int DoIHaveAMindAffectingSpellOnMe (object oTarget)
{
    if  (GetHasSpellEffect(SPELL_SLEEP, oTarget) ||
         GetHasSpellEffect(SPELL_DAZE, oTarget) ||
         GetHasSpellEffect(SPELL_HOLD_ANIMAL, oTarget) ||
         GetHasSpellEffect(SPELL_HOLD_MONSTER, oTarget) ||
         GetHasSpellEffect(SPELL_HOLD_PERSON, oTarget) ||
         GetHasSpellEffect(SPELL_CHARM_MONSTER, oTarget) ||
         GetHasSpellEffect(SPELL_CHARM_PERSON, oTarget) ||
         GetHasSpellEffect(SPELL_CHARM_PERSON_OR_ANIMAL, oTarget) ||
         GetHasSpellEffect(SPELL_MASS_CHARM, oTarget) ||
         GetHasSpellEffect(SPELL_DOMINATE_ANIMAL, oTarget) ||
         GetHasSpellEffect(SPELL_DOMINATE_MONSTER, oTarget) ||
         GetHasSpellEffect(SPELL_DOMINATE_PERSON, oTarget) ||
         GetHasSpellEffect(SPELL_CONFUSION, oTarget)  ||
         GetHasSpellEffect(SPELL_MIND_FOG, oTarget)   ||
         GetHasSpellEffect(SPELL_CLOUD_OF_BEWILDERMENT, oTarget)   ||
         GetHasSpellEffect(SPELLABILITY_BOLT_DOMINATE,oTarget) ||
         GetHasSpellEffect(SPELLABILITY_BOLT_CHARM,oTarget) ||
         GetHasSpellEffect(SPELLABILITY_BOLT_CONFUSE,oTarget) ||
         GetHasSpellEffect(SPELLABILITY_BOLT_DAZE,oTarget)) return TRUE;
    return FALSE;
}

// True if this spell is a cure spell.
int IsCureTouchSpell (int nSpell)
{
    switch (nSpell)
    {
        case SPELL_CURE_CRITICAL_WOUNDS:
        case SPELL_CURE_LIGHT_WOUNDS:
        case SPELL_CURE_MINOR_WOUNDS:
        case SPELL_CURE_MODERATE_WOUNDS:
        case SPELL_CURE_SERIOUS_WOUNDS:
        case SPELL_HEAL: return TRUE; break;
   }
   return FALSE;
}

// True if this spell is an inflict spell.
int IsInflictTouchSpell (int nSpell)
{
    switch (nSpell)
    {
        case SPELL_INFLICT_CRITICAL_WOUNDS:
        case SPELL_INFLICT_LIGHT_WOUNDS:
        case SPELL_INFLICT_MINOR_WOUNDS:
        case SPELL_INFLICT_MODERATE_WOUNDS:
        case SPELL_INFLICT_SERIOUS_WOUNDS:
        case SPELL_HARM: return TRUE; break;
   }
   return FALSE;
}

// True if this spell is an area of effect spell.
int IsAreaOfEffectSpell (int nSpell)
{
    switch (nSpell)
    {
        case SPELL_ACID_FOG          :
        case SPELL_MIND_FOG          :
        case SPELL_STORM_OF_VENGEANCE:
//      case SPELL_WEB               :
        case SPELL_GREASE            :
        case SPELL_CREEPING_DOOM     :
//      case SPELL_DARKNESS          :
        case SPELL_SILENCE           :
        case SPELL_BLADE_BARRIER     :
        case SPELL_CLOUDKILL         :
        case SPELL_STINKING_CLOUD    :
        case SPELL_WALL_OF_FIRE      :
        case SPELL_INCENDIARY_CLOUD  :
        case SPELL_ENTANGLE          :
        case SPELL_EVARDS_BLACK_TENTACLES:
        case SPELL_CLOUD_OF_BEWILDERMENT :
        case SPELL_STONEHOLD             :
        case SPELL_VINE_MINE             :
        case SPELL_SPIKE_GROWTH          :
        case SPELL_DIRGE                 :
        case 530                         : // vine mine
        case 531                         : // vine mine
        case 532                         : // vine mine
        case 961                         : // Prismatic Sphere
            return TRUE; break;
    }
    return FALSE;
}

// A different approach for timing these spells that has the positive side
// effects of making the spell dispellable as well.
// I am using the VFX applied by the spell to track the remaining duration
// instead of adding the remaining runtime on the stack
//
// This function returns FALSE if a delayed Spell effect from nSpell_ID has expired.
// Used in nw_s0_acidarrow
//------------------------------------------------------------------------------
int GetDelayedSpellEffectsExpired (int nSpell_ID, object oTarget, object oCaster)
{
    if (!GetHasSpellEffect (nSpell_ID,oTarget))
    {
        DeleteLocalInt (oTarget, "XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        return TRUE;
    }
    // If the caster is dead or no longer there, cancel the spell, as it is directed.
    if (oCaster == OBJECT_INVALID || GetIsDead (oCaster))
    {
        RemoveSpellEffects (nSpell_ID, oCaster, oTarget);
        DeleteLocalInt (oTarget, "XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        return TRUE;
    }
    return FALSE;
}

//  Returns TRUE if the spell can target oTarget based on nTargetType & oCaster.
int IsSpellTargetValid (object oTarget, int nTargetType, object oCaster)
{
    if (GetIsDead (oTarget) == TRUE) return FALSE;
    int nReturnValue = FALSE;
    switch (nTargetType)
    {
        case TARGET_TYPE_ALL :
            nReturnValue = TRUE;
            break;
        // This kind of spell will affect all friendlies and anyone in my
        // party, even if we are upset with each other currently.
        case TARGET_TYPE_ALLIES:
        {
            if (GetIsReactionTypeFriendly (oTarget, oCaster) ||
                GetFactionEqual (oTarget, oCaster)) nReturnValue = TRUE;
            break;
        }
        // Effects only hostile type creatures.
        case TARGET_TYPE_ENEMIES:
        {
            if (GetIsEnemy (oTarget, oCaster)) nReturnValue = TRUE;
            break;
        }
    }
    return nReturnValue;
}

int RemoveProtections (int nSpell_ID, object oTarget, int nCount)
{
    effect eProtection;
    int nCnt = 0;
    if (GetHasSpellEffect (nSpell_ID, oTarget))
    {
        //Search through the valid effects on the target.
        eProtection = GetFirstEffect (oTarget);
        while (GetIsEffectValid (eProtection))
        {
            //If the effect was created by the spell then remove it
            if (GetEffectSpellId (eProtection) == nSpell_ID)
            {
                RemoveEffect (oTarget, eProtection);
                nCnt ++;
            }
            //Get next effect on the target
            eProtection = GetNextEffect (oTarget);
        }
    }
    if(nCnt > 0) return 1;
    else return 0;
}

// Returns the nLastChecked-nth highest spell on the creature for use in
// the spell breach routines
//------------------------------------------------------------------------------
int GetSpellBreachProtection (int nLastChecked)
{
    //--------------------------------------------------------------------------
    // GZ: Protections are stripped in the order they appear here
    //--------------------------------------------------------------------------
    if(nLastChecked == 1) {return SPELL_GREATER_SPELL_MANTLE;}
    else if (nLastChecked == 2){return SPELL_PREMONITION;}
    else if(nLastChecked == 3) {return SPELL_SPELL_MANTLE;}
    else if(nLastChecked == 4) {return SPELL_SHADOW_SHIELD;}
    else if(nLastChecked == 5) {return SPELL_GREATER_STONESKIN;}
    else if(nLastChecked == 6) {return SPELL_ETHEREAL_VISAGE;}
    else if(nLastChecked == 7) {return SPELL_GLOBE_OF_INVULNERABILITY;}
    else if(nLastChecked == 8) {return SPELL_ENERGY_BUFFER;}
    else if(nLastChecked == 9) {return 443;} // greater sanctuary
    else if(nLastChecked == 10) {return SPELL_MINOR_GLOBE_OF_INVULNERABILITY;}
    else if(nLastChecked == 11) {return SPELL_SPELL_RESISTANCE;}
    else if(nLastChecked == 12) {return SPELL_STONESKIN;}
    else if(nLastChecked == 13) {return SPELL_LESSER_SPELL_MANTLE;}
    else if(nLastChecked == 14) {return SPELL_MESTILS_ACID_SHEATH;}
    else if(nLastChecked == 15) {return SPELL_MIND_BLANK;}
    else if(nLastChecked == 16) {return SPELL_ELEMENTAL_SHIELD;}
    else if(nLastChecked == 17) {return SPELL_PROTECTION_FROM_SPELLS;}
    else if(nLastChecked == 18) {return SPELL_PROTECTION_FROM_ELEMENTS;}
    else if(nLastChecked == 19) {return SPELL_RESIST_ELEMENTS;}
    else if(nLastChecked == 20) {return SPELL_DEATH_ARMOR;}
    else if(nLastChecked == 21) {return SPELL_GHOSTLY_VISAGE;}
    else if(nLastChecked == 22) {return SPELL_ENDURE_ELEMENTS;}
    else if(nLastChecked == 23) {return SPELL_SHADOW_SHIELD;}
    else if(nLastChecked == 24) {return SPELL_SHADOW_CONJURATION_MAGE_ARMOR;}
    else if(nLastChecked == 25) {return SPELL_NEGATIVE_ENERGY_PROTECTION;}
    else if(nLastChecked == 26) {return SPELL_SANCTUARY;}
    else if(nLastChecked == 27) {return SPELL_MAGE_ARMOR;}
    else if(nLastChecked == 28) {return SPELL_STONE_BONES;}
    else if(nLastChecked == 29) {return SPELL_SHIELD;}
    else if(nLastChecked == 30) {return SPELL_SHIELD_OF_FAITH;}
    else if(nLastChecked == 31) {return SPELL_LESSER_MIND_BLANK;}
    else if(nLastChecked == 32) {return SPELL_IRONGUTS;}
    else if(nLastChecked == 33) {return SPELL_RESISTANCE;}
    return nLastChecked;
}

// Attempts a dispel on one target, with all safety checks put in.
void DispelMagicEffect (object oTarget, int nCasterLevel, effect eVis, effect eImpac, int bAll = TRUE, int bBreachSpells = FALSE)
{
    // Don't dispel magic on petrified targets this change is in to prevent
    // weird things from happening with 'statue' creatures.
    // Also creature can be scripted to be immune to dispel magic as well.
    if (GetHasEffect (EFFECT_TYPE_PETRIFY, oTarget))
    {
        SendMessages ("You cannot dispel petrification!", COLOR_RED, OBJECT_SELF);
        return;
    }
    if (GetLocalInt (oTarget, "0_IMMUNE_TO_DISPEL"))
    {
        SendMessages ("You cannot use dispel on Villains!", COLOR_RED, OBJECT_SELF);
        return;
    }
    effect eDispel;
    float fDelay = GetRandomDelay (0.1, 0.3);
    int nId = GetSpellId();
    // Fire hostile event only if the target is hostile...
    if (IsSpellTargetValid (oTarget, TARGET_TYPE_ENEMIES, OBJECT_SELF))
    {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nId));
    }
    else SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nId, FALSE));
    if (bAll)
    {
        eDispel = EffectDispelMagicAll (nCasterLevel);
        // Support for Mord's disjunction
        if (bBreachSpells) DoSpellBreach (oTarget, 6, 10, nId);
    }
    else
    {
        eDispel = EffectDispelMagicBest (nCasterLevel);
        if (bBreachSpells) DoSpellBreach (oTarget, 2, 10, nId);
    }
    DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, oTarget));
    DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDispel, oTarget));
}

void DoSpellBreach (object oTarget, int nTotal, int nSR, int nSpellId = -1)
{
    if (nSpellId == -1) nSpellId =  SPELL_GREATER_SPELL_BREACH;
    effect eSR = EffectSpellResistanceDecrease (nSR);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eVis = EffectVisualEffect (VFX_IMP_BREACH);
    int nCnt, nIdx;
    if (!GetIsReactionTypeFriendly (oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (oTarget, EventSpellCastAt (OBJECT_SELF, nSpellId));
        //Search through and remove protections.
        while (nCnt <= 33 && nIdx < nTotal)
        {
            nIdx = nIdx + RemoveProtections (GetSpellBreachProtection (nCnt), oTarget, nCnt);
            nCnt++;
        }
        effect eLink = EffectLinkEffects(eDur, eSR);
        //--------------------------------------------------------------------------
        // This can not be dispelled
        //--------------------------------------------------------------------------
        eLink = ExtraordinaryEffect (eLink);
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10));
    }
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, oTarget);
}

// Returns the modifier from the ability score based on this characters casting class.
int GetCasterAbilityModifier (object oCaster)
{
    int nAbility;
    if (GetLevelByClass (CLASS_TYPE_WIZARD, oCaster) > 0) nAbility = ABILITY_INTELLIGENCE;
    else if (GetLevelByClass (CLASS_TYPE_SORCERER, oCaster) > 0) nAbility = ABILITY_CHARISMA;
    else if (GetLevelByClass (CLASS_TYPE_CLERIC, oCaster) > 0) nAbility = ABILITY_WISDOM;
    else if (GetLevelByClass (CLASS_TYPE_BARD, oCaster) > 0) nAbility = ABILITY_INTELLIGENCE;
    else if (GetLevelByClass (CLASS_TYPE_DRUID, oCaster) > 0) nAbility = ABILITY_WISDOM;
    else if (GetLevelByClass (47/*CLASS_TYPE_FAVOREDSOUL*/, oCaster) > 0) nAbility = ABILITY_CHARISMA;
    else nAbility = ABILITY_CHARISMA;
    return GetAbilityModifier (nAbility, oCaster);
}

// Handle Dispelling Area of Effects
// Since NWN does not give the required information to do proper dispelling
// on AoEs, we do some simulated stuff here:
// - Base chance to dispel is 25, 50, 75 or 100% depending on the spell
// - Chance is modified positive by the caster level and ability scores.
// - Chance is modified negative by the highest spellcasting class level of the
//   AoE creator and the releavant ability score.
void DispelAoEEffect (object oTargetAoE, object oCaster, int nCasterLevel)
{
    object oCreator = GetAreaOfEffectCreator (oTargetAoE);
    int nChance;
    int nId = GetSpellId ();
    if (nId == SPELL_LESSER_DISPEL) nChance = 25;
    else if (nId == SPELL_DISPEL_MAGIC) nChance = 50;
    else if (nId == SPELL_GREATER_DISPELLING ) nChance = 75;
    else if (nId == SPELL_MORDENKAINENS_DISJUNCTION) nChance = 100;
    nChance += ((nCasterLevel + GetCasterAbilityModifier (oCaster)) -
                (10 + GetCasterAbilityModifier (oCreator)) * 2);
    // the AI does cheat here, because it can not react as well as a player to
    // AoE effects. Also DMs are always successful
    if (!GetIsPC (oCaster)) nChance += 30;
    if (oCaster == oCreator) nChance = 100;
    int nRand = Random (100);
    if ((nRand < nChance)|| GetIsDungeonMaster (oCaster))
    {
        FloatingTextStrRefOnCreature(100929,oCaster);  // "AoE dispelled"
        DestroyObject (oTargetAoE);
    }
    else FloatingTextStrRefOnCreature(100930,oCaster); // "AoE not dispelled"
}

// Removes temporary hit points so that they will not stack.
void RemoveTempHitPoints ()
{
    effect eProtection;
    int nCnt = 0;
    eProtection = GetFirstEffect (OBJECT_SELF);
    while (GetIsEffectValid (eProtection))
    {
      if (GetEffectType (eProtection) == EFFECT_TYPE_TEMPORARY_HITPOINTS)
          RemoveEffect (OBJECT_SELF, eProtection);
      eProtection = GetNextEffect (OBJECT_SELF);
    }
}

// Saves spells to autobuff for a caster.
void SaveSpellToAutoBuff (struct stSpell Spell)
{
    // Check to make sure this spell is being cast on an ally! i.e. Buff spell.
    if (GetIsFriend (Spell.oTarget, Spell.oCaster))
    {
        int nSpell, nDomain, nLevel = GetLastSpellLevel ();
        string sName = GetStringByStrRef (StringToInt (Get2DAString ("spells", "Name", Spell.iSpellID)));
        if (Spell.iMetaMagic > 0)
        {
            // We must add the level of the metamagic to the spells level to get the spells correct level.
            if (Spell.iMetaMagic == METAMAGIC_EMPOWER) { sName += " (Empowered)"; nLevel += 2; }
            else if (Spell.iMetaMagic == METAMAGIC_EXTEND) { sName += " (Extended)"; nLevel += 1; }
            else if (Spell.iMetaMagic == METAMAGIC_MAXIMIZE) { sName += " (Maximized)"; nLevel += 3; }
            else if (Spell.iMetaMagic == METAMAGIC_QUICKEN) { sName += " (Quickened)"; nLevel += 4; }
            else if (Spell.iMetaMagic == METAMAGIC_SILENT) { sName += " (Silent)"; nLevel += 1; }
            else if (Spell.iMetaMagic == METAMAGIC_STILL) { sName += " (Still)"; nLevel += 1; }
        }
        nDomain = NWNX_Object_GetLastSpellCastDomainLevel (Spell.oCaster);
        if (nDomain > 0)
        {
            sName += " (Domain)";
        }
        string sList = "list" + GetServerDatabaseString (Spell.oCaster, BUFF_TABLE, "spells", "list");
        json jSpells = GetServerDatabaseJson (Spell.oCaster, BUFF_TABLE, "spells", sList);
        json jSpell = JsonArray ();
        jSpell = JsonArrayInsert (jSpell, JsonInt (Spell.iSpellID));
        jSpell = JsonArrayInsert (jSpell, JsonInt (Spell.iClass));
        jSpell = JsonArrayInsert (jSpell, JsonInt (nLevel));
        jSpell = JsonArrayInsert (jSpell, JsonInt (Spell.iMetaMagic));
        jSpell = JsonArrayInsert (jSpell, JsonInt (nDomain));
        string sTargetName = StripColorCodes (GetName (Spell.oTarget));
        jSpell = JsonArrayInsert (jSpell, JsonString (sTargetName));
        jSpells = JsonArrayInsert (jSpells, jSpell);
        CheckServerDataAndInitialize (Spell.oCaster, BUFF_TABLE, sList);
        SetServerDatabaseJson (Spell.oCaster, BUFF_TABLE, "spells", jSpells, sList);
        SendMessages (sName + " has been saved for fast buffing on " + sTargetName + ".", COLOR_GREEN, Spell.oCaster);
        ExecuteScript ("0e_updatebuff", Spell.oCaster);
    }
}

// Will check and make sure the spell is memorized and/or ready.
// Returns TRUE if memorized and ready, FALSE if memorized but not ready,
// and -1 if not memorized for classes that memorize.
// nSpell is the spell to find.
// nClass that cast the spell.
// nLevel the level of the spell.
// nMetamagic is if it has metamagic on it.
// nDomain is if it is a domain spell.
int GetSpellReady (object oCaster, int nSpell, int nClass, int nLevel, int nMetamagic, int nDomain)
{
    int nIndex, nMaxIndex, nMSpell, nMmSpell, nDSpell;
    if (StringToInt (Get2DAString ("classes", "MemorizesSpells", nClass)))
    {
        nMaxIndex = GetMemorizedSpellCountByLevel (oCaster, nClass, nLevel);
        while (nIndex < nMaxIndex)
        {
            nMSpell = GetMemorizedSpellId (oCaster, nClass, nLevel, nIndex);
            if (nSpell == nMSpell)
            {
                nMmSpell = GetMemorizedSpellMetaMagic (oCaster, nClass, nLevel, nIndex);
                nDSpell = GetMemorizedSpellIsDomainSpell (oCaster, nClass, nLevel, nIndex);
                if (nMmSpell == nMetamagic &&
                   ((nDomain > 0 && nDSpell == TRUE) || nDomain == 0 && nDSpell == FALSE))
                {
                    return GetMemorizedSpellReady (oCaster, nClass, nLevel, nIndex);
                }
            }
            nIndex ++;
        }
        return -1;
    }
    else
    {
        if (NWNX_Creature_GetRemainingSpellSlots (oCaster, nClass, nLevel) > 0) return TRUE;
    }
    return FALSE;
}

int GetItemHasSpellImmunity (object oItem, int nSpell)
{
    if (oItem == OBJECT_INVALID) return FALSE;
    //Debug ("0i_spells", "2702", " oItem: " + GetName (oItem) + " Spell: " + IntToString (nSpell));
    itemproperty ipProp = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ipProp))
    {
        //Debug ("0i_spells", "2706", " IPCostTableValue: " + IntToString (GetItemPropertyCostTableValue (ipProp)));
            if (GetItemPropertyType (ipProp) == ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL)
            {
                int nIPCostTV = GetItemPropertyCostTableValue (ipProp);
                //Debug ("0i_spells", "2710", " IP_SpellCost SpellIndex: " + Get2DAString ("iprp_spellcost", "SpellIndex", nIPCostTV));
                if (nSpell == StringToInt (Get2DAString ("iprp_spellcost", "SpellIndex", nIPCostTV))) return TRUE;
            }
        ipProp = GetNextItemProperty (oItem);
    }
    return FALSE;
}

int GetCreatureHasAnItemSpellImmunity (object oTarget, int nSpell)
{
    if (GetItemHasSpellImmunity (GetItemInSlot (INVENTORY_SLOT_CARMOUR, oTarget), nSpell)) return TRUE;
    if (GetItemHasSpellImmunity (GetItemInSlot (INVENTORY_SLOT_HEAD, oTarget), nSpell)) return TRUE;
    if (GetItemHasSpellImmunity (GetItemInSlot (INVENTORY_SLOT_NECK, oTarget), nSpell)) return TRUE;
    return FALSE;
}

// Returns TRUE if oTarget is immune to nSpells effects, uses Spells.2da ImmunityType.
int TargetImmuneToEffect (int nSpell, object oTarget)
{
    string sIType = Get2DAString ("spells", "ImmunityType", nSpell);
    if (sIType != "" && sIType != "Nosave")
    {
        //Debug ("0i_spells", "2732", "Checking spell immunity type (" + sIType + ").");
        if (sIType == "Death" && GetIsImmune (oTarget, IMMUNITY_TYPE_DEATH)) return TRUE;
        if (sIType == "Negative_level" && GetIsImmune (oTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL)) return TRUE;
        if (sIType == "Poison" && GetIsImmune (oTarget, IMMUNITY_TYPE_POISON)) return TRUE;
        if (sIType == "Disease" && GetIsImmune (oTarget, IMMUNITY_TYPE_DISEASE)) return TRUE;
        if (sIType == "Fear" && GetIsImmune (oTarget, IMMUNITY_TYPE_FEAR)) return TRUE;
        if (sIType == "Curse" && GetIsImmune (oTarget, IMMUNITY_TYPE_CURSED)) return TRUE;
        if (sIType == "Mind_Affecting" && GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS)) return TRUE;
        if (sIType == "Sleep" &&
           (GetIsImmune (oTarget, IMMUNITY_TYPE_SLEEP) ||
            GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if (sIType == "Paralysis" &&
           (GetIsImmune (oTarget, IMMUNITY_TYPE_PARALYSIS) ||
            GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if (sIType == "Domination" &&
           (GetIsImmune (oTarget, IMMUNITY_TYPE_DOMINATE) ||
            GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if (sIType == "Confusion" &&
           (GetIsImmune (oTarget, IMMUNITY_TYPE_CONFUSED) ||
            GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if (sIType == "Blindness" &&
           (GetIsImmune (oTarget, IMMUNITY_TYPE_BLINDNESS) ||
            GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if (sIType == "Dazed" &&
           (GetIsImmune (oTarget, IMMUNITY_TYPE_DAZED) ||
            GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if (sIType == "Charm" &&
           (GetIsImmune (oTarget, IMMUNITY_TYPE_CHARM) ||
            GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        // Check for damage immunities.
        // Negative damage does not work on undead!
        if (sIType == "Negative" && GetRacialType (oTarget) == RACIAL_TYPE_UNDEAD)
        {
            //Debug ("0i_spell", "2765", "Undead are immune to Negative energy!");
            return TRUE;
        }
        // Elemental damage resistances should be checked.
        if (sIType == "Acid" || sIType == "Cold"  || sIType == "Fire" ||
            sIType == "Electricty" || sIType == "Sonic")
        {
            if (GetHasEffect (EFFECT_TYPE_DAMAGE_RESISTANCE, oTarget))
            {
                //Debug ("0i_spell", "2776", "Target is resistant to my energy spell!");
                return TRUE;
            }
        }
    }
    // Now do they have item property immunity.
    if (nSpell == SPELL_WEB)
    {
        //Debug ("0i_spell", "2783", "Checking if the target is immune to Web.");
        if (GetCreatureHasAnItemSpellImmunity (oTarget, SPELL_WEB))
        {
            //Debug ("0i_spell", "2785", "Target is immune to Web via an item.");
            return TRUE;
        }
    }
    // Globe spells should be checked...
    if ((GetHasSpellEffect (SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oTarget) ||
        GetHasSpellEffect (SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, oTarget)) &&
        StringToInt (Get2DAString ("spells", "Innate", nSpell)) < 4) if (d100() < 75) return TRUE;
    if (GetHasSpellEffect (SPELL_GLOBE_OF_INVULNERABILITY, oTarget) &&
        StringToInt (Get2DAString ("spells", "Innate", nSpell)) < 5) if (d100() < 75) return TRUE;
    //Debug ("0i_spell", "2799", "Target is not immune to the spell.");
    return FALSE;
}

// Returns the range from the spells.2da (Column Range) for nSpell.
// S = 8.0f, M = 20.0f, L = 40.0f, T = 5.0f, else = 0.1f;
float GetSpellRange (int nSpell)
{
    string sRange = Get2DAString ("spells", "Range", nSpell);
    if (sRange == "S") return SHORT_DISTANCE;
    else if (sRange == "M") return MEDIUM_DISTANCE;
    else if (sRange == "L") return LONG_DISTANCE;
    else if (sRange == "T") return RANGE_MELEE;
    return 0.1;
}

// Returns TRUE if the target has a disabling spell cast from oCaster.
// FALSE if not.
int TargetHasDispelableEffect (object oTarget, object oCaster = OBJECT_SELF)
{
    int bSpell;
    // Cycle through the targets effects.
    effect eEffect = GetFirstEffect (oTarget);
    while (GetIsEffectValid (eEffect))
    {
        int nEffectID = GetEffectSpellId (eEffect);
        // If the effects originated from me (i.e., I cast
        // a disabling effect on you. Then I will not dispel that effect.
        if (GetEffectCreator (eEffect) == oCaster) return FALSE;
        else
        // This effect was applied from a spell if it isn't -1
        // Dispel magic should only attempt to remove spell granted effects.
        if (nEffectID == -1) { /*Do nothing since this was not a spell.*/ }
        else bSpell = TRUE;
        eEffect = GetNextEffect(oTarget);
    }
    return bSpell;
}

// Returns TRUE if persistant Area Of Effect spell will overlap an already
// existing AOE Spell of the same. FALSE if not.
// lTargetLocation is the location the new AOE spell will target.
// nAOESpellVFX is the AOE_* for the vfx_persistant.2da list.
int AOESpellOverlaps (location lTargetLocation, int nAOESpellVFX)
{
    int nCnt = 1;
    string sTag = Get2DAString ("vfx_persistent", "LABEL", nAOESpellVFX);
    float fRadius = StringToFloat (Get2DAString ("vfx_persistent", "RADIUS", nAOESpellVFX));
    object oAOE = GetNearestObjectToLocation (OBJECT_TYPE_AREA_OF_EFFECT, lTargetLocation);
    while (oAOE != OBJECT_INVALID)
    {
        if (GetTag (oAOE) == sTag)
        {
            if (GetDistanceBetweenLocations (lTargetLocation, GetLocation (oAOE)) <= fRadius)
            {
                return TRUE;
            }
        }
        oAOE = GetNearestObjectToLocation (OBJECT_TYPE_AREA_OF_EFFECT, lTargetLocation, ++nCnt);
    }
    return FALSE;
}
int GetTotalUndeadControlledHitDice(object oCaster)
{
    int nClassLevel = GetLevelByClass(CLASS_TYPE_CLERIC, oCaster);
    int nPaladinLevel = GetLevelByClass(CLASS_TYPE_PALADIN, oCaster);
    int nBlackguardlevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD, oCaster);
    nClassLevel += GetLevelByClass(CLASS_TYPE_PALE_MASTER, oCaster);
    if((nBlackguardlevel - 2) > 0 && (nBlackguardlevel > nPaladinLevel))
    {
        nClassLevel += (nBlackguardlevel - 2);
    }
    else if((nPaladinLevel - 2) > 0)
    {
        nClassLevel += (nPaladinLevel - 2);
    }
    return nClassLevel;
}
int IncreaseUndeadControlledHitDice(object oCaster, object oCreature, string sSpellTag, int nTotalHD)
{
    // Good characters can not control undead.
    if(GetAlignmentGoodEvil(oCaster) == ALIGNMENT_GOOD) return FALSE;
    // A character can only control up to their Level in Hitdice.
    int nTotalHDControlled = GetLocalInt(oCaster, sSpellTag);
    int nCreatureHD = GetHitDice(oCreature);
    object oMaster = GetPlayerMaster(oCaster);
    string sText;
    if(nCreatureHD > nTotalHD - nTotalHDControlled)
    {
        if(oMaster != OBJECT_INVALID)
        {
            if(oMaster == oCaster) sText = "You";
            else sText = GetName(oCaster);
            SendMessageToPC(oMaster, sText + " cannot control " + GetName(oCreature) + " with " + IntToString(nCreatureHD) +
                " Hit Dice from a total of " + IntToString(nTotalHD - nTotalHDControlled) + " Hit Dice left to control.");
        }
        return FALSE;
    }
    SetLocalInt(oCaster, sSpellTag, nTotalHDControlled + nCreatureHD);
    if(oMaster != OBJECT_INVALID)
    {
        if(oMaster == oCaster) sText = "You are";
        else sText = GetName(oCaster) + " is";
        SendMessageToPC(oMaster, sText + " now in control of " + GetName(oCreature) + " with " + IntToString(nCreatureHD) +
            " Hit Dice from a total of " + IntToString(nTotalHD - nTotalHDControlled - nCreatureHD) + " Hit Dice left to control.");
    }
    return TRUE;
}

void DecreaseUndeadControlledHitDice(object oCaster, object oCreature, string sSpellTag)
{
    // A character can only control up to their Level in Hitdice.
    int nTotalHDControlled = GetLocalInt(oCaster, sSpellTag);
    int nCreatureHD = GetHitDice(oCreature);
    SetLocalInt(oCaster, sSpellTag, nTotalHDControlled - nCreatureHD);
    SendMessageToPC(oCaster, sSpellTag + ": nTotalHDControlled: " + IntToString(nTotalHDControlled - nCreatureHD));
}

/* Copy to a new spell to setup the paramaters of the spell.
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.iDescriptor = DESC_FIRE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.sEnhancingComp = "";
    Spell.iCompAmount = 250;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.fAreaSize = 10.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 6;
    Spell.iDurDicePerLvl = 0;
    Spell.iMaxDurNumOfDice = 0;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 0;
    Spell.iMaxDuration = 0;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 5;
    Spell.iModifier = 0;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 0;
    Spell.iImpact = VFX_IMP_FLAME_S;
    Spell.iBeam = VFX_BEAM_FIRE;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
*/
