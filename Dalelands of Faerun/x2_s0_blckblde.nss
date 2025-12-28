/*////////////////////////////////////////////////
 Script: X2_S0_BlckBlde
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 9
Innate Level: 9
School: Conjuration
Descriptor(s): Summoned Item
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Point
Duration: Concentration, 1 Round / Level
Additional Counter Spells:
Save: None
Spell Resistance: No

The caster creates a black blade shaped planar rift, resembling a greatsword
which fights at her side. The blade cannot be harmed by physical attacks, but
it can be affected by dispel magic or similar effects. For the purpose of
bypassing damage reduction, the sword has an enhancement bonus equal to your
Intelligence bonus or your Charisma bonus (for wizards and sorcerers respectively)
to a maximum of +20. The spell requires the caster to concentrate on it -
casting spells or performing any other action than walking or talking may result
in a concentration failure and end the spell.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

//Creates the weapon that the creature will be using.
void spellsCreateItemForSummoned()
{
    //Declare major variables
    int nStat;

    // cast from scroll, we just assume +5 ability modifier
    if (GetSpellCastItem() != OBJECT_INVALID)
    {
        nStat = 5;
    }
     else
    {
        int nClass = GetLastSpellCastClass();
        int nLevel = GetLevelByClass(nClass);

        int nStat;

        int nCha =  GetAbilityModifier(ABILITY_CHARISMA,OBJECT_SELF);
        int nInt =  GetAbilityModifier(ABILITY_INTELLIGENCE,OBJECT_SELF);

        if (nClass == CLASS_TYPE_WIZARD)
        {
            nStat = nInt;
        }
        else
        {
            nStat = nCha;
        }

        if (nStat >20)
        {
            nStat =20;
        }

        if (nStat <1)
        {
           nStat = 0;
        }
    }

    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
    // Make the blade require concentration
    SetLocalInt(oSummon,"X2_L_CREATURE_NEEDS_CONCENTRATION",TRUE);
    SetPlotFlag (oSummon,TRUE);
    object oWeapon;
    //Create item on the creature, epuip it and add properties.
    oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oSummon);
    if (nStat > 0)
    {
        IPSetWeaponEnhancementBonus(oWeapon, nStat);
    }
    SetDroppableFlag(oWeapon, FALSE);
}

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eSummon = EffectSummonCreature ("x2_s_bblade", VFX_FNF_SUMMON_MONSTER_3);
    AdjustCurrentSummonedCreatures (Spell.oCaster, Spell.iSpellID);
    ApplyEffectAtLocation (Spell.iDurationType, eSummon, Spell.lTarget, Spell.fDuration);
    MarkSummonedCreatures (Spell.oCaster, Spell.iSpellID);
    DelayCommand (1.5, spellsCreateItemForSummoned ());
    CleanUpSpell (Spell);
}
