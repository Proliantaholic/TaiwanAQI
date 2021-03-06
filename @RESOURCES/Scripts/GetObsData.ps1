###########################################################
#  By Proliantaholic https://proliantaholic.blogspot.com  #
###########################################################

param (
    [string]$ObsDataPath = ".",
    [string]$BrowserType = "Chrome",
    [string]$stationId = "46692", # 臺北
    [string]$CountyID = "63" # 臺北市
)

[Console]::OutputEncoding=[Text.Encoding]::UTF8
$URL = "https://www.cwb.gov.tw/V8/C/W/OBS_Station.html?ID=$stationId"

if (!(Test-Connection 8.8.8.8 -Quiet) 2>$null) {
    # 網路連線異常
    $StationName = "網路連線異常"
    $obsDataStatus = "網路連線異常"
    $obsDataRowCount = "0"
    $mmdd = Get-Date -Format 'MM/dd'
    $HHMM = Get-Date -Format 'HH:mm'
    $tem = "-"
    $weather = "-"
    $w1 = "-"
    $w2 = "-"
    $w3 = "-"
    $visible = "-"
    $hum = "-"
    $pre = "-"
    $rain = "-"
    $sunlight = "-"
    $SSTimeSunRize = $(Get-Date -Format 'yyyy/MM/dd ') + "06:00"
    $SSTimeSunSet  = $(Get-Date -Format 'yyyy/MM/dd ') + "18:00"
    if (((Get-Date) -ge (Get-Date -Date $SSTimeSunRize)) -and (((Get-Date) -lt (Get-Date -Date $SSTimeSunSet)))) {
        $DayOrNight = 'DAY'
    } else {
        $DayOrNight = 'NIGHT'
    }
    Write-Host $stationId","$StationName","$obsDataStatus","$obsDataRowCount","$mmdd","$HHMM","$tem","$weather","$w1","$w2","$w3","$visible","$hum","$pre","$rain","$sunlight"," -NoNewline
    Write-Host $SSTimeSunRize","$SSTimeSunSet","$DayOrNight"," -NoNewline
    Write-Host 資料來源:中央氣象局全球資訊網","$URL"," -NoNewline
    Write-Host $ObsDataPath","$BrowserType","
    Exit
}

$DriverList = @{ 'Chrome' = 'chromedriver.exe'; 'Edge' = 'msedgedriver.exe'; 'Firefox' = 'geckodriver.exe' }
$WebDriverExe = $DriverList[$BrowserType]
Add-Type -Path "$($ObsDataPath)\WebDriver.dll"

switch ($BrowserType)
{
    'Chrome'  {
                  $BrowserOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                  $BrowserOptions.AddArgument('headless')
                  $BrowserOptions.AddArgument('blink-settings=imagesEnabled=false')
                  $BrowserOptions.PageLoadStrategy = "eager"

                  $service = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($ObsDataPath, $WebDriverExe)
                  $service.HideCommandPromptWindow = $true

                  $BrowserDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($service, $BrowserOptions)
                  Break
              }
    'Edge'    {
                  $BrowserOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
                  $BrowserOptions.UseChromium = $true
                  $BrowserOptions.AddArgument('headless')
                  $BrowserOptions.AddArgument('blink-settings=imagesEnabled=false')
                  $BrowserOptions.PageLoadStrategy = "eager"

                  $service = [OpenQA.Selenium.Edge.EdgeDriverService]::CreateChromiumService($ObsDataPath, $WebDriverExe)
                  $service.HideCommandPromptWindow = $true

                  $BrowserDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($service, $BrowserOptions)
                  Break
              }
    'Firefox' {
                  $BrowserOptions = New-Object OpenQA.Selenium.Firefox.FirefoxOptions
                  $BrowserOptions.AddArgument('--headless')
                  $BrowserOptions.AddArgument('--blink-settings=imagesEnabled=false')
                  $BrowserOptions.PageLoadStrategy = "eager"

                  $service = [OpenQA.Selenium.Firefox.FirefoxDriverService]::CreateDefaultService($ObsDataPath, $WebDriverExe)
                  $service.HideCommandPromptWindow = $true

                  $BrowserDriver = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($service, $BrowserOptions)
                  Break
              }
}

try {
        $BrowserDriver.Navigate().GoToURL($URL)
        Start-Sleep -Seconds 1
        if ($BrowserDriver.FindElementsByXPath('//*[@id="obstime"]/tr').Count -eq 0) {
            $BrowserDriver.Navigate().Refresh()
            Start-Sleep -Seconds 3
        }
        $obsData = $BrowserDriver.FindElementsByCssSelector('#StationData').GetAttribute('outerHTML')
    }
catch {
        $message1 = $_.Exception
        try {
                $BrowserDriver.Navigate().GoToURL($URL)
                $obsData = $BrowserDriver.FindElementsByCssSelector('#StationData').GetAttribute('outerHTML')
            }
        catch {
                $message2 = $_.Exception
              }
      }

switch ($obsDataRowCount = $BrowserDriver.FindElementsByXPath('//*[@id="obstime"]/tr').Count)
{
    0       {   # 無觀測資料或無此測站
                $obsDataStatus = "無觀測資料"
                $time = "-"
                $mmdd = Get-Date -Format 'MM/dd'
                $HHMM = Get-Date -Format 'HH:mm'
                $tem = "-"
                $weather = "-"
                $w1 = "-"
                $w2 = "-"
                $w3 = "-"
                $visible = "-"
                $hum = "-"
                $pre = "-"
                $rain = "-"
                $sunlight = "-"
                Break
            }
    1       {   # 測站儀器故障, 儀器調校中
                $obsDataStatus =  $BrowserDriver.FindElementsByCssSelector('#obstime > tr:nth-child(1)').Text
                $time = "-"
                $mmdd = Get-Date -UFormat '%m/%d'
                $HHMM = Get-Date -UFormat '%H:%M'
                $weather = "-"
                if ($obsDataStatus -eq "儀器故障") {
                    $tem = "儀器故障"
                    $w1 = "儀器故障"
                    $w2 = "儀器故障"
                    $w3 = "儀器故障"
                    $visible = "儀器故障"
                    $hum = "儀器故障"
                    $pre = "儀器故障"
                    $rain = "儀器故障"
                    $sunlight = "儀器故障"
                } else {
                    $tem = "儀器調校中"
                    $w1 = "儀器調校中"
                    $w2 = "儀器調校中"
                    $w3 = "儀器調校中"
                    $visible = "儀器調校中"
                    $hum = "儀器調校中"
                    $pre = "儀器調校中"
                    $rain = "儀器調校中"
                    $sunlight = "儀器調校中"
                }
                Break
            }
    default {   # 正常 (10分鐘更新150列, 1小時更新25列)
                $obsDataStatus = "正常"
                $time = $BrowserDriver.FindElementByXPath('//*[@id="obstime"]/tr/th[@headers="time"]').Text
                $mmdd = $time -replace '(.*)\r\n(.*)','$1'
                $HHMM = $time -replace '(.*)\r\n(.*)','$2'
                $tem = $BrowserDriver.FindElementByXPath('//*[@id="obstime"]/tr[1]/td[@headers="temp"]').Text
                if (($BrowserDriver.FindElementsByXPath('//*[@id="obstime"]/tr[1]/td[@headers="weather"]/img').Count) -ne 0) { 
                    $weather = $BrowserDriver.FindElementByXPath('//*[@id="obstime"]/tr[1]/td[@headers="weather"]/img').getAttribute('title')
                } else {
                    $weather = "-"
                }
                $w1 = $BrowserDriver.FindElementByXPath('//*[@id="obstime"]/tr[1]/td[@headers="w-1"]/span[@class="wind"]').getAttribute('innerHTML')
                if ($w1 -eq "－") { $w1 = "-" } # Replace Unicode minus sign U+FF0D "－" ef bc 8d
                $w2 = $BrowserDriver.FindElementByXPath('//*[@id="obstime"]/tr[1]/td[@headers="w-2"]/span[@class="wind_1 is-active"]').getAttribute('innerHTML')
                $w3 = $BrowserDriver.FindElementByXPath('//*[@id="obstime"]/tr[1]/td[@headers="w-3"]/span[@class="wind_1 is-active"]').getAttribute('innerHTML')
                $visible = $BrowserDriver.FindElementByCssSelector('#obstime > tr:nth-child(1) > td:nth-child(7)').getAttribute('innerHTML')
                $hum = $BrowserDriver.FindElementByCssSelector('#obstime > tr:nth-child(1) > td:nth-child(8)').getAttribute('innerHTML')
                $pre = $BrowserDriver.FindElementByCssSelector('#obstime > tr:nth-child(1) > td:nth-child(9)').getAttribute('innerHTML')
                $rain = $BrowserDriver.FindElementByCssSelector('#obstime > tr:nth-child(1) > td:nth-child(10)').getAttribute('innerHTML')
                $sunlight = $BrowserDriver.FindElementByCssSelector('#obstime > tr:nth-child(1) > td:nth-child(11)').getAttribute('innerHTML')
                Break
            }
}

if ($obsDataStatus -ne "無觀測資料") {
    try {
            $StationName = [regex]::Match($obsData,"data-cstname=`"(.*)`" data-estname").captures.groups[1].value
        }
    catch {
            $StationName = "$stationId $obsDataStatus"
          }
} else {
    $StationName = "無觀測資料或無此測站"
}

# SStime
if ($StationName -ne "無觀測資料或無此測站") {
    $SStimeURL = "https://www.cwb.gov.tw/V8/C/W/County/MOD/SunMoon/$($CountyID)_SunMoon.html"
} else {
    $SStimeURL = "https://www.cwb.gov.tw/V8/C/W/County/MOD/SunMoon/63_SunMoon.html"
}
try {
        $Header = 'P01','PStationName','PDataStatus','P04','P05','P06','P07','P08','P09','P10','P11','P12','P13','P14','P15','P16','PSSTimeSunRize','PSSTimeSunSet','P19','P20','P21','P22','P23'
        $P = Import-Csv "$ObsDataPath\ObsData.txt" -Header $Header -Encoding Unicode
        if (((Get-Date -Date $P.PSSTimeSunRize).DayOfYear -ne (Get-Date).DayOfYear) -or ($P.PDataStatus -eq "網路連線異常") -or ($P.PStationName -ne $StationName)) {
            $BrowserDriver.Navigate().GoToURL($SStimeURL)
            $SSTimeDay = $BrowserDriver.FindElementByCssSelector('body > div.panel-heading').Text
            $SSTimeSunRize = $BrowserDriver.FindElementByCssSelector('body > div.flex_table > table > tbody > tr > td:nth-child(1)').Text
            $SSTimeSunSet = $BrowserDriver.FindElementByCssSelector('body > div.flex_table > table > tbody > tr > td:nth-child(2)').Text
            $SSTimeSunRize = $(Get-Date -Format 'yyyy/') + $SSTimeDay + " " + $SSTimeSunRize
            $SSTimeSunSet = $(Get-Date -Format 'yyyy/') + $SSTimeDay+ " " + $SSTimeSunSet
        } else {
            $SSTimeSunRize = $P.PSSTimeSunRize
            $SSTimeSunSet = $P.PSSTimeSunSet
        }
    }
catch {
        $BrowserDriver.Navigate().GoToURL($SStimeURL)
        $SSTimeDay = $BrowserDriver.FindElementByXPath('/html/body/div[1]').Text
        $SSTimeSunRize = $BrowserDriver.FindElementByXPath('/html/body/div[2]/table/tbody/tr/td[1]').Text
        $SSTimeSunSet = $BrowserDriver.FindElementByXPath('/html/body/div[2]/table/tbody/tr/td[2]').Text
        $SSTimeSunRize = $(Get-Date -Format 'yyyy/') + $SSTimeDay + " " + $SSTimeSunRize
        $SSTimeSunSet = $(Get-Date -Format 'yyyy/') + $SSTimeDay+ " " + $SSTimeSunSet
      }

# DAY or NIGHT
if (((Get-Date) -ge (Get-Date -Date $SSTimeSunRize)) -and (((Get-Date) - (Get-Date -Date $SSTimeSunSet)).TotalMinutes -lt -15)) {
    $DayOrNight = 'DAY'
} else {
    $DayOrNight = 'NIGHT'
}

$BrowserDriver.Quit()

Write-Host $stationId","$StationName","$obsDataStatus","$obsDataRowCount","$mmdd","$HHMM","$tem","$weather","$w1","$w2","$w3","$visible","$hum","$pre","$rain","$sunlight"," -NoNewline
Write-Host $SSTimeSunRize","$SSTimeSunSet","$DayOrNight"," -NoNewline
Write-Host 資料來源:中央氣象局全球資訊網","$URL"," -NoNewline
Write-Host $ObsDataPath","$BrowserType","


# $stationId       ->  [ObsData1StationId]             ; 測站站號
# $StationName     ->  [ObsData2StationName]           ; 測站站名 
# $obsDataStatus   ->  [ObsData3DataStatus]            ; 測站狀態 (正常, 儀器故障, 儀器調校中, 網路連線異常)
# $obsDataRowCount ->  [ObsData4DataRowCount]          ; 觀測資料列數 (判斷測站狀態依據)
# $mmdd            ->  [ObsData5DataTimemmdd]          ; 觀測時間 (月日)
# $HHMM            ->  [ObsData6DataTimeHHMM]          ; 觀測時間 (時分)
# $tem             ->  [ObsData7TEMP]                  ; 溫度
# $weather         ->  [ObsData8Weather]               ; 天氣狀況
# $w1              ->  [ObsData9WindDirection]         ; 風向
# $w2              ->  [ObsData10Wind]                 ; 風力(級)
# $w3              ->  [ObsData11Gust]                 ; 陣風(級)
# $visible         ->  [ObsData12Visibility]           ; 能見度(公里)
# $hum             ->  [ObsData13HUMD]                 ; 相對濕度(%)
# $pre             ->  [ObsData14AtmosphericPressure]  ; 海平面氣壓(百帕)
# $rain            ->  [ObsData15Rain1day]             ; 當日累積雨量(毫米)
# $sunlight        ->  [ObsData16Sunlight]             ; 日照時數
# $SSTimeSunRize   ->  [ObsData17SSTimeSunRize]        ; 日出時刻 yyyy/mm/dd HH:MM -> HH:MM
# $SSTimeSunSet    ->  [ObsData18SSTimeSunSet]         ; 日沒時刻 yyyy/mm/dd HH:MM -> HH:MM
# $DayOrNight      ->  [ObsData19DayOrNight]           ; 白天夜晚 (DAY, NIGHT)

# 資料來源:中央氣象局全球資訊網  ->  [ObsData20DataSource]   ; 資料來源聲明
# $URL                           ->  [ObsData21URL]          ; 資料來源URL
# $ObsDataPath                   ->  [ObsData22ObsDataPath]  ; ObsData路徑
# $BrowserType                   ->  [ObsData23BrowserType]  ; 瀏覽器 (Edge, Chrome, Firefox)
