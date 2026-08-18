/*////////////////////////////////////////////////
 Script: 0s_sum_swarm
 Programmer: Philos
////////////////////////////////////////////////
Caster Level(s): Bard 2, Druid 2, Sorcerer/Wizard 2
Innate Level: 2
School: Conjuration
SubSchool: Summoning
Component(s): Verbal, Somatic, Material/ Divine Focus
Range: Close
Area of Effect / Target: One target
Duration: 1 Round / Level
Save: None
Spell Resistance: No

You summon a swarm of bats, rats or spiders (selected at random), which attacks
a creature within its area. If no living creatures are within its area, the
swarm attacks or pursues the nearest creature as best it can. The caster has no
control over its target or direction of travel.
Bats may cause fear for one round.
Rats may give a disease.
Spiders may poison.

Arcane Material Component
A square of red cloth.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_effect"
// We make attacks against the target until the spell ends.
void Swarm (struct stSpell Spell, string sSwarm, object oTarget, effect eSpecialEffect);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_SUMMONING;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iImpact = VFX_COM_BLOOD_LRG_RED;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iSwarm, iSpecialDuration, iSpecialDurationNumber;
    string sSwarm;
    effect eSpecialEffect;
    effect eVisual = EffectVisualEffect (VFX_DUR_FLIES);
    // Used to anchor the spell to the creature so we can test for it.
    effect eEffect = EffectSpellImmunity (SPELL_HORSE_MOUNT);
    eEffect = RemoveEffectIcon (eEffect);
    // Link the effects
    effect eLink = EffectLinkEffects (eEffect, eVisual);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    if (GetHasFeat (1033/*FEAT_SPIDER_DOMAIN_POWER*/, Spell.oCaster)) iSwarm = 2;
    else iSwarm = Random (3);
    if (iSwarm == 0)
    {
        sSwarm = "Swarm of bats ";
        Spell.iDamageType = DAMAGE_TYPE_PIERCING;
        Spell.iModNumOfDice = 1;
        Spell.iModifierDie = 6;
        Spell.iSave = SAVING_THROW_WILL;
        Spell.iSaveType = SAVING_THROW_TYPE_FEAR;
        eSpecialEffect = EffectFrightened ();
    }
    else if (iSwarm == 1)
    {
        sSwarm = "Swarm of rats ";
        Spell.iDamageType = DAMAGE_TYPE_PIERCING;
        Spell.iModNumOfDice = 1;
        Spell.iModifierDie = 6;
        eSpecialEffect = EffectDisease (DISEASE_FILTH_FEVER);
    }
    else if (iSwarm == 2)
    {
        sSwarm = "Swarm of spiders ";
        Spell.iDamageType = DAMAGE_TYPE_PIERCING;
        Spell.iModNumOfDice = 1;
        Spell.iModifierDie = 6;
        eSpecialEffect = EffectPoison (POISON_SMALL_SPIDER_VENOM);
    }
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink , Spell.oAreaTarget, Spell.fDuration));
        // Add one round since the Swarm function removes 1 round each pass.
        Spell.fDuration = Spell.fDuration + 6.0f;
        Swarm (Spell, sSwarm, Spell.oAreaTarget, eSpecialEffect);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}


// We make attacks against the target until the spell ends.
void Swarm (struct stSpell Spell, string sSwarm, object oTarget, effect eSpecialEffect)
{
    // Check to see if the spell has ended.
    if (Spell.fDuration <= 0.0f) return;
    else Spell.fDuration = Spell.fDuration - 6.0f;
    // If the target is dead then move to the nearest enemy.
    if (GetIsDead (oTarget))
    {
        int iCounter = 1;
        object oNewTarget = GetNearestObject (OBJECT_TYPE_CREATURE, oTarget, iCounter);
        while (GetIsObjectValid (oNewTarget))
        {
            if (GetIsSpellTargetValid (oNewTarget, Spell.iTargetType, Spell.oCaster) &&
                GetDistanceBetween (oTarget, oNewTarget) <= 30.0f)
            {
                RemoveSpellEffects (Spell.iSpellID, oNewTarget);
                // We found a new enemy so attack next round and exit this.
                SignalEvent(oNewTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                effect eVisual = EffectVisualEffect (VFX_DUR_FLIES);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eVisual , oNewTarget, Spell.fDuration));
                DelayCommand (6.0f, Swarm (Spell, sSwarm, oNewTarget, eSpecialEffect));
                return;
            }
            iCounter ++;
            oNewTarget = GetNearestObject (OBJECT_TYPE_CREATURE, oTarget, iCounter);
        }
        // We didn't find a new target so lets end the spell.
        return;
    }
    string sMessage;
    int iSwarmAtkRoll, iSwarmAtkMod, iTargetAC;
    // Make attack.
    iSwarmAtkMod = 2;
    iSwarmAtkRoll = d20();
    iTargetAC = GetAC (oTarget);
    if ((iSwarmAtkRoll + iSwarmAtkMod) >= iTargetAC)
    {
        // Send attack message *hit*.
        sMessage = AddColorToText (sSwarm, COLOR_DARK_MAGENTA) +
                   AddColorToText (" attacks " + GetName (oTarget) + " : *hit* : (" +
                           IntToString (iSwarmAtkRoll) + " + " + IntToString (iSwarmAtkMod) +
                     " = " + IntToString (iSwarmAtkRoll + iSwarmAtkMod) + ")", COLOR_ORANGE);
        SendMessageToPC (Spell.oCaster, sMessage);
        SendMessageToPC (oTarget, sMessage);
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        int iDurationType;
        float fDuration;
        effect eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
        effect eImpact = EffectVisualEffect (Spell.iImpact);
        if (sSwarm == "Swarm of bats ")
        {
            iDurationType = DURATION_TYPE_TEMPORARY;
            fDuration = RoundsToSeconds (1);
        }
        else if (sSwarm == "Swarm of rats ")
        {
            iDurationType = DURATION_TYPE_PERMANENT;
            fDuration = 0.0f;
        }
        else if (sSwarm == "Swarm of spiders ")
        {
            iDurationType = DURATION_TYPE_PERMANENT;
            fDuration = 0.0f;
        }
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget);
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult) ApplyEffectToObject (iDurationType, eSpecialEffect, oTarget, fDuration);
    }
    // Show that the spell missed!
    else
    {
       // Send attack message *miss*.
       sMessage = AddColorToText (sSwarm, COLOR_DARK_MAGENTA) +
                  AddColorToText (" attacks " + GetName (oTarget) + " : *miss* : (" +
                           IntToString (iSwarmAtkRoll) + " + " + IntToString (iSwarmAtkMod) +
                     " = " + IntToString (iSwarmAtkRoll + iSwarmAtkMod) + ")", COLOR_ORANGE);
       SendMessageToPC (Spell.oCaster, sMessage);
       SendMessageToPC (oTarget, sMessage);
    }
    DelayCommand (6.0f, Swarm (Spell, sSwarm, Spell.oAreaTarget, eSpecialEffect));
}
