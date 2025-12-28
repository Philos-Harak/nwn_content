/*////////////////////////////////////////////////
// Sudden feats (Empower, Widen, Maximize, & Extend
// Created By: Philos
////////////////////////////////////////////////
    Fires all Sudden feat scripts.

    Sets a variable that is checked in a spell to automatically use
    the sudden feat. Then it is removed.
/*///////////////////////////////////////////////
#include "0i_s_message"

void main()
{
    int nSpellID = GetSpellId ();
    object oCaster = OBJECT_SELF;
    switch (nSpellID)
    {
        // Sudden Empower.
        case 971:
        {
            SendMessages ("You are prepaired to Empower your next spell!", COLOR_GREEN, oCaster);
            SetLocalInt (oCaster, "0_SUDDEN_EMPOWER", TRUE);
            break;
        }
        // Sudden Widen.
        case 972:
        {
            SendMessages ("You are prepaired to Widen your next spell!", COLOR_GREEN, oCaster);
            SetLocalInt (oCaster, "0_SUDDEN_WIDEN", TRUE);
            break;
        }
        // Sudden Maximize.
        case 973:
        {
            SendMessages ("You are prepaired to Maximize your next spell!", COLOR_GREEN, oCaster);
            SetLocalInt (oCaster, "0_SUDDEN_MAXIMIZE", TRUE);
            break;
        }
        // Sudden Extend.
        case 974:
        {
            SendMessages ("You are prepaired to Extend your next spell!", COLOR_GREEN, oCaster);
            SetLocalInt (oCaster, "0_SUDDEN_EXTEND", TRUE);
            break;
        }
    }
}

