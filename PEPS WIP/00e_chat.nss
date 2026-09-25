/*//////////////////////////////////////////////////////////////////////////////
 Script: 00e_chat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  On dialogue script for our listener so we can have players command things via text.
*///////////////////////////////////////////////////////////////////////////////
void ai_RaisePortal(object oPortal);
void ai_PowerUp(object oSpeaker, object oRuneCircle, int nIndex);
void main()
{
    object oSpeaker = GetPCChatSpeaker();
    string sMessage = GetPCChatMessage();
    string sName = GetLocalString(GetModule(), "AI_RUIN_NAME");
    // Did they say the name?!
    if (FindSubString(sMessage, sName) > -1)
    {
        int nIndex;
        float fDelay;
        object oRuneCircle = GetObjectByTag("ai_rune_circle");
        object oCorpse = GetNearestObjectByTag("0_corpse", oRuneCircle);
        float fDistance = GetDistanceBetween(oRuneCircle, oCorpse);
        // The body must be laying within the circle.
        if(fDistance < 5.0f && fDistance != 0.0f)
        {
            object oPedestal;
            if(GetDistanceBetween(oSpeaker, oRuneCircle) < 5.0f)
            {
                for(nIndex = 1; nIndex <= 4; nIndex++)
                {
                    fDelay += 1.0f;
                    DelayCommand(fDelay, ai_PowerUp(oSpeaker, oRuneCircle, nIndex));
                }
                object oPortalSounds =GetObjectByTag("ai_portal_sound");
                SoundObjectPlay(oPortalSounds);
                SetObjectVisualTransform(oRuneCircle, 21, 360.0f, 2, 17.0f);
                SetObjectVisualTransform(oRuneCircle, 33, 0.5f, 2, 1.0f);
                object oPortal = GetObjectByTag("ai_magic_portal");
                DelayCommand(2.0f, ai_RaisePortal(oPortal));
                DestroyObject(oCorpse, 4.0f);
            }
        }
        else FloatingTextStringOnCreature("You sense that something is missing from the circle.", oSpeaker);
    }
}
void ai_RaisePortal(object oPortal)
{
    SetObjectVisualTransform(oPortal, 33, 3.0f, 2, 10.0f);
}
void ai_PowerUp(object oSpeaker, object oRuneCircle, int nIndex)
{
    object oPedestal = GetNearestObjectByTag("ai_pedestal_" + IntToString(nIndex), oRuneCircle);
    // sim_pulse
    DelayCommand(2.5, AssignCommand(oSpeaker, PlaySound("as_mg_telepin1")));
    CreateObject(OBJECT_TYPE_PLACEABLE, "x3_plc_slightb", GetLocation(oPedestal));
}
