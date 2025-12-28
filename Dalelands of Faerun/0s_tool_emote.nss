//::///////////////////////////////////////////////
//:: Player Tool 4 Instant Feat
//:: 0s_emote_tool
//:: Emote tool
//:: Copyright (c) 2007 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Emote tool to use the DMFI emotes.
*/
//:://////////////////////////////////////////////
//:: Created By: Brian Chung
//:: Created On: 2007-12-05
/*/:://////////////////////////////////////////////

#include "0i_messages"

////////////////////////////////////////////////////////////////////////
void dmw_CleanUp(object oMySpeaker)
{
   int nCount;
   int nCache;
   DeleteLocalObject(oMySpeaker, "dmfi_univ_target");
   DeleteLocalLocation(oMySpeaker, "dmfi_univ_location");
   DeleteLocalObject(oMySpeaker, "dmw_item");
   DeleteLocalString(oMySpeaker, "dmw_repamt");
   DeleteLocalString(oMySpeaker, "dmw_repargs");
   nCache = GetLocalInt(oMySpeaker, "dmw_playercache");
   for(nCount = 1; nCount <= nCache; nCount++)
   {
      DeleteLocalObject(oMySpeaker, "dmw_playercache" + IntToString(nCount));
   }
   DeleteLocalInt(oMySpeaker, "dmw_playercache");
   nCache = GetLocalInt(oMySpeaker, "dmw_itemcache");
   for(nCount = 1; nCount <= nCache; nCount++)
   {
      DeleteLocalObject(oMySpeaker, "dmw_itemcache" + IntToString(nCount));
   }
   DeleteLocalInt(oMySpeaker, "dmw_itemcache");
   for(nCount = 1; nCount <= 10; nCount++)
   {
      DeleteLocalString(oMySpeaker, "dmw_dialog" + IntToString(nCount));
      DeleteLocalString(oMySpeaker, "dmw_function" + IntToString(nCount));
      DeleteLocalString(oMySpeaker, "dmw_params" + IntToString(nCount));
   }
   DeleteLocalString(oMySpeaker, "dmw_playerfunc");
   DeleteLocalInt(oMySpeaker, "dmw_started");
}

/*///////////////////////////////////////////////////////////////////////
void main()
{
 /*   object oUser = OBJECT_SELF;
    object oItem = GetLocalObject(oUser, "dmfi_item");
    object oOther = GetLocalObject(oUser, "dmfi_target");
    location lLocation = GetLocalLocation(oUser, "dmfi_location");
    string sItemTag = GetTag(oItem);

    // listening system initialization moved to new function
    dmfiInitialize(oUser);

    dmw_CleanUp(oUser);

        SetLocalObject(oUser, "dmfi_univ_target", oUser);
        SetLocalLocation(oUser, "dmfi_univ_location", lLocation);
        SetLocalString(oUser, "dmfi_univ_conv", "pc_emote");
        AssignCommand(oUser, ClearAllActions());
        AssignCommand(oUser, ActionStartConversation(OBJECT_SELF, "dmfi_universal", TRUE));
    */
}
