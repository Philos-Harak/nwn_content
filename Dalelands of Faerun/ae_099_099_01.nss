/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ae_099_099_01
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs on_enter for area 099_099_01 (Unholy cavern).
 - Turns all enemy creatures evil and gives them protection from good!
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "nwnx_creature"
void main()
{
    object oCreature = GetLocalObject (OBJECT_SELF, "0_ENTERING_CREATURE");
    // Any creatures in this area that are not associates, the player, the DM are EVIL!
    if (!GetLocalInt(oCreature, PC_ASSOCIATE_TYPE) &&
        !GetIsPC(oCreature) &&
        !GetIsDungeonMaster(oCreature))
    {
        NWNX_Creature_SetAlignmentGoodEvil (oCreature, 0);
        // AC bonus
        effect eAC = EffectACIncrease (2, AC_DEFLECTION_BONUS);
        eAC = VersusAlignmentEffect (eAC, ALIGNMENT_ALL, ALIGNMENT_GOOD);
        // Save bonus
        effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, 2);
        eSave = VersusAlignmentEffect (eSave, ALIGNMENT_ALL, ALIGNMENT_GOOD);
        // Immunity to mind spells
        effect eImmune = EffectImmunity (IMMUNITY_TYPE_MIND_SPELLS);
        eImmune = VersusAlignmentEffect (eImmune, ALIGNMENT_ALL, ALIGNMENT_GOOD);
        effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
        // Link effects
        effect eLink = EffectLinkEffects (eImmune, eSave);
        eLink = EffectLinkEffects(eLink, eAC);
        eLink = EffectLinkEffects(eLink, eDur);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eLink, oCreature);
    }
}


