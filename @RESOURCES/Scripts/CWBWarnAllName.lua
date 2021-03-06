function CWBWarnAllName(code)
    local WarnAllName = {
        ["PWS"] = "災防告警訊息",
        ["EQ"] = "地震報告",
        ["TY_WIND"] = "颱風強風告警",
        ["TY_WARN"] = "颱風警報",
        ["TY_NEWS"] = "颱風消息",
        ["FIFOWS"] = "天氣警特報",
        ["W23"] = "熱帶性低氣壓特報",
        ["W24"] = "大規模或劇烈豪雨",
        ["W29"] = "高溫資訊",
        ["W33"] = "大雷雨即時訊息",
        ["W34"] = "即時天氣訊息",
        ["W37"] = "長浪即時訊息"
    }
    if (WarnAllName[code] == nil) then
        return ""
    else
        return WarnAllName[code]
    end
end
