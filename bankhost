function deploy()
    -- create the directories needed for bankhost to run
    
    if not fs.exists('bankhost') then
        fs.makeDir('bankhost')
    end
        
    if not fs.exists ('bankhost/userfiles') then
        fs.makeDir('bankhost/userfiles')
    end
end

function parse_userfile(user)
    -- Read a user database flatfile into a table
    --
    -- Args:
    --   user (str): userfile to lookup
    --
    -- Returns: 
    --   {pin, balance} or nil if no such userfile

    target_userfile = 'bankhost/userfiles/' .. tostring(user)
    
    if not fs.exists(target_userfile) then
        return nil
    end
    
    print(target_userfile)
    userfile_handle = fs.open(target_userfile, 'r')
    lines = {}
    line = true
    
    while line do
        line = userfile_handle.readLine()
        table.insert(lines, line)
    end
    
    userfile_handle.close()
    pin = lines[1]
    balance = lines[2]
    
    return pin, balance
end

function rednet_getargs()
    -- Listen for banknet arguments
    --
    -- Returns:
    --   senderId and args or nil
    
    senderId, message = rednet.receive(30)
    
    if message == nil then
        return nil
    else
        print('NEW SESSION: ' .. senderId)
        args = {}
        
        for arg in string.gmatch(message, "%w+") do
            table.insert(args, arg)
        end

        return senderId, args
    end
end

-- RUNTIME
deploy()
--rednet.host("banknet", "TRUSTED_BANK")

while 1 do
    senderId, args = rednet_getargs()

    if args == nil then
        print('RETRYING...')
    elseif args[1] == "send" then
        pin_attempt = args[2]
        send_amount = args[3]
        target_id = args[4]
        
        -- fetch sender's correct pin and current balance
        sender_correct_pin, sender_balance = parse_userfile(senderId)
        
        if sender_correct_pin == nil then
            print(senderId .. ": NO SUCH USER FILE (SENDER)")
            rednet.send(senderId, "ERROR: NO SUCH USER FILE (SENDER)")
            break
        end
        
        print(senderId .. ": FOUND SENDER USERFILE")
        
        -- check pin
        if pin_attempt ~= sender_correct_pin then
            print(pin_attempt .. " " .. sender_correct_pin)
            print(senderId .. ": PIN INCORRECT")
            rednet.send(senderId, "ERROR: BAD PIN")
            break
        end
        
        print(senderId .. ": PIN CORRECT")
        
        -- check balance: is there even enough for this transaction?
        if send_amount > sender_balance then
            print(senderId .. ": INSUFFICIENT BALANCE")
            rednet.send(senderId, "ERROR: INSUFFICIENT BALANCE")
            break
        end

        -- validate target userfile info, get balance
        target_pin, target_balance = parse_userfile(target_id)
        
        if target_pin == nil then
            print(senderId .. ": NO SUCH USER FILE (TARGET)")
            rednet.send(senderId, "ERROR: NO SUCH USER FILE (TARGET)")
            break
        end
        
        print(senderId .. ": FOUND TARGET USERFILE")
        
        -- add money to target's account
        target_new_balance = tonumber(target_balance) + send_amount
        target_userfile = fs.open('bankhost/userfiles/' .. target_id, 'w')
        new_target_info = target_pin .. "\n" .. target_new_balance
        target_userfile.write(new_target_info)
        target_userfile.close()
        
        print(senderId .. ": UPDATED TARGET USERFILE")
        
        -- lastly: subtract from sender
        sender_new_balance = sender_balance - send_amount
        userfile_handle = fs.open('bankhost/userfiles/' .. senderId, 'w')
        new_sender_data = sender_correct_pin .. "\n" .. sender_new_balance
        userfile_handle.write(new_sender_data)
        userfile_handle.close()
        
        print(senderId .. ": UPDATED SENDER USERFILE")

        print(senderId .. ": SUCCESS")
        rednet.send(senderId, "SUCCESS")
    elseif arg[1] == "balance" then
        break
    end
end
