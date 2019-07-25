------------------------------------------------------------------------
--- @file timesync.lua
--- @brief (timesync) utility.
--- Utility functions for the timesync_header structs
--- Includes:
--- - timesync constants
--- - timesync header utility
--- - Definition of timesync packets
------------------------------------------------------------------------

--[[
-- Use this file as template when implementing a new protocol (to implement all mandatory stuff)
-- Replace all occurrences of PROTO with your protocol (e.g. sctp)
-- Remove unnecessary comments in this file (comments inbetween [[...]]
-- Necessary changes to other files:
-- - packet.lua: if the header has a length member, adapt packetSetLength;
-- 				 if the packet has a checksum, adapt createStack (loop at end of function) and packetCalculateChecksums
-- - proto/proto.lua: add PROTO.lua to the list so it gets loaded
--]]
local ffi = require "ffi"
require "utils"
require "proto.template"
local initHeader = initHeader

local ntoh, hton = ntoh, hton

---------------------------------------------------------------------------
---- Timesync constants
---------------------------------------------------------------------------

--- Timesync protocol constants
local packetrecord = {}
---------------------------------------------------------------------------
---- Timesync header
---------------------------------------------------------------------------

packetrecord.headerFormat = [[
	uint8_t update_time[6];
	uint8_t residue;
	uint8_t entries;
]]

--- Variable sized member
packetrecord.headerVariableMember = nil

--- Module for timesync_address struct
local packetrecordHeader = initHeader()
packetrecordHeader.__index = packetrecordHeader

--[[ for all members of the header with non-standard data type: set, get, getString
-- for set also specify a suitable default value
--]]

--- Retrieve the num entries.
--- @return entries as A 8 bit integer.
function packetrecordHeader:getEntries()
	return self.entries
end

function packetrecordHeader:isPacketRecordEnd()
	if self.update_time[0] == 0 and self.update_time[1] == 0 and self.update_time[2] == 0 and self.update_time[3] and self.update_time[4] == 0 and self.update_time[5] == 0 then
		return true
	end
	return false
end

function packetrecordHeader:fill(args, pre)
	args = args or {}
	pre = pre or "packetrecord"

end

--- Retrieve the values of all members.
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @return Table of named arguments. For a list of arguments see "See also".
--- @see PROTOHeader:fill
function packetrecordHeader:get(pre)
	pre = pre or "packetrecord"

	local args = {}
	args[pre .. "entries"] = self:getEntries()
	args[pre .. "isprend"] = self:isPacketRecordEnd();
	return args
end

--- Retrieve the values of all members.
--- @return Values in string format.
function packetrecordHeader:getString()
	return "PacketRecord -> Entries:" .. self:getEntries()
end

--- Resolve which header comes after this one (in a packet)
--- For instance: in tcp/udp based on the ports
--- This function must exist and is only used when get/dump is executed on
--- an unknown (mbuf not yet casted to e.g. tcpv6 packet) packet (mbuf)
--- @return String next header (e.g. 'eth', 'ip4', nil)
function packetrecordHeader:resolveNextHeader()
	return nil
end

--- Change the default values for namedArguments (for fill/get)
--- This can be used to for instance calculate a length value based on the total packet length
--- See proto/ip4.setDefaultNamedArgs as an example
--- This function must exist and is only used by packet.fill
--- @param pre The prefix used for the namedArgs, e.g. 'PROTO'
--- @param namedArgs Table of named arguments (see See more)
--- @param nextHeader The header following after this header in a packet
--- @param accumulatedLength The so far accumulated length for previous headers in a packet
--- @return Table of namedArgs
--- @see PROTOHeader:fill
function packetrecordHeader:setDefaultNamedArgs(pre, namedArgs, nextHeader, accumulatedLength)
	return namedArgs
end


------------------------------------------------------------------------
---- Metatypes
------------------------------------------------------------------------
packetrecord.metatype = packetrecordHeader


return packetrecord
