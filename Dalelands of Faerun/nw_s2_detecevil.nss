/*////////////////////////////////////////////////
 Script: nw_s2_detecevil
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Divination
Level:  Clr 1
Components: V, S, DF
Casting Time:   1 standard action
Range:  60 ft.
Area: Sphere
Duration: 10 min.
Saving Throw:   None
Spell Resistance:   No

You can sense the presence of evil. Any evil creatures within 60' will glow
with a dim light.
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
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effect.
    if (!GetHasSpellEffect (Spell.iSpellID, Spell.oCaster))
    {
        effect eVis = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
        effect eIcon = EffectIcon (130/*EFFECT_ICON_DETECTING_EVIL*/);
        effect eAOE = EffectAreaOfEffect (48); /* VFX_DETECT_EVIL */
        //Fire cast spell at event for the specified target.
        SignalEvent (Spell.oCaster, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Create visual effect.
        ApplyEffectToObject (Spell.iDurationType, eVis, Spell.oCaster, Spell.fDuration);
        ApplyEffectToObject (Spell.iDurationType, eIcon, Spell.oCaster, Spell.fDuration);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectToObject (Spell.iDurationType, eAOE, Spell.oCaster, Spell.fDuration);
    }
    else SendMessages ("Detect Evil is still active!", COLOR_RED, Spell.oCaster);
    CleanUpSpell (Spell);
}

