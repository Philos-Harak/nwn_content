/*////////////////////////////////////////////////
 Script: NW_S0_PolySelf
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Level:Ranger 4,     Sor/Wiz 4
Components: V, S, M
Casting Time:   1 standard action
Range:Personal
Target:Caster
Duration:   0 minutes / level
Saving Throw:   None
Spell Resistance:   No

The caster is able to turn himself into one of the following forms:
Giant spider
Troll
Umber hulk
Pixie
Zombie
This spell functions like alter self, except that you change into another form
of living creature. The new form may be of the same type as the subject or any
of the following types: aberration, animal, dragon, fey, giant, humanoid,
magical beast, monstrous humanoid, ooze, plant, or vermin. The assumed form can’t
have more Hit Dice than your caster level (or the subject’s HD, whichever is
lower), to a maximum of 15 HD at 15th level. You can’t cause a subject to
assume a form smaller than Fine, nor can you cause a subject to assume an
incorporeal or gaseous form. The subject’s creature type and subtype (if any)
change to match the new form.

Upon changing, the subject regains lost hit points as if it had rested for a
night (though this healing does not restore temporary ability damage and provide
other benefits of resting; and changing back does not heal the subject further).
If slain, the subject reverts to its original form, though it remains dead.

The subject gains the Strength, Dexterity, and Constitution scores of the new
form but retains its own Intelligence, Wisdom, and Charisma scores. It also
gains all extraordinary special attacks possessed by the form but does not gain
the extraordinary special qualities possessed by the new form or any supernatural
or spell-like abilities.

Material Component: An empty cocoon.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iImpact = VFX_IMP_POLYMORPH;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Check for Sorcerer Abberation Blood line II, if has it then extend the spell.
    if (GetHasFeat (1311, Spell.oCaster)) Spell.fDuration = Spell.fDuration * 2.0f;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect ePolymorph;
    int iPolymorph;
    //Determine Polymorph subradial type
    if(Spell.iSpellID == 387) iPolymorph = POLYMORPH_TYPE_GIANT_SPIDER;
    else if (Spell.iSpellID == 388) iPolymorph = POLYMORPH_TYPE_TROLL;
    else if (Spell.iSpellID == 389) iPolymorph = POLYMORPH_TYPE_UMBER_HULK;
    else if (Spell.iSpellID == 390) iPolymorph = POLYMORPH_TYPE_PIXIE;
    else if (Spell.iSpellID == 391) iPolymorph = POLYMORPH_TYPE_ZOMBIE;
    ePolymorph = EffectPolymorph (iPolymorph);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event to fire.
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Clear actions to Prevent an exploit.
        AssignCommand (Spell.oAreaTarget, ClearAllActions ());
        //Apply the VFX impact and effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        // prevents an exploit.
        DelayCommand (Spell.fDelay + 0.04f, AssignCommand (Spell.oAreaTarget, ClearAllActions ()));
        DelayCommand (Spell.fDelay + 0.05f, ApplyEffectToObject (Spell.iDurationType, ePolymorph, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

