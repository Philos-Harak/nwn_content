/*////////////////////////////////////////////////
 Script: NW_S0_ShapeChg.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Level:  Animal 9, Drd 9, Sor/Wiz 9
Components: V, S, F
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   10 min./level (D)
This spell functions like polymorph, except that it enables you to assume the
form of any single nonunique creature (of any type) from Fine to Colossal size.
The assumed form cannot have more than your caster level in Hit Dice
(to a maximum of 25 HD). Unlike polymorph, this spell allows incorporeal or
gaseous forms to be assumed.

You gain all extraordinary and supernatural abilities (both attacks and qualities)
of the assumed form, but you lose your own supernatural abilities. You also gain
the type of the new form in place of your own. The new form does not disorient
you. Parts of your body or pieces of equipment that are separated from you do
not revert to their original forms.

You can become just about anything you are familiar with. You can change form
once each round as a free action. The change takes place either immediately
before your regular action or immediately after it, but not during the action.
If you use this spell to create a disguise, you get a +10 bonus on your Disguise
check.

Focus: A jade circlet worth no less than 1,500 gp, which you must place on your
head when casting the spell. (The focus melds into your new form when you change shape.)
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    //Spell.sArcaneComponent = "0_jade_circlet";
    Spell.sEnhancingComp = "sarbossa_dust";
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
    if(Spell.sEnhancingComp == "TRUE") Spell.fDuration *= 1.5;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect ePolymorph;
    int iPolymorph;
    //Determine Polymorph subradial type
    if(Spell.iSpellID == 392) iPolymorph = POLYMORPH_TYPE_RED_DRAGON;
    else if (Spell.iSpellID == 393) iPolymorph = POLYMORPH_TYPE_FIRE_GIANT;
    else if (Spell.iSpellID == 394) iPolymorph = POLYMORPH_TYPE_BALOR;
    else if (Spell.iSpellID == 395) iPolymorph = POLYMORPH_TYPE_DEATH_SLAAD;
    else if (Spell.iSpellID == 396) iPolymorph = POLYMORPH_TYPE_IRON_GOLEM;
    ePolymorph = EffectPolymorph (iPolymorph);
    ePolymorph = SetEffectCasterLevel(ePolymorph, Spell.iCasterLevel);
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
