/*////////////////////////////////////////////////
 Script Name: x0_s0_gustwind
 Programmer: Brent
////////////////////////////////////////////////
Evocation [Air]
Level:Bard 3, Wizard/Sorcer 3, Innate 3
Components: V, S
Casting Time:   1 standard action
Range: Medium
Effect: 20' Sphere
Duration:   1 round
Saving Throw:   Fortitude negates
Spell Resistance: No
This spell creates a severe blast of air (approximately 50 mph) that originates
from you, affecting all creatures in its path that fail a fortitude save.

Tiny or smaller creature is knocked down for a d4 rounds.
Small creatures are knocked down for a d2 rounds.
Medium creatures are knocked down for 1 round.
Area effect spells such as Stinking Cloud are dispersed.
Unlocked doors are blasted open or slammed shut.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_AIR;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_AREA_OF_EFFECT;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iImpact = VFX_IMP_PULSE_WIND;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iRounds, iSize;
    string sAOETag;
    // Create effect.
    effect eKnockdown = EffectKnockdown();
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_20);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        // Area of Effects - remove specific ones.
        if (GetObjectType (Spell.oAreaTarget) == OBJECT_TYPE_AREA_OF_EFFECT)
        {
            // Gust of wind should only destroy "cloud/fog like" area of effect spells.
            sAOETag = GetTag(Spell.oAreaTarget);
            if (sAOETag == "VFX_PER_FOGACID" ||
                sAOETag == "VFX_PER_FOGKILL" ||
                sAOETag == "VFX_PER_FOGBEWILDERMENT" ||
                sAOETag == "VFX_PER_FOGSTINK" ||
                sAOETag == "VFX_PER_FOGFIRE" ||
                sAOETag == "VFX_PER_FOGMIND" ||
                sAOETag == "VFX_PER_CREEPING_DOOM")
            {
                DestroyObject(Spell.oAreaTarget);
            }
        }
        // Doors.
        else if (GetObjectType (Spell.oAreaTarget) == OBJECT_TYPE_DOOR)
        {
            // If locked then exit.
            if (GetLocked(Spell.oAreaTarget) == FALSE)
            {
                // If closed then open the door.
                if (GetIsOpen (Spell.oAreaTarget) == FALSE) AssignCommand(Spell.oAreaTarget, ActionOpenDoor(Spell.oAreaTarget));
                // else close the door.
                else AssignCommand(Spell.oAreaTarget, ActionCloseDoor(Spell.oAreaTarget));
            }
        }
        // Placeables - Lights so we can blow them out.
        else if (GetObjectType (Spell.oAreaTarget) == OBJECT_TYPE_PLACEABLE)
        {
            // If the object has the tag of 0_Light then it can be lit.
            if (GetTag (Spell.oAreaTarget) == "0_Light")
            {
                // Turn the light off.
                // Delete variable stating its on.
                DeleteLocalInt (Spell.oAreaTarget, "0_Placeable_On");
                // Deactivate it.
                AssignCommand (Spell.oAreaTarget, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
                // Turn off the ambient light by removing light effect.
                effect eEffect = GetFirstEffect (Spell.oAreaTarget);
                while (GetIsEffectValid (eEffect))
                {
                    if (GetEffectType (eEffect) == EFFECT_TYPE_VISUALEFFECT) RemoveEffect (Spell.oAreaTarget, eEffect);
                    eEffect = GetNextEffect (Spell.oAreaTarget);
                }
            }
        }
        // Creatures.
        else
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make a resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                // Get the number of rounds the creature is knocked down.
                iSize = GetCreatureSize (Spell.oAreaTarget);
                if (iSize == CREATURE_SIZE_TINY) iRounds = d4();
                else if (iSize == CREATURE_SIZE_SMALL) iRounds = d2();
                else if (iSize == CREATURE_SIZE_MEDIUM) iRounds = 1;
                else iRounds = 0;
                if (iRounds > 0)
                {
                    // Apply effects
                    DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, Spell.oAreaTarget, RoundsToSeconds(iRounds)));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}









