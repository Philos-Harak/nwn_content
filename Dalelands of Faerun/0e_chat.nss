/*////////////////////////////////////////////////
 Script Name: 0e_chat
 Programmer: Philos
//////////////////////////////////////////////////
    Uses NWNX chat system.
*/////////////////////////////////////////////////
#include "0i_chat"
void main ()
{
    int bVoiceThrown = FALSE;
    float fDistance;
    object oPlayer;
    object oSender = NWNX_Chat_GetSender ();
    if (!GetIsPC (oSender)) return;
    object oTarget = NWNX_Chat_GetTarget ();
    string sMessage = NWNX_Chat_GetMessage ();
    int nChannel = NWNX_Chat_GetChannel ();
    // Check shouts to make sure normal players cannot shout on the server.
    switch (nChannel)
    {
        case NWNX_CHAT_CHANNEL_PLAYER_SHOUT :
        {
            // Check to see if this is a normal player!
            int nStatus = GetServerDatabaseInt (oSender, PLAYER_TABLE, "status");
            // Normal players cannot use the shout channel. Status 0 and 1.
            if (nStatus < 2)
            {
                NWNX_Chat_SkipMessage ();
                sMessage = "[SHOUT] " + sMessage;
                NWNX_Chat_SendMessage (NWNX_CHAT_CHANNEL_PLAYER_DM, sMessage, oSender);
                SendMessages ("You do not have shouting privledges. Your message was rerouted to the DM channel.", COLOR_GRAY, oSender, FALSE, FALSE);
            }
            return;
            break;
        }
    }
    // Check to see if the player is entering input.
    string sInput = GetLocalString (oSender, "0_Input");
    if (sInput != "") CheckPlayerInput (oSender, sInput, sMessage);
    // Check to see if we need to capture text.
    WatchChat (nChannel, oSender, oTarget, sMessage);
    // Check Dm's chat.
    //if (GetIsDungeonMaster (oSender)) DMChatPars (nChannel, oSender, oTarget, sMessage);
    // Check players chat.
    //else PCChatPars (nChannel, oSender, oTarget, sMessage);
    // Check if they are throwing their voice.
    if (GetStringLeft (sMessage, 1) == "/")
    {
        string sVariable = "0_PLAYER_Target";
        // Remove the throw voice character code.
        sMessage = GetSubString(sMessage, 1, GetStringLength(sMessage));
        // Mark that they are throwing their voice.
        if(GetIsDungeonMaster(oSender)) sVariable = DM_TARGET_CREATURE;
        object oTarget = GetLocalObject(oSender, sVariable);
        if(oTarget != OBJECT_INVALID)
        {
            oSender = oTarget;
            bVoiceThrown = TRUE;
        }
    }
    // Change the players chat based on any language code.
    struct stLanguage stLanguage = CheckLanguageChatPars (oSender, sMessage);
    // If the message has been translated.
    if (stLanguage.sTranslatedAllMessage != "")
    {
        // Now send out the message to the correct listeners.
        NWNX_Chat_SendMessage (nChannel, stLanguage.sTranslatedAllMessage, oSender, oTarget);
        NWNX_Chat_SkipMessage ();
        // Get the channel.
        switch (nChannel)
        {
            case NWNX_CHAT_CHANNEL_DM_TALK :
            case NWNX_CHAT_CHANNEL_PLAYER_TALK :
            {
                // Look for players to send message to.
                location lLocation = GetLocation (oSender);
                oPlayer = GetFirstPC ();
                while (GetIsObjectValid (oPlayer))
                {
                     fDistance = GetDistanceBetween (oSender, oPlayer);
                     if (fDistance <= SHORT_DISTANCE && fDistance != 0.0f)
                     {
                        // Check to see if they have the language.
                        if (GetHasFeat (stLanguage.nLanguageFeat, oPlayer) ||
                            GetIsDungeonMaster (oPlayer))
                        {
                            SendMessages (GetName (oSender) + " (" + stLanguage.sLanguageFeat + "): " +
                            stLanguage.sTranslatedSubMessage, COLOR_WHITE, oPlayer);
                        }
                     }
                     oPlayer = GetNextPC ();
                }
                break;
            }
            case NWNX_CHAT_CHANNEL_DM_TELL :
            case NWNX_CHAT_CHANNEL_PLAYER_TELL :
            {
                // Check to see if the target has the language.
                if (GetHasFeat (stLanguage.nLanguageFeat, oPlayer) ||
                    GetIsDungeonMaster (oPlayer))
                {
                   SendMessages (GetName (oSender) + " (" + stLanguage.sLanguageFeat + "): " +
                   stLanguage.sTranslatedSubMessage, COLOR_YELLOW, oTarget);
                }
                break;
            }
            case NWNX_CHAT_CHANNEL_DM_PARTY :
            case NWNX_CHAT_CHANNEL_PLAYER_PARTY :
            {
                // Look for players to send message to.
                oPlayer = GetFirstFactionMember (oSender);
                while (GetIsObjectValid (oPlayer))
                {
                    if (GetIsPC (oPlayer))
                    {
                        // Check to see if they have the language.
                        if (GetHasFeat (stLanguage.nLanguageFeat, oPlayer) ||
                            GetIsDungeonMaster (oPlayer))
                        {
                            SendMessages (GetName (oSender) + " (" + stLanguage.sLanguageFeat + "): " +
                            stLanguage.sTranslatedSubMessage, COLOR_BLUE, oPlayer);
                        }
                    }
                    oPlayer = GetNextFactionMember (oSender);
                }
                break;
            }
            case NWNX_CHAT_CHANNEL_DM_WHISPER :
            case NWNX_CHAT_CHANNEL_PLAYER_WHISPER :
            {
                // Look for players to send message to.
                location lLocation = GetLocation (oSender);
                oPlayer = GetFirstPC ();
                while (GetIsObjectValid (oPlayer))
                {
                    fDistance = GetDistanceBetween (oSender, oPlayer);
                    if (fDistance <= SHORT_DISTANCE && fDistance != 0.0f)
                    {
                        // Check to see if they have the language.
                        if (GetHasFeat (stLanguage.nLanguageFeat, oPlayer) ||
                            GetIsDungeonMaster (oPlayer))
                        {
                            SendMessages (GetName (oSender) + " (" + stLanguage.sLanguageFeat + "): " +
                            stLanguage.sTranslatedSubMessage, COLOR_GRAY, oPlayer);
                        }
                    }
                    oPlayer = GetNextPC ();
                }
                break;
            }
            case NWNX_CHAT_CHANNEL_DM_SHOUT :
            case NWNX_CHAT_CHANNEL_PLAYER_SHOUT :
            {
                // Look for players to send message to.
                oPlayer = GetFirstPC ();
                while (GetIsObjectValid (oPlayer))
                {
                    // Check to see if they have the language.
                    if (GetHasFeat (stLanguage.nLanguageFeat, oPlayer) ||
                        GetIsDungeonMaster (oPlayer))
                        {
                            SendMessages (GetName (oSender) + " (" + stLanguage.sLanguageFeat + "): " +
                            stLanguage.sTranslatedSubMessage, COLOR_YELLOW, oPlayer);
                        }
                    oPlayer = GetNextPC ();
                }
                break;
            }
            case NWNX_CHAT_CHANNEL_DM_DM :
            case NWNX_CHAT_CHANNEL_PLAYER_DM :
            {
                // Look for players to send message to.
                oPlayer = GetFirstPC ();
                while (GetIsObjectValid (oPlayer))
                {
                    // Check to see if they have the language.
                    if (GetIsDungeonMaster (oPlayer))
                    {
                        SendMessages (GetName (oSender) + " (" + stLanguage.sLanguageFeat + "): " +
                        stLanguage.sTranslatedSubMessage, COLOR_CYAN, oPlayer);
                    }
                    oPlayer = GetNextPC ();
                }
                break;
            }
        }

    }
    // Now send the message correctly for thrown voices.
    else if (bVoiceThrown)
    {
        int nVolume;
        switch (nChannel)
        {
            case NWNX_CHAT_CHANNEL_DM_PARTY: nVolume = TALKVOLUME_PARTY; break;
            case NWNX_CHAT_CHANNEL_DM_SHOUT: nVolume = TALKVOLUME_SHOUT; break;
            case NWNX_CHAT_CHANNEL_DM_TALK: nVolume = TALKVOLUME_TALK; break;
            case NWNX_CHAT_CHANNEL_DM_TELL: nVolume = TALKVOLUME_TELL; break;
            case NWNX_CHAT_CHANNEL_DM_WHISPER: nVolume = TALKVOLUME_WHISPER; break;
        }
        AssignCommand (oSender, SpeakString (sMessage, nVolume));
        if (nChannel != 0) NWNX_Chat_SkipMessage ();
    }
   // Check to see if the DM has set up a Ding for incoming messages.
    string sOptions = GetServerDatabaseString (oTarget, DM_TABLE, "options");
    if (GetStringArray (sOptions, 0) == "1") NWNX_Player_PlaySound (oTarget, "as_sw_x2gong3");
    switch (nChannel)
    {
        case NWNX_CHAT_CHANNEL_DM_DM:
        case NWNX_CHAT_CHANNEL_DM_SHOUT:
        case NWNX_CHAT_CHANNEL_PLAYER_DM:
        case NWNX_CHAT_CHANNEL_PLAYER_SHOUT:
        {
            object oDM = GetFirstPC ();
            while (GetIsObjectValid (oDM))
            {
                string sOptions = GetServerDatabaseString (oDM, DM_TABLE, "options");
                if (GetStringArray (sOptions, 0) == "1") NWNX_Player_PlaySound (oDM, "as_sw_x2gong3");
                oDM = GetNextPC ();
            }
            break;
        }
    }
}
