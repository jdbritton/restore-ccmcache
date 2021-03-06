#==============================================================================
# CCMCACHE RESTORER FOR GENOPRO & HPECM
# 
# Version: 1.0
# Modified: 06/03/2021
# Author: James D. Britton.
# Purpose: For, but not limited to, the Kinetic IT Service Desk
# team for Dept of Communities.
#==============================================================================


function Restore-CCMCache
{
# Locations of the installer files. These may need to be updated in the future.
#
    $sourceGenoPro = "\\dhw.wa.gov.au\appdata\PackageSource\Library\Applications\GenoPro\GenoPro 3.0.1.2"
    $sourceHPECM = "\\dhw.wa.gov.au\appdata\PackageSource\Library\Applications\HPE\Content Manager 9.1.1002\MSI R2"

# Prompting for the effected user's asset/hostname.
#
    Write-Host "__CCMCACHE WMI RESTORER FOR GENOPRO/HPE CONTENT MANAGER__" -ForegroundColor "Green" -BackgroundColor "Black"
    Write-Host "               __By JD Britton, 2021__                   " -ForegroundColor "Green" -BackgroundColor "Black"
    $assetTag = (Read-Host "Please supply the affected configuration item's hostname/asset tag. `nAssetID").Replace(" ","")
    Write-Host "$assetTag -- proceeding with this hostname.`n `n"

# Find out who is signed into the system.
# We're going to get the name of the affected contact, and a whole bunch of other bits of information as well.
    $loggedInUser = Get-WmiObject -Class Win32_ComputerSystem -Property UserName -ComputerName $assetTag
    $loggedInUser = Get-ADUser $loggedInUser.UserName.Replace("HEAD_OFFICE\","") -Properties DisplayName,OfficePhone,ExtensionAttribute15
    $loggedInUserName = $loggedInUser.DisplayName
    $loggedInUserPhone = $loggedInUser.OfficePhone
    $loggedInUserLoc = $loggedInUser.ExtensionAttribute15
    $loggedInUserLocShort = ($loggedInUser.ExtensionAttribute15.split("")[0])
    $assetIPAddress = (Test-NetConnection $assetTag).RemoteAddress.IPAddressToString

    Write-Host "Note: CONFIRM you are dealing with this person, or they have signed on with this person's account, or else this might be the wrong asset."
    Write-Host "Signed on user: $loggedInUserName `n" -ForegroundColor "Black" -BackgroundColor "Red"

# Which application are we dealing with?
#         
    Write-Host "Please select 1 or 2; 1 for GenoPro, 2 for HPE CM" -ForegroundColor "Green" -BackgroundColor "Black"
    Write-Host "    1 - GenoPro                                    "  -ForegroundColor "Green" -BackgroundColor "Black"
    Write-Host "    2 - HPE Content Manager`n                      "  -ForegroundColor "Green" -BackgroundColor "Black"
    [string]$appSelection = Read-Host -Prompt "Please provide either 1 or 2"
        while ($appSelection -ne [string]"1" -and $appSelection -ne [string]"2") 
            {
                Write-Host "Please select either 1 for GenoPro, or 2 for HPE CM. Any other entry not accepted. CTRL+C to quit." -foregroundcolor "RED" -backgroundcolor "BLACK"
                $appSelection = Read-Host -Prompt "Please provide either 1 or 2"
            }


# Where do we need to place the files?
#
    Write-Host "Please connect to the user's computer and get the path being prompted for by the installer. `nThis should look like either: `n
    C:\Windows\CCMCACHE\7\Files\ for GenoPro `n        
    C:\Windows\CCMCACHE\7\ for HPE `n
    If it looks drastically different, e.g. a network location, opt for a location in C:\Temp instead.`n" 
    $destination = Read-Host -Prompt "Please paste in the path being prompted for by the installer."


# Begin setting things up according to which application is required. 
#
    if ($appSelection -eq "1") 
    {
        $source = $sourceGenoPro
        $destination = $destination.replace("C:\","\\$assetTag\C$\").replace(" ","").TrimEnd("\Files\").TrimEnd("\")
        $appname = "GenoPro"
    }

    elseif ($appSelection -eq "2") 
    {
        $source = $sourceHPECM
        $destination = $destination.replace("C:\","\\$assetTag\C$\").replace(" ","").TrimEnd("\")
        $appname = "HPE Content Manager"
    }


# Testing destination path to see if it's accurate.
#
    Write-Host "Will now attempt to validate $source and $destination...`n"

    Try {
    if (-Not (Test-Path $destination)) # Does the filepath supplied exist/is reachable?
        {
            Throw "Failed to validate supplied filepath."
        }
    }

    Catch {
        Write-Warning "Unable to validate this file path. May be unable to connect, or there may be an mistake."
        Write-Error "Failed to find $destination"
        Read-Host "Confirm path is correct, as it could not be validated. If you are certain you wish to continue, press enter. Else, CTRL+C to end."
    }

    Finally {
        Write-Host "Copying over the files from $source to $destination via Robocopy..."
        Robocopy.exe "$source" "$destination" *.* /e /r:20 /w:20 /mt:50 # Finally start copying the files over.
    }



#=================================================================================================#
# Create notes for the incident. Purely for convenience. And because people using the template forget to include 
# the file paths. Please do this, as it greatly aids future/new technicians.

    Write-Host "`nBasic notes for incident.`nCHECK FOR ACCURACY -- Values may not be correct/up-to-date.`nAdd information as necessary. `n`n" -ForegroundColor "Yellow"
    Write-Host "`n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-`n"
    Write-Host "`n
$loggedInUserLocShort - $appname - `"The feature you are trying to use is on a network resource that is unavailable.`"`n
    
When user attempts to open $appname, they receive an error message: `n
`"The feature you are trying to use is on a network resource that is unavailable. 
Click OK to try again, or enter an alternate path to a folder containing the installation package in the box below.`"`n
There is a prompt requesting the location of an MSI, and the location listed is $destination. `n
Troubleshooting Performed:
Copied files from $source to $destination
Advised user to try again after the files finished copying.
Verified user could open the application.
Issue resolved.

-----------------------
User Details
• Name: $loggedInUserName
• Contact Number: $loggedInUserPhone
• Location: $loggedInUserLoc

Scope
• Number of affected users: single user.
• When this was last working: Recently.

Device Details
• Hostname: $assetTag
• IP Address: $assetIPAddress" -BackgroundColor "Black" -ForegroundColor "Yellow"


    Write-Host "`n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-`n"
    Write-Host "Finished."


    <#
    .SYNOPSIS
    Robocopies GenoPro or HPE Content Manager over to the specified location.
    Then provides an incident notes template.

    Example incidents where this script was/could be used for quick resolution:
    INC10095204 - GenoPro 
    INC10095420 - HPE Content Manager 

    Licensed under the GNU GPL 3.0. http://www.gnu.org/licenses/gpl-3.0.en.html

    .DESCRIPTION
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

    .EXAMPLE
    > .\Restore-CCMCache.ps1

    .INPUTS
    None. You cannot pipe objects to this script. It is 100% intended to be interactive. 

    .LINK
    LinkedIn:  https://www.linkedin.com/in/james-britton-476481123/
    GitHub:    https://github.com/jdbritton

    .NOTES
    This script was originally created by James Duncan Britton, without commission or pay.
    Therefore this script is released under the GNU GPL 3.0. http://www.gnu.org/licenses/gpl-3.0.en.html
    #>

}