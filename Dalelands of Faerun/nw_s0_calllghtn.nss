/*////////////////////////////////////////////////
 Script Name: NW_S0_CallLghtn
 Created By: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Druid 3
Innate Level: 3
School: Evocation
Descriptor(s): Electricity
Component(s): Verbal, Somatic
Range: Long
Area of Effect / Target: Large
Duration: 1 Min / Level
Save: Reflex 1/2
Spell Resistance: Yes

Immediately upon completion of the spell, and once per round thereafter,
a 5-foot-wide, 30-foot-long, vertical bolt of lightning that deals 3d6 points of
electricity damage. The bolt of lightning flashes down in a vertical stroke at a
random target within the spell’s range (measured from your position at the time).
You need not call a bolt of lightning as they will strike once per round for a
total number of times equal to your caster level (maximum 10 bolts).

If you are outdoors and in a stormy area or a rain shower, each bolt deals 3d10
points of electricity damage instead of 3d6.
This spell also works indoors or underground.
/*///////////////////////////////////////////////
#include "0i_spells"

// Fires a bolt at a random nearby enemy.
// Spell is the spell called to fire the bolt.
// iBolt is the number of bolts left to fire off, will decrement for each use.
void FireBolt (struct stSpell Spell, int iBolt);

void FireBolt (struct stSpell Spell, int iBolt)
{
    // Check to see if the spell is still active via the effect.
    if (!GetHasSpellEffect (Spell.iSpellID, Spell.oCaster)) return;
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eDmg;
    object oRandomTarget;
    int iChance = 75;
    // Base each lightning bolt from the caster.
    location lLocation = GetLocation (Spell.oCaster);
    // Get the spells target at random.
    oRandomTarget = GetFirstObjectInShape (Spell.iAreaShape, Spell.fAreaSize, lLocation, Spell.iLineOfSight, Spell.iObjectFilter, GetPosition (Spell.oCaster));
    while (GetIsObjectValid (oRandomTarget))
    {
        //Debug ("nw_s0_calllghtn", "46", "RTarget: " + GetName (oRandomTarget) + " Bolt: " + IntToString (iBolt));
        // Make a random check to see if this is the lucky target.
        // If we roll under the chance then drop out.
        //Debug ("nw_s0_calllghtn", "49", "Hostile: " + IntToString (GetIsReactionTypeHostile (oRandomTarget, Spell.oCaster)) + " Dead: "  + IntToString (GetIsDead (oRandomTarget)));
        if (GetIsEnemy (oRandomTarget, Spell.oCaster) && !GetIsDead (oRandomTarget))
        {
            // Save this enemy, if we get to the last target then this one gets hit!
            Spell.oAreaTarget = oRandomTarget;
            //Debug ("nw_s0_calllghtn", "54", "ATarget: " + GetName (Spell.oAreaTarget) + " Bolt: " + IntToString (iBolt));
            // Check for chance to hit this enemy.
            if (d100() < iChance) oRandomTarget = OBJECT_INVALID;
            // If not then get the next enemy.
            else oRandomTarget = GetNextObjectInShape (Spell.iAreaShape, Spell.fAreaSize, lLocation, Spell.iLineOfSight, Spell.iObjectFilter, GetPosition (Spell.oCaster));
            // increment the chance per check so we don't go over 5 targets, keeps the bolts close.
            iChance = iChance + 5;
        }
        else oRandomTarget = GetNextObjectInShape (Spell.iAreaShape, Spell.fAreaSize, lLocation, Spell.iLineOfSight, Spell.iObjectFilter, GetPosition (Spell.oCaster));
    }
    if (GetIsObjectValid (Spell.oAreaTarget) && !GetIsDead (Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            //Debug ("nw_s0_calllghtn", "74", "ATarget: " + GetName (Spell.oAreaTarget) + " Dmg: " + IntToString (Spell.iResult) + " Bolt: " + IntToString (iBolt));
            //Set the damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            // Apply effects to the currently selected target.
            ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget);
            // This visual effect is applied to the target object not the location as above.
            //represents the bolt that erupts on the target from above.
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            // Decrease the number of bolts left.
            iBolt--;
        }
    }
    // If there are any bolts left then delay the next bolt until the next round.
    if (iBolt > 0) DelayCommand (6.0f, FireBolt (Spell, iBolt));
    else RemoveEffectsFromSpell (Spell.oCaster, Spell.iSpellID);
}


void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_ELECTRICITY;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 35.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
    Spell.iModNumOfDice = 3;
    // Check for rain conditions if so set the die to 10 otherwise 6.
    if (GetWeather (GetArea (Spell.oCaster)) == WEATHER_RAIN) Spell.iModifierDie = 10;
    else Spell.iModifierDie = 6;
    Spell.iImpact = VFX_IMP_LIGHTNING_M;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Remove any previously cast spell on this target.
    RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
    // Get number of bolts to fire.
    int iBolts = Spell.iCasterLevel;
    // Limit the number of bolts to 10.
    if (iBolts > 10) iBolts == 10;
    // Place effect on caster to note the spells on.
    effect eDuration = EffectVisualEffect (VFX_DUR_AURA_DRAGON_FEAR);
    ApplyEffectToObject (Spell.iDurationType, eDuration, Spell.oCaster, Spell.fDuration);
    FireBolt (Spell, iBolts);
    CleanUpSpell (Spell);
}
