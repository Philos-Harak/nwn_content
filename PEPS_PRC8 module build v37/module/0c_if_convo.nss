/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_if_convo
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that check if oCreature has a linked conversation.
 Only checks for Henchman.
 Allows use of ai_conversation for henchman in other modules.
*///////////////////////////////////////////////////////////////////////////////
#include "nw_inc_gff"
#include "0i_messages"
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    if(GetAssociateType(oHenchman) == ASSOCIATE_TYPE_HENCHMAN)
    {
        json jHenchman = ObjectToJson(oHenchman);
        string sConversation = JsonGetString(GffGetResRef(jHenchman, "Conversation"));
        if(sConversation != "") return TRUE;
    }
    return FALSE;
}
