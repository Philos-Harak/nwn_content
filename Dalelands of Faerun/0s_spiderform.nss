/*////////////////////////////////////////////////
 Script: 0s_spiderform
 Programmer: Philos
////////////////////////////////////////////////
Transmutation
Level: Drow 5
Components: V, S, DF
Casting Time: 1 standard action
Range: Personal
Target: Caster
Duration: 1 hour / level
Saving Throw: None
Spell Resistance: No

The caster is able to turn himself into either a drider, or large monstrous spider.
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

Forms in the Polymorph.2da (62 Drider, 3 Large Spider)
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
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
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
    int iPolymorph;
    string sArray;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect ePolymorph;
    sArray = GetObjectDatabaseString (Spell.oCaster, CHARACTER_TABLE, "polymorph");
    iPolymorph = StringToInt (GetStringArray (sArray, 2));
    if (iPolymorph == 0) iPolymorph == 3;
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

