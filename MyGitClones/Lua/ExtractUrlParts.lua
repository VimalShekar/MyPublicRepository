print ("Hello, World!")

-- lua function to extract parts from URI and put them into a table
function StringStartsWith(str, pattern)
    return pattern == '' or string.sub(str, 1, string.len(pattern)) == pattern
end

function StringSplit(str, sep)
    if sep == nil then sep = "%s" end
    local t={}
    for s in string.gmatch(str, "([^"..sep.."]+)") do table.insert(t, s) end
    return t
end

function ExtractPartsFromUri(uri)
    -- example:   https://www.example.com:8080/path/to/file?query=string#fragment
    -- result:    { scheme = "https", host = "www.example.com", port = "8080", path = "/path/to/file?query=string#fragment" }
    local result = {}
    
    if(StringStartsWith(uri, "http") or StringStartsWith(uri, "ftp")) then
        local scheme, host, path = uri:match("^(%w+)://([^/]+)/(.+)$") 
        --print(string.format("scheme:[%s]  host:[%s] path:[%s] ", scheme, host, path))
        if (scheme) and (host) then -- as long as scheme and host are not nil            
            if(host:find(":", 1, true)) then
                parts = StringSplit(host, ":")
                --print(string.format("host:[%s] port[%s]", parts[1], parts[2]))
                result.host = parts[1]
                result.port = parts[2]
            else
                result.host = host
            end
            result.scheme = scheme
            result.path = path
        end
    end

    -- example: \\server\share\path\to\file
    -- result: { scheme = "smb", host = "server", path = "/share/path/to/file" }
    if(StringStartsWith(uri, "\\\\")) then
        local host, path = uri:match("^\\\\([^\\]+)\\([^\\].*)$")
        if host then
            result.scheme = "smb"
            result.host = host
            result.path = path
        end
    end

    return result
end




testcases = {
    [[https://192.168.20.33:8443/login.aspx]],
    [[http://192.168.20.33/download/sdfsdfs]],
    [[https://www.example.com:8080/path/to/file?query=string#fragment]],
    [[http://somesite/sites/something%20wiki/somefile.zip]],        
    [[ftp://192.168.20.33/download/ftppath.png]],
    [[ftp://domain.com/ftppath.png]],
    [[\\server\share\file]],
    [[\\mydc01.corp.domain.com\sysvol\logonscript\{aabb00000-0000-0000-0000-00000000ddff}\logon.ps1]],
    [[\\192.168.1.1\sysvol\logonscript\logon.ps1]],
    [[https://somecopany-my.sharepoint.com/:x:/g/personal/ssssss_cccccc_com/ESSSSTTTTTUUUUuuuuuVVVyyy?e=mOneYs]],
    [[https://github.com/someuser/somerepo/raw/master/Invoke-SomeScript.ps1]],
    [[https://raw.githubusercontent.com/someuser/somerepo/master/Invoke-SomeScript.ps1]],
    [[https://www.pastebin.com/c12345Ab]],    
    [[\\myserver]],  -- ignore if no path component
    [[https://gmail.com]], -- ignore if no path component
    [[https://google.com/]], -- ignore if no path component
}

for _,uri in ipairs(testcases) do
    print("testcase: " .. uri)
    local parts = ExtractPartsFromUri(uri)
    if(parts) then
        -- print the components of the table
        for k,v in pairs(parts) do
            print(k .. " = " .. v)
        end
        print("")
    end
end
