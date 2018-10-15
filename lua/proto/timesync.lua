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
local timesync = {}
timesync.TYPE_REQ = 0x2
timesync.TYPE_RES = 0x3
timesync.TYPE_DELAY_REQ = 0x4
timesync.TYPE_DELAY_RES = 0x5
timesync.TYPE_CAPTURE_TX  = 0x6
timesync.TYPE_GENDELAY_REQ = 0x10
timesync.TYPE_GENREQ = 0x11
---------------------------------------------------------------------------
---- Timesync header
---------------------------------------------------------------------------

timesync.headerFormat = [[
	uint16_t magic;
	uint8_t command;
	uint32_t reference_ts_hi;
	uint32_t reference_ts_lo;
	uint32_t eraTs;
	uint32_t delta;
	uint8_t igMacTs[6];
	uint8_t igTs[6];
	uint8_t egTs[6];
]]

-- uint32_t igMacTs;
-- uint32_t igTs;
-- uint32_t egTs;
--- Variable sized member
timesync.headerVariableMember = nil

--- Module for timesync_address struct
local timesyncHeader = initHeader()
timesyncHeader.__index = timesyncHeader

--[[ for all members of the header with non-standard data type: set, get, getString
-- for set also specify a suitable default value
--]]

--- Set the command.
--- @param command of the Timesync header
function timesyncHeader:setCommand(int)
	int = int or timesync.TYPE_REQ
	self.command = int
end

--- Retrieve the command.
--- @return command as A 8 bit integer.
function timesyncHeader:getCommand()
	return self.command
end

--- Set the magic.
--- @param Magic of the Timesync header
function timesyncHeader:setMagic(int)
	int = int or 0x0200
	self.magic = int
end

--- Retrieve the Magic.
--- @return Magic as A 8 bit integer.
function timesyncHeader:getMagic()
	return self.magic
end


--- Retrieve the reference_ts_lo.
--- @return Reference_lo as A 32 bit integer.
function timesyncHeader:getReference_ts_lo()
	return hton(self.reference_ts_lo)
end


--- Retrieve the reference_ts_hi.
--- @return Reference_lo as A 32 bit integer.
function timesyncHeader:getReference_ts_hi()
	return hton(self.reference_ts_hi)
end

--- Retrieve the eraTS.
--- @return eraTS as A 32 bit integer.
function timesyncHeader:getEraTs()
	return hton(self.eraTs)
end

--- Retrieve the delta.
--- @return egdelta as A 32 bit integer.
function timesyncHeader:getDelta()
	return hton(self.delta)
end


function timesyncHeader:getMacTs()
	local uint64_t ts = 0;
	-- ts = bit.band(self.igTs[2], 0x7F)
	for i=2,4,1
	do
		--printf("%X,", self.igTs[i])
		ts = bit.lshift(bit.bor(ts, self.igMacTs[i]), 8)
		--printf("%X,", ts)
	end
  ts = bit.bor(ts, self.igMacTs[5])
	--printf("%X", ts)
	return ts
end

--- Retrieve the ig TS.
--- @return igTs as A 64 bit integer.
function timesyncHeader:getIgTs()
	local uint64_t ts = 0;
	-- ts = bit.band(self.igTs[2], 0x7F)
	for i=2,4,1
	do
		--printf("%X,", self.igTs[i])
		ts = bit.lshift(bit.bor(ts, self.igTs[i]), 8)
		--printf("%X,", ts)
	end
  ts = bit.bor(ts, self.igTs[5])
	--printf("%X", ts)
	return ts
end


-- function timesyncHeader:getMacTs()
-- 	return hton(self.igMacTs)
-- end
-- --
-- function timesyncHeader:getIgTs()
-- 	return hton(self.igTs)
-- end


--- Retrieve the eg TS.
--- @return egTs as A 64 bit integer.
function timesyncHeader:getEgTs()
	local ts = 0;
	for i=2,4,1
	do
		ts = bit.lshift(bit.bor(ts, self.egTs[i]), 8)
	end
	ts = bit.bor(ts, self.egTs[5])
	return ts
end
-- function timesyncHeader:getEgTs()
-- 	return hton(self.egTs)
-- end
--- Set all members of the PROTO header.
--- Per default, all members are set to default values specified in the respective set function.
--- Optional named arguments can be used to set a member to a user-provided value.
--- @param args Table of named arguments. Available arguments: PROTOXYZ
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @code
--- fill() -- only default values
--- fill{ PROTOXYZ=1 } -- all members are set to default values with the exception of PROTOXYZ, ...
--- @endcode
function timesyncHeader:fill(args, pre)
	args = args or {}
	pre = pre or "timesync"
	self:setMagic(args[pre .. "magic"])
	self:setCommand(args[pre .. "command"])

end

--- Retrieve the values of all members.
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @return Table of named arguments. For a list of arguments see "See also".
--- @see PROTOHeader:fill
function timesyncHeader:get(pre)
	pre = pre or "timesync"

	local args = {}
	args[pre .. "command"] = self:getCommand()
	args[pre .. "magic"] = self.getMagic()
	args[pre .. "reference_ts_hi"] = self:getReference_ts_hi()
	args[pre .. "reference_ts_lo"] = self:getReference_ts_lo()
	args[pre .. "eraTs"] = self:getEraTs()
	args[pre .. "delta"] = self:getDelta()
	args[pre .. "igMacTs"] = self:getMacTs();
	args[pre .. "igTs"] = self:getIgTs()
	args[pre .. "egTs"] = self:egTs()
	return args
end

--- Retrieve the values of all members.
--- @return Values in string format.
function timesyncHeader:getString()
	return "Timesync -> Command:" .. self:getCommand() .. " Reference HI: " .. self:getReference_ts_hi() .. " Reference LO: " .. self:getReference_ts_lo() .. " EraTS: " .. self:getEraTs() .. " Delta: ".. self:getDelta().. " igMacTs: ".. self:getMacTs().. " igTS: ".. self:getIgTs().. " egTS: ".. self:getEgTs()
end

--- Resolve which header comes after this one (in a packet)
--- For instance: in tcp/udp based on the ports
--- This function must exist and is only used when get/dump is executed on
--- an unknown (mbuf not yet casted to e.g. tcpv6 packet) packet (mbuf)
--- @return String next header (e.g. 'eth', 'ip4', nil)
function timesyncHeader:resolveNextHeader()
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
function timesyncHeader:setDefaultNamedArgs(pre, namedArgs, nextHeader, accumulatedLength)
	return namedArgs
end


------------------------------------------------------------------------
---- Metatypes
------------------------------------------------------------------------

timesync.metatype = timesyncHeader


return timesync
