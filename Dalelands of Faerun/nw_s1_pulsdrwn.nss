/*//////////////////////////////////////////////////////////////////////////////
 Script Name: NW_S1_plsdrwn
 Programmer: Preston Watmaniuk
////////////////////////////////////////////////////////////////////////////////
This has become Vortex blast a modified version from the Monster Manual 3.5.
Exception: They do not need to be in water to perform this ability, and it will
 always do damage.

Vortex Blast (Su):
Descriptor(s): Water
Range: Caster
Area of Effect / Target: Large (16')
Duration: Instant
Save: Reflex 1/2
Spell Resistance: No

Blast a vortex of water and debris for 16 feet, centered on the caster.
Any creature within the blast must make a reflex save to take half damage.
The save difficulty and number of dice is based on your size.
 Small   DC 10 Dmg 1d6
 Medium  DC 15 Dmg 3d6
 Large   DC 20 Dmg 4d6
 Huge    DC 25 Dmg 10d6
 Greater DC 30 Dmg 15d6
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_creature"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_SUPERNATURAL;
    Spell.iDescriptor = DESC_WATER;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 16.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL_BUT_CASTER;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = FALSE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iDamageType = DAMAGE_TYPE_BLUDGEONING;
    // Get spell damage based on the size of the elemental.
    string sSize = GetLocalString (OBJECT_SELF, "0_Vortex_Size");
    if (sSize == "small") { Spell.iModNumOfDice = 1; Spell.iSaveDC = 10; }
    else if (sSize == "medium") { Spell.iModNumOfDice = 3; Spell.iSaveDC = 15; }
    else if (sSize == "large") { Spell.iModNumOfDice = 6; Spell.iSaveDC = 20; }
    else if (sSize == "huge") { Spell.iModNumOfDice = 10; Spell.iSaveDC = 25; }
    else if (sSize == "greater") { Spell.iModNumOfDice = 15; Spell.iSaveDC = 30; }
    Spell.iModifierDie = 6;
    Spell.iImpact = VFX_IMP_FROST_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    effect eDmg;
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_IMP_PULSE_WATER);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    // Set Cooldown timer to give the special ability after 2 minutes.
    DelayCommand (120.0f, NWNX_Creature_RestoreSpecialAbilities (Spell.oCaster));
    CleanUpSpell (Spell);
}
