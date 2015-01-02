-- get an http resource via uri
-- Lillian Lemmer

HELP = "get <source> <destination>"
BAD_URL = "ERROR: cannot access source"

args = {...}
source = args[1]
destination = args[2]

if source and destination then
    response = http.get(source)
    
    if response == nil then
        print('bad uri')
    else
        response = response.readAll()
        destination_handle = fs.open(destination, 'w')
        destination_handle.write(response)
        destination_handle.close()
    end
    
else
    print(HELP)
end
