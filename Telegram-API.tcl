# ---------------------------------------------------------------------------- #
# Telegram-API module v20170419 for Eggdrop                                    #
#                                                                              #
# written by Eelco Huininga 2016-2017                                          #
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# Global internal variables                                                    #
# ---------------------------------------------------------------------------- #
set tg_update_id	0
set tg_botname		""
set irc_botname		""



# ---------------------------------------------------------------------------- #
# Initialization procedures                                                    #
# ---------------------------------------------------------------------------- #
# Initialize some variables (botnames)                                         #
# ---------------------------------------------------------------------------- #
proc initialize {} {
	global tg_bot_id tg_bot_token tg_botname irc_botname nick

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/getMe]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using getMe method: $result"
		return -1
	}

	if {[jq::jq ".ok" $result ] != "true"} {
		putlog "Telegram-API: bad result from getMe method: [jsonGetValue $result "" "description"]"
		return 1
	}

	set tg_botname [jsonGetValue $result "result" "username"]
	set irc_botname "$nick"
}


# ---------------------------------------------------------------------------- #
# Procedure to compute an int value from the arg string                        #
# Convert all ascii char (from arg) to hex value                               #
# then sum into one int.                                                       #
# ---------------------------------------------------------------------------- #
# Arg: String shouldnot contain space                                          #
# Return: int base 10                                                          #
# ---------------------------------------------------------------------------- #
proc computenickcolor { nick } { 
        set num [binary encode hex $nick]
        set base 16

        set total 0
        foreach d [split $num ""] {
            if {[string is alpha $d]} {
                set d [expr {[scan [string tolower $d] %c] - 87}]
            } elseif {![string is digit $d]} {
                putlog "bad digit: $d"
                return -1
            }   
            if {$d >= $base} {
                putlog "bad digit: $d"
                return -1
            }   
            incr total $d
        }   

		# Sum the result to produce the smallest number
        # Unsafe but it can unlikely overflow. To get more than 99 the
		# first computed number need to be more than 99 999 999 999
        foreach d [split $total ""] {
                incr result $d
        }   

        return $result
}

# ---------------------------------------------------------------------------- #
# Procedures for sending data to the Telegram servers                          #
# ---------------------------------------------------------------------------- #
# Changes the bot's status in Telegram                                         #
# ---------------------------------------------------------------------------- #
proc tg_sendChatAction {chat_id action} {
	global tg_bot_id tg_bot_token

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/sendChatAction -d chat_id=$chat_id -d action=$action]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using sendChatAction method: $result"
		return -1
	}
	return result
}

# ---------------------------------------------------------------------------- #
# Sends a message to a chat group in Telegram                                  #
# ---------------------------------------------------------------------------- #
proc tg_sendMessage {chat_id parse_mode message} {
	global tg_bot_id tg_bot_token tg_web_page_preview

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/sendMessage -d disable_web_page_preview=$tg_web_page_preview -d chat_id=$chat_id -d parse_mode=$parse_mode -d text=$message]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using sendMessage method: $result"
		return -1
	}
	return result
}

# ---------------------------------------------------------------------------- #
# Sends a reply-to message to a chat group in Telegram                         #
# ---------------------------------------------------------------------------- #
proc tg_sendReplyToMessage {chat_id msg_id parse_mode message} {
	global tg_bot_id tg_bot_token tg_web_page_preview

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/sendMessage -d disable_web_page_preview=$tg_web_page_preview -d chat_id=$chat_id -d parse_mode=$parse_mode -d reply_to_message_id=$msg_id -d text=$message]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using sendMessage reply method: $result"
		return -1
	}
	return result
}

# ---------------------------------------------------------------------------- #
# Sends a photo to a chat group in Telegram                                    #
# ---------------------------------------------------------------------------- #
proc tg_sendPhoto {chat_id msg_id photo caption} {
	global tg_bot_id tg_bot_token

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/sendPhoto -d chat_id=$chat_id -d reply_to_message_id=$msg_id -d photo=$photo -d caption=$caption]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using sendPhoto method: $result"
		return -1
	}
	return result
}

# ---------------------------------------------------------------------------- #
# Kicks an user from a chat group in Telegram                                  #
# ---------------------------------------------------------------------------- #
proc tg_kickChatMember {chat_id user_id} {
	global tg_bot_id tg_bot_token

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/kickChatMember -d chat_id=$chat_id -d user_id=$user_id]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using kickChatMember method: $result"
		return -1
	}
	return result
}

# ---------------------------------------------------------------------------- #
# Get up to date information about the chat group in Telegram                  #
# ---------------------------------------------------------------------------- #
proc tg_getChat {chat_id} {
	global tg_bot_id tg_bot_token

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/getChat -d chat_id=$chat_id]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using getChat method: $result"
		return -1
	}
	return result
}

# ---------------------------------------------------------------------------- #
# Get a list of administrators in a chat group in Telegram                     #
# ---------------------------------------------------------------------------- #
proc tg_getChatAdministrators {chat_id} {
	global tg_bot_id tg_bot_token

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/getChatAdministrators -d chat_id=$chat_id]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using getChatAdministrators method: $result"
		return -1
	}
	return result
}

# ---------------------------------------------------------------------------- #
# Get the number of members in a chat group in Telegram                        #
# ---------------------------------------------------------------------------- #
proc tg_getChatMembersCount {chat_id} {
	global tg_bot_id tg_bot_token

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/getChatMembersCount -d chat_id=$chat_id]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using getChatMembersCount method: $result"
		return -1
	}
	return result
}

# ---------------------------------------------------------------------------- #
# Get information about a member of a chat group in Telegram                   #
# ---------------------------------------------------------------------------- #
proc tg_getChatMember {chat_id user_id} {
	global tg_bot_id tg_bot_token

	if { [ catch {
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/getChatMember -d chat_id=$chat_id -d user_id=$user_id]
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using getChatMember method: $result"
		return -1
	}
	return result
}



# ---------------------------------------------------------------------------- #
# Procedures for sending data from IRC to Telegram                             #
# ---------------------------------------------------------------------------- #
# Send a message from IRC to Telegram                                          #
# ---------------------------------------------------------------------------- #
proc irc2tg_sendMessage {nick uhost hand channel msg} {
	global tg_channels MSG_IRC_MSGSENT

	foreach {chat_id tg_channel} [array get tg_channels] {
		if {$channel eq $tg_channel} {
			tg_sendMessage $chat_id "html" [format $MSG_IRC_MSGSENT "$nick" "$msg"]
		}
	}
	return 0
}

# ---------------------------------------------------------------------------- #
# Let the Telegram group(s) know that someone joined an IRC channel            #
# ---------------------------------------------------------------------------- #
proc irc2tg_nickJoined {nick uhost handle channel} {
	global irc_botname serveraddress
	global tg_channels MSG_IRC_NICKJOINED

	foreach {chat_id tg_channel} [array get tg_channels] {
		if {$channel eq $tg_channel} {
			if {$nick ne "$irc_botname"} {
#				tg_sendMessage $chat_id "html" [format $MSG_IRC_NICKJOINED "$nick" "$serveraddress/$channel" "$channel"]
			}
		}
	}
	return 0
}

# ---------------------------------------------------------------------------- #
# Let the Telegram group(s) know that someone has left an IRC channel          #
# ---------------------------------------------------------------------------- #
proc irc2tg_nickLeft {nick uhost handle channel message} {
	global  serveraddress tg_channels MSG_IRC_NICKLEFT

	foreach {chat_id tg_channel} [array get tg_channels] {
		if {$channel eq $tg_channel} {
#			tg_sendMessage $chat_id "html" [format $MSG_IRC_NICKLEFT "$nick" "$serveraddress/$channel" "$channel" "$message"]
		}
	}
	return 0
}

# ---------------------------------------------------------------------------- #
# Send an action from an IRC user to Telegram                                  #
# ---------------------------------------------------------------------------- #
proc irc2tg_nickAction {nick uhost handle dest keyword message} {
	global tg_channels MSG_IRC_NICKACTION
	
	foreach {chat_id tg_channel} [array get tg_channels] {
		if {$dest eq $tg_channel} {
			tg_sendMessage $chat_id "html" [format $MSG_IRC_NICKACTION "$nick" "$nick" "$message"]
		}
	}
	return 0
}

# ---------------------------------------------------------------------------- #
# Inform the Telegram group(s) that an IRC nickname has been changed           #
# ---------------------------------------------------------------------------- #
proc irc2tg_nickChange {nick uhost handle channel newnick} {
	global tg_channels MSG_IRC_NICKCHANGE

	foreach {chat_id tg_channel} [array get tg_channels] {
		if {$channel eq $tg_channel} {
			tg_sendMessage $chat_id "html" [format $MSG_IRC_NICKCHANGE "$nick" "$newnick"]
		}
	}
	return 0
}

# ---------------------------------------------------------------------------- #
# Inform the Telegram group(s) that the topic of an IRC channel has changed    #
# ---------------------------------------------------------------------------- #
proc irc2tg_topicChange {nick uhost handle channel topic} {
	global  serveraddress tg_channels MSG_IRC_TOPICCHANGE

	foreach {chat_id tg_channel} [array get tg_channels] {
		if {$channel eq $tg_channel} {
			if {$nick ne "*"} {
				tg_sendMessage $chat_id "html" [format $MSG_IRC_TOPICCHANGE "$nick" "$serveraddress/$channel" "$channel" "$topic"]
			}
		}
	}
	return 0
}

# ---------------------------------------------------------------------------- #
# Inform the Telegram group(s) that someone has been kicked from the channel   #
# ---------------------------------------------------------------------------- #
proc irc2tg_nickKicked {nick uhost handle channel target reason} {
	global tg_channels MSG_IRC_KICK

	foreach {chat_id tg_channel} [array get tg_channels] {
		if {$channel eq $tg_channel} {
			tg_sendMessage $chat_id "html" [format $MSG_IRC_KICK "$nick" "$target" "$channel" "$reason"]
		}
	}
	return 0
}



# ---------------------------------------------------------------------------- #
# Procedures for reading data from the Telegram servers                        #
# ---------------------------------------------------------------------------- #
# Poll the Telegram server for updates                                         #
# ---------------------------------------------------------------------------- #
proc tg2irc_pollTelegram {} {
	global tg_bot_id tg_bot_token tg_update_id tg_poll_freq tg_channels utftable irc_botname
	global MSG_TG_MSGSENT MSG_TG_AUDIOSENT MSG_TG_PHOTOSENT MSG_TG_DOCSENT MSG_TG_STICKERSENT MSG_TG_VIDEOSENT MSG_TG_VOICESENT MSG_TG_CONTACTSENT MSG_TG_LOCATIONSENT MSG_TC_VENUESENT MSG_TG_USERADD MSG_TG_USERLEFT MSG_TG_CHATTITLE MSG_TG_PICCHANGE MSG_TG_PICDELETE MSG_TG_UNIMPL

	if { [botonchan] != 1 } {
		putlog "Not connected to IRC, skipping"
		# Dont go into the function but plan the next one
		utimer $tg_poll_freq tg2irc_pollTelegram
		return 1
	}

	#putlog "updateid: $tg_update_id"

	# Catch if curl fail
	if { [catch { 
		set result [exec curl --tlsv1.2 -s -X POST https://api.telegram.org/bot$tg_bot_id:$tg_bot_token/getUpdates?offset=$tg_update_id] 
	} ] } {
		putlog "Telegram-API: cannot connect to api.telegram.com using getUpdates method: $result"
		# Dont go into the parsing process but plan the next polling
		utimer $tg_poll_freq tg2irc_pollTelegram^M
		return -1
	}

	# Catch if result isnot formated as it should (curl worked but get another page)
	if { [catch { set isok [jq::jq ".ok" $result] } ] } {
		putlog "Telegram-API: Error while reading TG result. No internet connection? "
		# Dont go into the parsing process but plan the next polling
		utimer $tg_poll_freq tg2irc_pollTelegram
		return -1
	}

	# Catch if result is not in a format we can parse
	if { $isok != "true"} {
		putlog "Telegram-API: bad result from getUpdates method: [jsonGetValue $result "" "description"]"
		return -1
		# Dont go into the parsing process but plan the next polling
		utimer $tg_poll_freq tg2irc_pollTelegram
		return -1
	}
	#putlog "result true, clear update_id"
	set tg_update_id 0

	foreach u_id [jq::jq ".result\[\].update_id" $result] {
		#puts "------uid: $u_id"
		set msg [ jq::jq ".result\[\] \| select(.update_id == $u_id)" $result]
		#putlog "update: $tg_update_id"
		#putlog "loop: $msg"

		switch [jq::jq ".message.chat.type" $msg] {
			# Check if this record is a private chat record...
			"private" {
				if { [jq::jq ".message.text" $msg] != "null" } {
					# Bug: the object should really be "message" and not ""
					set txt [remove_slashes [utf2ascii [jq::jq ".message.text" $msg]]]
					set msgid [jq::jq ".message.message_id" $msg]
					set fromid [jq::jq ".message.from.id" $msg]

					tg2irc_privateCommands "$fromid" "$msgid" "$txt"
				}
			}

			# Check if this record is a group chat record...
			"group" {
				set chatid [jq::jq ".message.chat.id" $msg]
				set name [jq::jq ".message.from.username" $msg]

				# If username is not find use first_name instead
				if { $name == "null" } {
					set name [jq::jq ".message.from.first_name" $msg]
				}

				# Colorize nick and store it
				catch [set color [computenickcolor $name]]
				set name "\003$color$name\003"
				
				#
				if { [jq::jq ".message.text" $msg] != "null" } {
					set txt [remove_slashes [utf2ascii [jq::jq ".message.text" $msg ]]]
					if { [jq::jq ".message.reply_to_message" $msg] != "null" } {
						set replyname [jq::jq ".message.reply_to_message.from.username" $msg]
						catch [set color [computenickcolor $replyname]]
						set txt "reply to \003$color$replyname\003: $txt"
					}

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_MSGSENT "[utf2ascii $name]" "$txt"]
							if {[string index $txt 0] eq "/"} {
								set msgid [jq::jq ".message.message_id" $msg]
								tg2irc_botCommands "$tg_chat_id" "$msgid" "$irc_channel" "$txt"
							}
						}
					}
				}


				# Check if audio has been sent to the Telegram group
				if { [jq::jq ".message.audio" $msg ] != "null" } {
					set tg_file_id [jq::jq ".message.audio.file_id" $msg]
					set tg_performer [jq::jq ".message.audio.performer" $msg]
					set tg_title [jq::jq ".message.audio.title" $msg]
					set tg_duration [jq::jq ".message.audio.duration" $msg]
					if {$tg_duration eq ""} {
						set tg_duration "0"
					}

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_AUDIOSENT "[utf2ascii $name]" "$tg_performer" "$tg_title" "[expr {$tg_duration/60}]:[expr {$tg_duration%60}]" "$irc_botname" "$tg_file_id"]
						}
					}
				}

				# Check if a document has been sent to the Telegram group
				if { [jq::jq ".message.document" $msg] != "null" } {
					set tg_file_id [jq::jq  ".message.document.file_id" $msg]
					set tg_file_name [jq::jq ".message.document.file_name" $msg]
					set tg_file_size [jq::jq ".message.document.file_size" $msg]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_DOCSENT "[utf2ascii $name]" "$tg_file_name" "$tg_file_size" "$irc_botname" "$tg_file_id"]
						}
					}
				}

				# Check if a photo has been sent to the Telegram group
				if { [jq::jq ".message.photo" $msg] != "null" } {
					set tg_file_id [jq::jq ".message.photo\[0\].file_id" $msg]
					if {[jq::jq ".message.photo\[0\].caption" $msg] != "null" } {
						set caption " ([utf2ascii [remove_slashes [jq::jq ".message.photo\[0\].caption" $msg]]])"
					} else {
						set caption ""
					}

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_PHOTOSENT "[utf2ascii $name]" "$caption" "$irc_botname" "$tg_file_id"]
						}
					}
				}

				# Check if a sticker has been sent to the Telegram group
				if {[jq::jq ".message.sticker" $msg] != "null" } {
					set emoji [jq::jq ".message.thumb.file_id" $msg]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_STICKERSENT "[utf2ascii $name]" "[sticker2ascii $emoji]"]
						}
					}
				}

				# Check if a video has been sent to the Telegram group
				if {[jq::jq ".message.video" $msg] != "null"} {
					set tg_file_id [jq::jq ".message.video.file_id" $msg]
					set tg_duration [jq::jq ".message.video.duration" $msg]
					if {$tg_duration eq "null"} {
						set tg_duration "0"
					}
					if {[jq::jq ".message.video.caption" $msg] != "null" } {
						set caption " ([utf2ascii [remove_slashes [jq:jq ".message.video.caption" $msg]]])"
					} else {
						set caption ""
					}

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_VIDEOSENT "[utf2ascii $name]" "$caption" "[expr {$tg_duration/60}]:[expr {$tg_duration%60}]" "$irc_botname" "$tg_file_id"]
						}
					}
				}

				# Check if a voice object has been sent to the Telegram group
				if {[jq::jq ".message.voice" $msg] != "null"} {
					set tg_file_id [jq::jq ".message.voice.file_id" $msg]
					set tg_duration [jq::jq ".message.voice.duration" $msg]
					set tg_file_size [jq::jq ".message.voice.file_size" $msg]
					if { $tg_duration eq "null" } {
						set tg_duration 0
					}

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_VOICESENT "[utf2ascii $name]" "[expr {$tg_duration/60}]:[expr {$tg_duration%60}]" "$tg_file_size" "$irc_botname" "$tg_file_id"]
						}
					}
				}

if {0} {
				# Check if a contact has been sent to the Telegram group
				if {[jsonHasKey $record "contact"]} {
					set tg_phone_number [jsonGetValue $record "contact" "phone_number"]
					set tg_first_name [jsonGetValue $record "contact" "first_name"]
					set tg_last_name [jsonGetValue $record "contact" "last_name"]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_CONTACTSENT "[utf2ascii $name]" "$tg_phone_number" "$tg_first_name" "$tg_last_name"]
						}
					}
				}

				# Check if a location has been sent to the Telegram group
				if {[jsonHasKey $record "location"]} {
					set tg_longitude [jsonGetValue $record "location" "longitude"]
					set tg_latitude [jsonGetValue $record "location" "latitude"]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_LOCATIONSENT "[utf2ascii $name]" "$tg_longitude" "$tg_latitude"]
						}
					}
				}

				# Check if a venue has been sent to the Telegram group
				if {[jsonHasKey $record "venue"]} {
					set tg_location [jsonGetValue $record "venue" "location"]
					set tg_title [jsonGetValue $record "venue" "title"]
					set tg_address [jsonGetValue $record "venue" "address"]
					set tg_foursquare_id [jsonGetValue $record "venue" "foursquare_id"]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_VENUESENT "[utf2ascii $name]" "$tg_location" "$tg_title" "$tg_address" "$tg_foursquare_id"]
						}
					}
				}

				# Check if someone has been added to the Telegram group
				if {[jsonHasKey $record "new_chat_member"]} {
					set new_chat_member [concat [jsonGetValue $record "new_chat_member" "first_name"] [jsonGetValue $record "new_chat_member" "last_name"]]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_USERADD "[utf2ascii $name]" "[utf2ascii $new_chat_member]"]
						}
					}
				}

				# Check if someone has been removed from the Telegram group
				if {[jsonHasKey $record "left_chat_member"]} {
					set left_chat_member [concat [jsonGetValue $record "left_chat_member" "first_name"] [jsonGetValue $record "left_chat_member" "last_name"]]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_USERLEFT "[utf2ascii $name]" "[utf2ascii $left_chat_member]"]
						}
					}
				}

				# Check if the title of the Telegram group chat has changed
				if {[jsonHasKey $record "new_chat_title"]} {
					# Bug: the object should really be "message" and not ""
					set chat_title [jsonGetValue $record "" "new_chat_title"]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_CHATTITLE "[utf2ascii $name]" "[utf2ascii $chat_title]"]
						}
					}
				}

				# Check if the photo of the Telegram group chat has changed
				if {[jsonHasKey $record "new_chat_photo"]} {
					# Bug: the object should really be "message" and not ""
					set tg_file_id [jsonGetValue $record "" "file_id"]

					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_PICCHANGE "[utf2ascii $name]" "$irc_botname" "$tg_file_id"]
						}
					}
				}

				# Check if the photo of the Telegram group chat has been deleted
				if {[jsonHasKey $record "delete_chat_photo"]} {
					foreach {tg_chat_id irc_channel} [array get tg_channels] {
						if {$chatid eq $tg_chat_id} {
							putchan $irc_channel [format $MSG_TG_PICDELETE "[utf2ascii $name]"
						}
					}
				}
			}
}

			# Check if this record is a supergroup record
			"supergroup" {
				foreach {tg_chat_id irc_channel} [array get tg_channels] {
					if {$chatid eq $tg_chat_id} {
						putchan $irc_channel [format $MSG_TG_UNIMPLEMENTED "Supergroup message received ($record)"
					}
				}
			}

			# Check if this record is a channel record
			"channel" {
				foreach {tg_chat_id irc_channel} [array get tg_channels] {
					if {$chatid eq $tg_chat_id} {
						putchan $irc_channel [format $MSG_TG_UNIMPLEMENTED "Channel message received ($record)"
					}
				}
			}

		}
	# If we are here everything goes fine
	# increment tg offset
	set tg_update_id $u_id
	incr tg_update_id

	}

	# ...and set a timer so it triggers the next poll
	utimer $tg_poll_freq tg2irc_pollTelegram
}

# ---------------------------------------------------------------------------- #
# Respond to group commands send by Telegram users                             #
# ---------------------------------------------------------------------------- #
proc tg2irc_botCommands {chat_id msgid channel message} {
	global serveraddress tg_botname irc_botname
	global MSG_BOT_HELP MSG_BOT_TG_TOPIC MSG_BOT_IRC_TOPIC MSG_BOT_HELP_IRCUSER MSG_BOT_IRCUSER MSG_BOT_TG_UNKNOWNUSER MSG_BOT_IRCUSERS MSG_BOT_UNKNOWNCMD

	set message [string trim [string map -nocase {"@$tg_botname" ""} $message]]
	set parameter_start [string wordend $message 1]
	set command [string tolower [string range $message 1 $parameter_start-1]]

	switch $command {
		"help" {
			tg_sendChatAction $chat_id "typing"

			set response "[format $MSG_BOT_HELP "$irc_botname"]"
			tg_sendReplyToMessage $chat_id $msgid "html" "$response"
			putchan $channel "[strip_html $response]"
		}

		"irctopic" {
			tg_sendChatAction $chat_id "typing"

			set response "[format $MSG_BOT_TG_TOPIC "$serveraddress/$channel" "$channel" "[topic $channel]"]"
			tg_sendReplyToMessage $chat_id $msgid "html" "$response"
			putchan $channel "[strip_html $response]"
		}

		"ircuser" {
			tg_sendChatAction $chat_id "typing"
			set handle [string trim [string range $message $parameter_start end]]

			if {$handle != ""} {
				if {[onchan $handle $channel]} {
					set online_since [getchanjoin $handle $channel]
					set response "[format $MSG_BOT_IRCUSER "$handle" "$online_since" "$serveraddress/$channel" "$channel" "[getchanhost $handle $channel]"]"
				} else {
					set response "[format $MSG_BOT_TG_UNKNOWNUSER "$handle" "$serveraddress/$channel" "channel"]"
				}
			} else {
				set response $MSG_BOT_HELP_IRCUSER
			}
			tg_sendReplyToMessage $chat_id $msgid "html" "$response"
			putchan $channel "[strip_html $response]"
		}

		"ircusers" {
			tg_sendChatAction $chat_id "typing"

			set response "[format $MSG_BOT_IRCUSERS "$serveraddress/$channel" "$channel" "[chanlist $channel]"]"
			tg_sendReplyToMessage $chat_id $msgid "html" "$response"
			putchan $channel "[strip_html $response]"
		}

		"get" {
			imagesearch_getImage $chat_id $msgid $channel $message $parameter_start
		}

		"spotify" {
			spotify_getTrack $chat_id $msgid $channel $message $parameter_start
		}

		"soundcloud" {
			soundcloud_getTrack $chat_id $msgid $channel $message $parameter_start
		}

		"psn" {
			psn_getPSNInfo $chat_id $msgid $channel $message $parameter_start
		}

		"quote" {
			quotes_getQuote $chat_id $msgid $channel $message $parameter_start
		}

		"addquote" {
			quotes_addQuote $chat_id $msgid $channel $message $parameter_start
		}

		default {
			tg_sendChatAction $chat_id "typing"
			tg_sendReplyToMessage $chat_id $msgid "markdown" "$MSG_BOT_UNKNOWNCMD"
			putchan $channel "$MSG_BOT_UNKNOWNCMD"
		}
	}
}

# ---------------------------------------------------------------------------- #
# Respond to private commands send by Telegram users                           #
# ---------------------------------------------------------------------------- #
proc tg2irc_privateCommands {from_id msgid message} {
	global tg_owner_id
	global MSG_BOT_CONNECTED MSG_BOT_DISCONNECTED MSG_BOT_UNAUTHORIZED MSG_BOT_UNKNOWNCMD

	set parameter_start [string wordend $message 1]
	set command [string tolower [string range $message 1 $parameter_start-1]]

	tg_sendChatAction $from_id "typing"

	switch $command {
		"notifications" {
		}

		"addadmin" {
		}

		"removeadmin" {
		}

		"connect" {
			if {$from_id == $tg_owner_id} {
				tg_sendReplyToMessage $from_id $msgid "markdown" "[format $MSG_BOT_CONNECTED "-171580291" "Loungecafé test" "#loungecafe"]"
			} else {
				tg_sendReplyToMessage $from_id $msgid "markdown" "$MSG_BOT_UNAUTHORIZED"
			}
		}

		"disconnect" {
			if {$from_id == $tg_owner_id} {
				tg_sendReplyToMessage $from_id $msgid "markdown" "[format $MSG_BOT_DISCONNECTED "-171580291" "Loungecafé test" "#loungecafe"]"
			} else {
				tg_sendReplyToMessage $from_id $msgid "markdown" "$MSG_BOT_UNAUTHORIZED"
			}
		}

		"binds" {
			if {$from_id == $tg_owner_id} {
				putquick "PRIVMSG EelCapone binds=[binds]"
				tg_sendReplyToMessage $from_id $msgid "markdown" "[binds]"
			} else {
				tg_sendReplyToMessage $from_id $msgid "markdown" "$MSG_BOT_UNAUTHORIZED"
			}
		}

		default {
			tg_sendReplyToMessage $from_id $msgid "markdown" "$MSG_BOT_UNKNOWNCMD"
		}
	}
}



# ---------------------------------------------------------------------------- #
# Some general usage procedures
# ---------------------------------------------------------------------------- #
# Replace Escaped-Unicode characters to ASCII                                  #
# ---------------------------------------------------------------------------- #
proc utf2ascii {txt} {
	global utftable

	foreach {utfstring asciistring} [array get utftable] {
		set txt [string map -nocase [concat $utfstring $asciistring] $txt]
	}
	return $txt
}

# ---------------------------------------------------------------------------- #
# Replace ASCII characters to Escaped-Unicode                                  #
# ---------------------------------------------------------------------------- #
proc ascii2utf {txt} {
	global utftable

	foreach {utfstring asciistring} [array get utftable] {
		set txt [string map [concat $asciistring $utfstring] $txt]
	}
	return [encoding convertto unicode $txt]
}

# ---------------------------------------------------------------------------- #
# Replace sticker code with ASCII code                                         #
# ---------------------------------------------------------------------------- #
proc sticker2ascii {txt} {
	global stickertable
	global MSG_TG_UNKNOWNSTICKER

	foreach {utfstring stickerdesc} [array get stickertable] {
		set txt [string map -nocase [concat $utfstring $stickerdesc] $txt]
	}
	if {$stickerdesc eq ""} {
		return $MSG_TG_UNKNOWNSTICKER
	}
	return $stickerdesc
}

# ---------------------------------------------------------------------------- #
# Remove HTML tags from a string                                               #
# ---------------------------------------------------------------------------- #
proc strip_html {htmlText} {
	regsub -all {<[^>]+>} $htmlText "" newText
	return $newText
}

# ---------------------------------------------------------------------------- #
# Remove double slashes from a string                                          #
# ---------------------------------------------------------------------------- #
proc remove_slashes {txt} {
	regsub -all {\\} $txt {} txt
	return $txt
}

# ---------------------------------------------------------------------------- #
# Add backslashes to [ and ] characters                                        #
# ---------------------------------------------------------------------------- #
proc escape_out_bracket {txt} {
	regsub -all {\[} $txt {\[} txt
#	regsub -all {\]} $txt {\]} txt
	return $txt
}

# ---------------------------------------------------------------------------- #
# Check if a JSON key is present                                               #
# ---------------------------------------------------------------------------- #
proc jsonHasKey {record key} {
	if {[string first $key $record] != -1} {
		return 1
	} else {
		return 0
	}
}

# ---------------------------------------------------------------------------- #
# Return the value of a JSON key                                               #
# ---------------------------------------------------------------------------- #
proc jsonGetValue {record object key} {
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
				return [string range $record [expr $keystart+$length+3] $end-1]
			}
		}
	}
	return ""
}


# http://wiki.tcl.tk/11630

# jq-0.4.0.tm
# To use this module you need jq version 1.5rc1 or later installed.
namespace eval jq {
    proc jq {filter data {options {-r}}} {
        exec jq {*}$options $filter << $data
    }
    proc json2dict {data} {
        jq {
            def totcl:
                if type == "array" then
                    # Convert array to object with keys 0, 1, 2... and process
                    # it as object.
                    [range(0;length) as $i
                        | {key: $i | tostring, value: .[$i]}]
                    | from_entries
                    | totcl
                elif type == "object" then
                    .
                    | to_entries
                    | map("{\(.key)} {\(.value | totcl)}")
                    | join(" ")
                else
                    tostring
                    | gsub("{"; "\\{")
                    | gsub("}"; "\\}")
                end;
            . | totcl
        } $data
    }
}

# ---------------------------------------------------------------------------- #
# Start of main code                                                           #
# ---------------------------------------------------------------------------- #
# Start bot by loading Telegram modules, bind actions and do a Telegram poll   #
# ---------------------------------------------------------------------------- #

source "[file dirname [info script]]/Telegram-API-config.tcl"
source "[file dirname [info script]]/Telegram-API.$language.tcl"
source "[file dirname [info script]]/utftable.tcl"

source "[file dirname [info script]]/ImageSearch.tcl"
source "[file dirname [info script]]/PSN.tcl"
source "[file dirname [info script]]/Soundcloud.tcl"
source "[file dirname [info script]]/Spotify.tcl"

bind pubm - * irc2tg_sendMessage
bind join - * irc2tg_nickJoined
bind part - * irc2tg_nickLeft
bind sign - * irc2tg_nickLeft
bind ctcp - "ACTION" irc2tg_nickAction
bind nick - * irc2tg_nickChange
bind topc - * irc2tg_topicChange
bind kick - * irc2tg_nickKicked

initialize

tg2irc_pollTelegram

putlog "Script loaded: Telegram-API.tcl ($tg_botname)"
