/*////////////////////////////////////////////////
 Script: NW_S0_MordSwrd.nss
 Programmer: Philos
////////////////////////////////////////////////
Evocation [Force]
Level:  Sor/Wiz 7
Components: V, S, F
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Effect: One sword
Duration:   1 round/level (D)
Saving Throw:   None
Spell Resistance:   Yes

This spell brings into being a shimmering sword. The sword strikes at any opponent
within its range. The sword attacks its designated target once each round.
Its attack bonus is equal to your caster level + your Int bonus or
your Cha bonus (for wizards or sorcerers, respectively) with an additional +3
enhancement bonus (maximum of +20). It deals 4d6+3 points of force damage, with a threat
range of 19-20 and a critical multiplier of x2.

The sword cannot be harmed by physical attacks, but magical attacks can affect it.

Focus: A tiny platinum sword with a grip and pommel of copper and zinc.
It costs 250 gp to construct.
/*////////////////////////////////////////////////
#include "0i_spells"
//Creates the weapon that the creature will be using.
void MordenkainenSummoned (struct stSpell Spell, object oSummon)
{
    //Declare major variables
    int iAttack, iClass, iAbility;
    string sAbility;
    object oWeapon;
    // Get the attack bonus.
    iClass = GetLastSpellCastClass ();
    sAbility = Get2DAString ("classes", "SpellcastingAbli", iClass);
    if (sAbility == "INT") iAbility = ABILITY_INTELLIGENCE;
    else if (sAbility == "WIS") iAbility = ABILITY_WISDOM;
    else if (sAbility == "CHA") iAbility = ABILITY_CHARISMA;
    // +2 is the enhancment bonus minus the creatures base attack of 1.
    iAttack = Spell.iCasterLevel + (GetAbilityModifier (iAbility, Spell.oCaster) / 2) + 2;
    // Just in case...
    if (iAttack > 19) iAttack = 19;
    else if (iAttack < 1) iAttack = 1;
    if (GetIsObjectValid(oSummon))
    {
        //Create item on the creature, equip it and add properties.
        oWeapon = CreateItemOnObject ("0_morden_sword", oSummon);
        SetDroppableFlag (oWeapon,FALSE);
        AssignCommand (oSummon, ActionEquipItem (oWeapon, INVENTORY_SLOT_RIGHTHAND));
        // Add attack bonus.
        if (iAttack > 0) AddItemProperty (DURATION_TYPE_TEMPORARY, ItemPropertyAttackBonus (iAttack), oWeapon, Spell.fDuration);
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
    Spell.sArcaneComponent = "0_t_plat_sword";
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    object oSummon;
    effect eCenter = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3);
    effect eSummons = EffectRunScript("", "0e_removesummons");
    //Apply the VFX impact and summon effect
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eCenter, Spell.lTarget);
    oSummon = CreateObject(OBJECT_TYPE_CREATURE, "0_mordenkainen", Spell.lTarget);
    SetLocalInt(oSummon, "0_Summon_ID", Spell.iSpellID);
    // Fix the base attack to 1 so it only gets 1 attack and we add the attack bonus to the sword.
    NWNX_Creature_SetBaseAttackBonus(oSummon, 1);
    // If cast from a placeable (trap) lets just make them hostile!
    if (GetObjectType (Spell.oCaster) == OBJECT_TYPE_PLACEABLE) ChangeToStandardFaction(oSummon, STANDARD_FACTION_HOSTILE);
    // Add so he follows the caster.
    else AddHenchman(Spell.oCaster, oSummon);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSummons, oSummon, Spell.fDuration);
    DelayCommand(1.0, MordenkainenSummoned (Spell, oSummon));
    CleanUpSpell(Spell);
}

