using module ./Modules/person.psm1
using module ./Modules/bankholidays.psm1

# Check if the execution directory is the script directory
if ($PSScriptRoot -ne (Get-Location)) {
    Write-Error "The execution directory is not the script directory. Please change to the script directory. $PSScriptRoot"
    Exit 1
}

# verify that the modules can be loaded
if (Test-Path -Path "./Modules/bankholidays.psm1") {
    Write-Debug "The module './Modules/bankholidays.psm1' could be found."
} else {
    Write-Error "The module './Modules/bankholidays.psm1' could not be found."
    Exit 1
}

if (Test-Path -Path "./Modules/person.psm1") {
    Write-Debug "The module './Modules/person.psm1' could be found."
} else {
    Write-Error "The module './Modules/person.psm1' could not be found."
    Exit 1
}

$startDate = Get-Date -Year 2025 -Month 1 -Day 1
$endDate = Get-Date -Year 2025 -Month 12 -Day 31

# Combine person and schedule into a single object
$child = [PSCustomObject]@{
    Person = [Person]::new("John", "Doe",2)
    Schedule = [ordered]@{
        Monday    = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Monday
        Tuesday   = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Tuesday
        Wednesday = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Wednesday
        Thursday  = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Thursday
    }
}

# Save the combined object to a JSON file
$child | ConvertTo-Json | Set-Content -Path "child.json"

$restDateFormat = Get-RestDateFormat
$startDateString = $startDate.ToString($restDateFormat)
$endDateString = $endDate.ToString($restDateFormat)

Write-Output "Start date: $startDateString - End date: $endDateString with format: $restDateFormat"

$holidayArray = Get-AustrianBankHolidays -StartDate $startDateString -EndDate $endDateString

Write-Output "Feiertage $($holidayArray.Count)"

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

    $currentDate = $currentDate.AddDays(1)
}

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
    if ($Child.Schedule.Contains("$dayOfWeek") -and -not $isHoliday) {
        # Create a custom object for the workday
        $workday = [PSCustomObject]@{
            Date      = $currentDate.ToString('yyyy-MM-dd')
            DayOfWeek = $dayOfWeek.ToString()
            StartTime = $child.Schedule[$dayOfWeek.ToString()].Start
            EndTime   = $child.Schedule[$dayOfWeek.ToString()].End
        }
        # Add the workday to the array
        $workdays += $workday
    }

    # Move to the next day
    $currentDate = $currentDate.AddDays(1)
}

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