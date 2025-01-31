/*//////////////////////////////////////////////////////////////////////////////
 Script: 00e_generate_name
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 A Script that generates a random name to be placed upon a stone slab to allow
 a magical portal to be opened. Once a player speaks the name then portal will
 appear and become active.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
void main()
{
    object oModule = GetModule();
    object oUser = GetLastUsedBy();
    object oDragon = GetObjectByTag("ai_dragon");
    if(GetLocalString(oModule, "AI_RUIN_NAME") != "") return;
    string sName = RandomName(Random(23));
    SetName(oDragon, sName);
    SetLocalString(oModule, "AI_RUIN_NAME", sName);
    ai_SendMessages("As you touch the slab of rock the symbols burn into your " +
    "skin forming a name. " + sName, AI_COLOR_RED, oUser);
    PlayVoiceChat(Random(3) + 14, oUser);
}

