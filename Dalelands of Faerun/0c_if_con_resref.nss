/*//////////////////////////////////////////////////////////////////////////////
 Script:0c_if_con_resref
 Programmer:Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks if param equals the NPC's ResRef.
 Parm:
 sResRef - the resref of the npc for this conversation.
 sResRef# - will check for multiple ResRefs up to 10.
 Used to link a single conversation into a convesation for various NPCs.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
int StartingConditional()
{
    int i;
    string sNPC_ResRef = GetScriptParam ("sResRef");
    string sResRef = GetResRef (OBJECT_SELF);
    Debug("0c_if_con_resref", "16", "sNPC_ResRef: " + sNPC_ResRef + " sResRef: " + sResRef);
    if (sResRef == sNPC_ResRef) return TRUE;
    else
    {
        i = 1;
        while (i < 11)
        {
            sNPC_ResRef = GetScriptParam ("sResRef" + IntToString (i));
            if (sResRef == sNPC_ResRef) return TRUE;
            i ++;
        }
    }
    return FALSE;
}
