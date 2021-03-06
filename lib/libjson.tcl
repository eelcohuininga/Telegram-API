# ---------------------------------------------------------------------------- #
# JSON library for Tcl - v20180222                                             #
#                                                                              #
# written by Eelco Huininga 2016-2018                                          #
# ---------------------------------------------------------------------------- #


namespace eval libjson {
	variable ::libjson::processor
	variable ::libjson::result
	variable ::libjson::errorMessage	""
	variable ::libjson::errorNumber		0
}

# ---------------------------------------------------------------------------- #
# Check if a JSON key is present                                               #
# ---------------------------------------------------------------------------- #
proc ::libjson::hasKey {record key} {
	set ::libjson::errornumber 0

	switch $::libjson::processor {
		"json_pkg" {
			set ::libjson::errorMessage "Tcllib::json json processor not supported"
			set ::libjson::errornumber -1
			return -1
		}

		"jq" {
			if { [ catch {
				set ::libjson::result [exec jq --raw-output $key << $record]
			} ] } {
				set ::libjson::errorMessage "libjson: cannot exec jq (key=$key, record=$record)"
				set ::libjson::errornumber -1
				return -1
			}
			if {$::libjson::result != "null"} {
				return true
			} else {
				return false
			}
		}

		"internal" {
			return [::libjson::internal::hasKey $record $key]
		}

		default {
			set ::libjson::errorMessage "::libjson::hasKey unknown json processor $::libjson::processor"
			set ::libjson::errornumber -1
			return -1
		}
	}
}

# ---------------------------------------------------------------------------- #
# Return the value of a JSON key                                               #
# ---------------------------------------------------------------------------- #
proc ::libjson::getValue {record key} {
	set ::libjson::errornumber 0

	switch $::libjson::processor {
		"json_pkg" {
			set ::libjson::errorMessage "Tcllib::json json processor not supported"
			set ::libjson::errornumber -1
			return -1
		}

		"jq" {
			# http://wiki.tcl.tk/11630
			if { [ catch {
				set ::libjson::result [exec jq --raw-output --compact-output $key << $record]
			} ] } {
				set ::libjson::errorMessage "libjson: cannot exec jq (key=$key, record=$record)"
				set ::libjson::errornumber -1
				return -1
			}
			return $::libjson::result
		}

		"internal" {
			set object "tmp"
			return [::libjson::internal::getValue $record $object $key]
		}

		default {
			set ::libjson::errorMessage "::libjson::hasKey unknown json processor $::libjson::processor"
			set ::libjson::errornumber -1
			return -1
		}
	}
}

namespace eval ::libjson::internal {}

# ---------------------------------------------------------------------------- #
# Check if a JSON key is present                                               #
# ---------------------------------------------------------------------------- #
proc ::libjson::internal::hasKey {record key} {
	if {[string first [string range $key [string last "." $key]+1 end] $record] != -1} {
		return 1
	} else {
		return 0
	}
}

# ---------------------------------------------------------------------------- #
# Return the value of a JSON key                                               #
# ---------------------------------------------------------------------------- #
proc ::libjson::internal::getValue {record object key} {
	set length [string length $key]
	set objectstart [string first "\"$object\":\{" $record]
	# Bug: this is a quick fix because this procedure doesn't iterate through all the objects correctly yet
	if {$object eq ""} {
		set objectend [string length $record]
	} else {
		set objectend [string first "\}" $record $objectstart]
	}

	set keystart [string first "\"$key\":" $record $objectstart]
	if {$keystart != -1} {
		if {$keystart < $objectend} {
			if {[string index $record [expr $keystart+$length+3]] eq "\""} {
				set end [string first "\"" $record [expr $keystart+$length+5]]
				return [string range $record [expr $keystart+$length+4] $end-1]
			} else {
				set end [string first "," $record [expr $keystart+$length+3]]
				if {$end != -1} {
					return [string range $record [expr $keystart+$length+3] $end-1]
				} else {
					set end [string first "\}" $record [expr $keystart+$length+3]]
					if {$end != -1} {
						return [string trim [string range $record [expr $keystart+$length+3] $end-1]]
					} else {
						return "UNKNOWN"
					}
				}
			}
		}
	}
	return ""
}

set ::libjson::processor "jq"

# Default JSON processor is Tcl's json package
#set ::libjson::processor "json_pkg"

# Fall back to jq if the json package isn't available
#if { [ catch {
#	package require json
#} ] } {
#	set ::libjson::processor "jq"
#}

# Fall back to internal code in this library if both the json package and jq aren't available
#if { [catch {
#	[exec jq --help]
#} ] } {
#	set ::libjson::processor "internal"
#}
