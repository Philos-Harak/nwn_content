/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_tool_dmchest
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Spell script that stops combat in the area of the DM.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_area"
void main()
{
    int nObjectType, nCounter = 1;
    // Setup paralyze to stop all creatures from attacking for 6 seconds.
    effect eEffect, eStop = EffectCutsceneParalyze ();
    // Change all creatures faction to neutral.
    object oEffectCreator, oMaster, oTarget;
    object oArea = GetArea (OBJECT_SELF);
    object oNeutralFaction = GetObjectByTag ("neutral_faction");
    object oObject = GetObjectInArea  (oArea, nCounter, OBJECT_TYPE_ALL);
    while (oObject != OBJECT_INVALID)
    {
        nObjectType = GetObjectType (oObject);
        if (nObjectType == OBJECT_TYPE_CREATURE)

        {
            if (!GetIsPC (oObject) &&
                !GetIsDead (oObject))
            {
                if (GetLocalInt (oObject, PC_ASSOCIATE_TYPE) == 0
                && !GetIsDMPossessed (oObject))
                {
                    // Get the target of this creature so we can clear reputation.
                    oTarget = GetAttackTarget (oObject);
                    AssignCommand (oObject, ClearAllActions (TRUE));
                    SetLocalInt (oObject, "0_CurrentFaction", 4/*FACTION_NEUTRAL*/);
                    AssignCommand (oObject, SpeakString (AddColorToText ("Combat stopped!", COLOR_WHITE)));
                    ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eStop, oObject, 12.0f);
                    // Clear master incase he is not attacking.
                    oMaster = GetMaster (oTarget);
                    if (GetIsObjectValid (oMaster))
                    {
                        ClearPersonalReputation (oMaster, oObject);
                        ClearPersonalReputation (oObject, oMaster);
                    }
                    // Clear reputation for us and who we are attacking.
                    ClearPersonalReputation (oTarget, oObject);
                    ClearPersonalReputation (oObject, oTarget);
                    ChangeFaction (oObject, oNeutralFaction);
                    // Remove hosile spells.
                    eEffect = GetFirstEffect(oObject);
                    while (GetIsEffectValid (eEffect))
                    {
                        oEffectCreator = GetEffectCreator (eEffect);
                        if (GetIsObjectValid (oEffectCreator) && !GetFactionEqual (oObject, oEffectCreator))
                        {
                            RemoveEffect (oObject, eEffect);
                        }
                        eEffect = GetNextEffect (oObject);
                    }
                }
            }
            else
            {
                ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eStop, oObject, 6.0f);
                AssignCommand (oObject, ClearAllActions (TRUE));
            }
        }
        // Remove area of effects..
        else if (nObjectType == OBJECT_TYPE_AREA_OF_EFFECT)
        {
            DestroyObject (oObject);
        }
        nCounter ++;
        oObject = GetObjectInArea  (oArea, nCounter, OBJECT_TYPE_ALL);
    }
}

