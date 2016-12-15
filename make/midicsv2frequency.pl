
    # Convert the note on/off events to frequency/duration pair
	# 1. Create the midi notes2frequency table. Tuning is based upon A=440
	my $a = 440; # a is 440 hz...
	my @midi;
	for($x = 0; $x < 127; ++$x)
	{
		$midi[$x] = ($a / 32) * (2 ** (($x - 9) / 12));		
	}
	# 2. Parse the channel events
	BEGIN{ $arg=shift }
	if($arg == "") {print("Usage: ./Midicsv SONG.mid | perl midicsv2frequency.pl TRACK\n"); exit;}
	my $track = $arg;
	my $ppqn = 24;
	my $tempo = 500000;
    my $note_on = 0;
	my $note_on_time = 0;
	my $note_off_time = 0;
	my $note = 0;
	my $end_time = 0;
    while ($a = <>) {
    	if (!($a =~ m/\s*[\#\;]/)) { 	# Ignore comment lines
			# match header
			if ($a =~ m/\s*\d+\s*,\s*\d+\s*,\s*Header\s*,\s*\d+\s*,\s*\d+\s*,\s*(\d+)\s*/) {
				$ppqn = $1;
			}
			# match tempo
			elsif ($a =~ m/\s*(\d+)\s*,\s*\d+\s*,\s*Tempo\s*,\s*(\d+)/) {
				$tempo = $2;
			}
			# match note on
			elsif ($a =~ m/\s*(\d+)\s*,\s*(\d+)\s*,\s*Note_on_c\s*,\s*\d+\s*,\s*(\d+)\s*,\s*(\d+)\s*/) {
				# $1 track, $2 time, $3 note, $4 velocity
				if($1 == $track) {
					if($4 == 0 && $note_on) {
						$note_on = 0;
						$note_off_time = $2;
						print("".$midi[$note]." ".(($note_off_time-$note_on_time)/$ppqn*$tempo/1000)."\n");
					} else {
						$note_on_time = $2;
						$note = $3;
						if(!$note_on) {
							print("0 ".(($note_on_time-$note_off_time)/$ppqn*$tempo/1000)."\n");
							$note_on = 1;
						}
					}
				}
			}
			# match note off
			elsif ($a =~ m/\s*(\d+)\s*,\s*(\d+)\s*,\s*Note_off_c\s*,\s*\d+/) {
				if($1 == $track && $note_on) {
					$note_on = 0;
					$note_off_time = $2;
					print("".$midi[$note]." ".(($note_off_time-$note_on_time)/$ppqn*$tempo/1000)."\n");
				}
			}
			# match end of track
			elsif ($a =~ m/\s*(\d+)\s*,\s*(\d+)\s*,\s*End_track\s*/) {
				if($1 == $track) {$end_time = $2;}
			}
		}
	}
	# The last note may not be set off
	if($note_on) {
		print("".$midi[$note]." ".(($end_time-$note_on_time)/$ppqn*$tempo/1000)."\n");
	}
	
