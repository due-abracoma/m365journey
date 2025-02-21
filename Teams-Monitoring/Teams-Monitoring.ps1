#Import the neccessary modules

Import-Module Microsoft.Graph.Teams
Import-Module Microsoft.Graph.Users.Actions

$ClientId = "<ClientID>"
$CertificateThumbprint = "<Thumbprint>"
$TenantID = "<TenantID>"

Connect-MgGraph -ClientId $ClientId -CertificateThumbprint $CertificateThumbprint -TenantId $TenantID -NoWelcome

#Create a Team

$DisplayNameTeam = "Monitoring - pls ignore"

$params = @{
    "template@odata.bind" = "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
    displayName           = $DisplayNameTeam
    description           = "Monitoring - pls ignore"
    visibility            = "Private"
    members               = @(
        @{
            "@odata.type"     = "#microsoft.graph.aadUserConversationMember"
            roles             = @(
                "owner"
            )
            "user@odata.bind" = "https://graph.microsoft.com/v1.0/users('<upn@ofuser>')"
        }
    )
}

try {
    New-MgTeam -BodyParameter $params
}
catch {
    $params = @{
        message         = @{
            subject      = "Error in monitoring flow - couldn't create a Team"
            body         = @{
                contentType = "Text"
                content     = "A new team couldn't be created by the automatic monitoring task, please check if there are any issues."
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = "<mailaddressWhereAlertsComeFrom>"
                    }
                }
            )
        }
        saveToSentItems = "false"
    }
    Send-MgUserMail -UserId "<mailaddressWhereAlertsComeFrom>" -BodyParameter $params
}

Start-Sleep -Seconds 60 #otherwise, the script will throw errors because not all groups are correct provisioned if this step would be skipped

#Add a channel to the newly created Team
$TeamID = Get-MgTeam | Where-Object DisplayName -eq $DisplayNameTeam | Select-Object -ExpandProperty Id
$MonitoringChannelName = "Monitoring Channel"
try {
    $params = @{
        displayName    = $MonitoringChannelName
        description    = "This channel will be gone in a few moments, pls ignore"
        membershipType = "standard"
    }
    
    New-MgTeamChannel -TeamId $TeamID -BodyParameter $params
    
}
catch {
    $params = @{
        message         = @{
            subject      = "Error in monitoring flow - couldn't create a channel"
            body         = @{
                contentType = "Text"
                content     = "Couldn't create a channel inside of the Team $DisplayNameTeam"
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = "<mailaddressWhereAlertsComeFrom>"
                    }
                }
            )
        }
        saveToSentItems = "false"
    }
    Send-MgUserMail -UserId "<mailaddressWhereAlertsComeFrom>" -BodyParameter $params
}

Start-Sleep -Seconds 20
#Delete the channel
$ChannelId = Get-MgTeamChannel -TeamId $TeamId | Where-Object DisplayName -eq $MonitoringChannelName | Select-Object -ExpandProperty Id

try {
    Remove-MgTeamChannel -TeamId $TeamID -ChannelId $ChannelId
}
catch {
    $params = @{
        message         = @{
            subject      = "Error in monitoring flow - couldn't delete the channel $MonitoringChannelName"
            body         = @{
                contentType = "Text"
                content     = "Couldn't delete the Channel $MonitoringChannelName. Please check why this happened and remove the Team manually in TAC"
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = "<mailaddressWhereAlertsComeFrom>"
                    }
                }
            )
        }
        saveToSentItems = "false"
    }
    Send-MgUserMail -UserId "<mailaddressWhereAlertsComeFrom>" -BodyParameter $params
}

Start-Sleep -Seconds 10

#Delete the Team
try {
    $GroupID = Get-MgGroup | Where-Object DisplayName -eq $DisplayNameTeam | Select-Object -ExpandProperty Id
}
catch {
    $params = @{
        message         = @{
            subject      = "Error in monitoring flow - couldn't get the Group ID"
            body         = @{
                contentType = "Text"
                content     = "Couldn't get the group ID to delete the test Team. Please check why this happened and remove the Team manually in TAC"
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = "<mailaddressWhereAlertsComeFrom>"
                    }
                }
            )
        }
        saveToSentItems = "false"
    }
    Send-MgUserMail -UserId "<mailaddressWhereAlertsComeFrom>" -BodyParameter $params
}


try {
    Remove-MgGroup -GroupId $GroupID
}
catch {
    $params = @{
        message         = @{
            subject      = "Error in monitoring flow - couldn't delete the Group $GroupID"
            body         = @{
                contentType = "Text"
                content     = "Couldn't delete the Group $GroupID. Please check why this happened and remove the Team manually in TAC"
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = "<mailaddressWhereAlertsComeFrom>"
                    }
                }
            )
        }
        saveToSentItems = "false"
    }
    Send-MgUserMail -UserId "<mailaddressWhereAlertsComeFrom>" -BodyParameter $params
}

Disconnect-MgGraph