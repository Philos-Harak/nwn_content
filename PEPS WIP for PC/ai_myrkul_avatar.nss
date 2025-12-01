/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_myrkul_avatar
//////////////////////////////////////////////////////////////////////////////////////////////////////
 AI combat action scripts for Myrkul's avatar.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void MyrkulPulseAttack(object oCreature, location lLocation)
{
    int nSave, nDamage, nLevel = ai_GetCharacterLevels(oCreature);
    int nDC = nLevel + 10;
    if(nLevel > 15) nLevel = 15;
    effect eStun = EffectStunned();
    effect eKnockdown = EffectKnockdown();
    effect eDamage;
    effect ePulse = EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE, FALSE, 3.0);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, ePulse, lLocation);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 12.0, lLocation);
    while(oTarget != OBJECT_INVALID)
    {
        ai_Debug("ai_myrkul_avatar", "22", "Pulse Attack on " + GetName(oTarget) + "!");
        nSave = ReflexSave(oTarget, nDC);
        if(!nSave)
        {
            nDamage = d6(nLevel);
            nDamage = GetReflexAdjustedDamage(nDamage, oTarget, nDC);
            eDamage = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
            nSave = WillSave(oTarget, nDC);
            if(!nSave) ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, oTarget, RoundsToSeconds(d4()));
            nSave = FortitudeSave(oTarget, nDC);
            if(!nSave) ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oTarget, RoundsToSeconds(d4()));
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 12.0, lLocation);
    }
}

void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    int nTeleport = GetLocalInt(oCreature, "0_Teleport_Chance");
    nTeleport += nInMelee * 20;
    ai_Debug("ai_myrkul_avatar", "45", "nTeleport: " + IntToString(nTeleport));
    if(d100() < nTeleport)
    {
        SetLocalInt(oCreature, "0_Teleport_Chance", 0);
        // Teleport away from enemies!
        object oWP = GetNearestObjectByTag("WP_TELEPORT", oCreature, d2() + 1);
        if(oWP != OBJECT_INVALID)
        {
            ai_Debug("ai_myrkul_avatar", "53", "Teleporting!");
            ClearAssociateActions(oCreature);
            effect eDisappear = EffectVisualEffect(VFX_DUR_GHOSTLY_PULSE);
            location lLocation = GetLocation(oCreature);
            location lTeleport = GetLocation(oWP);
            effect eImpact_str = EffectVisualEffect(1008);
            effect eImpact_mid = EffectVisualEffect(1009);
            effect eImpact_end = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_2);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDisappear, oCreature, 10.0f);
            DelayCommand(1.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact_str, oCreature));
            DelayCommand(1.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact_mid, oCreature));
            DelayCommand(3.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_end, lLocation));
            DelayCommand(5.0f, JumpToLocation (lTeleport));
            DelayCommand(5.5f, MyrkulPulseAttack(oCreature, lLocation));
            DelayCommand(6.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_str, lTeleport));
            DelayCommand(6.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_mid, lTeleport));
            DelayCommand(7.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_end, lTeleport));
            // Used to make creature wait before starting its next round.
            SetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS, 12);
            return;
        }
    }
    else SetLocalInt(oCreature, "0_Teleport_Chance", nTeleport);
    //**************************************************************************
    //************************ END SPECIAL AI SCRIPTS **************************
    //**************************************************************************
    ExecuteScript("ai_cleric", oCreature);
}
