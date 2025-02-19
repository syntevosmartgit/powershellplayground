using module ./Modules/person.psm1
using module ./Modules/bankholidays.psm1

if (Test-Path -Path "./Modules/bankholidays.psm1") {
    Write-Debug "The module './Modules/bankholidays.psm1' could be found."
} else {
    Write-Error "The module './Modules/bankholidays.psm1' could not be found."
}

# Example usage
$person = [Person]::new("John", "Doe",2)

# Define the weekly work schedule as an ordered hashtable
$Schedule = [ordered]@{
    Monday    = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Monday
    Tuesday   = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Tuesday
    Wednesday = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Wednesday
    Thursday  = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Thursday
}

# Combine person and schedule into a single object
$child = [PSCustomObject]@{
    Person = $person
    Schedule = $Schedule
}

# Output the combined object
Write-Output $child

# Save the combined object to a JSON file
$combinedObject | ConvertTo-Json | Set-Content -Path "child.json"

# Save the schedule to a JSON file
$Schedule | ConvertTo-Json | Set-Content -Path "schedule.json"

$person.SaveToFile("person.json")
Write-Output "Person saved to file $person"

$loadedPerson =[Person]::LoadFromFile("person.json")
Write-Output $loadedPerson.FirstName




$startDate = Get-Date -Year 2025 -Month 1 -Day 1
$endDate = Get-Date -Year 2025 -Month 12 -Day 31
$restDateFormat = Get-RestDateFormat
$startDateString = $startDate.ToString($restDateFormat)
$endDateString = $endDate.ToString($restDateFormat)

Write-Output "Start date: $startDateString - End date: $endDateString with format: $restDateFormat"

$holidayArray = Get-AustrianBankHolidays -StartDate $startDateString -EndDate $endDateString

# Output the array to verify
Write-Output "Holidays in 2025:"
Write-Output $holidayArray


# Define an array to hold the data
$daysArray = @()

# Get all days of 2025
$currentDate = $startDate
while ($currentDate -le $endDate) {
    $isHoliday = $false
    $holidayName = ""

    foreach ($holiday in $holidayArray) {
        if ($currentDate.Date -eq $holiday.Date.Date) {
            $isHoliday = $true
            $holidayName = $holiday.Name
            break
        }
    }

    $dayOfWeek = $currentDate.DayOfWeek
    $dayInfo = @{
        Date = $currentDate.ToString('yyyy-MM-dd')
        DayOfWeek = $dayOfWeek
        IsHoliday = $isHoliday
        HolidayName = $holidayName
    }

    # Add the day's information to the array
    $daysArray += $dayInfo

    # if ($isHoliday) {
    #     Write-Debug "$($currentDate.ToString('yyyy-MM-dd')) - $dayOfWeek - Holiday: $holidayName"
    # } else {
    #     Write-Debug "$($currentDate.ToString('yyyy-MM-dd')) - $dayOfWeek - Regular day"
    # }

    $currentDate = $currentDate.AddDays(1)
}

# # Output the array to verify
# $daysArray | ForEach-Object {
#     Write-Output "$($_.Date) - $($_.DayOfWeek) - Holiday: $($_.HolidayName)"
# }

# Save the array to a JSON file
# $daysArray | ConvertTo-Json | Set-Content -Path "daysArray.json"

# # Load the array from the JSON file
# $loadedDaysArray = Get-Content -Path "daysArray.json" | ConvertFrom-Json

# # Display the loaded array
# foreach ($day in $loadedDaysArray) {
#     Write-Output  "$($day.Date) : $($day.DayOfWeek) - Holiday: $($day.HolidayName)"
# }



# # Load the schedule from the JSON file
# $loadedSchedule = Get-Content -Path "schedule.json" | ConvertFrom-Json

# # Display the loaded schedule
# Write-Output "Loaded Schedule:"
# $loadedSchedule.PSObject.Properties | ForEach-Object {
#     Write-Output "$($_.Name): $($_.Value.Start) - $($_.Value.End)"
# }

# Initialize an array to hold workdays
$workdays = @()

# Loop through each day in the year
$currentDate = $startDate
while ($currentDate -le $endDate) {
    # Get the day of the week
    $dayOfWeek = $currentDate.DayOfWeek

    # Check if the current day is a holiday
    $isHoliday = $false
    $holidayName = ""
    foreach ($holiday in $holidayArray) {
        if ($currentDate.Date -eq $holiday.Date.Date) {
            $isHoliday = $true
            $holidayName = $holiday.Name
            break
        }
    }

    # Check if the day is in the schedule and is not a holiday
    if ($Schedule.Contains("$dayOfWeek") -and -not $isHoliday) {
        # Create a custom object for the workday
        $workday = [PSCustomObject]@{
            Date      = $currentDate.ToString('yyyy-MM-dd')
            DayOfWeek = $dayOfWeek.ToString()
            StartTime = $Schedule[$dayOfWeek.ToString()].Start
            EndTime   = $Schedule[$dayOfWeek.ToString()].End
        }
        # Add the workday to the array
        $workdays += $workday
    }

    # Move to the next day
    $currentDate = $currentDate.AddDays(1)
}

# # Output the workdays
# Write-Output "Workdays (excluding holidays):"
# $workdays | ForEach-Object {
#     Write-Output "$($_.Date) - $($_.DayOfWeek): $($_.StartTime) - $($_.EndTime)"
# }

# Save the workdays to a JSON file
#$workdays | ConvertTo-Json | Set-Content -Path "workdays.json"

# Load the workdays from the JSON file
#$loadedWorkdays = Get-Content -Path "workdays.json" | ConvertFrom-Json
# $loadedWorkdays = $workdays

# # Display the loaded workdays
# Write-Output "Loaded Workdays:"
# foreach ($workday in $loadedWorkdays) {
#     Write-Output "$($workday.Date) - $($workday.DayOfWeek): $($workday.StartTime) - $($workday.EndTime)"
# }

# Group workdays by month and convert to JSON-friendly format
$workdaysByMonthForJson = $workdays |
    Group-Object { (Get-Date $_.Date).ToString('yyyy-MM') } |
    ForEach-Object {
        [PSCustomObject]@{
            Month = $_.Name
            Count = $_.Count
            # Optionally include the group if needed, otherwise remove this line
            # Group = $_.Group 
        }
    }

# Output the workdays per month
Write-Output "Workdays per month:"
$workdaysByMonthForJson | ForEach-Object {
    Write-Output "Month: $($_.Month) - Count: $($_.Count)"
}

# Save the workdays per month to a JSON file
$workdaysByMonthForJson | ConvertTo-Json | Set-Content -Path "workdaysByMonth.json"

# # Load the workdays per month from the JSON file
# $loadedWorkdaysByMonth = $workdaysByMonthForJson

# # Display the loaded workdays per month
# Write-Output "Loaded Workdays per month:"
# foreach ($month in $loadedWorkdaysByMonth) {
#     Write-Output "Month: $($month.Name) - Count: $($month.Count)"
# }




