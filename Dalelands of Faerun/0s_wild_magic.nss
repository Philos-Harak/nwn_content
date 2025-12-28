/*////////////////////////////////////////////////
 Script: 0s_wild_magic
 Programmer: Philos
////////////////////////////////////////////////
Transmutation
Level: Innate 1
Components: Verbal
Casting Time: 1 standard action
Range:  Personal
Effect: Current area
Duration: 1 Min / Level
Saving Throw: None
Spell Resistance: No

Opens up a Wild magic vortex in the current area.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_CHAOTIC;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
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
    // Check to make sure they have the correct god to Cast this spell.
    int nDeity, bHasDomain;
    if(GetIsCharacter(Spell.oCaster))
    {
        nDeity = GetObjectDatabaseInt (Spell.oCaster, CHARACTER_TABLE, "deity");
        bHasDomain = StringToInt (Get2DAString ("deities", "Chaos_Domain", nDeity));
    }
    else bHasDomain = TRUE;
    if (bHasDomain)
    {
        effect eCenter = EffectVisualEffect (VFX_FNF_DISPEL_DISJUNCTION);
        effect eCenter2 = EffectVisualEffect (VFX_FNF_MYSTICAL_EXPLOSION);
        // Apply center vfx effect.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, GetLocation (Spell.oCaster));
        DelayCommand (2.0f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter2, GetLocation (Spell.oCaster)));
        object oArea = GetArea (Spell.oCaster);
        SetLocalInt (oArea, "0_Spell_State", 2);
        DelayCommand (Spell.fDuration, SetLocalInt (oArea, "0_Spell_State", 0));
    }
    else SendMessages ("Your god does not have Choas as a domain. The spell fizzles out!", COLOR_RED, Spell.oCaster);
}




