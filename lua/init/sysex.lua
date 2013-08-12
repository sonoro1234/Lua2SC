
--convert a sysex string to a table
function sysexToTable(dump)
    local len = string.len(dump)
    local tab = {}
    for i=1,len do
        table.insert(tab,string.byte(dump, i))
    end    
    return tab  
end

--convert a sysex string to a hexdump
function sysexToHex(dump)
    local len = string.len(dump)
    local thex = {}
    for i=1,len do
        table.insert(thex, string.format("%02X ",string.byte(dump, i)))
    end    
    return table.concat(thex)    
end



--convert a hex string to a binary string
function fromHex(str)
    local match="(%x%x)[%s%p]*"
    local digits = {}

    function insertDigit(digit)
        table.insert(digits, string.char(('0x'..digit)+0))
        return ""
    end
    string.gsub(str, match, insertDigit)
        
    
    return table.concat(digits)
end

--convert a hex string, integer or table of these into a string
function hexToSysex(dump)

    --simple number
    if type(dump)=='number' then
        return string.char(dump)
    end
    
    --hex block
    if type(dump)=='string' then
        return fromHex(dump)
    end
    
    --table 
    if type(dump)=='table' then
        local dtable = {}
        for i,v in ipairs(dump) do
            --recursively dump elements
            table.insert(dtable, hexToSysex(v))        
        end
        return table.concat(dtable)
    end

end