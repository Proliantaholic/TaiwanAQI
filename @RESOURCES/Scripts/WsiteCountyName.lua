function WsiteCountyName(county)
    local CountyName = {
        ["基隆"] = "Keelung",
        ["彭佳嶼"] = "Keelung",
        ["臺北"] = "Taipei",
        ["鞍部"] = "Taipei",
        ["陽明山"] = "Taipei",
        ["板橋"] = "NewTaipeiCity",
        ["新屋"] = "Taoyuan",
        ["新竹"] = "Hsinchu",
        ["臺中"] = "Taichung",
        ["梧棲"] = "Taichung",
        ["玉山"] = "Nantou",
        ["日月潭"] = "Nantou",
        ["嘉義"] = "Chiayi",
        ["阿里山"] = "Chiayi",
        ["臺南"] = "Tainan",
        ["高雄"] = "Kaohsiung",
        ["南沙島"] = "Kaohsiung",
        ["東沙島"] = "Kaohsiung",
        ["恆春"] = "Pingtung",
        ["蘇澳"] = "Yilan",
        ["宜蘭"] = "Yilan",
        ["花蓮"] = "Hualien",
        ["大武"] = "Taitung",
        ["成功"] = "Taitung",
        ["蘭嶼"] = "Taitung",
        ["臺東"] = "Taitung",
        ["東吉島"] = "Penghu",
        ["澎湖"] = "Penghu",
        ["金門"] = "Kinmen",
        ["馬祖"] = "Matsu"
    }
    if (CountyName[county] == nil) then
        return "Taipei"
    else
        return CountyName[county]
    end
end
