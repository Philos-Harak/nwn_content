/*////////////////////////////////////////////////
 Script: NW_S0_Sanctuary.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Clr 1, Protection 1
Components: V, S, DF
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   1 round/level
Saving Throw:   Will negates
Spell Resistance:   No

Any opponent attempting to strike or otherwise directly attack the warded creature,
even with a targeted spell, must attempt a Will save. If the save succeeds, the
opponent can attack normally and is unaffected by that casting of the spell.
If the save fails, the opponent can't follow through with the attack, that part
of its action is lost, and it can't directly attack the warded creature for the
duration of the spell. Those not attempting to attack the subject remain unaffected.
This spell does not prevent the warded creature from being attacked or affected
by area or effect spells. The subject cannot attack without breaking the spell
but may use nonattack spells or otherwise act.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the Spell DC.
    Spell = GetSaveDC (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eSanc = EffectSanctuary (Spell.iSaveDC);
    effect eLink = EffectLinkEffects(eSanc, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
   //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

