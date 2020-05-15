set("log.file.path", "/tmp/basic-radio-20190225.log")

###############################################################################
# Live Inputs
###############################################################################

# Live input harbor
live = input.harbor("live",port=1024,user="source",password="INPUT PASSWORD HERE")

# Gate the input for starters, stops noise from clobbering things in silent periods.
live = ladspa.gate(live, threshold = -60.0, attack = 0.15, hold = 1.0, decay = 200.0, range = -25.0)

# Multiband compression - split up, compress, recombine, sky does it all, but is not very configurable. 3-band.
live = sky(live)

# Now overall compression, faster attack, harder ratio, mostly RMS based.
live = compress(live, attack = 5.0, gain = 8.0, knee = 10.0, ratio = 5.0, release = 100.0, threshold = -18.0, rms_window = 0.7)

# Mobile studio input harbor
#mobile = input.harbor("mobile", port=1025, user="source", password="MARSFMMOBILE")
#
## Gate the input for starters, stops noise from clobbering things in silent periods.
#mobile = ladspa.gate(mobile, threshold = -60.0, attack = 0.15, hold = 1.0, decay = 200.0, range = -25.0)
#
## Multiband compression - split up, compress, recombine, sky does it all, but is not very configurable. 3-band.
#mobile = sky(mobile)
#
## Now overall compression, faster attack, harder ratio, mostly RMS based.
#mobile = compress(mobile, attack = 5.0, gain = 8.0, knee = 10.0, ratio = 5.0, release = 100.0, threshold = -18.0, rms_window = 0.7)

###############################################################################
# Shuffle
###############################################################################

playlist = skip_blank(playlist(reload=600, "/srv/liquidsoap/library/general/playlist.m3u"))

###############################################################################
# Transitions
###############################################################################

silence = single("/etc/liquidsoap/silence.wav")

###############################################################################
# Mail Alerts
###############################################################################

def downhandler()
  system("/etc/liquidsoap/mailalert_down.sh")
end

def backhandler()
  system("/etc/liquidsoap/mailalert_up.sh")
end

live = on_blank(max_blank=15.,threshold=-20.,on_noise=backhandler,downhandler,live)

# fallback
# strip_blank(max_blank=15., threshold=-20., mobile), 
source = fallback(track_sensitive=false, [strip_blank(max_blank=15.,threshold=-20.,live),playlist,silence])


###############################################################################
# Processing
###############################################################################

# Normalize, with a higher threshold to stop suck-up.
source = normalize(source, target = -1.0, threshold = -65.0)

# Limiter, this one's a scaling one which limits nicely and without artefacting mostly
source = ladspa.tap_limiter(source, limit_level = -0.5)

# And a final limiter - this should never really get hit, but stops anything nasty hitting the DAC. Highly peak-focused.
source = limit(source, threshold = -0.2, attack = 2.0, release = 25.0, rms_window = 0.02)


###############################################################################
# Output
###############################################################################

finalsource = mksafe(source)

output.icecast(%vorbis, host="stream.marsfm.ie", port=8000, password="Broadcasting Password", mount="listenogg", finalsource)
output.icecast(%vorbis, host="stream.marsfm.ie", port=8000, password="Broadcasting Password", mount="listen.ogg", finalsource)
output.icecast(%mp3, host="stream.marsfm.ie", port=8000, password="Broadcasting Password", mount="listen", finalsource)
output.icecast(%mp3, host="stream.marsfm.ie", port=8000, password="Broadcasting Password", mount="listen.mp3", finalsource)

#output.file(
#    %vorbis, 
#    reopen_when={0m0s}, 
#    "/Storage/Disk1/Liquidsoap/Recordings/%Y-%m-%d/%Y-%m-%d-%H_%M_%S.ogg", 
#    finalsource
#)

#output.file(
#    %wav(stereo=true),
#    "/Storage/Disk1/Liquidsoap/Recordings/%Y-%m-%d/%Y-%m-%d-%H_%M_%S.wav",
#    on_close=fun(s)->system("qwavheaderdump -F #{s}"),
#    reopen_when={0m0s},
#    finalsource
#)

output.file(
    %mp3,
    "/Storage/Disk1/Liquidsoap/Recordings/%Y-%m-%d/%Y-%m-%d-%H:00.mp3",
    reopen_when={0m0s},
    finalsource
)
