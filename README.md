# Restore-CCMCache
Robocopies MSI/installer files of two specific programs to ccmcache; a specific issue at a specific workplace. Please note this doesn't actually restore the CCMCache or anything like that. It has a specific purpose (to fix two apps that like to fail because their MSIs disappear from the CCMCache) and is intended for a common issue at a single workplace. 
But it is one of the better scripts I've written, so it would be silly not to have it on my Github.

##  SYNOPSIS
    Robocopies GenoPro or HPE Content Manager over to the specified location.
    Then provides an incident notes template.

    Example incidents where this script was/could be used for quick resolution:
    INC10095204 - GenoPro 
    INC10095420 - HPE Content Manager 

    Licensed under the GNU GPL 3.0. http://www.gnu.org/licenses/gpl-3.0.en.html
    
## DESCRIPTION
    This is a utility for the purposes of easily and quickly copying over the files required when
    a user is facing the "The feature you are trying to use is on a network drive that is 
    currently unavailable." issue for either GenoPro or HPE CM.

    Select which of the two applications are experiencing the issue. 
    Paste in the path that the installer is prompting for.
    Allow Robocopy to transfer the files using multi-threading.
    Advise the user to try again.

    In addition, echos out a short description to be used for the incident ticket.
    Main purpose of this is to not just make resolving these incidents quick and easy,
    but to make it easy to write the notes for it.

## EXAMPLE
    > .\Restore-CCMCache.ps1

## INPUTS
    None. You cannot pipe objects to this script. It is 100% intended to be interactive. 

## LINK
    LinkedIn:  https://www.linkedin.com/in/james-britton-476481123/
    GitHub:    https://github.com/jdbritton

## NOTES
    This script was originally created by James Duncan Britton, without commission or pay.
    Therefore this script is released under the GNU GPL 3.0. http://www.gnu.org/licenses/gpl-3.0.en.html
    You know. Unless my boss tells me to take it down, I guess? (I can't imagine why).
