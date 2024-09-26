/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_cast_polymorp
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Conversation script to setup the tokens for the henchman in the speakers party
 except for who they are talking to.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
void main()
{
    object oSpeaker = OBJECT_SELF;
    object oPC = GetPCSpeaker();
    int nCntr = 1;
    object oHenchman = GetHenchman(oPC, nCntr);
    while(oHenchman != OBJECT_INVALID)
    {
        if(oHenchman != oSpeaker) SetCustomToken(77100 + nCntr, GetName(oHenchman));
        oHenchman = GetHenchman(oPC, ++nCntr);
    }
}
