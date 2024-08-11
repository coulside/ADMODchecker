script_name('ADMOD`S Checker') -- �������� �������
script_author('Kostya Shushtikov') -- ����� �������
script_description('Admod`s Checker') -- �������� �������
local count = 0
local filePath = getWorkingDirectory() .. '\\config\\checker_admod.txt'
local sampev = require('lib.samp.events')
local font = renderCreateFont('TimesNewRoman', 14, 5)

-- ������� ��� ������ ���������� �� �����
require "sampfuncs"
require "moonloader"
local sampev = require "samp.events"
local inicfg = require "inicfg"
require "lib.moonloader" -- ����������� ����������
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local function readCountFromFile()
    local file = io.open(filePath, 'r')
    if file then
        local savedCount = file:read('*n')
        file:close()
        return savedCount or 0
    else
        return 0
    end
end

local script_vers = 2
local script_vers_text = "1.05"

local update_url = "https://raw.githubusercontent.com/coulside/admods/main/update.ini" -- ��� ���� ���� ������
local update_path = getWorkingDirectory() .. "/update.ini" -- � ��� ���� ������

local script_url = "" -- ��� ���� ������
local script_path = thisScript().path


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    sampRegisterChatCommand("update", cmd_update)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("���� ����������! ������: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
    
	while true do
        wait(0)

        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("������ ������� ��������!", -1)
                    thisScript():reload()
                end
            end)
            break
        end

	end
end

function cmd_update(arg)
    sampShowDialog(1000, "�������������� v2.0", "{FFFFFF}��� ���� �� ����������\n{FFF000}����� ������", "�������", "", 0)
end

-- ������� ��� ���������� ���������� � ����
local function saveCountToFile()
    local file = io.open(filePath, 'w')
    if file then
        file:write(count)
        file:close()
    end
end

-- ������������� ���������� count ��������� �� �����
count = readCountFromFile()

function sampev.onServerMessage(color, text)
    if text:gsub('{......}',''):find('%[������� .+%] �������� .+ Eric_Huml') then
        count = count + 1
        saveCountToFile()  -- ��������� ���������� ��� ������ ����������
    end
end

function main()
    sampRegisterChatCommand('admods', function(arg)
        count = tonumber(arg)
        saveCountToFile()
        sampAddChatMessage('C������ ADMOD ������� ��: {ff0000}'..arg, -1)
    end)
    while true do
        wait(0)
        local screenX, screenY = getScreenResolution()
        renderFontDrawText(font, '{fffc81}admod: ' .. tostring(count), 1020, screenY / 5, 0xFFFFFFFF)
    end
end