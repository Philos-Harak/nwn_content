/*////////////////////////////////////////////////
 Script: NW_S0_MetSwarm
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Fire]
Level:  Sor/Wiz 9
Components: V, S
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area:   Four 40-ft.-radius spreads; see text
Duration:   Instantaneous
Saving Throw:   None or Reflex half; see text
Spell Resistance:   Yes

Meteor swarm is a very powerful and spectacular spell that is similar to fireball
in many aspects. When you cast it, meteors come from the sky striking the ground.

Four meteors attempt a ranged touch attack against the closest creatures to the
center of the 50' area meteor swarm. Any creature struck by one of these meteors takes
2d6 points of bludgeoning damage (no save) and receives no saving throw against
the fire damage as well(see below). If a targeted sphere misses its target, it
simply explodes near the creature.

Once a sphere reaches its destination, it explodes in a 40-foot-radius spread,
dealing 6d6 points of fire damage to each creature in the area. If a creature is
within the area of more than one sphere, it must save separately against each.
(Fire resistance applies to each sphere’s damage individually.)
/*//////////////////////////////////////////////
#include "0i_spells"

void MeteorHit (struct stSpell Spell)
{
    int iBludgeonDmg, iHit;
    float fDelay;
    object oTarget;
    location lMeteor;
    effect eDmg;
    effect eMeteorCenter = EffectVisualEffect (VFX_FNF_FIREBALL);
    // Make a touch attack to hit.
    iHit = TouchAttackRanged (Spell.oAreaTarget);
    if (iHit)
    {
        // Do Bludgeoning Damage 2d6.
        iBludgeonDmg = d6 (2);
        eDmg = EffectDamage (iBludgeonDmg, DAMAGE_TYPE_BLUDGEONING);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget);
    }
    // Check the new 40' blast area!
    lMeteor = GetLocation (Spell.oAreaTarget);
    // Apply visual effect for each meteor hit.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eMeteorCenter, lMeteor);
    oTarget = GetFirstObjectInShape (SHAPE_SPHERE, 12.0f, lMeteor, TRUE);
    while (GetIsObjectValid (oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make a evasion check if the target does not get a save.
        if (oTarget == Spell.oAreaTarget && iHit) Spell.iResult = GetReflexAdjustedDamage (Spell.iResult, oTarget, 100, SAVING_THROW_TYPE_DIVINE);
        // else give them a save for half.
        else Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            // Set the damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            fDelay = GetDistanceBetweenLocations (lMeteor, GetLocation (oTarget)) / 20;
            // Apply effect.
            DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget));
        }
        oTarget = GetNextObjectInShape (SHAPE_SPHERE, 12.0f, lMeteor, TRUE);
    }
}

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 50.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 6;
    Spell.iModifierDie = 6;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    int iMeteors = 4;
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_METEOR_SWARM);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget) && iMeteors > 0)
    {
        // We wouldn't hit dead creatures with a meteor!
        if (!GetIsDead (Spell.oAreaTarget))
        {
            iMeteors --;
            DelayCommand (Spell.fDelay, MeteorHit (Spell));
            //Get the spells target(s).
            Spell = GetSpellTarget (Spell);
        }
    }
    CleanUpSpell (Spell);
}
