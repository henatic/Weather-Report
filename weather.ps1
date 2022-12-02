#   https://api.weather.gov/points/39.7456,-97.0892

$locations = New-Object -TypeName "System.Collections.ArrayList"

#Weott
#https://www.weather.gov/wrh/WxTable?LAT=40.3290&LNG=-123.9190&DAYS=7&INT=6&CWA=eka
$locations.Add( @("Weott", "40.3290", "-123.9190") )

#Salyer
#https://www.weather.gov/wrh/WxTable?LAT=40.9020&LNG=-123.5780&DAYS=7&INT=6&CWA=eka
$locations.Add( @("Salyer", "40.9020", "-123.5780") )

#Dinsmore
#https://www.weather.gov/wrh/WxTable?LAT=40.4920&LNG=-123.6110&DAYS=7&INT=6&CWA=eka
$locations.Add( @("Dinsmore", "40.4920", "-123.6110") )

#Eureka
#https://www.weather.gov/wrh/WxTable?LAT=40.7880&LNG=-123.1390&DAYS=7&INT=6&CWA=eka
$locations.Add( @("Eureka", "40.7880", "-123.1390") )

#Bridgeville
#https://www.weather.gov/wrh/WxTable?LAT=40.4650&LNG=-123.7800&DAYS=7&INT=6&CWA=eka
$locations.Add( @("Bridgeville", "40.4650", "-123.7800") )

#Trinidad
#https://www.weather.gov/wrh/WxTable?LAT=41.0590&LNG=-124.1280&DAYS=7&INT=6&CWA=eka
$locations.Add( @("Trinidad", "41.0590", "-124.1280") )




# Start building message body. 

$msg = new-object Net.Mail.MailMessage
$msg.From = "weather@mercerfraser.com"
$msg.ReplyTo = "weather@mercerfraser.com"
$msg.To.Add("weather@mercerfraser.com")
$msg.subject = "Weather Report"
$msg.IsBodyHtml = $True
$msg.Body = "<p>https://weather.gov</p>"



foreach( $location in $locations )
{
    $geodataUri = "https://api.weather.gov/points/$($location[1]),$($location[2])"
    $attempts=3    
    $sleepInSeconds=5
    do
    {
        try
        {
            $geodata = Invoke-RestMethod -uri $geodataUri
            break;
        }
        catch [Exception]
        {
            Write-Host $_.Exception.Message
        }            
        $attempts--
        if ($attempts -gt 0) { sleep $sleepInSeconds }
    } while ($attempts -gt 0) 






    $griddataUri = $geodata.properties.forecastGridData
    $attempts=3    
    $sleepInSeconds=5
    do
    {
        try
        {
            $griddata = Invoke-RestMethod -uri $griddataUri
            break;
        }
        catch [Exception]
        {
            Write-Host $_.Exception.Message
        }            
        $attempts--
        if ($attempts -gt 0) { sleep $sleepInSeconds }
    } while ($attempts -gt 0) 


    $forecastUri = $griddataUri + "/forecast"

    $probPrecip = @()
    $quanPrecip = @()
    $probPrecip += $griddata.properties.probabilityOfPrecipitation.values[0].value.ToString().PadLeft( 2, "0" ) + "%"
    $probPrecip += $griddata.properties.probabilityOfPrecipitation.values[1].value.ToString().PadLeft( 2, "0" ) + "%"
    $probPrecip += $griddata.properties.probabilityOfPrecipitation.values[2].value.ToString().PadLeft( 2, "0" ) + "%"
    $probPrecip += $griddata.properties.probabilityOfPrecipitation.values[3].value.ToString().PadLeft( 2, "0" ) + "%"
    $quanPrecip += ($griddata.properties.quantitativePrecipitation.values[0].value*0.0393701).ToString()
    $quanPrecip[0] = $quanPrecip[0].ToString().substring(0,[Math]::Min($quanPrecip[0].ToString().length, 4)) + "in"
    $quanPrecip += ($griddata.properties.quantitativePrecipitation.values[1].value*0.0393701).ToString()
    $quanPrecip[1] = $quanPrecip[1].ToString().substring(0,[Math]::Min($quanPrecip[1].ToString().length, 4)) + "in"
    $quanPrecip += ($griddata.properties.quantitativePrecipitation.values[2].value*0.0393701).ToString()
    $quanPrecip[2] = $quanPrecip[2].ToString().substring(0,[Math]::Min($quanPrecip[2].ToString().length, 4)) + "in"
    $quanPrecip += ($griddata.properties.quantitativePrecipitation.values[3].value*0.0393701).ToString()
    $quanPrecip[3] = $quanPrecip[3].ToString().substring(0,[Math]::Min($quanPrecip[3].ToString().length, 4)) + "in"

    $msg.Body += @" 

    <b>$($location[0])</b>
    <pre>
    https://forecast.weather.gov/MapClick.php?lat=$($location[1])&lon=-$($location[2])&unit=0&lg=english&FcstType=graphical
    
    Probability of Precipitation:
    $probPrecip
    Quantitative Precipitation:
    $quanPrecip
    </pre>
"@


}


#$msg.Body




$smtpServer = "mail.mercerfraser.com"
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($msg)
$msg.Dispose();


