# Storyline: List services and then give user option to view stopped, running, or all services

function select_service () {

    cls

    # List all registered services
    Get-Service

    # Declare array with 3 predetermined values
    $arrService =@('all','stopped','running')

    $readService = Read-Host -Prompt "Would you like to view 'all' services, 'stopped' services, or 'running' services? Alternatively, enter 'q' to quit."

    # Check if the user wants to quit.
    if ($readService -match "^[qQ]$") {
        
        # Stop executing the program and close the script
        break
}

service_check -serviceToSearch $readService

}

function service_check() {
    
    # String the user types in within the select_service function
    Param([string]$serviceToSearch)

    # Set variable $theService
    $theService = "$serviceToSearch"

    # If the input status exists in the $arrService array list the related services
    if ($arrService -match $theService){

        write-host -BackgroundColor Green -ForegroundColor white "Please wait, it may take a few moments to retrieve the service entries."
        sleep 2

        # Call the function to view the service
        view_service -serviceToSearch $serviceToSearch

        # If not tell the user that those services don't exist
        } else {

            write-host -BackgroundColor red -ForegroundColor white "Invalid value."

            sleep 2

            select_service

        }

    } # Ends the service_check()

function view_service () {

    cls

    if ($serviceToSearch -eq "all") {

    Get-Service | Sort-Object -Property Status, Name

    # Pause the screen and wait until the user is ready to proceed.
    read-host -Prompt "Press enter when you are done."

    # Go back to select_service
    select_service

    } else {

    # Gets the services
    Get-Service | Where-Object {$_.Status -eq $serviceToSearch} | Sort-Object -Property Name

    # Pause the screen and wait iuntil the user is ready to proceed.
    read-host -Prompt "Press enter when you are done."

    # Go back to select_service
    select_service

    }

} # Ends the view_service()

select_service