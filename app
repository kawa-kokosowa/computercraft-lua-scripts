-- add/remove software
-- Lillian Lemmer

-- Update client uses https://bpaste.net/
-- This version of app's resources defaults to 45e718520c8a

-- install, delete, update, sources, deploy, list

args = {...}
command = args[1]
app = args[2]

if command == "install" then
    sources_handle = fs.open('/apps/sources.txt', 'r')
    line = true

    while line do
        line = sources_handle.readLine()
        
        if string.sub(line, 1, string.len(app)) == app then
            source = string.sub(line, string.len(app) + 1)
            break
        end
    end
    
    if source == nil then
        error(app .. ' is not in /apps/sources.txt!')
    end
    
    sources_handle.close()
    response = http.get(source)

    if response == nil then
        print('bad uri')
    else
        response = response.readAll()
        destination_handle = fs.open('/apps/' .. app, 'w')
        destination_handle.write(response)
        destination_handle.close()
    end
elseif command == "list" then
    local installed = fs.list("/apps")
    pkg_use = 0

    for _, file in ipairs(installed) do
        if file ~= "sources.txt" then
            file_size = fs.getSize("/apps/" ..file)
            print(file .. " (" .. file_size .. " bytes)")
            pkg_use = pkg_use + file_size
        end
    end

    print()
    print("pkg using " .. pkg_use .. " bytes; " .. fs.getFreeSpace('/') .. " remaining")
elseif command == "sources" then
    sources_handle = fs.open('/apps/sources.txt', 'r')
    print(sources_handle.readAll())
    sources_handle.close()
elseif command == "update" then
    response = http.get('https://bpaste.net/raw/' .. app)

    if response == nil then
        print('bad uri/invalid sources file')
    else
        response = response.readAll()
        destination_handle = fs.open('/apps/sources.txt', 'w')
        destination_handle.write(response)
        destination_handle.close()
    end
elseif command == "deploy" then
    fs.makeDir('/apps')
    fs.copy(shell.dir() .. '/pkg', '/apps/pkg')
    response = http.get('https://bpaste.net/raw/45e718520c8a')

    if response == nil then
        print('bpaste.net down?')
    else
        response = response.readAll()
        destination_handle = fs.open('/apps/sources.txt', 'w')
        destination_handle.write(response)
        destination_handle.close()
    end
elseif command == "delete" then
    fs.delete('/apps/' .. app)
else
    print(HELP)
end
