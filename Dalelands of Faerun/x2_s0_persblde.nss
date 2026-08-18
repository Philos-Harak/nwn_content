/*////////////////////////////////////////////////
 Script: X2_S0_PersBlde
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 1
Innate Level: 1
School: Conjuration
Component(s): Verbal, Somatic, Arcane Focus
Range: Short
Area of Effect / Target: Point
Duration: 1 Minute / 2 Levels
Save: None
Spell Resistance: No

The caster summons a dagger that acts as a faithful and loyal servant.

Focus: A silvered dagger.
/*///////////////////////////////////////////////
#include "0i_spells"
//Creates the weapon that the creature will be using.
void spellsCreateItemForSummoned(object oCaster, float fDuration)
{
    int iStat = GetAbilityModifier (ABILITY_INTELLIGENCE, oCaster) / 2;
    if (iStat > 20) iStat = 20;
    else if (iStat < 1) iStat = 1;
    object oSummon = GetAssociate (ASSOCIATE_TYPE_SUMMONED);
    object oWeapon;
    if (GetIsObjectValid(oSummon))
    {
        //Create item on the creature, epuip it and add properties.
        oWeapon = CreateItemOnObject ("NW_WSWDG001", oSummon);
        // GZ: Fix for weapon being dropped when killed
        SetDroppableFlag (oWeapon,FALSE);
        AssignCommand (oSummon, ActionEquipItem (oWeapon, INVENTORY_SLOT_RIGHTHAND));
        // GZ: Check to prevent invalid item properties from being applies
        if (iStat > 0) AddItemProperty (DURATION_TYPE_TEMPORARY, ItemPropertyAttackBonus (iStat), oWeapon, fDuration);
        AddItemProperty (DURATION_TYPE_TEMPORARY, ItemPropertyDamageReduction (IP_CONST_DAMAGEREDUCTION_1, 5), oWeapon, fDuration);
    }
}

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 2;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eSummon = EffectSummonCreature ("X2_S_FAERIE001", VFX_FNF_SUMMON_MONSTER_1);
    eSummon = SetEffectCasterLevel(eSummon, Spell.iCasterLevel);
    AdjustCurrentSummonedCreatures (Spell.oCaster, Spell.iSpellID);
    ApplyEffectAtLocation (DURATION_TYPE_TEMPORARY, eSummon, Spell.lTarget, Spell.fDuration);
    DelayCommand(0.1, MarkSummonedCreatures (Spell.oCaster, Spell.iSpellID));
    DelayCommand(1.0, spellsCreateItemForSummoned (Spell.oCaster, Spell.fDuration));
    CleanUpSpell (Spell);
}

