/*//////////////////////////////////////////////////////////////////////////////
 Sprict Name: 0i_chat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with chat.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "0i_database"
#include "0i_itemproperty"
#include "nwnx_chat"
#include "nwnx_player"
struct stLanguage
{
    string sTranslatedAllMessage;
    string sLanguageFeat;
    string sTranslatedSubMessage;
    int nLanguageFeat;
};
// Parses all DM chat.
// nChannel is the channel used.
// oSender is the person sending the message.
// oTarget is the person receiving the message.
// sMessage is the message.
void DMChatPars(int nChannel, object oSender, object oTarget, string sMessage);
// Parses all PC chat.
// iChannel is the channel used.
// oSender is the person sending the message.
// oTarget is the person receiving the message.
// sMessage is the message.
void PCChatPars(int nChannel, object oSender, object oTarget, string sMessage);
// Checks to see if any messages need to be recorded.
// iChannel is the channel used.
// oSender is the person sending the message.
// oTarget is the person receiving the message.
// sMessage is the message.
void WatchChat (int nChannel, object oSender, object oTarget, string sMessage);
// Checks for special input from a player.
void CheckPlayerInput (object oPC, string sInput, string sMessage);
// Checks the chat to see if any of it should be translated to another language.
// using the [] brackets.
struct stLanguage CheckLanguageChatPars (object oSender, string sMessage);
void SetQuestPaperDescription (object oTarget);
int GetLanguageByRace (object oCreature);
// Parses all DM chat.
// nChannel is the channel used.
// oSender is the person sending the message.
// oTarget is the person receiving the message.
// sMessage is the message.
void DMChatPars(int nChannel, object oSender, object oTarget, string sMessage)
{
    /*/ Check to see if they are renaming an object.
    // Change the name of an object with colors!
    object oDMTarget = GetLocalObject (oSender, "0_Rename");
    if (GetIsObjectValid (oDMTarget) && !GetIsPC (oDMTarget))
    {
        // Check to see if we should add color.
        iColor = GetLocalInt (oSender, "0_TextColor");
        sText = "";
        if (iColor == 0) StripColorCodes (sMessage); // Normal - no color.
        if (iColor == 1) sText = "<cT�>"; // Blue - masterwork
        else if (iColor == 2) sText = "<c�K�>"; // Purple - 2 Powers
        else if (iColor == 3) sText = "<c�22>"; // Red - 3 Powers
        else if (iColor == 4) sText = "<c��>"; // Orange - 4 Powers
        else if (iColor == 5) sText = "<c��>"; // Gold - Unique
        else if (iColor == 6) sText = "<c�>"; // Green - Sets
        else if (iColor == 7) sText = "<c���>"; // Gray
        else if (iColor == 8) sText = "<c���>"; // White
        if (iColor > 0) sMessage = sText + sMessage + "</c>";
        // Send message that the name was changed.
        SendMessages (GetName (oDMTarget) + " name has been changed to " + sMessage, COLOR_GRAY, oSender, FALSE, FALSE);
        // Set the name.
        SetName (oDMTarget, sMessage);
        // Delete the target.
        DeleteLocalObject (oSender, "0_Rename");
        // Remove the message from chat.
        if (iChannel != 0) NWNX_Chat_SkipMessage ();
    } */
}
// Parses all PC chat.
// iChannel is the channel used.
// oSender is the person sending the message.
// oTarget is the person receiving the message.
// sMessage is the message.
void PCChatPars (int iChannel, object oSender, object oTarget, string sMessage)
{
}
// Checks to see if any messages need to be recorded.
// iChannel is the channel used.
// oSender is the person sending the message.
// oTarget is the person receiving the message.
// sMessage is the message.
void WatchChat (int nChannel, object oSender, object oTarget, string sMessage)
{
    int nWatchingSender, nWatchingTarget, bDM = FALSE;
    string sChannel;
    // Get the Chat watching.
    nWatchingSender = GetServerDatabaseInt (oSender, PLAYER_TABLE, "watched");
    nWatchingTarget = GetServerDatabaseInt (oTarget, PLAYER_TABLE, "watched");
    if (nWatchingSender || nWatchingTarget )
    {
        bDM = TRUE;
        switch (nChannel)
        {
            case NWNX_CHAT_CHANNEL_DM_TALK :
            case NWNX_CHAT_CHANNEL_PLAYER_TALK : { sChannel = "TALK"; break; }
            case NWNX_CHAT_CHANNEL_DM_TELL :
            case NWNX_CHAT_CHANNEL_PLAYER_TELL : { sChannel = "TELL"; break; }
            case NWNX_CHAT_CHANNEL_DM_PARTY :
            case NWNX_CHAT_CHANNEL_PLAYER_PARTY : { sChannel = "PARTY"; break; }
            case NWNX_CHAT_CHANNEL_DM_WHISPER :
            case NWNX_CHAT_CHANNEL_PLAYER_WHISPER : { sChannel = "WHISPER"; break; }
            case NWNX_CHAT_CHANNEL_DM_SHOUT :
            case NWNX_CHAT_CHANNEL_PLAYER_SHOUT : { sChannel = "Shout"; break; }
            case NWNX_CHAT_CHANNEL_DM_DM :
            case NWNX_CHAT_CHANNEL_PLAYER_DM : { sChannel = "DM"; break; }
        }
        sChannel = "Watching (" + sChannel + ") " + GetName (oSender) + " send to " + GetName (oTarget) + " : ";
        SendMessages (sChannel + sMessage, COLOR_GRAY, OBJECT_INVALID, bDM, TRUE);
    }
}
// Checks for special input from a player.
void CheckPlayerInput (object oPC, string sInput, string sMessage)
{
    if (sInput == "ChangeEnchantedName")
    {
        object oItem = GetLocalObject (oPC, "0_Enchanted_Item");
        // Check the items quality.
        itemproperty ipProperty = HasProperty (oItem, 86);
        int nQuality = GetItemPropertyCostTableValue (ipProperty);
        if (nQuality == 1) sMessage = AddColorToText (sMessage, COLOR_MAGIC);
        else if (nQuality == 2) sMessage = AddColorToText (sMessage, COLOR_EXQUISITE);
        else if (nQuality == 3) sMessage = AddColorToText (sMessage, COLOR_LEGENDARY);
        else if (nQuality == 4) sMessage = AddColorToText (sMessage, COLOR_RELIC);
        else if (nQuality == 5) sMessage = AddColorToText (sMessage, COLOR_ARTIFACT);
        SetName (oItem, sMessage);
    }
    DeleteLocalString (oPC, "0_Input");
    // Remove the message from chat for all inputs.
    NWNX_Chat_SkipMessage ();
}
// Checks the chat to see if any of it should be translated to another language.
// using the [] brackets.
struct stLanguage CheckLanguageChatPars (object oSender, string sMessage)
{
    int bParsing = FALSE, nStartString, nEndString, nStringLength, nCounter;
    int nTranslate, nSubRace, nEmoteDone;
    string sLetter, sNewLanguage;
    string sTranslate, sLeftMessage, sRightMessage;
    struct stLanguage stLanguage;
    // Check for characters in message to translate.
    // Characters to look for "[".
    nStartString = FindSubString (sMessage, "[");
    if (nStartString > -1)
    {
        // Increase the StartString by one to align it correctly.
        nStartString ++;
        // Message has other language in it.
        // Setup default translation string.
        sTranslate = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        // Get the language the character is speaking now.
        stLanguage.nLanguageFeat = GetLocalInt (oSender, "0_Language");
        // If no default language then select it.
        if (stLanguage.nLanguageFeat == 0)
        {
            // Get the first Language feat they have.
            int bLanguageFound = FALSE;
            stLanguage.nLanguageFeat = 1171;
            while (!bLanguageFound && stLanguage.nLanguageFeat < 1198)
            {
                if (GetHasFeat (stLanguage.nLanguageFeat, oSender)) bLanguageFound = TRUE;
                else stLanguage.nLanguageFeat ++;
            }
            // If they don't have a feat then default to race.
            if (stLanguage.nLanguageFeat > 1197) stLanguage.nLanguageFeat = GetLanguageByRace (oSender);
            // Now save the language.
            SetLocalInt (oSender, "0_Language", stLanguage.nLanguageFeat);
        }
        // Convert nLanguage to a string... sLang.
        stLanguage.sLanguageFeat = IntToString (stLanguage.nLanguageFeat);
        // Get the whole message length.
        nStringLength = GetStringLength (sMessage);
        // Get the end of the language translation.
        nEndString = FindSubString (sMessage, "]");
        // If there is no end then make it the end of the string.
        if (nEndString == -1) nEndString = nStringLength;
        // Get the length of the substring.
        nCounter = nEndString - nStartString;
        // Get the substring should be text.
        stLanguage.sTranslatedSubMessage = GetSubString (sMessage, nStartString, nCounter);
        // Now create translated string.
        // Create language translation.
        nCounter = 1;
        while (nCounter < nStringLength)
        {
            // Get each letter to translate.
            sLetter = GetSubString (stLanguage.sTranslatedSubMessage, nCounter, 1);
            // Get the letter to number conversion based on sTranslate
            // So we can pull the new text from the 2da file.
            nTranslate = FindSubString (sTranslate, sLetter);
            // If it translates then add it.
            if (nTranslate > -1) sNewLanguage = sNewLanguage + Get2DAString ("languages", stLanguage.sLanguageFeat, nTranslate);
            // If it doesn't then then check for "*" the emote character.
            else
            {
                // If the emote character "*" then pass the text through.
                if (sLetter == "*")
                {
                    nEmoteDone = FALSE;
                    // Add the emote text until we fine another "*"
                    while (!nEmoteDone)
                    {
                        sNewLanguage = sNewLanguage + sLetter;
                        nCounter ++;
                        sLetter = GetSubString (stLanguage.sTranslatedSubMessage, nCounter, 1);
                        // We have found the end so lets exit.
                        if (sLetter == "*")
                        {
                            nEmoteDone = TRUE;
                            // Don't forget to add the "*" to the end.
                            sNewLanguage = sNewLanguage + "*";
                        }
                    }
                }
                else sNewLanguage = sNewLanguage + sLetter;
            }
            // Go get next letter.
            nCounter ++;
        }
        // Get message before language.
        sLeftMessage = GetStringLeft (sMessage, nStartString - 1);
        // Get message after language.
        if (nEndString != nStringLength)
        {
            nEndString = nStringLength - nEndString - 1;
            sRightMessage = GetStringRight (sMessage, nEndString);
        }
        else sRightMessage == "";
        // Put the message together.
        stLanguage.sTranslatedAllMessage = sLeftMessage + sNewLanguage + sRightMessage;
        // Get the name of the Language.
        stLanguage.sLanguageFeat = Get2DAString ("languages", stLanguage.sLanguageFeat, 52);
        // Send message to player.
        SendMessages (GetName (oSender) + " (" + stLanguage.sLanguageFeat + "): " + stLanguage.sTranslatedSubMessage, COLOR_WHITE, oSender);
    }
    return stLanguage;
}

void SetQuestPaperDescription (object oTarget)
{
    int nQuestStrRef = StringToInt (GetLocalString (oTarget, "0_Q_STRREF"));
    string sArea = GetStringArray (GetLocalString (oTarget, "0_Q_START"), 0, "-");
    string sName = GetStringArray (GetLocalString (oTarget, "0_Q_GIVER"), 0, "-");
    string sQuestText = GetStringByStrRef (nQuestStrRef + 1);
   //sQuestText = ParseQuestText (sQuestText, oTarget, GetItemPossessor (oTarget));
    // Set the Papers description.
    SetDescription (oTarget, sName + " located in " + sArea + " has given you a quest. '" + sQuestText + "'.");
}

int GetLanguageByRace (object oCreature)
{
    int nRace = GetRaceType(oCreature, TRUE);
    if (nRace == RACIAL_TYPE_ANIMAL) return 1172;
    else if (nRace == RACIAL_TYPE_BEAST) return 1172;
    else if (nRace == RACIAL_TYPE_CONSTRUCT) return 1185;
    else if (nRace == RACIAL_TYPE_DRAGON) return 1178;
    else if (nRace == RACIAL_TYPE_DWARF) return 1181;
    else if (nRace == RACIAL_TYPE_ELEMENTAL) return 1188;
    else if (nRace == RACIAL_TYPE_ELF) return 1182;
    else if (nRace == RACIAL_TYPE_FEY) return 1194;
    else if (nRace == RACIAL_TYPE_GIANT) return 1183;
    else if (nRace == RACIAL_TYPE_GNOME) return 1185;
    else if (nRace == RACIAL_TYPE_HALFELF) return 1182;
    else if (nRace == RACIAL_TYPE_HALFLING) return 1187;
    else if (nRace == RACIAL_TYPE_HALFORC) return 1192;
    else if (nRace == RACIAL_TYPE_HUMAN) return 1176;
    else if (nRace == RACIAL_TYPE_HUMANOID_GOBLINOID) return 1186;
    else if (nRace == RACIAL_TYPE_HUMANOID_MONSTROUS) return 1190;
    else if (nRace == RACIAL_TYPE_HUMANOID_ORC) return 1192;
    else if (nRace == RACIAL_TYPE_HUMANOID_REPTILIAN) return 1178;
    else if (nRace == RACIAL_TYPE_MAGICAL_BEAST) return 1174;
    else if (nRace == RACIAL_TYPE_OUTSIDER)
    {
        if (GetAlignmentGoodEvil (oCreature) == ALIGNMENT_EVIL)
        {
            if (d2()) return 1171;
            else return 1190;
        }
        else return 1175;
    }
    else if (nRace == RACIAL_TYPE_VERMIN) return 1172;
    return 1176;
}
