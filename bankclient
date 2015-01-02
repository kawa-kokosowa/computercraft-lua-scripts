TRUSTED_HOST = 16

args = {...}
send = args[1]
pin = args[2]
amount = args[3]
target_id = args[4]

rednet.open('back')
rednet.send(TRUSTED_HOST, send .. " " .. pin .. " " .. amount .. " " .. target_id)
senderId, message, protocol = rednet.receive(60)
print(message)
rednet.close('back')
