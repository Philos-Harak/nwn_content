/*////////////////////////////////////////////////
 Script: 0s_liveoak
 Programmer: Philos
////////////////////////////////////////////////
Transmutation
Level: Druid 6
Components: V, S
Casting Time: 1 action
Range: Short
Target: One Tree
Duration: 24 hours
Saving Throw: None
Spell Resistance: No

This spell turns an oak tree into a protector or guardian. The spell can be cast
on only a single tree at a time; while liveoak is in effect, you can’t cast it
again on another tree. This spell only works in a natural area above ground.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    object oArea = GetArea (Spell.oCaster);
    if (GetIsAreaAboveGround (oArea) && GetIsAreaNatural (oArea))
    {
        object oCreature = GetAssociateWithResRef (Spell.oCaster, "0_s_treant");
        if (!GetIsObjectValid (oCreature))
        {
            effect eImpact = EffectVisualEffect (VFX_FNF_NATURES_BALANCE);
            oCreature = CreateObject (OBJECT_TYPE_CREATURE, "0_s_treant", Spell.lTarget);
            ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact, Spell.lTarget);
            AddHenchman (Spell.oCaster, oCreature);
            // Must mark them as a summoned creature.
            SetLocalInt (oCreature, "0_Summon_ID", Spell.iSpellID);
        }
        else SendMessages ("You already have a treant under your power!", COLOR_RED, Spell.oCaster);
    }
    else SendMessages ("There are no trees near by!", COLOR_RED, Spell.oCaster);
    CleanUpSpell (Spell);
}


