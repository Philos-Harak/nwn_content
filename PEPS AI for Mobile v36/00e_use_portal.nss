/*//////////////////////////////////////////////////////////////////////////////
 Script: 00e_use_portal
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  On use of a placeable jump to waypoint.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
// Portal effect used in most portals.
// returns the wait period before jumping the character.
float TeleportEffect (object oUser)
{
    effect eVFX2 = EffectVisualEffect (VFX_FNF_DISPEL, FALSE, 0.25f);
    DelayCommand (1.0f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX2, oUser));
    effect eVFX3 = EffectVisualEffect (VFX_DUR_AURA_PULSE_GREY_WHITE);
    DelayCommand (0.5f, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eVFX3, oUser, 10.0f));
    return 3.0f;
}
void main()
{
    object oUser = GetLastUsedBy();
    string sTag = GetLocalString(OBJECT_SELF, "AI_DESTINATION_TAG");
    object oWP = GetObjectByTag(sTag);
    float fDelay;
    //ai_Debug("0e_use_portal", "12", "sTag: " + sTag);
    effect eVFX = EffectVisualEffect (VFX_IMP_DEATH_WARD, FALSE, 2.0f);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVFX, GetLocation (OBJECT_SELF));
    fDelay = TeleportEffect(oUser);
    DelayCommand(fDelay, AssignCommand(oUser, JumpToObject(oWP)));
    object oAssociate = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oUser);
    if (oAssociate != OBJECT_INVALID)
    {
        TeleportEffect(oAssociate);
        DelayCommand(fDelay, AssignCommand(oAssociate, JumpToObject(oWP)));
    }
    oAssociate = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oUser);
    if (oAssociate != OBJECT_INVALID)
    {
        TeleportEffect(oAssociate);
        DelayCommand(fDelay, AssignCommand(oAssociate, JumpToObject(oWP)));
    }
    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oUser, 1);
    if (oAssociate != OBJECT_INVALID)
    {
        TeleportEffect(oAssociate);
        DelayCommand(fDelay, AssignCommand(oAssociate, JumpToObject(oWP)));
    }
    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oUser, 2);
    if (oAssociate != OBJECT_INVALID)
    {
        TeleportEffect(oAssociate);
        DelayCommand(fDelay, AssignCommand(oAssociate, JumpToObject(oWP)));
    }
    oAssociate = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oUser);
    if (oAssociate != OBJECT_INVALID)
    {
        TeleportEffect(oAssociate);
        DelayCommand(fDelay, AssignCommand(oAssociate, JumpToObject(oWP)));
    }
}
