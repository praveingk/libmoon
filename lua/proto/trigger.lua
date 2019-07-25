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


--- Timesync protocol constants
local trigger = {}
---------------------------------------------------------------------------
---- Timesync header
---------------------------------------------------------------------------

trigger.headerFormat = [[
	uint32_t trigger_id;
	uint32_t trigger_hit_time;
	uint8_t  trigger_origin;
]]

--- Variable sized member
trigger.headerVariableMember = nil

--- Module for timesync_address struct
local triggerHeader = initHeader()
triggerHeader.__index = triggerHeader

--[[ for all members of the header with non-standard data type: set, get, getString
-- for set also specify a suitable default value
--]]

--- Retrieve the trigger id
--- @return entries as A 32 bit integer.
function triggerHeader:getId()
	return hton(self.trigger_id);
end

--- Retrieve the trigger time
--- @return entries as A 32 bit integer.
function triggerHeader:getTriggerTime()
	return hton(self.trigger_hit_time);
end

--- Retrieve the trigger origin
--- @return entries as A 8 bit integer.
function triggerHeader:getOrigin()
	return self.trigger_origin;
end


function triggerHeader:fill(args, pre)
	args = args or {}
	pre = pre or "trigger"
end

--- Retrieve the values of all members.
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @return Table of named arguments. For a list of arguments see "See also".
--- @see PROTOHeader:fill
function triggerHeader:get(pre)
	pre = pre or "trigger"

	local args = {}
	args[pre .. "id"] = self:getId()
	args[pre .. "triggertime"] = self:getTriggerTime();
	args[pre .. "origin"] = self:getOrigin();
	return args
end

--- Retrieve the values of all members.
--- @return Values in string format.
function triggerHeader:getString()
	return "Trigger -> Id:" .. self:getId() .. " Time :" .. self:getTriggerTime() .. " Origin: ".. self:getOrigin()
end

--- Resolve which header comes after this one (in a packet)
--- For instance: in tcp/udp based on the ports
--- This function must exist and is only used when get/dump is executed on
--- an unknown (mbuf not yet casted to e.g. tcpv6 packet) packet (mbuf)
--- @return String next header (e.g. 'eth', 'ip4', nil)
function triggerHeader:resolveNextHeader()
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
function triggerHeader:setDefaultNamedArgs(pre, namedArgs, nextHeader, accumulatedLength)
	return namedArgs
end


------------------------------------------------------------------------
---- Metatypes
------------------------------------------------------------------------
trigger.metatype = triggerHeader


return trigger
