# Define the Workday class
class Workday {
    [string]$Date
    [string]$DayOfWeek
    [string]$StartTime
    [string]$EndTime

    Workday([string]$date, [string]$dayOfWeek, [string]$startTime, [string]$endTime) {
        $this.Date = $date
        $this.DayOfWeek = $dayOfWeek
        $this.StartTime = $startTime
        $this.EndTime = $endTime
    }
}